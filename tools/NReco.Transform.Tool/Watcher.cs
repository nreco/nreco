#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.IO;
using NReco.Logging;

namespace NReco.Transform.Tool {
	
	public class Watcher {
		FileSystemWatcher TransformWatcher;
		FileSystemWatcher[] SourceWatchers;
		string RootFolder;
		RuleStatsTracker Deps;
		LocalFolderRuleProcessor RuleProcessor;
		Queue<string> TransformQueue;
		Queue<string> MergeQueue;
		Thread TransformThread;
		Thread MergeThread;
		MergeConfig MergeCfg;
		static ILog log = LogManager.GetLogger(typeof(Watcher));
		readonly IList<string> tmpExtensions = new string[] { ".tmp", ".bak" };
		readonly IList<string> aspnetKnownExtensions = new string[] { 
			".ascx", ".ascx.cs", ".aspx", ".aspx.cs", ".master", ".dll", ".css", ".js", ".html", ".txt", ".log",".mdf"};

		public Watcher(string rootFolder, RuleStatsTracker deps, LocalFolderRuleProcessor ruleProcessor, MergeConfig mCfg) {
			RootFolder = Path.GetFullPath( rootFolder );

			Deps = deps;
			MergeCfg = mCfg;
			RuleProcessor = ruleProcessor;
			TransformQueue = new Queue<string>();
			MergeQueue = new Queue<string>();
			TransformThread = new Thread(ProcessTransform);
			MergeThread = new Thread(ProcessMerge);

			// subscribe to writing event for dependencies chain checking
			RuleProcessor.FileManager.Writing += new FileManagerEventHandler(FileManagerWriting);
		}

		public void Start() {
			TransformWatcher = new FileSystemWatcher(RootFolder);
			TransformWatcher.IncludeSubdirectories = true;
			TransformWatcher.NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.FileName;
			TransformWatcher.Changed += new FileSystemEventHandler(TransformWatcherChanged);
			TransformWatcher.Deleted += new FileSystemEventHandler(TransformWatcherChanged);
			TransformWatcher.Created += new FileSystemEventHandler(TransformWatcherChanged);
			TransformWatcher.EnableRaisingEvents = true;

			if (MergeCfg != null) {
				var srcWatchersList = new List<FileSystemWatcher>();
				foreach (var srcRoot in MergeCfg.Sources)
					srcWatchersList.Add(CreateSourceWatcher(srcRoot));
				SourceWatchers = srcWatchersList.ToArray();
			}

			TransformThread.Start();
			MergeThread.Start();
		}

		protected FileSystemWatcher CreateSourceWatcher(string path) {
			var watcher = new FileSystemWatcher(path);
			watcher.IncludeSubdirectories = true;
			watcher.NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.FileName;
			watcher.Changed += new FileSystemEventHandler(SourceWatcherChanged);
			watcher.Deleted += new FileSystemEventHandler(SourceWatcherChanged);
			watcher.Created += new FileSystemEventHandler(SourceWatcherChanged);
			watcher.Renamed += new RenamedEventHandler(SourceWatcherRenamed);
			watcher.EnableRaisingEvents = true;
			return watcher;
		}

		public void Stop() {
			TransformWatcher.EnableRaisingEvents = false;
			if (SourceWatchers != null)
				foreach (var watcher in SourceWatchers)
					watcher.EnableRaisingEvents = false;

			if (TransformThread.IsAlive)
				TransformThread.Abort();
			if (MergeThread.IsAlive)
				MergeThread.Abort();
		}

		protected void ProcessMerge() {

		}

		protected void ProcessTransform() {
			bool isInSleepMode = false;
			while (true) {
				string changeFileName = null;
				if (TransformQueue.Count > 0) {
					// b/c filesystem watcher can raise a lot of events for the same file,
					// lets wait a moment
					if (isInSleepMode) {
						Thread.Sleep(300);
						isInSleepMode = false;
					}
					changeFileName = TransformQueue.Dequeue();
				} else {
					Thread.Sleep(100);
					isInSleepMode = true;
					continue;
				}

				if (changeFileName != null) {
					string[] ruleFiles = Deps.GetDependentRuleFileNames(changeFileName);
					if (ruleFiles.Length > 0) {
						foreach (string ruleFileName in ruleFiles) {
							log.Write(LogEvent.Info, "Dependent rule file: {0}", ruleFileName);
						}

						TransformWatcher.EnableRaisingEvents = false;
						RuleProcessor.FileManager.StartSession();
						try {
							PushChangedFilesToQueue = true;
							RuleProcessor.ExecuteForFiles(ruleFiles);
						} catch (Exception ex) {
							log.Write(LogEvent.Error, ex);
						} finally {
							PushChangedFilesToQueue = false;
						}
						RuleProcessor.FileManager.EndSession();
						TransformWatcher.EnableRaisingEvents = true;
					}
					// special logic for asp.net applications
					var changedFileExt = Path.GetExtension(changeFileName).ToLower();
					var webConfigPath = Path.Combine(RootFolder, "web.config");
					if (Path.GetFileName(changeFileName).ToLower()!="web.config" &&
						!aspnetKnownExtensions.Contains(changedFileExt) &&
						File.Exists(webConfigPath))
						File.SetLastWriteTime(webConfigPath, DateTime.Now);
				}
			}
		}

		protected bool PushChangedFilesToQueue = false;

		protected void FileManagerWriting(object sender, FileManagerEventArgs e) {
			//TBD - avoid infinite cycle
			//if (PushChangedFilesToQueue && !ChangesQueue.Contains(e.FileName))
			//	ChangesQueue.Enqueue(e.FileName);
		}

		protected void TransformWatcherChanged(object sender, FileSystemEventArgs e) {
			// skip folders
			if (!File.Exists(e.FullPath) && e.ChangeType != WatcherChangeTypes.Deleted)
				return;

			string changeFileName = Path.GetFullPath(e.FullPath);
			lock (TransformQueue) {
				if (!TransformQueue.Contains(changeFileName)) {
					log.Write(LogEvent.Info, "Release file changed: {0}", e.Name);
					TransformQueue.Enqueue(changeFileName);
				}
			}

		}

		protected void SourceWatcherChanged(object sender, FileSystemEventArgs e) {
			var fullPath = Path.GetFullPath(e.FullPath);

			// skip tmp files
			var ext = Path.GetExtension( fullPath );
			if (ext != null && tmpExtensions.Contains(ext.ToLower()))
				return;
			// skip changes from release folder
			if (fullPath.ToLower().StartsWith(RootFolder.ToLower()))
				return;

			// skip folders
			if (e.ChangeType != WatcherChangeTypes.Deleted && !File.Exists(fullPath))
				return;

			log.Write(LogEvent.Info, "Source file changed: {0} ({1})", fullPath, e.ChangeType);
			try {
				MergeFile(fullPath, e.ChangeType);
			} catch (Exception ex) {
				log.Write(LogEvent.Error, ex);
			}
		}

		protected void SourceWatcherRenamed(object sender, RenamedEventArgs e) {
			SourceWatcherChanged(sender,
				new FileSystemEventArgs(WatcherChangeTypes.Changed,
					Path.GetDirectoryName(e.FullPath),
					Path.GetFileName(e.FullPath) ));
		}


		protected bool MergeFile(string fileName, WatcherChangeTypes changeType) {
			if (MergeCfg == null)
				return true;

			// 1. lets find 'base' path
			int basePathIdx = MergeCfg.MatchSource(fileName);
			if (basePathIdx < 0)
				return true; // not from source
			string relativeFilePath = fileName.Substring(MergeCfg.Sources[basePathIdx].Length);

			// 2. check for override
			for (int i = (MergeCfg.Sources.Length - 1); i >= 0 && i>basePathIdx; i--) {
				var srcPath = Path.Combine(MergeCfg.Sources[i], relativeFilePath);
				if (File.Exists(srcPath))
					return false; // file is overrided; nothing to change
			}

			// 3. this file is for release. lets copy
			var releasePath = Path.Combine(RootFolder, relativeFilePath);
			if (!File.Exists(releasePath))
				return false; // ignore not-from-release sources
			if (changeType == WatcherChangeTypes.Deleted) {
				//log.Write(LogEvent.Info, "Merge: deleting file {0}...", relativeFilePath);
				//File.Delete(releasePath);
			} else {
				log.Write(LogEvent.Info, "Merge: updating file {0}...", relativeFilePath);
				Thread.Sleep(100); // small sleep: let VS to release file lock...

				RuleProcessor.FileManager.ResetFile(releasePath);
				File.Copy(fileName, releasePath, true);
			}
			return true;
		}

	}

}
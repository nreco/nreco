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
		FileSystemWatcher AccessWatcher;
		string RootFolder;
		RuleStatsTracker Deps;
		LocalFolderRuleProcessor RuleProcessor;
		Queue<string> ChangesQueue;
		Thread ChangesThread;
		static ILog log = LogManager.GetLogger(typeof(Watcher));

		public Watcher(string rootFolder, RuleStatsTracker deps, LocalFolderRuleProcessor ruleProcessor) {
			RootFolder = rootFolder;
			Deps = deps;
			RuleProcessor = ruleProcessor;
			ChangesQueue = new Queue<string>();
			ChangesThread = new Thread(ProcessChanges);

			// subscribe to writing event for dependencies chain checking
			RuleProcessor.FileManager.Writing += new FileManagerEventHandler(FileManagerWriting);
		}

		public void Start() {
			AccessWatcher = new FileSystemWatcher(RootFolder);
			AccessWatcher.IncludeSubdirectories = true;
			AccessWatcher.NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.FileName;
			AccessWatcher.Changed += new FileSystemEventHandler(AccessWatcherChanged);
			AccessWatcher.Deleted += new FileSystemEventHandler(AccessWatcherChanged);
			AccessWatcher.Created += new FileSystemEventHandler(AccessWatcherChanged);
			AccessWatcher.EnableRaisingEvents = true;
			ChangesThread.Start();
		}

		public void Stop() {
			AccessWatcher.EnableRaisingEvents = false;
			if (ChangesThread.IsAlive)
				ChangesThread.Abort();
		}

		protected void ProcessChanges() {
			while (true) {
				string changeFileName = null;
				if (ChangesQueue.Count > 0) {
					// b/c filesystem watcher can raise a lot of events for the same file,
					// lets wait a moment to ensure that the latest version of file present 
					Thread.Sleep(300);
					changeFileName = ChangesQueue.Dequeue();
				}
				if (changeFileName != null) {
					string[] ruleFiles = Deps.GetDependentRuleFileNames(changeFileName);
					if (ruleFiles.Length > 0) {
						foreach (string ruleFileName in ruleFiles) {
							log.Write(LogEvent.Info, "Dependent rule file: {0}", ruleFileName);
						}

						AccessWatcher.EnableRaisingEvents = false;
						RuleProcessor.FileManager.StartSession();
						try {
							PushChangedFilesToQueue = true;
							RuleProcessor.ExecuteForFiles(ruleFiles);
						}
						finally {
							PushChangedFilesToQueue = false;
						}
						RuleProcessor.FileManager.EndSession();
						AccessWatcher.EnableRaisingEvents = true;
					}
				}
				if (ChangesQueue.Count == 0)
					Thread.Sleep(100);
			}
		}

		protected bool PushChangedFilesToQueue = false;

		protected void FileManagerWriting(object sender, FileManagerEventArgs e) {
			//TBD - avoid infinite cycle
			//if (PushChangedFilesToQueue && !ChangesQueue.Contains(e.FileName))
			//	ChangesQueue.Enqueue(e.FileName);
		}

		protected void AccessWatcherChanged(object sender, FileSystemEventArgs e) {
			// skip folders
			if (!File.Exists(e.FullPath) && e.ChangeType != WatcherChangeTypes.Deleted)
				return;

			string changeFileName = Path.GetFullPath(e.FullPath);
			lock (ChangesQueue) {
				if (!ChangesQueue.Contains(changeFileName)) {
					log.Write(LogEvent.Info, "File changed: {0}", e.Name);
					ChangesQueue.Enqueue(changeFileName);
				}
			}

		}

	}

}
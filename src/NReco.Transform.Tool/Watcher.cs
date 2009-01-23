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
					foreach (string ruleFileName in ruleFiles) {
						log.Write(LogEvent.Info, "Applying rule file: {0}", ruleFileName);
					}
					AccessWatcher.EnableRaisingEvents = false;
					RuleProcessor.FileManager.StartSession();
					RuleProcessor.ExecuteForFiles(ruleFiles);
					RuleProcessor.FileManager.EndSession();
					AccessWatcher.EnableRaisingEvents = true;
				}
				if (ChangesQueue.Count == 0)
					Thread.Sleep(100);
			}
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
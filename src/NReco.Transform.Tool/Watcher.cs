using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace NReco.Transform.Tool {
	
	public class Watcher {
		FileSystemWatcher AccessWatcher;
		string RootFolder;
		RuleStatsTracker Deps;
		LocalFolderRuleProcessor RuleProcessor;

		public Watcher(string rootFolder, RuleStatsTracker deps, LocalFolderRuleProcessor ruleProcessor) {
			RootFolder = rootFolder;
			Deps = deps;
			RuleProcessor = ruleProcessor;
		}

		public void Start() {
			AccessWatcher = new FileSystemWatcher(RootFolder);
			AccessWatcher.IncludeSubdirectories = true;
			AccessWatcher.NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.FileName;
			AccessWatcher.Changed += new FileSystemEventHandler(AccessWatcherChanged);
			AccessWatcher.Deleted += new FileSystemEventHandler(AccessWatcherChanged);
			AccessWatcher.Created += new FileSystemEventHandler(AccessWatcherChanged);
			AccessWatcher.EnableRaisingEvents = true;
		}

		public void Stop() {
			AccessWatcher.EnableRaisingEvents = false;
		}

		protected void AccessWatcherChanged(object sender, FileSystemEventArgs e) {
			// skip folders
			if (!File.Exists(e.FullPath) && e.ChangeType != WatcherChangeTypes.Deleted)
				return;
			string changeFileName = Path.GetFullPath(e.FullPath);
			Console.WriteLine("Changed: " + changeFileName);

			string[] ruleFiles = Deps.GetDependentRuleFileNames(changeFileName);
			foreach (string ruleFileName in ruleFiles) {
				Console.WriteLine(ruleFileName);
			}
			RuleProcessor.FileManager.StartSession();
			RuleProcessor.ExecuteForFiles(ruleFiles);
			RuleProcessor.FileManager.EndSession();
		}

	}

}
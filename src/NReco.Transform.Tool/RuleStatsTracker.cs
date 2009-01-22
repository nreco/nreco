using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace NReco.Transform.Tool {
	
	public class RuleStatsTracker {

		IDictionary<string, IList<string>> RuleDependencies;
		FileRuleEventArgs CurrentRule = null;

		public RuleStatsTracker() {
			RuleDependencies = new Dictionary<string, IList<string>>();
		}

		public string[] GetDependentRuleFileNames(string fName) {
			List<string> ruleFileNames = new List<string>();
			foreach (KeyValuePair<string, IList<string>> dep in RuleDependencies)
				if (dep.Value.Contains(fName))
					ruleFileNames.Add(dep.Key);
			return ruleFileNames.ToArray();
		}

		public void OnFileReading(object sender, FileManagerEventArgs e) {
			if (CurrentRule != null) {
				string fileName = Path.GetFullPath(e.FileName);
				if (!RuleDependencies[CurrentRule.RuleFileName].Contains(fileName))
					RuleDependencies[CurrentRule.RuleFileName].Add(fileName);
			}
		}

		public void OnRuleExecuting(object sender, FileRuleEventArgs e) {
			if (RuleDependencies.ContainsKey(e.RuleFileName)) {
				RuleDependencies[e.RuleFileName].Clear();
			} else {
				RuleDependencies[e.RuleFileName] = new List<string>();
			}
			CurrentRule = e;
		}

		public void OnRuleExecuted(object sender, FileRuleEventArgs e) {
			CurrentRule = null;
		}

	}
}

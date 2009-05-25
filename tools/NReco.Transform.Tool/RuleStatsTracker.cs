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
using System.IO;

namespace NReco.Transform.Tool {
	
	public class RuleStatsTracker {

		IDictionary<string, RuleDepInfo> RuleDependencies;
		FileRuleEventArgs CurrentRule = null;

		public RuleStatsTracker() {
			RuleDependencies = new Dictionary<string, RuleDepInfo>();
		}

		public string[] GetDependentRuleFileNames(string fName) {
			List<string> ruleFileNames = new List<string>();
			GetDirectRuleFileNames(ruleFileNames, fName);
			return ruleFileNames.ToArray();
		}

		protected void GetDirectRuleFileNames(List<string> rules, string fName) {
			foreach (var dep in RuleDependencies) {
				if (dep.Value.Uses.Contains(fName)) {
					if (AddDistinct(rules, dep.Key)) {
						CollectRuleDeps(rules, dep.Value);
					}
				}
			}
		}

		protected void CollectRuleDeps(List<string> rules, RuleDepInfo depInfo) {
			// collect direct dependencies from this rule
			foreach (var affectedFileName in depInfo.Affects)
				GetDirectRuleFileNames(rules,affectedFileName);

			// collect indirect dependencies: 
			// when some rule generates file used by the rule
			foreach (var usedFileName in depInfo.Uses)
				GetGenerationRuleFileNames(rules, usedFileName);
		}

		protected void GetGenerationRuleFileNames(List<string> rules, string fName) {
			foreach (var dep in RuleDependencies) 
				if (dep.Value.Affects.Contains(fName))
					if (AddDistinct(rules, dep.Key)) {
						CollectRuleDeps(rules, dep.Value);
					}
		}

		public void OnFileReading(object sender, FileManagerEventArgs e) {
			if (CurrentRule != null) {
				string fileName = Path.GetFullPath(e.FileName);
				AddDistinct(RuleDependencies[CurrentRule.RuleFileName].Uses, fileName);
			}
		}

		public void OnFileWriting(object sender, FileManagerEventArgs e) {
			if (CurrentRule != null) {
				string fileName = Path.GetFullPath(e.FileName);
				AddDistinct(RuleDependencies[CurrentRule.RuleFileName].Affects, fileName);
			}
		}

		public void OnRuleExecuting(object sender, FileRuleEventArgs e) {
			if (RuleDependencies.ContainsKey(e.RuleFileName)) {
				// because one file may contain more than one rule, lets just accumulate all deps
				//RuleDependencies[e.RuleFileName].Clear();
			} else {
				RuleDependencies[e.RuleFileName] = new RuleDepInfo();
				RuleDependencies[e.RuleFileName].Uses.Add(e.RuleFileName);
			}
			CurrentRule = e;
		}

		protected bool AddDistinct(IList<string> list, string val) {
			if (!list.Contains(val)) {
				list.Add(val);
				return true;
			}
			return false;
		}

		public void OnRuleExecuted(object sender, FileRuleEventArgs e) {
			CurrentRule = null;
		}

		public class RuleDepInfo {
			public IList<string> Uses { get; set; }
			public IList<string> Affects { get; set; }

			public RuleDepInfo() {
				Uses = new List<string>();
				Affects = new List<string>();
			}
		}

	}
}

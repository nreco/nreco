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

using NReco;
using NReco.Logging;

namespace NReco.Transform {
	
	/// <summary>
	/// File rules processor for local filesystem folder (including subfolders)
	/// </summary>
	public class LocalFolderRuleProcessor {
		static ILog log = LogManager.GetLogger(typeof(LocalFolderRuleProcessor));

		public IFileRule[] Rules { get; set; }
		public LocalFileManager FileManager { get; set; }

		public event FileRuleEventHandler RuleExecuting;
		public event FileRuleEventHandler RuleExecuted;

		public LocalFolderRuleProcessor() {
		}

		public void Execute() {
			string[] allFiles = Directory.GetFiles(FileManager.RootPath, "*.*", SearchOption.AllDirectories);
			log.Write(LogEvent.Info, "Found {0} file(s)", allFiles.Length);
			ExecuteForFiles(allFiles);
		}

		public void ExecuteForFiles(string[] files) {
			// sort files - order is defined
			Array.Sort<string>(files);
			IDictionary<IFileRule,List<string>> executionPlan = new Dictionary<IFileRule,List<string>>();
			foreach (IFileRule r in Rules)
				executionPlan[r] = new List<string>();
			// build execution plan
			foreach (string filePath in files) {
				foreach (IFileRule r in Rules)
					if (r.MatchFile(filePath, FileManager)) 
						executionPlan[r].Add(filePath);
			}
			// execute in exact order
			foreach (IFileRule r in Rules)
				if (executionPlan[r].Count>0) {
					log.Write(LogEvent.Info, "Applying {0} for {1} file(s)", r, executionPlan[r].Count);
					foreach (string ruleFName in executionPlan[r]) {
						FileRuleContext ruleContext = new FileRuleContext(ruleFName, FileManager);
						if (RuleExecuting != null)
							RuleExecuting(this, new FileRuleEventArgs(ruleFName, r));
						r.Execute(ruleContext);
						if (RuleExecuted != null)
							RuleExecuted(this, new FileRuleEventArgs(ruleFName, r));
					}
				}
		}


	}
}

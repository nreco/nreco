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
using System.Xml;
using System.Xml.XPath;

using NReco;
using NReco.Logging;

namespace NReco.Transform.Tool {
	
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
			// sort files - processing order is defined
			Array.Sort<string>(files);
			IList<string> executionPlan = new List<string>();
			// build execution plan
			foreach (string filePath in files) {
				string fName = Path.GetFileName(filePath);
				if (fName.Length > 0 && fName[0] == '@') {
					executionPlan.Add(Path.GetFullPath(filePath));
				}
			}
			log.Write(LogEvent.Info, "Found {0} rule file(s)", executionPlan.Count);
			// stats
			IDictionary<IFileRule, int> counters = new Dictionary<IFileRule, int>();
			foreach (var rule in Rules)
				counters[rule] = 0;

			// execute in exact order
			foreach (string ruleFile in executionPlan) {
				string fileContent = FileManager.Read(ruleFile);
				log.Write(LogEvent.Info, "Processing rule file: {0}", ruleFile);

				Mvp.Xml.XInclude.XIncludingReader xmlIncludeContentRdr = new Mvp.Xml.XInclude.XIncludingReader(new StringReader(fileContent));
				xmlIncludeContentRdr.XmlResolver = new FileManagerXmlResolver(FileManager, Path.GetDirectoryName(ruleFile));
				XPathDocument ruleXPathDoc = new XPathDocument(xmlIncludeContentRdr);
				XPathNavigator ruleFileNav = ruleXPathDoc.CreateNavigator();

				XPathNodeIterator ruleNavs =
					ruleFileNav.SelectSingleNode("rules")!=null ?
					ruleFileNav.Select("rules/*") :
					ruleFileNav.Select("*");
				foreach (XPathNavigator ruleNav in ruleNavs) {
					for (int i = 0; i < Rules.Length; i++)
						if (Rules[i].IsMatch(ruleNav)) {
							var r = Rules[i];
							// for now its hardcoded rule that handles XslTransformRule caching issue
							if (r is XslTransformFileRule)
								((XslTransformFileRule)r).TransformRule.CacheEnabled = false;

							var ruleContext = new FileRuleContext(ruleFile, FileManager, ruleNav);
							if (RuleExecuting != null)
								RuleExecuting(this, new FileRuleEventArgs(ruleFile, r));
							try {
								Rules[i].Execute(ruleContext);
							} catch (Exception ex) {
								throw new Exception(String.Format("Rule processing failed: {0} ({1})", ex.Message, ruleContext), ex);
							}
							if (RuleExecuted != null)
								RuleExecuted(this, new FileRuleEventArgs(ruleFile, r));
							counters[Rules[i]]++;
						}
				}
			}

			foreach (var rule in Rules) {
				log.Write(LogEvent.Info, "Applied {0} for {1} file(s)", rule, counters[rule]);
			}


		}


	}
}

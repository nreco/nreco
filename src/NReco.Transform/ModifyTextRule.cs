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
using System.Text.RegularExpressions;
using System.Xml;
using System.IO;

namespace NReco.Transform {
	
	public class ModifyTextRule : IFileRule {

		public bool MatchFile(string filePath, IFileManager fm) {
			// match code should be ultra-fast: match rule is hardcoded.
			if (Path.GetFileName(filePath).StartsWith("@")) {
				string trimmed = fm.Read(filePath).Trim();
				return (trimmed.StartsWith("<text-insert") && trimmed.EndsWith("</text-insert>")) ||
					(trimmed.StartsWith("<text-replace") && trimmed.EndsWith("</text-replace>"));
			}
			return false;
		}

		public override string ToString() {
			return "Modify text rule";
		}

		public void Execute(FileRuleContext ruleContext) {
			for (int i=0; i<ruleContext.RuleFileNames.Length; i++) {
				string filePath = ruleContext.RuleFileNames[i];
				string fileContent = ruleContext.FileManager.Read(filePath);
				XmlDocument ruleConfig = new XmlDocument();
				ruleConfig.PreserveWhitespace = true;
				ruleConfig.LoadXml(fileContent);

				XmlNode rootNode = ruleConfig.SelectSingleNode("/*");
				// params for 'start-end' exact patterns (fast)
				ModifyRuleConfig config = new ModifyRuleConfig(rootNode);

				// target text file
				string targetFilePath = String.IsNullOrEmpty(config.TargetFile) ? 
					Path.Combine( Path.GetDirectoryName(filePath), Path.GetFileName(filePath).Substring(1) ) :
					config.TargetFile;
				string targetFileContent = ruleContext.FileManager.Read(targetFilePath);
				bool targetChanged = false;
				string changedContent = targetFileContent;
				if (config.RegexMarker!=null) {
					targetChanged = ApplyRegexRule(config, targetFileContent, out changedContent);
				} else {
					targetChanged = ApplyStartEndRule(config, targetFileContent, out changedContent);
				}

				ruleContext.FileManager.Write(targetFilePath, changedContent );
			}
		}

		protected bool ApplyRegexRule(ModifyRuleConfig cfg, string targetText, out string result) {
			if (cfg.RuleType=="text-insert") {
				Match m = Regex.Match(targetText, cfg.RegexMarker, RegexOptions.Singleline);
				if (m.Success) {
					result = targetText.Insert(m.Index+m.Length, cfg.Text);
					return true;
				}
			} else if (cfg.RuleType=="text-replace" || cfg.RuleType=="text-remove") {
				string replaceWith = cfg.RuleType=="text-remove" ? String.Empty : cfg.Text;
				result = Regex.Replace(targetText, cfg.RegexMarker, replaceWith, RegexOptions.Singleline);
				return result!=targetText;
			}
			result = targetText;
			return false;
		}

		protected bool ApplyStartEndRule(ModifyRuleConfig cfg, string targetText, out string result) {
			if (cfg.RuleType=="text-insert") {
				EnsureStartEnd(cfg, true, false);
				// find start
				int startIdx = targetText.IndexOf(cfg.StartMarker);
				if (startIdx>=0) {
					result = targetText.Insert(startIdx+cfg.StartMarker.Length, cfg.Text);
					return true;
				}
			} else if (cfg.RuleType=="text-replace" || cfg.RuleType=="text-remove") {
				EnsureStartEnd(cfg, true, true);
				int startIdx = targetText.IndexOf(cfg.StartMarker);
				if (startIdx>=0) {
					int endIdx = targetText.IndexOf(cfg.EndMarker, startIdx+cfg.StartMarker.Length);
					if (endIdx>=0) {
						int removeLength = (endIdx-startIdx-cfg.StartMarker.Length);
						StringBuilder sb = new StringBuilder(targetText);
						sb.Remove(startIdx+cfg.StartMarker.Length, removeLength);
						if (cfg.RuleType=="text-replace")
							sb.Insert(startIdx+cfg.StartMarker.Length, cfg.Text);
						result = sb.ToString();
						return true;
					}
				}
			}
			result = targetText;
			return false;
		}

		protected void EnsureStartEnd(ModifyRuleConfig cfg, bool startRequired, bool endRequired) {
			if (startRequired && cfg.StartMarker==null)
				throw new Exception("rule start pattern is missed");
			if (endRequired && cfg.EndMarker==null)
				throw new Exception("rule end pattern is missed");
		}


		public class ModifyRuleConfig {
			string _RuleType;
			string _StartMarker;
			string _EndMarker;
			string _RegexMarker;
			string _TargetFile;
			string _Text;

			public string StartMarker {
				get { return _StartMarker; }
			}

			public string EndMarker {
				get { return _EndMarker; }
			}

			public string RegexMarker {
				get { return _RegexMarker; }
			}

			public string RuleType {
				get { return _RuleType; }
			}

			public string TargetFile {
				get { return _TargetFile; }
			}

			public string Text {
				get { return _Text; }
			}

			public ModifyRuleConfig(XmlNode rootNode) {
				_RuleType = rootNode.Name;
				_StartMarker = rootNode.Attributes["start"]!=null ? rootNode.Attributes["start"].Value : null;
				_EndMarker = rootNode.Attributes["end"]!=null ? rootNode.Attributes["end"].Value : null;
				_RegexMarker = rootNode.Attributes["regex"]!=null ? rootNode.Attributes["regex"].Value : null;
				_TargetFile = rootNode.Attributes["file"]!=null ? rootNode.Attributes["file"].Value : null;
				_Text = rootNode.SelectNodes("*").Count>0 ? rootNode.InnerXml : rootNode.InnerText;
			}


		}

	}

}

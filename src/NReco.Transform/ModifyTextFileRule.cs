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
using System.Xml.XPath;
using System.IO;

namespace NReco.Transform {
	
	/// <summary>
	/// Text file content modification rule
	/// </summary>
	/// <remarks>
	/// This rule processes files that started with special char ('@' by default).
	/// It may contain single rule XML configuration 
	/// <code>
	/// <text-insert file="somefile.text" start="z&gt;">
	/// ***
	/// </text-insert>
	/// </code>
	/// or multiple rules.
	/// </remarks>
	public class ModifyTextFileRule : IFileRule {

		public bool MatchFile(string filePath, IFileManager fm) {
			// match code should be ultra-fast: match rule is hardcoded.
			if (Path.GetFileName(filePath).StartsWith("@")) {
				string trimmed = fm.Read(filePath);
				return (trimmed.Contains("<text-insert") && trimmed.Contains("</text-insert>")) ||
					(trimmed.Contains("<text-replace") && trimmed.Contains("</text-replace>")) ||
					(trimmed.Contains("<text-remove") && trimmed.Contains("</text-remove>"));
			}
			return false;
		}

		public override string ToString() {
			return "Modify text rule";
		}

		public void Execute(FileRuleContext ruleContext) {
			string filePath = ruleContext.RuleFileName;
			string fileContent = ruleContext.FileManager.Read(filePath);

            Mvp.Xml.XInclude.XIncludingReader xmlIncludeContentRdr = new Mvp.Xml.XInclude.XIncludingReader(new StringReader(fileContent));
            xmlIncludeContentRdr.XmlResolver = new FileManagerXmlResolver(ruleContext.FileManager, Path.GetDirectoryName(filePath));
            XPathDocument ruleXPathDoc = new XPathDocument(xmlIncludeContentRdr);
			XPathNavigator ruleNav = ruleXPathDoc.CreateNavigator();

			XPathNodeIterator ruleNavs = ruleNav.Select("/rules/*[starts-with(name(),'text-')]|/*[starts-with(name(),'text-')]");
			foreach (XPathNavigator ruleConfigNav in ruleNavs) {
				Config config = new Config();
				config.ReadFromXmlNode( ruleConfigNav );
				if (String.IsNullOrEmpty( config.TargetFile ))
					config.TargetFile = Path.Combine(Path.GetDirectoryName(filePath), Path.GetFileName(filePath).Substring(1));
				ProcessFileRule(ruleContext, config );
			}
		}

		protected void ProcessFileRule(FileRuleContext ruleContext, Config config) {
			// target text file
			string targetFilePath = config.TargetFile;
			string targetFileContent = ruleContext.FileManager.Read(targetFilePath);
			bool targetChanged = false;
			string changedContent = targetFileContent;
			if (config.RegexMarker!=null) {
				targetChanged = ApplyRegexRule(config, targetFileContent, out changedContent);
			} else {
				targetChanged = ApplyStartEndRule(config, targetFileContent, out changedContent);
			}

			ruleContext.FileManager.Write(targetFilePath, changedContent);
		}

		protected bool ApplyRegexRule(Config cfg, string targetText, out string result) {
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

		protected bool ApplyStartEndRule(Config cfg, string targetText, out string result) {
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

		protected void EnsureStartEnd(Config cfg, bool startRequired, bool endRequired) {
			if (startRequired && cfg.StartMarker==null)
				throw new Exception("rule start pattern is missed");
			if (endRequired && cfg.EndMarker==null)
				throw new Exception("rule end pattern is missed");
		}


		public class Config {
			string _RuleType;
			string _StartMarker;
			string _EndMarker;
			string _RegexMarker;
			string _TargetFile;
			string _Text;

			public string StartMarker {
				get { return _StartMarker; }
				set { _StartMarker = value; }
			}

			public string EndMarker {
				get { return _EndMarker; }
				set { _EndMarker = value; }
			}

			public string RegexMarker {
				get { return _RegexMarker; }
				set { _RegexMarker = value; }
			}

			public string RuleType {
				get { return _RuleType; }
				set { _RuleType = value; }
			}

			public string TargetFile {
				get { return _TargetFile; }
				set { _TargetFile = value; }
			}

			public string Text {
				get { return _Text; }
				set { _Text = value; }
			}

			public Config() {
			}

			public void ReadFromXmlNode(IXPathNavigable config) {
				XPathNavigator configNav = config.CreateNavigator();
				_RuleType = configNav.Name;
				_StartMarker = configNav.GetAttribute("start", String.Empty)!=String.Empty ? configNav.GetAttribute("start", String.Empty) : null;
				_EndMarker = configNav.GetAttribute("end", String.Empty)!=String.Empty ? configNav.GetAttribute("end", String.Empty) : null;
				_RegexMarker = configNav.GetAttribute("regex", String.Empty)!=String.Empty ? configNav.GetAttribute("regex", String.Empty) : null;
				_TargetFile = configNav.GetAttribute("file", String.Empty)!=String.Empty ? configNav.GetAttribute("file", String.Empty) : null;
				_Text = configNav.SelectChildren(XPathNodeType.Element).Count>0 ? configNav.InnerXml : configNav.Value;
			}


		}

	}

}

#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
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
using NReco.Logging;

namespace NReco.Transform {
	
	/// <summary>
	/// XML file modification rule
	/// </summary>
	/// <remarks>
	/// This rule processes files that started with special char ('@' by default).
	/// It may contain single rule XML configuration 
	/// <code>
	/// <xml-insert file="somefile.text" xpath="/root">
	/// ***
	/// </xml-insert>
	/// </code>
	/// or multiple rules.
	/// </remarks>
	public class ModifyXmlFileRule : IFileRule {
		ILog log = LogManager.GetLogger(typeof(ModifyXmlFileRule));
		// TODO: extract similar functionality to shared FileRule base class

		public bool IsMatch(XPathNavigator nav) {
			string nodeName = nav.LocalName;
			return (nodeName=="xml-insert" ||
					nodeName=="xml-replace" ||
					nodeName=="xml-remove");
			return false;
		}

		public override string ToString() {
			return "Modify XML rule";
		}

		public void Execute(FileRuleContext ruleContext) {
			Config config = new Config();
			config.ReadFromXmlNode( ruleContext.XmlSettings );
			if (String.IsNullOrEmpty( config.TargetFile ))
				config.TargetFile = Path.Combine(
					Path.GetDirectoryName(ruleContext.RuleFileName),
					Path.GetFileName(ruleContext.RuleFileName).Substring(1));
			ProcessFileRule(ruleContext, config );
		}

		protected void ProcessFileRule(FileRuleContext ruleContext, Config config) {
			// target text file
			string targetFilePath = config.TargetFile;
			string targetFileContent = ruleContext.FileManager.Read(targetFilePath);

			// TODO: handle exceptions
			XmlDocument xmlDoc = new XmlDocument();
			xmlDoc.PreserveWhitespace = true;
			xmlDoc.LoadXml(targetFileContent);
			// deal with namespaces
			IDictionary<string,string> namespaces = config.Xml.GetNamespacesInScope(XmlNamespaceScope.All);
			XmlNamespaceManager xmlNsMgr = new XmlNamespaceManager(xmlDoc.NameTable);
			foreach (KeyValuePair<string,string> ns in namespaces) {
				xmlNsMgr.AddNamespace(ns.Key, ns.Value);
			}

			bool targetChanged = false;
			if (config.XPath!=null) {
				targetChanged = ApplyXPathRule(config, xmlDoc, xmlNsMgr);
			}

			if (targetChanged)
				ruleContext.FileManager.Write(targetFilePath, PrepareXmlContent(xmlDoc.OuterXml) );
			else {
				log.Write(LogEvent.Warn, new {Msg = "Rule is not matched", Config = config });
			}
		}

		public string PrepareXmlContent(string content) {
			return XmlHelper.DecodeSpecialChars(content);
		}

		protected bool ApplyXPathRule(Config cfg, XmlDocument xmlDoc, XmlNamespaceManager xmlNsMgr) {
			if (cfg.RuleType == "xml-insert") {
				XmlNode targetNode = xmlDoc.SelectSingleNode(cfg.XPath, xmlNsMgr);
				if (targetNode!=null) {
					XPathNavigator targetNav = targetNode.CreateNavigator();
					foreach (XPathNavigator nav in cfg.Xml.SelectChildren(XPathNodeType.All)) {
						switch (cfg.InsertMode) {
							case Config.InsertModeType.Child:
								targetNav.AppendChild(nav);
								break;
							case Config.InsertModeType.Before:
								targetNav.InsertBefore(nav);
								break;
							case Config.InsertModeType.After:
								targetNav.InsertAfter(nav);
								break;
						}
					}
					return true;
				}
			} else if (cfg.RuleType=="xml-remove" || cfg.RuleType=="xml-replace") {
				// if replace - insert nodes first
				XmlNodeList targetNodes = xmlDoc.SelectNodes(cfg.XPath, xmlNsMgr);
				if (cfg.RuleType == "xml-replace") {
					if (targetNodes.Count>0) {
						XPathNavigator targetNav = targetNodes[0].CreateNavigator();
						foreach (XPathNavigator nav in cfg.Xml.SelectChildren(XPathNodeType.All))
							targetNav.InsertBefore(nav);
					}
				}

				foreach (XmlNode node in targetNodes)
					node.ParentNode.RemoveChild(node);
				return targetNodes.Count > 0;
			}
			return false;
		}

		public class Config {
			public enum InsertModeType { Child, Before, After };

			public InsertModeType InsertMode { get; set; }
			public string XPath { get; set; }

			public string RuleType { get; set; }

			public string TargetFile { get; set; }

			public XPathNavigator Xml { get; set; }

			public Config() {
			}

			public void ReadFromXmlNode(IXPathNavigable config) {
				XPathNavigator configNav = config.CreateNavigator();
				RuleType = configNav.Name;
				XPath = configNav.GetAttribute("xpath", String.Empty)!=String.Empty ? configNav.GetAttribute("xpath", String.Empty) : null;
				TargetFile = configNav.GetAttribute("file", String.Empty)!=String.Empty ? configNav.GetAttribute("file", String.Empty) : null;
				Xml = configNav;
				InsertMode = configNav.GetAttribute("mode", String.Empty) != String.Empty ? 
								(InsertModeType)Enum.Parse( typeof(InsertModeType), configNav.GetAttribute("mode", String.Empty), true) : InsertModeType.Child;
			}

			public override string ToString() {
				return String.Format("{{RuleType={0},XPath={1},TargetFile={2}}}", RuleType,XPath,TargetFile);
			}

		}

	}

}

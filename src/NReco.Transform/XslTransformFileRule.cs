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
using System.IO;
using System.Xml;
using System.Xml.Xsl;
using System.Xml.XPath;
using NReco.Logging;

namespace NReco.Transform {
	
	/// <summary>
	/// File XSL-transform rule implementation
	/// </summary>
	public class XslTransformFileRule : IFileRule {

		static ILog log = LogManager.GetLogger(typeof(XslTransformFileRule));

		public XslTransformRule TransformRule { get; set; }

		public XslTransformFileRule(XslTransformRule transformRule) {
			TransformRule = transformRule;
		}

		public bool IsMatch(XPathNavigator nav) {
			// match code should be ultra-fast: match rule is hardcoded.
			return nav.LocalName=="xsl-transform";
		}

		public override string ToString() {
			return "XSL transformation rule";
		}

		static Regex RemoveNamespaceRegex = new Regex(@"xmlns:[a-z0-9]+\s*=\s*[""']urn:remove[""']", RegexOptions.IgnoreCase | RegexOptions.Singleline | RegexOptions.Compiled);

		public string PrepareTransformedContent(string content) {
			// there are 3 chars that may be needed in output content but could be hardly generated from XSL
			var sb = new StringBuilder(content);
			sb.Replace("@@lt;","<").Replace("@@gt;",">").Replace("@@@","@").Replace("@@", "&");
			// also lets take about special namespace, 'urn:remove' that used when xmlns declaration should be totally removed 
			// (for 'asp' prefix for instance)
			return RemoveNamespaceRegex.Replace( sb.ToString(), String.Empty);
		}

		public void Execute(FileRuleContext ruleContext) {
			XslTransformRule.Context xsltContext = new XslTransformRule.Context();
			xsltContext.FileManager = ruleContext.FileManager;
			xsltContext.ReadFromXmlNode(ruleContext.XmlSettings);
			string resContent = TransformRule.Provide(xsltContext);

			XPathNavigator resultFileNameNav = ruleContext.XmlSettings.SelectSingleNode("result/@file");
			if (resultFileNameNav != null) {
				if (!String.IsNullOrEmpty(resultFileNameNav.Value)) {
					if (log.IsEnabledFor(LogEvent.Debug))
						log.Write(LogEvent.Debug,
							new {
								Msg = "Writing XSL transformation result to file",
								File = resultFileNameNav.Value
							});
					ruleContext.FileManager.Write(resultFileNameNav.Value, PrepareTransformedContent( resContent ) );
				} else
					log.Write(LogEvent.Warn, "Nothing to do with XSLT result: output file name is not specified.");
			} else {
				// may be result-dependent files are configured?
				XPathNavigator resultFileNav = ruleContext.XmlSettings.SelectSingleNode("result/file");
				if (resultFileNav != null) {
					// read result
					var resultXPathDoc = new XPathDocument(new StringReader(resContent));
					
					// check @xpath attr
					var xPathNav = resultFileNav.SelectSingleNode("@xpath");
					if (xPathNav==null) {
						log.Write(LogEvent.Warn, "Nothing to do with XSLT result: XPath for output file is not specified.");
						return;
					}
					string xPath = xPathNav.Value;
					// determine file name xpath
					string fileNameXPath = null; 
					var fileNameXPathNav = resultFileNav.SelectSingleNode("name/@xpath");
					if (fileNameXPathNav != null)
						fileNameXPath = fileNameXPathNav.Value;
					// determine file content xpath
					string fileContentXPath = null; 
					var fileContentXPathNav = resultFileNav.SelectSingleNode("content/@xpath");
					if (fileContentXPathNav != null)
						fileContentXPath = fileContentXPathNav.Value;

					// iterate 
					var results = resultXPathDoc.CreateNavigator().Select(xPath);
					if (log.IsEnabledFor(LogEvent.Info))
						log.Write(LogEvent.Info, "Matched {0} file generation results.", results.Count);
					foreach (XPathNavigator nav in results) {
						// determine file name
						var currentFileNameNav = nav.SelectSingleNode(fileNameXPath);
						if (currentFileNameNav == null) {
							log.Write(LogEvent.Warn, new { 
								Msg = "Result is matched but output file name is not matched." });
							continue;
						}
						// determine file contents
						var resultFileContentNav = nav.SelectSingleNode(fileContentXPath);
						if (resultFileContentNav==null) {
							log.Write(LogEvent.Warn, new { 
								Msg = "Result is matched but output file content is not matched." });
							continue;
						}

						string fileContent = PrepareTransformedContent(resultFileContentNav.InnerXml);
						ruleContext.FileManager.Write(currentFileNameNav.Value, fileContent);
					}
				}

			}
		}




	}

}

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
using System.Xml.Xsl;
using System.Xml.XPath;

namespace NReco.Transform {
	
	/// <summary>
	/// File XSL-transform rule implementation
	/// </summary>
	public class XslTransformFileRule : IFileRule {

		public bool MatchFile(string fullFileName, IFileManager fileManager) {
			// match code should be ultra-fast: match rule is hardcoded.
			if (Path.GetFileName( fullFileName ).StartsWith("@")) {
				string trimmed = fileManager.Read(fullFileName);
				return trimmed.Contains("<xsl-transform") && trimmed.Contains("</xsl-transform>");
			}
			return false;
		}

		public override string ToString() {
			return "XSL transformation rule";
		}

		public void Execute(FileRuleContext ruleContext) {
			XslTransformRule xsltRule = new XslTransformRule();
			for (int i=0; i<ruleContext.RuleFileNames.Length; i++) {
				string filePath = ruleContext.RuleFileNames[i];
				string fileContent = ruleContext.FileManager.Read(filePath);

				XPathDocument ruleXPathDoc = new XPathDocument(new StringReader(fileContent));
				XPathNavigator ruleNav = ruleXPathDoc.CreateNavigator();
				XPathNodeIterator ruleNavs = ruleNav.Select("/rules/xsl-transform|/xsl-transform");
				foreach (XPathNavigator ruleConfigNav in ruleNavs) {
					XslTransformRule.Context xsltContext = new XslTransformRule.Context();
					xsltContext.FileManager = ruleContext.FileManager;
					xsltContext.ReadFromXmlNode(ruleConfigNav);
					string resContent = xsltRule.Provide(xsltContext);

					XPathNavigator resultFileNav = ruleConfigNav.SelectSingleNode("result/@file");
					if (!String.IsNullOrEmpty(resultFileNav.Value))
						ruleContext.FileManager.Write(resultFileNav.Value, resContent);
				}
			}
		}




	}

}

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
using System.Text;

namespace NReco.Transform {
	
	public class XslTransformFileRule : IFileRule {

		public bool MatchFile(string fullFileName, IFileManager fileManager) {
			// match code should be ultra-fast: match rule is hardcoded.
			if (Path.GetFileName( fullFileName ).StartsWith("@")) {
				string trimmed = fileManager.Read(fullFileName).Trim();
				return trimmed.StartsWith("<xsl-transform") && trimmed.EndsWith("</xsl-transform>");
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
				XmlDocument ruleConfig = new XmlDocument();
				ruleConfig.LoadXml(fileContent);

				XmlNode xmlConfigNode = ruleConfig.SelectSingleNode("/xsl-transform");
				if (xmlConfigNode==null)
					throw new Exception("Invalid transformation rule config "+filePath);
				
				XslTransformRule.Context xsltContext = new XslTransformRule.Context();
				xsltContext.FileManager = ruleContext.FileManager;
				xsltContext.ReadFromXmlNode(xmlConfigNode);
				string resContent = xsltRule.Provide(xsltContext);

				XmlNode resultNode = ruleConfig.SelectSingleNode("/xsl-transform/result");
				if (resultNode.Attributes["file"]!=null)
					ruleContext.FileManager.Write( resultNode.Attributes["file"].Value, resContent );
			}
		}




	}

}

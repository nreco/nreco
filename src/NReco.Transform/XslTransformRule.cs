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
	
	public class XslTransformRule : IFileRule {

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
#if OMIT_OBSOLETE
			IDictionary<string,XslCompiledTransform> transformCache = new Dictionary<string,XslCompiledTransform>();
#else
			IDictionary<string, XslTransform> transformCache = new Dictionary<string, XslTransform>();
#endif

			for (int i=0; i<ruleContext.RuleFileNames.Length; i++) {
				string filePath = ruleContext.RuleFileNames[i];
				string fileContent = ruleContext.FileManager.Read(filePath);
				XmlDocument ruleConfig = new XmlDocument();
				ruleConfig.LoadXml(fileContent);

				XmlNode xmlContentNode = ruleConfig.SelectSingleNode("/xsl-transform/xml");
				if (xmlContentNode==null)
					throw new Exception("Invalid transformation rule config (xml missed): "+filePath);
				string xmlContentFilePath = xmlContentNode.Attributes["file"].Value;
				string xmlContent = ruleContext.FileManager.Read(xmlContentFilePath);
				string xmlXPath = xmlContentNode.Attributes["select"]!=null ? xmlContentNode.Attributes["select"].Value : null;

				XmlNode ruleXslNode = ruleConfig.SelectSingleNode("/xsl-transform/xsl");
				if (ruleXslNode==null)
					throw new Exception("Invalid transformation rule config (xsl missed): "+filePath);
				string xslFilePath = ruleXslNode.Attributes["file"].Value;
				string xslContent = ruleContext.FileManager.Read(xslFilePath);

				if (!transformCache.ContainsKey(xslContent)) {
#if OMIT_OBSOLETE
					XslCompiledTransform xslt = new XslCompiledTransform();
#else 
					// obsolete XslTransform is used b/c XslCompiledTransform takes much more time to load XSL
					XslTransform xslt = new XslTransform();
#endif

					FileManagerXmlResolver xslUriResolver = new FileManagerXmlResolver(ruleContext.FileManager, Path.GetDirectoryName(xslFilePath));
#if OMIT_OBSOLETE
					xslt.Load(new XmlTextReader(new StringReader(xslContent)), XsltSettings.TrustedXslt, xslUriResolver);
#else
					xslt.Load( new XmlTextReader(new StringReader(xslContent)), xslUriResolver);
#endif
					transformCache[xslContent] = xslt;
				}

				StringWriter resWriter = new StringWriter();
				Mvp.Xml.XInclude.XIncludingReader xmlContentRdr = new Mvp.Xml.XInclude.XIncludingReader( new StringReader(xmlContent) );
				xmlContentRdr.XmlResolver = new FileManagerXmlResolver(ruleContext.FileManager, Path.GetDirectoryName(xmlContentFilePath));
				XPathDocument xmlXPathDoc = new XPathDocument( xmlContentRdr );
				if (xmlXPath!=null) {
					string selectedXmlContent = xmlXPathDoc.CreateNavigator().SelectSingleNode(xmlXPath).OuterXml;
					xmlXPathDoc = new XPathDocument(new StringReader(selectedXmlContent));
				}
#if OMIT_OBSOLETE
				//transformCache[xslContent].Transform(new XmlTextReader(new StringReader(xmlContent)), new XmlTextWriter(resWriter));
#else
				transformCache[xslContent].Transform(xmlXPathDoc, null, new XmlTextWriter(resWriter) );
#endif
				string resContent = resWriter.ToString();

				XmlNode resultNode = ruleConfig.SelectSingleNode("/xsl-transform/result");
				if (resultNode.Attributes["file"]!=null)
					ruleContext.FileManager.Write( resultNode.Attributes["file"].Value, resContent );
			}
		}




	}

}

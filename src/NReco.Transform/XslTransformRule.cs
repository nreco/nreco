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
	
	public class XslTransformRule : IProvider<XslTransformRule.Context,string> {

#if OMIT_OBSOLETE
		IDictionary<string,XslCompiledTransform> transformCache = new Dictionary<string,XslCompiledTransform>();
#else
		IDictionary<string, XslTransform> transformCache = new Dictionary<string, XslTransform>();
#endif

		public XslTransformRule() {

		}

		public override string ToString() {
			return "XSL transformation rule";
		}

		public string Provide(Context ruleContext) {

			if (String.IsNullOrEmpty(ruleContext.Xml))
				throw new Exception("xml missed");
			if (String.IsNullOrEmpty(ruleContext.Xsl))
				throw new Exception("xsl missed");
			if (!transformCache.ContainsKey(ruleContext.Xsl)) {
#if OMIT_OBSOLETE
				XslCompiledTransform xslt = new XslCompiledTransform();
#else 
				// obsolete XslTransform is used b/c XslCompiledTransform takes much more time to load XSL
				XslTransform xslt = new XslTransform();
#endif

				FileManagerXmlResolver xslUriResolver = new FileManagerXmlResolver(ruleContext.FileManager, ruleContext.XslBasePath);
#if OMIT_OBSOLETE
				xslt.Load(new XmlTextReader(new StringReader(xslContent)), XsltSettings.TrustedXslt, xslUriResolver);
#else
				xslt.Load( new XmlTextReader(new StringReader(ruleContext.Xsl)), xslUriResolver);
#endif
				transformCache[ruleContext.Xsl] = xslt;
			}

			StringWriter resWriter = new StringWriter();
			Mvp.Xml.XInclude.XIncludingReader xmlContentRdr = new Mvp.Xml.XInclude.XIncludingReader( new StringReader(ruleContext.Xml) );
			xmlContentRdr.XmlResolver = new FileManagerXmlResolver(ruleContext.FileManager, ruleContext.XmlBasePath);
			// !!! XIncludingReader contain bug: when used directly with XslTransform.
			XPathDocument xmlTmpXPathDoc = new XPathDocument(xmlContentRdr);
			XPathDocument xmlXPathDoc = new XPathDocument( new StringReader( xmlTmpXPathDoc.CreateNavigator().OuterXml ) );
			//Console.WriteLine(xmlTmpXPathDoc.CreateNavigator().OuterXml);

			if (ruleContext.XmlSelectXPath!=null) {
				string selectedXmlContent = xmlXPathDoc.CreateNavigator().SelectSingleNode(ruleContext.XmlSelectXPath).OuterXml;
				xmlXPathDoc = new XPathDocument(new StringReader(selectedXmlContent));
			}
#if OMIT_OBSOLETE
			//transformCache[xslContent].Transform(new XmlTextReader(new StringReader(xmlContent)), new XmlTextWriter(resWriter));
#else
			transformCache[ruleContext.Xsl].Transform(xmlXPathDoc, null, new XmlTextWriter(resWriter) );
#endif
			string resContent = resWriter.ToString();
			return resContent;
		}

		public class Context {
			string _Xsl;
			string _Xml;
			string _XmlSelectXPath;
			string _XslBasePath;
			string _XmlBasePath;
			IFileManager _FileManager;

			public string Xsl { get { return _Xsl; } set { _Xsl = value; } }
			public string Xml { get { return _Xml; } set { _Xml = value; } }
			public string XmlSelectXPath { get { return _XmlSelectXPath; } set { _XmlSelectXPath = value; } }
			public string XslBasePath { get { return _XslBasePath; } set {_XslBasePath = value; } }
			public string XmlBasePath { get { return _XmlBasePath; } set {_XmlBasePath = value; } }
			public IFileManager FileManager { get { return _FileManager; } set { _FileManager = value; } }

			public Context() {

			}

			public void ReadFromXmlNode(XmlNode ruleConfig) {
				XmlNode xmlNode = ruleConfig.SelectSingleNode("xml");
				if (xmlNode==null)
					throw new Exception("xml node missed");
				string xmlContentFilePath = xmlNode.Attributes["file"].Value;
				Xml = FileManager.Read(xmlContentFilePath);
				XmlSelectXPath = xmlNode.Attributes["select"]!=null ? xmlNode.Attributes["select"].Value : null;

				XmlNode xslNode = ruleConfig.SelectSingleNode("xsl");
				if (xslNode==null)
					throw new Exception("xsl node missed");
				string xslFilePath = xslNode.Attributes["file"].Value;
				Xsl = FileManager.Read(xslFilePath);

				XmlBasePath = Path.GetDirectoryName(xmlContentFilePath);
				XslBasePath = Path.GetDirectoryName(xslFilePath);
			}

		}


	}

}

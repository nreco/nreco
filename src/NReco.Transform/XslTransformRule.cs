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

using NReco.Logging;

namespace NReco.Transform {
	
	public class XslTransformRule : IProvider<XslTransformRule.Context,string> {

		static ILog log = LogManager.GetLogger(typeof(XslTransformRule));

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
				try {
#if OMIT_OBSOLETE
				xslt.Load(new XmlTextReader(new StringReader(xslContent)), XsltSettings.TrustedXslt, xslUriResolver);
#else
				xslt.Load( new XmlTextReader(new StringReader(ruleContext.Xsl)), xslUriResolver);
#endif
				} catch (Exception ex) {
					log.Write(LogEvent.Error,
						new string[]{LogKey.Action,LogKey.Exception,"xsl"},
						new object[]{"loading XSL",ex, ruleContext.Xsl} );
					throw new Exception("Cannot load XSL: "+ex.Message, ex);
				}
				transformCache[ruleContext.Xsl] = xslt;
			}

			StringWriter resWriter = new StringWriter();
			Mvp.Xml.XInclude.XIncludingReader xmlIncludeContentRdr = new Mvp.Xml.XInclude.XIncludingReader( new StringReader(ruleContext.Xml) );
			xmlIncludeContentRdr.XmlResolver = new FileManagerXmlResolver(ruleContext.FileManager, ruleContext.XmlBasePath);
			// !!! Note: XIncludingReader has bug: when used directly with XslTransform (incorrect transformation occurs).
			XPathDocument xmlXPathDoc = new XPathDocument(xmlIncludeContentRdr);
			//Console.WriteLine(xmlTmpXPathDoc.CreateNavigator().OuterXml);

			if (ruleContext.XmlSelectXPath!=null) {
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug,
							new string[] {LogKey.Action,"xmlSelectXPath"},
							new object[] {"select from XML",ruleContext.XmlSelectXPath} );
				try {
					string selectedXmlContent = xmlXPathDoc.CreateNavigator().SelectSingleNode(ruleContext.XmlSelectXPath).OuterXml;
					xmlXPathDoc = new XPathDocument(new StringReader(selectedXmlContent));
				} catch (Exception ex) {
					log.Write(LogEvent.Error,
						new string[] {LogKey.Action, LogKey.Exception,"xpath"},
						new object[] {"select from XML",ex,ruleContext.XmlSelectXPath} );
					throw new Exception("Cannot select XML (XPath="+ruleContext.XmlSelectXPath+"):"+ex.Message,ex);
				}
			} else {
				string allXmlContent = xmlXPathDoc.CreateNavigator().OuterXml;
				xmlXPathDoc = new XPathDocument( new StringReader(allXmlContent ) );
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

			public void ReadFromXmlNode(IXPathNavigable ruleConfig) {
				XPathNavigator nav = ruleConfig.CreateNavigator();
				XPathNavigator xmlNav = nav.SelectSingleNode("xml");
				if (xmlNav==null)
					throw new Exception("xml element missed");
				string xmlContentFilePath = xmlNav.GetAttribute("file",String.Empty);
				Xml = FileManager.Read(xmlContentFilePath);
				XmlSelectXPath = xmlNav.GetAttribute("select",String.Empty);
				if (XmlSelectXPath==String.Empty)
					XmlSelectXPath = null;

				XPathNavigator xslNav = nav.SelectSingleNode("xsl");
				if (xslNav==null)
					throw new Exception("xsl element missed");
				string xslFilePath = xslNav.GetAttribute("file",String.Empty);
				Xsl = FileManager.Read(xslFilePath);

				XmlBasePath = Path.GetDirectoryName(xmlContentFilePath);
				XslBasePath = Path.GetDirectoryName(xslFilePath);
			}

		}


	}

}

using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Xml.XPath;
using System.Xml;
using System.Web;
using System.IO;

using NI.Winter;
using NReco.Transform;
using NI.Common.Xml;

namespace NReco.Winter {

	public class WinterConfigSectionHandler : IConfigurationSectionHandler {

		public WinterConfigSectionHandler() {
		}

		public object Create(object parent, object configContext, XmlNode section) {
			try {
				StringBuilder tmpsb = new StringBuilder();
				tmpsb.Append("<components>");
				tmpsb.Append(section.InnerXml);
				tmpsb.Append("</components>");

				string rootDir = Path.GetDirectoryName(typeof(WinterConfigSectionHandler).Assembly.Location);
				if (HttpContext.Current!=null)
					rootDir = HttpRuntime.AppDomainAppPath;

				StringReader tmpRdr = new StringReader(tmpsb.ToString());
				Mvp.Xml.XInclude.XIncludingReader xmlContentRdr = new Mvp.Xml.XInclude.XIncludingReader(tmpRdr);
				LocalFileManager fileManager = new LocalFileManager(rootDir);
				xmlContentRdr.XmlResolver = new FileManagerXmlResolver(fileManager, "./");
				XPathDocument xmlXPathDoc = new XPathDocument(xmlContentRdr);

				IModifyXmlDocumentHandler preprocessor = new RuleConfigProcessor(fileManager);
				XmlComponentsConfig config = new XmlComponentsConfig(
					xmlXPathDoc.CreateNavigator().OuterXml, preprocessor);
				return config;
			} catch (Exception ex) {
				throw new ConfigurationException(ex.Message, ex);
			}
			
		}

	}
}

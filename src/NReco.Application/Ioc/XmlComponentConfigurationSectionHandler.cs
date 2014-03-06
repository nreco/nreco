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
using System.Configuration;
using System.Text;
using System.Xml.XPath;
using System.Xml;
using System.Web;
using System.IO;

using NI.Ioc;
using NI.Vfs;
using NReco.Logging;

namespace NReco.Application.Ioc {
	
	public class XmlComponentConfigurationSectionHandler : IConfigurationSectionHandler {
		
		ILog log = LogManager.GetLogger(typeof(XmlComponentConfigurationSectionHandler));

		public XmlComponentConfigurationSectionHandler() {
		}
		
		protected string GetAppBasePath() {
			string rootDir = AppDomain.CurrentDomain.BaseDirectory;
			if (HttpContext.Current != null)
				rootDir = HttpRuntime.AppDomainAppPath;
			return rootDir;
		}

		public virtual object Create(object parent, object input, XmlNode section) {
			try {
				var xmlRdr = XmlReader.Create(new StringReader(section.InnerXml), null,
						new XmlParserContext(null, null, null, XmlSpace.Default) { BaseURI = "http://vfs/" });

				var appFs = new LocalFileSystem( GetAppBasePath() );
				var xIncludingXmlRdr = new Mvp.Xml.XInclude.XIncludingReader(xmlRdr);
				xIncludingXmlRdr.XmlResolver = new NI.Vfs.XmlVfsResolver(appFs, "./");
				
				// workaround for strange bug that prevents XPathNavigator to Select nodes with XIncludingReader
				var xPathDoc = new XPathDocument(xIncludingXmlRdr);
				var fullConfigXmlRdr = XmlReader.Create(new StringReader(xPathDoc.CreateNavigator().OuterXml));

				var config = new XmlComponentConfiguration(fullConfigXmlRdr);
				return config;
			} catch (Exception ex) {
				throw new ConfigurationException(ex.Message, ex);
			}

		}
		

	}
}

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

using NI.Winter;
using NReco.Logging;
using NReco.Transform;
using NI.Common.Xml;

namespace NReco.Winter {
	
	/// <summary>
	/// Winter configuration section handler with enabled NReco transformation features.
	/// </summary>
	public class WinterConfigSectionHandler : IConfigurationSectionHandler {
		
		ILog log = LogManager.GetLogger(typeof(WinterConfigSectionHandler));
		
		public WinterConfigSectionHandler() {
		}
		
		protected string GetAppBasePath() {
			string rootDir = AppDomain.CurrentDomain.BaseDirectory;
			if (HttpContext.Current != null)
				rootDir = HttpRuntime.AppDomainAppPath;
			return rootDir;
		}
		
		protected IModifyXmlDocumentHandler GetPreprocessor(string sectionName, IFileManager fileMgr) {
			// lets check for custom rule config processor configuration
			string ruleConfigSectionName = sectionName + ".ruleprocessor";
			object ruleConfigObj = ConfigurationSettings.GetConfig(ruleConfigSectionName);
			if (ruleConfigObj!=null) {
				if (!(ruleConfigObj is IComponentsConfig))
					throw new ConfigurationException(String.Format("Invalid configuration section '{0}': expected IComponentsConfig"));
				if (log.IsEnabledFor(LogEvent.Debug))
					log.Write(LogEvent.Debug,
						new{Action="get rule processor",Msg="found custom config",ConfigSectionName=ruleConfigSectionName});
				
				IComponentsConfig ruleConfig = (IComponentsConfig)ruleConfigObj;
				IServiceProvider srvPrv = new NReco.Winter.ServiceProvider(ruleConfig);
				XmlConfigRuleProcessor preprocessor = srvPrv.GetService(typeof(XmlConfigRuleProcessor)) as XmlConfigRuleProcessor;
				if (preprocessor!=null) {
					preprocessor.FileManager = fileMgr;
					return preprocessor;
				} else
					log.Write(LogEvent.Warn,
						new{Action="get rule processor from custom config",
							Msg="RuleConfigProcessor instance not found",
							ConfigSectionName=ruleConfigSectionName});
			}

			XmlConfigRuleProcessor defaultPreprocessor = new XmlConfigRuleProcessor(fileMgr);
			defaultPreprocessor.Rules = new IXmlConfigRule[] {
					new NReco.Transform.XslTransformXmlConfigRule()
				};
			
			if (log.IsEnabledFor(LogEvent.Debug)) {
				log.Write(LogEvent.Debug,
					new{Action="get rule processor",Msg="default rule processor is used"});
			}
			
			return defaultPreprocessor;
		}
		
		public object Create(object parent, object configContext, XmlNode section) {
			try {
				string componentsXml;
				if (section.Name=="components") {
					componentsXml = section.OuterXml;
				} else {
					StringBuilder tmpsb = new StringBuilder();
					tmpsb.Append("<components>");
					tmpsb.Append(section.InnerXml);
					tmpsb.Append("</components>");
					componentsXml = tmpsb.ToString();
				}

				string rootDir = GetAppBasePath();
				if (section.Attributes["includebasepath"] != null) {
					var explicitBase = section.Attributes["includebasepath"].Value;
					rootDir = Path.IsPathRooted(explicitBase) ? explicitBase : Path.Combine(rootDir, explicitBase);
				}

				var xmlRdr = XmlReader.Create(new StringReader(componentsXml), null,
						new XmlParserContext(null, null, null, XmlSpace.Default) { BaseURI = rootDir });
				Mvp.Xml.XInclude.XIncludingReader xmlContentRdr = new Mvp.Xml.XInclude.XIncludingReader(xmlRdr);
				LocalFileManager fileManager = new LocalFileManager(rootDir);
				xmlContentRdr.XmlResolver = new FileManagerXmlResolver(fileManager,"./");
				XPathDocument xmlXPathDoc = new XPathDocument(xmlContentRdr);

				IModifyXmlDocumentHandler preprocessor = GetPreprocessor(section.Name, fileManager);
				
				XmlComponentsConfig config = new XmlComponentsConfig(
					xmlXPathDoc.CreateNavigator().OuterXml, preprocessor);
				return config;
			} catch (Exception ex) {
				throw new ConfigurationException(ex.Message, ex);
			}
			
		}

	}
}

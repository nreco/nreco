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
						new string[] {LogKey.Action, LogKey.Msg, "configSectionName"},
						new object[] {"get rule processor", "found custom config", ruleConfigSectionName} );
				
				IComponentsConfig ruleConfig = (IComponentsConfig)ruleConfigObj;
				IServiceProvider srvPrv = new NReco.Winter.ServiceProvider(ruleConfig);
				RuleConfigProcessor preprocessor = srvPrv.GetService(typeof(RuleConfigProcessor)) as RuleConfigProcessor;
				if (preprocessor!=null) {
					preprocessor.FileManager = fileMgr;
					return preprocessor;
				} else
					log.Write(LogEvent.Warn,
						new string[] {LogKey.Action,LogKey.Msg,"configSectionName"},
						new object[] { "get rule processor from custom config", "RuleConfigProcessor instance not found", ruleConfigSectionName }
					);
			}

			RuleConfigProcessor defaultPreprocessor = new RuleConfigProcessor(fileMgr);
			defaultPreprocessor.Rules = new IXmlConfigRule[] {
					new NReco.Transform.XslTransformXmlConfigRule()
				};
			
			if (log.IsEnabledFor(LogEvent.Debug)) {
				log.Write(LogEvent.Debug,
					new string[] { LogKey.Action, LogKey.Msg},
					new object[] { "get rule processor", "default rule processor is used"});				
			}
			
			return defaultPreprocessor;
		}
		
		public object Create(object parent, object configContext, XmlNode section) {
			try {
				StringBuilder tmpsb = new StringBuilder();
				tmpsb.Append("<components>");
				tmpsb.Append(section.InnerXml);
				tmpsb.Append("</components>");

				string rootDir = GetAppBasePath();

				StringReader tmpRdr = new StringReader(tmpsb.ToString());
				Mvp.Xml.XInclude.XIncludingReader xmlContentRdr = new Mvp.Xml.XInclude.XIncludingReader(tmpRdr);
				LocalFileManager fileManager = new LocalFileManager(rootDir);
				xmlContentRdr.XmlResolver = new FileManagerXmlResolver(fileManager, "./");
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

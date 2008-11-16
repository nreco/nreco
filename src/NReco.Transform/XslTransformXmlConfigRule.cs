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

using NReco;
using NReco.Logging;

namespace NReco.Transform {
	
	/// <summary>
	/// XML config XSL-transform rule implementation
	/// </summary>
	public class XslTransformXmlConfigRule : IXmlConfigRule {

		XslTransformRule Rule;
		string _NodeName = "xsl-transform";
		static ILog log = LogManager.GetLogger(typeof(XslTransformXmlConfigRule));

		public string NodeName {
			get { return _NodeName; }
			set { _NodeName = value; }
		}

		public XslTransformXmlConfigRule() {
			Rule = new XslTransformRule();
		}

		public override string ToString() {
			return "XSL transformation rule";
		}

		public string Provide(XmlConfigRuleContext ruleContext) {
			XslTransformRule.Context context = new XslTransformRule.Context();
			context.FileManager = ruleContext.FileManager;
			context.ReadFromXmlNode( ruleContext.RuleConfig );

			string result = Rule.Provide(context);
			// test for result
			XPathNavigator nav = ruleContext.RuleConfig.CreateNavigator();
			XPathNavigator resultNav = nav.SelectSingleNode("result");
			if (resultNav!=null) {
				// store result in file
				string resultFileName = resultNav.GetAttribute("file",String.Empty);
				if (!String.IsNullOrEmpty( resultFileName )) {
					if (log.IsEnabledFor(LogEvent.Debug))
						log.Write(LogEvent.Debug, 
							new string[] {"action", "file"},
							new object[] {"writing transform result to file", resultFileName } );
					ruleContext.FileManager.Write(resultFileName, result);
					result = null;
				}
			}
			return result;
		}




	}

}

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

		public XslTransformRule TransformRule { get; set; }

		public XslTransformFileRule(XslTransformRule transformRule) {
			TransformRule = transformRule;
		}

		public bool IsMatch(XPathNavigator nav) {
			// match code should be ultra-fast: match rule is hardcoded.
			return nav.LocalName=="xsl-transform";
		}

		public override string ToString() {
			return "XSL transformation rule";
		}

		public void Execute(FileRuleContext ruleContext) {
			XslTransformRule.Context xsltContext = new XslTransformRule.Context();
			xsltContext.FileManager = ruleContext.FileManager;
			xsltContext.ReadFromXmlNode(ruleContext.XmlSettings);
			string resContent = TransformRule.Provide(xsltContext);

			XPathNavigator resultFileNav = ruleContext.XmlSettings.SelectSingleNode("result/@file");
			if (!String.IsNullOrEmpty(resultFileNav.Value))
				ruleContext.FileManager.Write(resultFileNav.Value, resContent);
		}




	}

}

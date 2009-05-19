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
using System.Text;
using System.Xml;
using System.Reflection;
using System.Configuration;

namespace NReco.Web {
	
	/// <summary>
	/// Web manager configuration handler.
	/// </summary>
	/// <remarks>
	/// Configuration sample (for all possible keys see WebManagerCfg class):
	/// <code>
	/// <nreco.web>
	///		<ActionDispatcherName>webActionController</ActionDispatcherName>
	/// </nreco.web>
	/// </code>
	/// </remarks>
	public class WebManagerCfgHandler : IConfigurationSectionHandler {

		public WebManagerCfgHandler() {

		}

		public object Create(object parent, object configContext, XmlNode section) {
			WebManagerCfg cfg = new WebManagerCfg();
			PropertyInfo[] cfgProps = cfg.GetType().GetProperties();
			foreach (PropertyInfo cfgProp in cfgProps) {
				// check attr first
				string propValue = null;
				if (section.Attributes[cfgProp.Name] != null) {
					propValue = section.Attributes[cfgProp.Name].Value;
				} else {
					XmlNode propNode = section.SelectSingleNode(cfgProp.Name);
					if (propNode != null) {
						propValue = propNode.InnerText;
					}
				}
				if (propValue != null) {
					cfgProp.SetValue(cfg, Convert.ChangeType(propValue, cfgProp.PropertyType), null);
				}
			}
			return cfg;
		}

	}
}

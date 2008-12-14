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
using System.Xml;
using System.Configuration;

namespace NReco.Converters {
	
	/// <summary>
	/// Type manager configuration handler.
	/// </summary>
	/// <remarks>
	/// Expects configuration like:
	/// <code>
	///		<converter>NReco.Converters.GenericProviderConverter,NReco</converter>
	/// </code>
	/// </remarks>
	public class TypeManagerCfgHandler : IConfigurationSectionHandler {

		public TypeManagerCfgHandler() {

		}

		public object Create(object parent, object configContext, XmlNode section) {
			XmlNodeList convNodes = section.SelectNodes("converter");
			List<Type> convTypes = new List<Type>();
			foreach (XmlNode convNode in convNodes) {
				string typeStr = convNode.InnerText.Trim();
				Type t = Type.GetType(typeStr, true, true);
				convTypes.Add(t);
			}
			return convTypes;
		}

	}
}

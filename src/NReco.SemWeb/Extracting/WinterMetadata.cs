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
using System.Linq;
using System.Text;
using System.Reflection;
using System.IO;
using NReco;
using NReco.Transform;
using SemWeb;
using NI.Winter;

namespace NReco.SemWeb.Extracting {
	
	public class WinterMetadata  {

		public string BaseNs { get; set; }

		public WinterMetadata() { }

		protected Entity GetCEntity(IComponentInitInfo cInfo) {
			string name = cInfo.Name ?? "component" + cInfo.GetHashCode().ToString();
			return new Entity(BaseNs + name);
		}

		public void Extract(IComponentsConfig config, Store rdfStore) {
			foreach (IComponentInitInfo cInfo in config) {
				ExtractComponent(cInfo, rdfStore);
			}
		}

		protected void ExtractComponent(IComponentInitInfo cInfo, Store rdfStore) {
			var cEntity = GetCEntity(cInfo );
			rdfStore.Add(new Statement(
				cEntity, NS.Rdf.type, NS.DotNet.GetTypeEntity(cInfo.ComponentType)));
			// properties
			if (cInfo.Properties != null)
				foreach (var pInfo in cInfo.Properties) {
					var propValue = ExtractValue(cEntity, pInfo.Value, rdfStore);
					if (propValue!=null)
						rdfStore.Add(new Statement(
							cEntity, NS.DotNet.GetPropertyEntity(pInfo.Name), propValue));
				}
			// const-prv
			if (cInfo.ConstructorArgs!=null )
				foreach (var constrVal in cInfo.ConstructorArgs) {
					ExtractValue(cEntity, constrVal, rdfStore);
				}

		}

		protected Resource ExtractValue(Entity cEntity, IValueInitInfo valInfo, Store rdfStore) {
			if (valInfo is RefValueInfo) {
				var compRef = ((RefValueInfo)valInfo).ComponentRef;
				ExtractComponent(compRef,rdfStore);
				// register dependency
				var resEntity = GetCEntity(compRef);
				rdfStore.Add( new Statement( cEntity, NS.NrDepFromEntity, resEntity ) );
				return resEntity;
			} else if (valInfo is ValueInitInfo) {
				var val = ((ValueInitInfo)valInfo).Value;
				return new Literal( Convert.ToString(val) );
			} else if (valInfo is ListValueInitInfo) {
				Entity bNode = new BNode();
				rdfStore.Add(new Statement(
					bNode, NS.Rdf.type, NS.Rdf.SeqEntity ));
				var values = ((ListValueInitInfo)valInfo).Values;
				for (int i = 0; i < values.Length; i++) {
					var valEntity = ExtractValue(cEntity, values[i], rdfStore);
					if (valEntity != null) {
						rdfStore.Add(new Statement(
							bNode, NS.Rdf.BASE + "_" + (i + 1).ToString(), valEntity));
					}

				}
				return bNode;
			}
			return null;
		}

	}
}

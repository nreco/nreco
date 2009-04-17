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
using SemWeb;

namespace NReco.Metadata.Extracting {
	
	public class AssemblyMetadata {

		public AssemblyMetadata() { }

		protected Entity GetEntity(Type t) {
			return NS.DotNet.GetTypeEntity(t);
		}

		public void Extract(string appBinDir, Store rdfStore) {
			string[] assemblyFiles = Directory.GetFiles( appBinDir, "*.dll");
			foreach (var assemblyFile in assemblyFiles) {
				
				var assembly = Assembly.LoadFrom(assemblyFile);
				Extract(assembly, rdfStore);
			}
		}

		public void Extract(Assembly assembly, Store rdfStore) {
			var types = assembly.GetExportedTypes();
			foreach (var t in types) {
				// store class hierarchy
				var typeEntity = GetEntity(t);
				if (t.IsInterface) {
					rdfStore.Add(new Statement(typeEntity, NS.Rdf.typeEntity, NS.CSO.interfaceEntity));
				} else if (t.IsClass) {
					rdfStore.Add(new Statement(typeEntity, NS.Rdf.typeEntity, NS.CSO.classEntity));
				} else
					continue;
				if (t.BaseType != null)
					rdfStore.Add(new Statement(typeEntity, NS.Rdfs.subClassOfEntity, GetEntity(t.BaseType) ));
				// store info about interfaces
				var ifaces = t.GetInterfaces();
				foreach (var iType in ifaces) {
					rdfStore.Add(new Statement(typeEntity, NS.CSO.Implements, GetEntity(iType)));
					rdfStore.Add(new Statement(typeEntity, NS.Rdfs.subClassOfEntity, GetEntity(iType)));
				}
				// store info about properties
				var props = t.GetProperties(BindingFlags.Public|BindingFlags.SetProperty|BindingFlags.DeclaredOnly|BindingFlags.Instance);
				foreach (var p in props) {
					var propEntity = NS.DotNet.GetPropertyEntity(p.Name);
					rdfStore.Add(new Statement(propEntity, NS.Rdf.typeEntity, NS.Rdfs.PropertyEntity));
					rdfStore.Add(new Statement(propEntity, NS.Rdfs.domainEntity, typeEntity));
				}
			}
		}

	}
}

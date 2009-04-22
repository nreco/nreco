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
using NI.Winter;
using SemWeb;
using SemWeb.Inference;
using SemWeb.Query;

namespace NReco.SemWeb.Extracting {
	
	public class WebAppRdfExport {

		public string BaseUri { get; set; }

		public void Run(IComponentsConfig config, string targetFile) {
			var rdfStore = new MemoryStore();

			rdfStore.Add(new Statement(NS.CSO.classEntity, NS.Rdfs.subClassOf, NS.Rdfs.ClassEntity));
			rdfStore.Add(new Statement(NS.CSO.interfaceEntity, NS.Rdfs.subClassOf, NS.Rdfs.ClassEntity));

			var assemblyExtractor = new AssemblyMetadata();
			assemblyExtractor.Extract( System.Web.HttpRuntime.BinDirectory, rdfStore);

			var configExtractor = new WinterMetadata();
			var baseUri = String.IsNullOrEmpty(BaseUri) ?
				"file:///"+System.Web.HttpRuntime.AppDomainAppPath.Replace('\\','/')+"#" : 
				BaseUri;
			configExtractor.BaseNs = baseUri;
			configExtractor.Extract(config, rdfStore);

			using (RdfXmlWriter wr = new RdfXmlWriter(targetFile)) {
				wr.BaseUri = NS.NrMeta;
				wr.Namespaces.AddNamespace(NS.DotNet.Type, "type");
				wr.Namespaces.AddNamespace(NS.DotNet.Property, "prop");
				wr.Namespaces.AddNamespace(NS.NrMetaTerms, "nr");
				wr.Write(rdfStore);
			}

		}
	}
}

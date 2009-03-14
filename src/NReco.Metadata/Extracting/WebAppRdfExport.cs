using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NI.Winter;
using SemWeb;
using SemWeb.Inference;
using SemWeb.Query;

namespace NReco.Metadata.Extracting {
	
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
				wr.Namespaces.AddNamespace(NS.DotNet.Type, "t");
				wr.Namespaces.AddNamespace(NS.DotNet.Property, "p");
				wr.Write(rdfStore);
			}

		}
	}
}

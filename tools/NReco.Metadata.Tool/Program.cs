using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

using SemWeb;
using SemWeb.Inference;
using SemWeb.Query;

namespace NReco.Metadata.Tool {
	class Program {

		static void Main(string[] args) {

			var rdfStore = new MemoryStore();

			//rdfStore.Add(new Statement(NS.CSO.classEntity, NS.Rdfs.subClassOf, NS.Rdfs.ClassEntity));
			//rdfStore.Add(new Statement(NS.CSO.interfaceEntity, NS.Rdfs.subClassOf, NS.Rdfs.ClassEntity));

			var rdfsReasoner = new RDFS();
			rdfsReasoner.LoadSchema(rdfStore);
			rdfStore.AddReasoner(rdfsReasoner);

			/*using (var wr = new RdfXmlWriter(Console.Out)) {
				wr.BaseUri = NS.NrMeta;
				wr.Write(rdfStore);
			}*/

			
			/*var r = rdfStore.Contains(new Statement(
				(Entity)(NS.NrDotNetType + "NReco.Operations.ChainOperationCall"),
				(Entity)NS.Rdfs.subClassOfEntity,
				(Entity)(NS.NrDotNetType + "NReco.Operations.OperationCall") )); //
			Console.WriteLine(r.ToString());*/
			/*foreach (Statement s in rdfStore.Select(new Statement(
					(Entity)(NS.NrDotNetProp+"ContextFilter"),
					(Entity)NS.Rdfs.domainEntity,
					null))) { //Entity)(NS.NrDotNetType + "NReco.IProvider`2")
				Console.WriteLine(s.Object.Uri.ToString());
			}*/
			/*Query query = new GraphMatch(new N3Reader(new StringReader(rdfQuery)));
			QueryResultSink sink = new SparqlXmlQuerySink(Console.Out);
			query.Run(rdfStore, sink); */

			using (RdfXmlWriter wr = new RdfXmlWriter(@"c:\temp\_1.rdf")) {
				//wr.BaseUri = NS.NrMeta;
				//wr.Namespaces.AddNamespace(NS.DotNet.Type, "t");
				//wr.Namespaces.AddNamespace(NS.DotNet.Property, "p");
				wr.Write(rdfStore);
			}
			Console.ReadKey();



		}
	}
}

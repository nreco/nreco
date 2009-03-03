using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NReco.Metadata;
using SemWeb;

namespace NReco.Metadata.Tool {
	class Program {
		static void Main(string[] args) {

			var rdfStore = new MemoryStore();
			var op = new ExtractAssemblyMetadata();
			op.RdfStore = rdfStore;
			op.Execute(typeof(NReco.IOperation<>).Assembly);

			using (var wr = new RdfXmlWriter(Console.Out)) {
				wr.BaseUri = NS.NRecoType;
				wr.Write(rdfStore);
			}
			
			Console.ReadKey();

		}
	}
}

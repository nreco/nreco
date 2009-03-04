using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using NReco;
using SemWeb;

namespace NReco.Metadata {
	
	public class ExtractAssemblyMetadata : IOperation<Assembly> {

		public Store RdfStore { get; set; }

		public ExtractAssemblyMetadata() { }

		public ExtractAssemblyMetadata(Store store) {
			RdfStore = store;
		}

		protected Entity GetEntity(Type t) {
			string fullName = t.Namespace+"."+t.Name;
			return new Entity(NS.NRecoType + fullName);
		}

		public void Execute(Assembly assembly) {
			var types = assembly.GetExportedTypes();
			foreach (var t in types) {
				// store class hierarchy
				RdfStore.Add(new Statement( NS.NRecoType + t.FullName, NS.RdfTypeEntity, NS.RdfsClassEntity));
				if (t.BaseType != null)
					RdfStore.Add(new Statement(GetEntity(t), NS.RdfsSubClassOf, GetEntity(t.BaseType) ));
			}
		}

	}
}

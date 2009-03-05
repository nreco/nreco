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
			return new Entity(NS.NrNetType + fullName);
		}

		public void Execute(Assembly assembly) {
			var types = assembly.GetExportedTypes();
			foreach (var t in types) {
				// store class hierarchy
				var typeEntity = GetEntity(t);
				RdfStore.Add(new Statement( typeEntity, NS.RdfTypeEntity, NS.RdfsClassEntity));
				if (t.BaseType != null)
					RdfStore.Add(new Statement(typeEntity, NS.RdfsSubClassOfEntity, GetEntity(t.BaseType) ));
				// store info about interfaces
				var ifaces = t.GetInterfaces();
				foreach (var iType in ifaces) {
					RdfStore.Add(new Statement(typeEntity, NS.NrNetImplementEntity, GetEntity(iType)));
				}
				// store info about properties
				/*var props = t.GetProperties();
				foreach (var p in props) {
					RdfStore.Add(new Statement(typeEntity, NS.RdfType, GetEntity(iType)));
				}*/
			}
		}

	}
}

using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

using NI.Data.Dalc;
using SemWeb;

namespace NReco.Metadata.Dalc {
	
	public class RdfDalc : IDalc {

		public Store RdfStore { get; set; }

		public string DefaultNamespace { get; set; }

		public IDictionary<string, string> FieldMapping { get; set; }
		
		public IDictionary<string, string> SourceNameMapping { get; set; }

		public RdfDalc() { }

		public RdfDalc(Store rdfStore) {
			RdfStore = rdfStore;
		}

		protected string ResolveField(string fldName) {
			return ResolveResource(fldName, FieldMapping);
		}

		protected string ResolveSourceName(string sourcename) {
			return ResolveResource(sourcename, SourceNameMapping);
		}

		protected string ResolveResource(string name, IDictionary<string,string> map) {
			if (map != null && map.ContainsKey(name))
				return map[name];
			if (DefaultNamespace != null)
				name += DefaultNamespace;
			return name;
		}

		public int Delete(IQuery query) {
			//RdfStore.Remove( 
			return 0;
		}

		public void Insert(IDictionary data, string sourceName) {
			
		}

		public void Load(DataSet ds, IQuery query) {
			
		}

		public bool LoadRecord(IDictionary data, IQuery query) {
			throw new NotImplementedException();
		}

		public int RecordsCount(string sourceName, IQueryNode conditions) {
			throw new NotImplementedException();
		}

		public int Update(IDictionary data, IQuery query) {
			throw new NotImplementedException();
		}

		public void Update(DataSet ds, string sourceName) {
			throw new NotImplementedException();
		}

	}

}

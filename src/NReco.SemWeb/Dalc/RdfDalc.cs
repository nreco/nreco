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
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

using NI.Data.Dalc;
using SemWeb;

namespace NReco.SemWeb.Dalc {
	
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

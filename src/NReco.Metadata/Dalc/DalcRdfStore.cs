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

using NI.Data.Dalc;
using SemWeb;

namespace NReco.Metadata.Dalc {
	
	/// <summary>
	/// Read-only RDF access to relational data using DALC interface.
	/// </summary>
	public class DalcRdfStore : SelectableSource {

		public IDalc Dalc { get; set; }

		public SourceDescriptor[] SourceDescriptors { get; set; }
		public string Separator { get; set; }

		IDictionary<string, IList<SourceDescriptor>> SourceNsHash;
		IDictionary<string, IList<SourceDescriptor>> FieldSourceNsHash;

		public DalcRdfStore() {
			Separator = "#";
		}

		public void Init() {
			SourceNsHash = new Dictionary<string, IList<SourceDescriptor>>();
			FieldSourceNsHash = new Dictionary<string,IList<SourceDescriptor>>();
			for (int i = 0; i < SourceDescriptors.Length; i++) {
				var descr = SourceDescriptors[i];
				AddToHashList(SourceNsHash, descr.Ns, descr);
				for (int j = 0; j < descr.Fields.Length; j++)
					AddToHashList(FieldSourceNsHash, descr.Fields[j].Ns, descr);
			}
		}

		protected void AddToHashList(IDictionary<string, IList<SourceDescriptor>> hash, string key, SourceDescriptor descr) {
			if (!hash.ContainsKey(key))
				hash[key] = new List<SourceDescriptor>();
			hash[key].Add(descr);
		}

		public bool Contains(Statement template) {
			throw new NotImplementedException();
		}

		public bool Contains(Resource resource) {
			// source
			if (SourceNsHash.ContainsKey(resource.Uri))
				return true;
			// fields
			if (SourceNsHash.ContainsKey(resource.Uri))
				return true;

			// source items
			for (int i = 0; i < SourceDescriptors.Length; i++) {
				var descr = SourceDescriptors[i];
				if (IsSourceItemNs(descr, resource.Uri)) {
					string id = ExtractSourceId(descr, resource.Uri);
					//TODO: id type, 'virtual' resources?
					var matchedRecords = Dalc.RecordsCount(descr.SourceName, (QField)descr.IdFieldName == (QConst)id);
					if (matchedRecords > 0)
						return true;
				}
			}
			return false;
		}

		protected SourceDescriptor FindSourceBySubj(string uri) {
			//TODO: check for source/field queries

			for (int i = 0; i < SourceDescriptors.Length; i++) {
				var descr = SourceDescriptors[i];
				if (IsSourceItemNs(descr, uri))
					return descr;
			}
			return null;
		}

		protected bool IsSourceItemNs(SourceDescriptor descr, string uri) {
			return uri.StartsWith(descr.Ns + Separator);
		}

		protected string ExtractSourceId(SourceDescriptor descr, string uri) {
			return uri.Substring(descr.Ns.Length+Separator.Length);
		}

		public void Select(SelectFilter filter, StatementSink sink) {
			
		}

		public void Select(Statement template, StatementSink sink) {
			// case 1: subject is defined
			if (template.Subject != null) {
				var sourceDescr = FindSourceBySubj(template.Subject.Uri);
				if (sourceDescr == null) return;
			}
		}

		public bool Distinct {
			get { return true; }
		}

		public void Select(StatementSink sink) {
			
		}


		public class SourceDescriptor {
			public string Ns { get; set; }
			public string SourceName { get; set; }
			public string RdfType { get; set; }
			public string IdFieldName { get; set; }

			public FieldDescriptor[] Fields { get; set; }
		}

		public class FieldDescriptor {
			public string Ns { get; set; }
			public string FieldName { get; set; }
			public string RdfType { get; set; }
		}

	}
}

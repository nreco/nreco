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
using System.Collections;
using System.Linq;
using System.Text;
using System.Data;

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
		IDictionary<SourceDescriptor, IDictionary<string,FieldDescriptor>> FieldNsSourceHash;
		IDictionary<FieldDescriptor, Entity> EntityFieldHash;
		IDictionary<SourceDescriptor, Entity> EntitySourceHash;
		IDictionary recordData;

		public DalcRdfStore() {
			Separator = "#";
			recordData = new Hashtable();
		}



		public void Init() {
			SourceNsHash = new Dictionary<string, IList<SourceDescriptor>>();
			FieldSourceNsHash = new Dictionary<string,IList<SourceDescriptor>>();
			FieldNsSourceHash = new Dictionary<SourceDescriptor, IDictionary<string, FieldDescriptor>>();
			EntityFieldHash = new Dictionary<FieldDescriptor, Entity>();
			EntitySourceHash = new Dictionary<SourceDescriptor, Entity>();
			for (int i = 0; i < SourceDescriptors.Length; i++) {
				var descr = SourceDescriptors[i];
				AddToHashList<string,SourceDescriptor>(SourceNsHash, descr.Ns, descr);
				var fieldNsHash = new Dictionary<string, FieldDescriptor>();
				for (int j = 0; j < descr.Fields.Length; j++) {
					AddToHashList<string,SourceDescriptor>(FieldSourceNsHash, descr.Fields[j].Ns, descr);
					fieldNsHash[descr.Fields[j].Ns] = descr.Fields[j];
					EntityFieldHash[descr.Fields[j]] = new Entity(descr.Fields[j].Ns);
				}
				FieldNsSourceHash[descr] = fieldNsHash;
				EntitySourceHash[descr] = new Entity(descr.Ns);
			}
		}

		protected void AddToHashList<TK,LET>(IDictionary<TK, IList<LET>> hash, TK key, LET descr) {
			if (!hash.ContainsKey(key))
				hash[key] = new List<LET>();
			hash[key].Add(descr);
		}

		public bool Contains(Statement template) {
			return Store.DefaultContains(this, template);
		}

		public bool Contains(Resource resource) {
			// source
			if (SourceNsHash.ContainsKey(resource.Uri))
				return true;
			// fields
			if (FieldSourceNsHash.ContainsKey(resource.Uri))
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

		protected IEnumerable<SourceDescriptor> FindSourceByItemSubject(string uri) {
			for (int i = 0; i < SourceDescriptors.Length; i++) {
				var descr = SourceDescriptors[i];
				if (IsSourceItemNs(descr, uri))
					yield return descr;
			}
		}

		protected bool IsSourceItemNs(SourceDescriptor descr, string uri) {
			return uri.StartsWith(descr.Ns + Separator);
		}

		protected Entity GetSourceItemEntity(SourceDescriptor descr, object id) {
			return new Entity( descr.Ns + Separator + Convert.ToString(id) );
		}

		protected string ExtractSourceId(SourceDescriptor descr, string uri) {
			return uri.Substring(descr.Ns.Length+Separator.Length);
		}

		protected Literal PrepareLiteral(FieldDescriptor fldDescr, object val) {
			//TODO: correct representation from object
			return new Literal(Convert.ToString(val));
		}

		protected object PrepareObject(Resource r) {
			if (r is Literal)
				return ((Literal)r).ParseValue();
			// TODO! FK handling!
			return r.Uri;
		}

		protected bool IsNull(object o) {
			return o == null || o == DBNull.Value;
		}

		public void Select(SelectFilter filter, StatementSink sink) {

			if (filter.Subjects != null) {
				// case 1: subject is defined
				SelectBySubject(filter, sink);
			} else if (filter.Predicates != null) {
				// case 2: predicate is defined
				SelectByPredicate(filter, sink);
			} else if (filter.Objects != null) {
				// case 3: only object is defined
				foreach (var sourceDescr in SourceDescriptors)
					LoadToSink(sourceDescr, null, null, filter.Objects, sink);
			} else {
				// dump all sources
				foreach (var sourceDescr in SourceDescriptors)
					LoadToSink(sourceDescr, null, null, null, sink);
			}
			

		}

		public void Select(Statement template, StatementSink sink) {
			Select(new SelectFilter(template), sink);

		}

		protected void LoadToSink(SourceDescriptor sourceDescr, IList<object> ids, IList<FieldDescriptor> predFlds, Resource[] vals, StatementSink sink) {
			// todo: more effective impl using IDbDalc datareader
			var ds = new DataSet();
			var q = new Query(sourceDescr.SourceName);
			var flds = predFlds ?? sourceDescr.Fields;
			q.Fields = new string[flds.Count + 1];
			q.Fields[0] = sourceDescr.IdFieldName;
			for (int i = 0; i < flds.Count; i++)
				q.Fields[i + 1] = flds[i].FieldName;
			var condition = new QueryGroupNode(GroupType.And);
			if (ids != null)
				condition.Nodes.Add(ComposeCondition(sourceDescr.IdFieldName, ids.ToArray()));
			if (vals != null) {
				var orGrp = new QueryGroupNode(GroupType.Or);
				for (int i = 0; i < flds.Count; i++)
					orGrp.Nodes.Add( ComposeCondition(flds[i], vals) );
				condition.Nodes.Add(orGrp);
			}
			q.Root = condition;
			Dalc.Load(ds, q);
			var tbl = ds.Tables[q.SourceName];
			for (int i = 0; i < tbl.Rows.Count; i++) {
				var itemEntity = GetSourceItemEntity(sourceDescr, tbl.Rows[i][sourceDescr.IdFieldName]);
				for (int j = 0; j < flds.Count; j++) {
					var f = flds[j];
					var obj = PrepareLiteral(f, tbl.Rows[i][f.FieldName]);
					if (vals==null || vals.Contains(obj)) 
						sink.Add( new Statement(itemEntity, EntityFieldHash[f], obj) );
				}
				if (predFlds == null) {
					// wildcard predicate - lets push type triplet too
					sink.Add(
						new Statement( itemEntity, NS.Rdf.typeEntity, EntitySourceHash[sourceDescr] ));
				}
			}
		}

		protected IQueryNode ComposeCondition(string fldName, object[] vals) {
			if (vals.Length == 1) {
				// trivial equals
				return (QField)fldName == new QConst(vals[0]);
			} else {
				return new QueryConditionNode((QField)fldName, Conditions.In, new QConst(vals));
			}
		}

		protected IQueryNode ComposeCondition(FieldDescriptor fld, Resource[] vals) {
			object[] objValues = new object[vals.Length];
			for (int i = 0; i < vals.Length; i++)
				objValues[i] = PrepareObject(vals[i]);
			return ComposeCondition(fld.FieldName, objValues);
		}

		protected Query ComposeIdQuery(SourceDescriptor sourceDescr, object id, string fld) {
			var q = new Query(sourceDescr.SourceName,
							(QField)sourceDescr.IdFieldName == new QConst(id));
			if (fld != null)
				q.Fields = new string[] { fld };
			return q;
		}

		protected void SelectByPredicate(SelectFilter filter, StatementSink sink) {
			// TODO: schema select 

			var selectFldSourceHash = new Dictionary<SourceDescriptor, IList<FieldDescriptor>>();
			for (int i = 0; i < filter.Predicates.Length; i++) 
				if (FieldSourceNsHash.ContainsKey(filter.Predicates[i].Uri)) {
					foreach (var srcDescr in FieldSourceNsHash[filter.Predicates[i].Uri]) {
						var fldDescr = FieldNsSourceHash[srcDescr][filter.Predicates[i].Uri];
						AddToHashList<SourceDescriptor, FieldDescriptor>(
							selectFldSourceHash, srcDescr, fldDescr);
					}
				}

			foreach (var selectEntry in selectFldSourceHash) {
				LoadToSink(selectEntry.Key, null, selectEntry.Value, filter.Objects, sink);
			}
		}


		protected void SelectBySubject(SelectFilter filter, StatementSink sink) {
			// TODO: schema select

			var selectIdsSourceHash = new Dictionary<SourceDescriptor, IList<object>>();
			for (int i = 0; i < filter.Subjects.Length; i++) {
				var subj = filter.Subjects[i];
				foreach (var sourceDescr in FindSourceByItemSubject(subj.Uri)) {
					var itemId = ExtractSourceId(sourceDescr, subj.Uri);
					AddToHashList(selectIdsSourceHash, sourceDescr, itemId);
				}
			}

			foreach (var sourceEntry in selectIdsSourceHash) {
				if (filter.Predicates!=null) {
					// case 1.1: is predicate is defined
					var sourceFlds = new List<FieldDescriptor>();
					for (int i = 0; i < filter.Predicates.Length; i++) {
						var pred = filter.Predicates[i];
						// check for "type" predicate
						if (pred == NS.Rdf.typeEntity) {
							for (int j = 0; j < sourceEntry.Value.Count; j++)
								sink.Add(new Statement(
											GetSourceItemEntity(sourceEntry.Key, sourceEntry.Value[j]),
											pred,
											EntitySourceHash[sourceEntry.Key]));
							continue;
						}
						if (FieldNsSourceHash[sourceEntry.Key].ContainsKey(pred.Uri)) {
							sourceFlds.Add(FieldNsSourceHash[sourceEntry.Key][pred.Uri]);
						}
					}
					if (sourceFlds.Count>0)
						LoadToSink(sourceEntry.Key, sourceEntry.Value, sourceFlds, filter.Objects, sink);

				} else {
					// case 1.2: predicate is undefined
					LoadToSink(sourceEntry.Key, sourceEntry.Value, null, filter.Objects, sink);
				}

			}
		}


		public bool Distinct {
			get { return true; }
		}

		public void Select(StatementSink sink) {
			Select(new Statement(null, null, null), sink);
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

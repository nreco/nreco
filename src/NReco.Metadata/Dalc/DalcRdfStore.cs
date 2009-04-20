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
using NReco.Converting;
using SemWeb;

namespace NReco.Metadata.Dalc {
	
	/// <summary>
	/// Read-only RDF access to relational data using DALC interface.
	/// </summary>
	public class DalcRdfStore : SelectableSource {

		public IDalc Dalc { get; set; }

		public SourceDescriptor[] Sources { get; set; }
		public string Separator { get; set; }

		IDictionary<string, IList<SourceDescriptor>> SourceNsHash;
		IDictionary<string, IList<SourceDescriptor>> FieldSourceNsHash;
		IDictionary<SourceDescriptor, IDictionary<string,FieldDescriptor>> FieldNsSourceHash;
		IDictionary<FieldDescriptor, Entity> EntityFieldHash;
		IDictionary<SourceDescriptor, Entity> EntitySourceHash;
		IDictionary<SourceDescriptor, IDictionary<string,FieldDescriptor>> FieldNameSourceHash;
		IDictionary<string, SourceDescriptor> SourceNameHash;
		MemoryStore SchemaStore;
		IDictionary recordData;

		public DalcRdfStore() {
			Separator = "#";
			recordData = new Hashtable();
		}

		public void Init() {
			SourceNsHash = new Dictionary<string, IList<SourceDescriptor>>();
			FieldSourceNsHash = new Dictionary<string,IList<SourceDescriptor>>();
			FieldNsSourceHash = new Dictionary<SourceDescriptor, IDictionary<string, FieldDescriptor>>();
			FieldNameSourceHash = new Dictionary<SourceDescriptor, IDictionary<string, FieldDescriptor>>();
			EntityFieldHash = new Dictionary<FieldDescriptor, Entity>();
			EntitySourceHash = new Dictionary<SourceDescriptor, Entity>();
			SourceNameHash = new Dictionary<string, SourceDescriptor>();
			SchemaStore = new MemoryStore();
			for (int i = 0; i < Sources.Length; i++) {
				var descr = Sources[i];
				AddToHashList(SourceNsHash, descr.Ns, descr);
				var sourceEntity = new Entity(descr.Ns);
				EntitySourceHash[descr] = sourceEntity;
				SourceNameHash[descr.SourceName] = descr;
				// fill schema
				SchemaStore.Add(new Statement(sourceEntity, NS.Rdf.type, (Entity)descr.RdfType));
				SchemaStore.Add(new Statement(sourceEntity, NS.Rdfs.label, new Literal(descr.SourceName)));

				var fieldNsHash = new Dictionary<string, FieldDescriptor>();
				var fieldNameHash = new Dictionary<string, FieldDescriptor>();
				for (int j = 0; j < descr.Fields.Length; j++) {
					var fldDescr = descr.Fields[j];
					AddToHashList(FieldSourceNsHash, fldDescr.Ns, descr);
					fieldNsHash[fldDescr.Ns] = descr.Fields[j];
					fieldNsHash[fldDescr.FieldName] = fldDescr;
					var fldEntity = new Entity(fldDescr.Ns);
					EntityFieldHash[fldDescr] = fldEntity;
					// fill schema
					SchemaStore.Add(new Statement(fldEntity, NS.Rdf.type, (Entity)fldDescr.RdfType));
					SchemaStore.Add(new Statement(fldEntity, NS.Rdfs.label, new Literal(fldDescr.FieldName)));
					SchemaStore.Add(new Statement(fldEntity, NS.Rdfs.domainEntity, sourceEntity));

				}
				FieldNsSourceHash[descr] = fieldNsHash;
				FieldNameSourceHash[descr] = fieldNameHash;
			}
		}

		protected void AddToHashList<TK,LET>(IDictionary<TK, IList<LET>> hash, TK key, LET descr) {
			if (!hash.ContainsKey(key))
				hash[key] = new List<LET>();
			hash[key].Add(descr);
		}

		public bool Contains(Statement template) {
			if (SchemaStore.Contains(template))
				return true;
			return Store.DefaultContains(this, template);
		}

		public bool Contains(Resource resource) {
			if (SchemaStore.Contains(resource))
				return true;

			// source items
			if (resource is Entity) 
				for (int i = 0; i < Sources.Length; i++) {
					var descr = Sources[i];
					if (IsSourceItemNs(descr, resource.Uri)) {
						var id = ExtractSourceId(descr, resource.Uri);
						//TODO: id type, 'virtual' resources?
						var matchedRecords = Dalc.RecordsCount(descr.SourceName, (QField)descr.IdFieldName == (QConst)id);
						if (matchedRecords > 0)
							return true;
					}
				}
			// should we check for literals?..

			return false;
		}

		protected IEnumerable<SourceDescriptor> FindSourceByItemSubject(string uri) {
			for (int i = 0; i < Sources.Length; i++) {
				var descr = Sources[i];
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

		protected object ExtractSourceId(SourceDescriptor descr, string uri) {
			var idStr = uri.Substring(descr.Ns.Length + Separator.Length);
			if (descr.IdFieldType != null)
				return ConvertManager.ChangeType(idStr, descr.IdFieldType);
			// may be this field is registered?
			if (FieldNameSourceHash[descr].ContainsKey(descr.IdFieldName)) {
				var fldDescr = FieldNameSourceHash[descr][descr.IdFieldName];
				if (fldDescr.FieldType != null)
					return ConvertManager.ChangeType(idStr, fldDescr.FieldType);
			}
			return idStr;
		}

		protected Resource PrepareResource(FieldDescriptor fldDescr, object val) {
			if (fldDescr.FkSourceName != null) {
				var fkSrc = SourceNameHash[fldDescr.FkSourceName];
				return GetSourceItemEntity(fkSrc, val);
			}
			//TODO: correct representation from object
			return new Literal(Convert.ToString(val));
		}

		protected object PrepareObject(Resource r) {
			if (r is Literal)
				return ((Literal)r).ParseValue();
			// FK handling
			if (r is Entity) {
				var fkEntity = (Entity)r;
				for (int i = 0; i < Sources.Length; i++) {
					var descr = Sources[i];
					if (IsSourceItemNs(descr, fkEntity.Uri)) {
						return ExtractSourceId(descr, fkEntity.Uri);
					}
				}

			}
			return r.Uri;
		}

		protected bool IsNull(object o) {
			return o == null || o == DBNull.Value;
		}

		public void Select(SelectFilter filter, StatementSink sink) {
			// possible schema matches
			SchemaStore.Select(filter, sink);

			if (filter.Subjects != null) {
				// case 1: subject is defined
				SelectBySubject(filter, sink);
			} else if (filter.Predicates != null) {
				// case 2: predicate is defined
				SelectByPredicate(filter, sink);
			} else if (filter.Objects != null) {
				// case 3: only object is defined
				foreach (var sourceDescr in Sources)
					LoadToSink(sourceDescr, null, null, filter.Objects, sink, filter.Limit);
			} else {
				// dump all sources
				foreach (var sourceDescr in Sources)
					LoadToSink(sourceDescr, null, null, null, sink, filter.Limit);
			}
			

		}

		public void Select(Statement template, StatementSink sink) {
			Select(new SelectFilter(template), sink);

		}

		protected void LoadToSink(SourceDescriptor sourceDescr, IList<object> ids, IList<FieldDescriptor> predFlds, Resource[] vals, StatementSink sink, int limit) {
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
			if (limit > 0)
				q.RecordCount = limit;
			Action<IDataReader> loadToSinkAction = delegate(IDataReader dataReader) {
				int recIndex = 0;
				while (dataReader.Read() && (recIndex<q.RecordCount) ) {
					recIndex++;
					var itemEntity = GetSourceItemEntity(sourceDescr, dataReader[sourceDescr.IdFieldName]);
					for (int j = 0; j < flds.Count; j++) {
						var f = flds[j];
						var obj = PrepareResource(f, dataReader[f.FieldName]);
						if (vals == null || vals.Contains(obj))
							if (!sink.Add(new Statement(itemEntity, EntityFieldHash[f], obj)))
								return;
					}
					if (predFlds == null) {
						// wildcard predicate - lets push type triplet too
						if (!sink.Add(
							new Statement(itemEntity, NS.Rdf.typeEntity, EntitySourceHash[sourceDescr])))
							return;
					}
				}
			};

			if (Dalc is IDbDalc) {
				var dbDalc = (IDbDalc)Dalc;
				bool closeConn = false;
				try {
					if (dbDalc.Connection.State != ConnectionState.Open) {
						dbDalc.Connection.Open();
						closeConn = true;
					}
					IDataReader rdr = dbDalc.LoadReader(q);
					try {
						loadToSinkAction(rdr);
					} finally {
						rdr.Close();
					}
				} finally {
					if (closeConn)
						dbDalc.Connection.Close();
				}

			} else {
				Dalc.Load(ds, q);
				var tblRdr = ds.Tables[q.SourceName].CreateDataReader();
				try {
					loadToSinkAction( tblRdr );
				} finally {
					tblRdr.Close();
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
			var selectFldSourceHash = new Dictionary<SourceDescriptor, IList<FieldDescriptor>>();
			for (int i = 0; i < filter.Predicates.Length; i++) {
				var pred = filter.Predicates[i];
				// check for schema select 

				if (FieldSourceNsHash.ContainsKey(pred.Uri)) {
					foreach (var srcDescr in FieldSourceNsHash[pred.Uri]) {
						var fldDescr = FieldNsSourceHash[srcDescr][pred.Uri];
						AddToHashList<SourceDescriptor, FieldDescriptor>(
							selectFldSourceHash, srcDescr, fldDescr);
					}
				}
			}

			foreach (var selectEntry in selectFldSourceHash) {
				LoadToSink(selectEntry.Key, null, selectEntry.Value, filter.Objects, sink, filter.Limit);
			}
		}


		protected void SelectBySubject(SelectFilter filter, StatementSink sink) {

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
								if (!sink.Add(new Statement(
											GetSourceItemEntity(sourceEntry.Key, sourceEntry.Value[j]),
											pred,
											EntitySourceHash[sourceEntry.Key])))
									return;
							continue;
						}
						if (FieldNsSourceHash[sourceEntry.Key].ContainsKey(pred.Uri)) {
							sourceFlds.Add(FieldNsSourceHash[sourceEntry.Key][pred.Uri]);
						}
					}
					if (sourceFlds.Count>0)
						LoadToSink(sourceEntry.Key, sourceEntry.Value, sourceFlds, filter.Objects, sink, filter.Limit);

				} else {
					// case 1.2: predicate is undefined
					LoadToSink(sourceEntry.Key, sourceEntry.Value, null, filter.Objects, sink, filter.Limit);
				}

			}
		}

		public bool Distinct {
			get { return false; }
		}

		public void Select(StatementSink sink) {
			Select(new Statement(null, null, null), sink);
		}

		/// <summary>
		/// Relational source descriptor.
		/// </summary>
		public class SourceDescriptor {
			/// <summary>
			/// RDF class namespace (required)
			/// </summary>
			public string Ns { get; set; }

			/// <summary>
			/// Source name (required)
			/// </summary>
			public string SourceName { get; set; }
			
			/// <summary>
			/// RDF class type (required)
			/// </summary>
			public string RdfType { get; set; }
			
			/// <summary>
			/// Resource ID field (required)
			/// </summary>
			public string IdFieldName { get; set; }

			/// <summary>
			/// resource ID field type (optional)
			/// </summary>
			public Type IdFieldType { get; set; }

			/// <summary>
			/// Source fields
			/// </summary>
			public FieldDescriptor[] Fields { get; set; }
		}

		/// <summary>
		/// Relational structure field descriptior.
		/// </summary>
		public class FieldDescriptor {
			/// <summary>
			/// RDF predicate namespace (required)
			/// </summary>
			public string Ns { get; set; }
			
			/// <summary>
			/// Field name (required)
			/// </summary>
			public string FieldName { get; set; }

			/// <summary>
			/// Field type (optional)
			/// </summary>
			public Type FieldType { get; set; }

			/// <summary>
			/// RDF predicate type (required)
			/// </summary>
			public string RdfType { get; set; }

			/// <summary>
			/// Foreign key source name (optional)
			/// </summary>
			public string FkSourceName { get; set; }
		}

	}
}

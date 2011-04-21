#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
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
using NReco.Logging;
using SemWeb;
using SemWeb.Filters;

namespace NReco.SemWeb.Dalc {
	
	/// <summary>
	/// Read-only RDF access to relational data using DALC interface.
	/// </summary>
	public class DalcRdfStore : SelectableSource {

		static ILog log = LogManager.GetLogger(typeof(DalcRdfStore));

		public IDalc Dalc { get; set; }

		public SourceDescriptor[] Sources { get; set; }
		public string Separator { get; set; }
		
		public bool UseSchemaFacts { get; set; }
		
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
			UseSchemaFacts = true;
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
				LoadSchemaInfo(descr, sourceEntity, descr.SourceName, SchemaStore);

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
					LoadSchemaInfo(fldDescr, fldEntity, fldDescr.FieldName, SchemaStore);
					SchemaStore.Add(new Statement(fldEntity, NS.Rdfs.domainEntity, sourceEntity));
				}
				FieldNsSourceHash[descr] = fieldNsHash;
				FieldNameSourceHash[descr] = fieldNameHash;
			}
		}

		protected void LoadSchemaInfo(BaseDescriptor baseDescr, Entity subj, string defLabel, MemoryStore sink) {
			// avoid dup types
			var typeSt = new Statement(subj, NS.Rdf.typeEntity, (Entity)baseDescr.RdfType);
			if (!sink.Contains(typeSt))
				sink.Add(typeSt);
			string label = baseDescr.RdfsLabel != null ? baseDescr.RdfsLabel : defLabel;

			// and multiple labels
			if (!sink.Contains( new Statement( subj, NS.Rdfs.labelEntity, null)))
				sink.Add( new Statement(subj, NS.Rdfs.labelEntity, new Literal(label)) );
			
			if (baseDescr.RdfsComment!=null)
				sink.Add(new Statement(subj, NS.Rdfs.commentEntity, new Literal(baseDescr.RdfsComment)));
		}

		protected void AddToHashList<TK,LET>(IDictionary<TK, IList<LET>> hash, TK key, LET descr) {
			if (!hash.ContainsKey(key))
				hash[key] = new List<LET>();
			if (descr!=null)
				hash[key].Add(descr);
		}

		public bool Contains(Statement template) {
			if (UseSchemaFacts && SchemaStore.Contains(template))
				return true;
			return Store.DefaultContains(this, template);
		}

		public bool Contains(Resource resource) {
			if (UseSchemaFacts && SchemaStore.Contains(resource))
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

		/// <summary>
		/// Get data key by RDF entity.
		/// </summary>
		/// <param name="e">RDF Entity</param>
		/// <returns>data key structure or null if given Entity does not refers to DALC source.</returns>
		public DataKey GetDataKey(Entity e) {
			var list = new List<string>();
			object id = null;
			foreach (var src in FindSourceByItemSubject(e.Uri)) {
				list.Add(src.SourceName);
				if (id==null)
					id = ExtractSourceId(src, e.Uri);
			}
			return id != null ? new DataKey(list.ToArray(), id) : null;
		}

		/// <summary>
		/// Get RDF entity for given sourcename and ID.
		/// </summary>
		public Entity GetEntity(string sourceName, object id) {
			if (SourceNameHash.ContainsKey(sourceName)) {
				return GetSourceItemEntity(SourceNameHash[sourceName], id);
			}
			return null;
		}

		protected bool IsSourceItemNs(SourceDescriptor descr, string uri) {
			if (descr == null || uri==null)
				return false;
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

		protected bool CanCompare(FieldDescriptor fld, Resource r) {
			if (r is Entity) {
				var key = GetDataKey((Entity)r);
				if (key != null) {
					if (fld.FkSourceName == null)
						return false;
					if (!key.SourceNames.Contains(fld.FkSourceName))
						return false;
				} else {
					// also we cannot compare URI with non-string vars
					if (fld.FieldType != typeof(string))
						return false;
				}
			}
			// TODO: literal type check?
			return fld.Comparable;
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
			// wrap sink
			sink = new DistinctPredicateStatementSink(sink, NS.Rdf.typeEntity);

			// possible schema matches
			if (UseSchemaFacts)
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
					LoadToSink(sourceDescr, null, null, filter.Objects, sink, filter);
			} else {
				// dump all sources
				foreach (var sourceDescr in Sources)
					LoadToSink(sourceDescr, null, null, null, sink, filter);
			}
			

		}

		public void Select(Statement template, StatementSink sink) {
			Select(new SelectFilter(template), sink);

		}

		protected void LoadToSink(SourceDescriptor sourceDescr, IList<object> ids, IList<FieldDescriptor> predFlds, Resource[] vals, StatementSink sink, SelectFilter flt) {
			// todo: more effective impl using IDbDalc datareader
			var ds = new DataSet();
			var q = new Query(sourceDescr.SourceName);
			var flds = predFlds ?? sourceDescr.Fields;
			var loadType = flt.Predicates == null || flt.Predicates.Contains(NS.Rdf.typeEntity);
			q.Fields = new string[flds.Count + 1];
			q.Fields[0] = sourceDescr.IdFieldName;
			for (int i = 0; i < flds.Count; i++)
				q.Fields[i + 1] = flds[i].FieldName;
			// compose query condition
			var condition = new QueryGroupNode(GroupType.And);
			if (ids != null)
				condition.Nodes.Add(ComposeCondition(sourceDescr.IdFieldName, ids.ToArray()));
			if (vals != null && !loadType) {
				var orGrp = new QueryGroupNode(GroupType.Or);
				for (int i = 0; i < flds.Count; i++) {
					var valCnd = ComposeCondition(flds[i], vals);
					if (valCnd!=null)
						orGrp.Nodes.Add(valCnd);
				}
				if (orGrp.Nodes.Count==0)
					return; //values are not for this source
				condition.Nodes.Add(orGrp);
			}
			if (flt.LiteralFilters != null) {
				var literalFltCondition = ComposeLiteralFilter(flds, flt.LiteralFilters);
				if (literalFltCondition != null)
					condition.Nodes.Add(literalFltCondition);
			}
			q.Root = condition;
			if (flt.Limit > 0)
				q.RecordCount = flt.Limit;
			// log
			log.Write(LogEvent.Debug, q);
			Console.WriteLine(q.ToString());
			// query result handler
			Action<IDataReader> loadToSinkAction = delegate(IDataReader dataReader) {
				int recIndex = 0;
				while (dataReader.Read() && (recIndex<q.RecordCount) ) {
					recIndex++;
					var itemEntity = GetSourceItemEntity(sourceDescr, dataReader[sourceDescr.IdFieldName]);
					for (int j = 0; j < flds.Count; j++) {
						var f = flds[j];
						var obj = PrepareResource(f, dataReader[f.FieldName]);
						if (vals == null || vals.Contains(obj)) {
							// literals post-filter
							if (flt.LiteralFilters != null && !LiteralFilter.MatchesFilters(obj, flt.LiteralFilters, this))
								continue;
							if (!sink.Add(new Statement(itemEntity, EntityFieldHash[f], obj)))
								return;
						}
					}
					// type predicate
					if (loadType && flt.LiteralFilters == null) {
						if (vals==null || vals.Contains(EntitySourceHash[sourceDescr]))
							if (!sink.Add(
								new Statement(itemEntity, NS.Rdf.typeEntity, EntitySourceHash[sourceDescr])))
								return;
					}
				}
			};
			// DB DALC datareader optimization
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

		protected IQueryNode ComposeLiteralFilter(IList<FieldDescriptor> flds, LiteralFilter[] filters) {
			// at least one
			var qNode = new QueryGroupNode(GroupType.Or);
			for (int i = 0; i < flds.Count; i++) {
				var fldFlt = ComposeLiteralFilter(flds[i], filters);
				if (fldFlt != null)
					qNode.Nodes.Add(fldFlt);
			}
			return qNode.Nodes.Count>0 ? qNode : null;
		}

		protected IQueryNode ComposeLiteralFilter(FieldDescriptor fld, LiteralFilter[] filters) {
			if (fld.FkSourceName != null)
				return null; // only _literals_
			var qNode = new QueryGroupNode(GroupType.And);
			for (int i = 0; i < filters.Length; i++) {
				var cnd = ComposeLiteralCondition(fld, filters[i]);
				if (cnd != null)
					qNode.Nodes.Add(cnd);
			}
			return qNode.Nodes.Count>0 ? qNode : null;
		}
		protected IQueryConditionNode ComposeLiteralCondition(FieldDescriptor fld, LiteralFilter filter) {
			if (filter is StringCompareFilter) {
				var f = (StringCompareFilter)filter;
				return new QueryConditionNode((QField)fld.FieldName, GetQueryCondition(f.Type), new QConst(f.Pattern));
			} else if (filter is StringContainsFilter) {
				var f = (StringContainsFilter)filter;
				return new QueryConditionNode((QField)fld.FieldName, Conditions.Like, new QConst( String.Format("%{0}%",f.Pattern) ));
			} else if (filter is StringStartsWithFilter) {
				var f = (StringStartsWithFilter)filter;
				return new QueryConditionNode((QField)fld.FieldName, Conditions.Like, new QConst(String.Format("{0}%", f.Pattern)));
			} else if (filter is StringEndsWithFilter) {
				var f = (StringEndsWithFilter)filter;
				return new QueryConditionNode((QField)fld.FieldName, Conditions.Like, new QConst(String.Format("%{0}", f.Pattern)));
			} else if (filter is NumericCompareFilter) {
				var f = (NumericCompareFilter)filter;
				if (fld.FieldType == null || !IsNumericType(fld.FieldType) )
					return null; // avoid SQL 'cannot compare' error
				// should we check for fld type?
				return new QueryConditionNode((QField)fld.FieldName, GetQueryCondition(f.Type), new QConst(f.Number));
			}
			return null;
		}
		private bool IsNumericType(Type t) {
			return t == typeof(decimal)
					|| t == typeof(byte) || t == typeof(sbyte)
					|| t == typeof(short) || t == typeof(ushort)
					|| t == typeof(int) || t == typeof(uint)
					|| t == typeof(long) || t == typeof(ulong)
					|| t == typeof(float) || t == typeof(double);
		}
		private Conditions GetQueryCondition(LiteralFilter.CompType op) {
			switch (op) {
				case LiteralFilter.CompType.LT: return Conditions.LessThan;
				case LiteralFilter.CompType.LE: return Conditions.LessThan | Conditions.Equal;;
				case LiteralFilter.CompType.NE: return Conditions.Equal | Conditions.Not;;
				case LiteralFilter.CompType.EQ: return Conditions.Equal;
				case LiteralFilter.CompType.GT: return Conditions.GreaterThan;
				case LiteralFilter.CompType.GE: return Conditions.GreaterThan|Conditions.Equal;
				default: throw new ArgumentException(op.ToString());
			}
		}


		protected IQueryNode ComposeCondition(string fldName, IList vals) {
			if (vals.Count == 0)
				return null;
			if (vals.Count == 1) {
				// trivial equals
				return (QField)fldName == new QConst(vals[0]);
			} else {
				return new QueryConditionNode((QField)fldName, Conditions.In, new QConst(vals));
			}
		}

		protected IQueryNode ComposeCondition(FieldDescriptor fld, Resource[] vals) {
			var objValues = new ArrayList(vals.Length);
			for (int i = 0; i < vals.Length; i++)
				if (CanCompare(fld, vals[i]))
					objValues.Add( PrepareObject(vals[i]) );
			return ComposeCondition(fld.FieldName, objValues);
		}

		protected void SelectByPredicate(SelectFilter filter, StatementSink sink) {
			var selectFldSourceHash = new Dictionary<SourceDescriptor, IList<FieldDescriptor>>();
			for (int i = 0; i < filter.Predicates.Length; i++) {
				var pred = filter.Predicates[i];
				// check for schema select 
				if (pred == NS.Rdf.typeEntity) {
					if (filter.Objects != null) {
						foreach (var obj in filter.Objects)
							if (obj is Entity)
								if (SourceNsHash.ContainsKey(((Entity)obj).Uri)) 
									foreach (var srcDescr in SourceNsHash[ ((Entity)obj).Uri ])
										AddToHashList( selectFldSourceHash, srcDescr, null);
					} else {
						// dump types for all sources
						foreach (var srcDescr in Sources)
							AddToHashList(selectFldSourceHash, srcDescr, null);
					}
				}

				if (FieldSourceNsHash.ContainsKey(pred.Uri)) {
					foreach (var srcDescr in FieldSourceNsHash[pred.Uri]) {
						var fldDescr = FieldNsSourceHash[srcDescr][pred.Uri];
						AddToHashList(
							selectFldSourceHash, srcDescr, fldDescr);
					}
				}
			}
			foreach (var selectEntry in selectFldSourceHash) {
				LoadToSink(selectEntry.Key, null, selectEntry.Value, filter.Objects, sink, filter);
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
						LoadToSink(sourceEntry.Key, sourceEntry.Value, sourceFlds, filter.Objects, sink, filter);

				} else {
					// case 1.2: predicate is undefined
					LoadToSink(sourceEntry.Key, sourceEntry.Value, null, filter.Objects, sink, filter);
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
		/// RDB-to-RDF mapping descriptor base class.
		/// </summary>
		public class BaseDescriptor {
			/// <summary>
			/// RDF predicate namespace (required)
			/// </summary>
			public string Ns { get; set; }

			/// <summary>
			/// RDF predicate type (required)
			/// </summary>
			public string RdfType { get; set; }

			/// <summary>
			/// RDFS label value
			/// </summary>
			public string RdfsLabel { get; set; }

			/// <summary>
			/// RDFS comment value
			/// </summary>
			public string RdfsComment { get; set; }

		}

		/// <summary>
		/// Relational source descriptor.
		/// </summary>
		public class SourceDescriptor : BaseDescriptor {
			/// <summary>
			/// Source name (required)
			/// </summary>
			public string SourceName { get; set; }
			
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
		public class FieldDescriptor : BaseDescriptor {
			
			/// <summary>
			/// Field name (required)
			/// </summary>
			public string FieldName { get; set; }

			/// <summary>
			/// Field type (optional)
			/// </summary>
			public Type FieldType { get; set; }

			/// <summary>
			/// Foreign key source name (optional)
			/// </summary>
			public string FkSourceName { get; set; }

			/// <summary>
			/// Determines whether this field can be compared in data query
			/// </summary>
			public bool Comparable { get; set; }

			public FieldDescriptor() {
				Comparable = true;
			}
		}

		/// <summary>
		/// Represents RDB data key
		/// </summary>
		public class DataKey {
			string[] _SourceNames;
			object _Id;

			public string SourceName {
				get {
					return _SourceNames.Length > 0 ? _SourceNames[0] : null;
				}
			}
			public string[] SourceNames { get { return _SourceNames; } }
			public object Id { get { return _Id; } }

			public DataKey(string[] sourceNames, object id) {
				_SourceNames = sourceNames;
				_Id = id;
			}
		}

		internal class DistinctPredicateStatementSink : StatementSink {
			StatementSink Sink;
			Entity Predicate;
			IDictionary<Entity,Resource> PushedPairs;

			public DistinctPredicateStatementSink(StatementSink underlyingSink, Entity pred) {
				Sink = underlyingSink;
				Predicate = pred;
				PushedPairs = new Dictionary<Entity, Resource>();
			}

			public bool Add(Statement statement) {
				if (statement.Predicate == Predicate) {
					if (PushedPairs.ContainsKey(statement.Subject))
						return true;
					else
						PushedPairs[statement.Subject] = statement.Object;
				}
				return Sink.Add(statement);
			}

		}

	}
}

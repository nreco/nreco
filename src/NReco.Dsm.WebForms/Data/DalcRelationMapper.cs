using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

using NReco;
using NReco.Converting;
using NI.Data;

namespace NReco.Dsm.WebForms.Data {

	/// <summary>
	/// DALC-based relation mapper
	/// </summary>
	public class DalcRelationMapper : IRelationMapper {

		public DataRowDalcMapper DbContext { get; set; }

		public string FromFieldName { get; set; }
		public string ToFieldName { get; set; }
		public string PositionFieldName { get; set; }
		public string TableName { get; set; }
		
		public IDictionary<string,object> ExtraKeys { get; set; }

		public DalcRelationMapper() {
		}

		public DalcRelationMapper(DataRowDalcMapper dbContext, string relationTblName, string fromFldName, string toFldName) {
			DbContext = dbContext;
			TableName = relationTblName;
			FromFieldName = fromFldName;
			ToFieldName = toFldName;
		}

		public DalcRelationMapper(IDalc dalc, IDataSetFactory dsFactory, string relationTblName, string fromFldName, string toFldName) {
			DbContext = new DataRowDalcMapper(dalc,dsFactory.GetDataSet);
			TableName = relationTblName;
			FromFieldName = fromFldName;
			ToFieldName = toFldName;
		}

		protected bool AreEqual(object o1, object o2) {
			var o1norm = o1 == DBNull.Value ? null : o1;
			var o2norm = o2 == DBNull.Value ? null : o2;
			return ValueComparer.Instance.Compare(o1norm, o2norm)==0;
		}

		public void Update(object fromKey, IEnumerable toKeys) {
			// load
			var relationTbl = DbContext.LoadAll(new Query(TableName, ComposeFromCondition(fromKey) ));

			var data = ExtraKeys == null ? new Dictionary<string, object>() : new Dictionary<string, object>(ExtraKeys);
			data[FromFieldName] = fromKey;
			
			int pos = 1;
			if (toKeys==null)
				toKeys = new object[0];
			foreach (var toKey in toKeys) {
				DataRow relationRow = relationTbl.Rows.Cast<DataRow>().Where(r => AreEqual(toKey, r[ToFieldName])).FirstOrDefault();
				if (relationRow == null) {
					relationRow = relationTbl.NewRow();
					relationRow[FromFieldName] = fromKey;
					relationRow[ToFieldName] = toKey;
					if (ExtraKeys!=null)
						foreach (var extraKeyEntry in ExtraKeys)
							relationRow[extraKeyEntry.Key] = extraKeyEntry.Value;
					relationTbl.Rows.Add(relationRow);
				}
				
				if (PositionFieldName != null)
					relationRow[PositionFieldName] = pos++;
			}

			// delete missed relations
			foreach (DataRow r in relationTbl.Rows) {
				if (! toKeys.Cast<object>().Where( k => AreEqual(k, r[ToFieldName] )).Any() )
					r.Delete();
			}
			
			DbContext.Update(relationTbl);
			
		}
		
		protected QueryNode ComposeFromCondition(object fromKey) {
			var grpAnd = new QueryGroupNode(QueryGroupNodeType.And);
			grpAnd.Nodes.Add((QField)FromFieldName == new QConst(fromKey));
			if (ExtraKeys != null)
				foreach (var entry in ExtraKeys)
					grpAnd.Nodes.Add((QField)entry.Key == new QConst(entry.Value));
			return grpAnd;
		}

		public object[] Load(object fromKey) {
			var q = new Query(TableName, ComposeFromCondition(fromKey) );
			if (PositionFieldName != null)
				q.SetSort( PositionFieldName );
			var tbl = DbContext.LoadAll(q);
			return tbl.Rows.Cast<DataRow>().Select(r => r[ToFieldName]).ToArray();
		}

	}
}

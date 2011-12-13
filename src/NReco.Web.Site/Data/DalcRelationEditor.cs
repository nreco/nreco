using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using NReco.Collections;
using NReco.Converting;
using NI.Data.Dalc;

namespace NReco.Web.Site.Data {

	/// <summary>
	/// Relation manager based on IDalc component
	/// </summary>
	public class DalcRelationEditor : IRelationEditor {

		public IDalc Dalc { get; set; }

		public string FromFieldName { get; set; }
		public string ToFieldName { get; set; }
		public string PositionFieldName { get; set; }
		public string RelationSourceName { get; set; }
		
		public IDictionary<string,object> ExtraKeys { get; set; }

		public DalcRelationEditor() {
		}

		public void Set(object fromKey, IEnumerable toKeys) {
			// load existing keys
			var currentToKeys = GetToKeys(fromKey);
			
			// remove missed relations
			var fromCondition = ComposeFromCondition(fromKey);
			var deleteCondition = fromCondition;
			var toKeysArr = toKeys.Cast<object>().ToArray();
			if (toKeysArr.Length>0) {
				deleteCondition = new QueryConditionNode((QField)ToFieldName, Conditions.In | Conditions.Not, new QConst(toKeysArr)) & deleteCondition;
			}
			Dalc.Delete(new Query(RelationSourceName, deleteCondition));

			var data = ExtraKeys == null ? new Hashtable() : new Hashtable( new DictionaryWrapper<string,object>(ExtraKeys) );
			data[FromFieldName] = fromKey;
			int pos = 1;
			foreach (var toKey in toKeys) {
				data[ToFieldName] = toKey;
				if (PositionFieldName != null)
					data[PositionFieldName] = pos++; 
				
				if (Contains(toKey, currentToKeys)) {
					if (PositionFieldName!=null)
						Dalc.Update( new Hashtable() { {PositionFieldName, data[PositionFieldName]} },
							new Query(RelationSourceName, (QField)ToFieldName == new QConst(toKey) & fromCondition));
				} else {
					Dalc.Insert(data, RelationSourceName);
				}
			}
		}

		protected IQueryNode ComposeFromCondition(object fromKey) {
			var grpAnd = new QueryGroupNode(GroupType.And);
			grpAnd.Nodes.Add((QField)FromFieldName == new QConst(fromKey));
			if (ExtraKeys != null)
				foreach (var entry in ExtraKeys)
					grpAnd.Nodes.Add((QField)entry.Key == new QConst(entry.Value));
			return grpAnd;
		}

		public object[] GetToKeys(object fromKey) {
			var q = new Query(RelationSourceName, ComposeFromCondition(fromKey));
			if (PositionFieldName != null)
				q.Sort = new[] { PositionFieldName };
			var ds = new DataSet();
			Dalc.Load(ds, q);
			return ds.Tables[q.SourceName].Rows.Cast<DataRow>().Select(r => r[ToFieldName]).ToArray();
		}

		internal static bool AreEqual(object o1, object o2) {
			if ((o1 == null && o2 == null) || (DBNull.Value.Equals(o1) && DBNull.Value.Equals(o2)))
				return true;

			if (o1 != null) {
				var o1EqRes = o1.Equals(o2);
				if (!o1EqRes && o2 != null) {
					var o2Conv = ConvertManager.FindConverter(o2.GetType(), o1.GetType());
					if (o2Conv != null)
						return o1.Equals(o2Conv.Convert(o2, o1.GetType()));
				}
				return o1EqRes;
			}
			return o2 != null ? o2.Equals(o1) : false;
		}

		internal static bool Contains(object o, IEnumerable arr) {
			foreach (var elem in arr) {
				if (AreEqual(o, elem))
					return true;
			}

			return false;
		}			
		
		

	}
}

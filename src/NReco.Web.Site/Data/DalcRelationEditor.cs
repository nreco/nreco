using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using NReco.Collections;
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
			// clear
			Dalc.Delete(new Query(RelationSourceName, ComposeFromCondition(fromKey)));

			var data = ExtraKeys == null ? new Hashtable() : new Hashtable( new DictionaryWrapper<string,object>(ExtraKeys) );
			data[FromFieldName] = fromKey;
			int pos = 1;
			foreach (var toKey in toKeys) {
				data[ToFieldName] = toKey;
				if (PositionFieldName != null)
					data[PositionFieldName] = pos++; 
				Dalc.Insert(data, RelationSourceName);
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

	}
}

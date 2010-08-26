using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using NI.Data.Dalc;

namespace NReco.Web.Site.Data {

	/// <summary>
	/// Relation manager based on DalcManager component (uses DataRow for relation manipulations)
	/// </summary>
	public class DalcManagerRelationEditor : IRelationEditor {

		public DalcManager DalcManager { get; set; }

		public string FromFieldName { get; set; }
		public string ToFieldName { get; set; }
		public string PositionFieldName { get; set; }
		public string RelationSourceName { get; set; }
		
		public IDictionary<string,object> ExtraKeys { get; set; }

		public DalcManagerRelationEditor() {
		}

		public void Set(object fromKey, IEnumerable toKeys) {
			// clear
			DalcManager.Delete( new Query(RelationSourceName, ComposeFromCondition(fromKey) ));

			var data = ExtraKeys == null ? new Dictionary<string, object>() : new Dictionary<string, object>(ExtraKeys);
			data[FromFieldName] = fromKey;
			var pos = 1;
			foreach (var toKey in toKeys) {
				data[ToFieldName] = toKey;
				if (PositionFieldName != null)
					data[PositionFieldName] = pos++;
				DalcManager.Insert(RelationSourceName, data);
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
			var q = new Query(RelationSourceName, ComposeFromCondition(fromKey) );
			if (PositionFieldName != null)
				q.Sort = new[] { PositionFieldName };
			var tbl = DalcManager.LoadAll(q);
			return tbl.Rows.Cast<DataRow>().Select(r => r[ToFieldName]).ToArray();
		}

	}
}

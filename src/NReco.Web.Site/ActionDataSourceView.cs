using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Web;
using System.Web.UI;
using NI.Data.Dalc;

namespace NReco.Web.Site {
	
	public class ActionDataSourceView : DataSourceView {
		protected ActionDataSource DataSource { get; set; }

		public ActionDataSourceView(ActionDataSource owner, string sourceName) : base(owner, sourceName) {
			DataSource = owner;
		}

		protected override IEnumerable ExecuteSelect(DataSourceSelectArguments arguments) {
			Query q = new Query(Name);
			if (arguments.RetrieveTotalRowCount) {
				arguments.TotalRowCount = DataSource.Dalc.RecordsCount(q.SourceName, q.Root);
			}

			if (!String.IsNullOrEmpty(arguments.SortExpression))
				q.Sort = arguments.SortExpression.Split(',');
			q.StartRecord = arguments.StartRowIndex;
			if (arguments.MaximumRows>0)
				q.RecordCount = arguments.MaximumRows;
			DataSet ds = new DataSet();
			DataSource.Dalc.Load(ds, q);
			return ds.Tables[q.SourceName].DefaultView;
		}

		protected IQueryNode ComposeUidCondition(IDictionary keys) {
			// compose UID condition
			var uidGroup = new QueryGroupNode(GroupType.And);
			foreach (DictionaryEntry key in keys)
				uidGroup.Nodes.Add(new QField(key.Key.ToString()) == new QConst(key.Value));
			return uidGroup;
		}

		protected override int ExecuteInsert(IDictionary values) {
			DataSource.Dalc.Insert(values, Name);
			return 1;
		}

		protected override int ExecuteUpdate(IDictionary keys, IDictionary values, IDictionary oldValues) {
			var uidCondition = ComposeUidCondition(keys);
			return DataSource.Dalc.Update(values, new Query(Name, uidCondition));
		}

		protected override int ExecuteDelete(IDictionary keys, IDictionary oldValues) {
			var uidCondition = ComposeUidCondition(keys);
			return DataSource.Dalc.Delete(new Query(Name, uidCondition));
		}

		public override bool CanDelete {
			get {
				return true;
			}
		}

		public override bool CanInsert {
			get {
				return true;
			}
		}

		public override bool CanUpdate {
			get {
				return true;
			}
		}

		public override bool CanPage {
			get {
				return true;
			}
		}

		public override bool CanRetrieveTotalRowCount {
			get {
				return true;
			}
		}

		public override bool CanSort {
			get {
				return true;
			}
		}

	}
}

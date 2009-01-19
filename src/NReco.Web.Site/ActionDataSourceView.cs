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
			return null;
		}

		protected IQueryNode ComposeUidCondition(IDictionary keys) {
			// compose UID condition
			var uidGroup = new QueryGroupNode(GroupType.And);
			foreach (DictionaryEntry key in keys)
				uidGroup.Nodes.Add(new QField(key.Key.ToString()) == new QConst(key.Value));
			return uidGroup;
		}

		protected override int ExecuteInsert(IDictionary values) {
			return 1;
		}

		protected override int ExecuteUpdate(IDictionary keys, IDictionary values, IDictionary oldValues) {
			return 1;
		}

		protected override int ExecuteDelete(IDictionary keys, IDictionary oldValues) {
			return 1;
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

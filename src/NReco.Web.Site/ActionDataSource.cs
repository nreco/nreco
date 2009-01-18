using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using NI.Data.Dalc;

namespace NReco.Web.Site {

	public class ActionDataSource : DataSourceControl {
		public string SelectActionName { get; set; }
		public string InsertActionName { get; set; }
		public string UpdateActionName { get; set; }
		public string DeleteActionName { get; set; }

		public ActionDataSource() { }

		protected override DataSourceView GetView(string viewName) {
			return new ActionDataSourceView(this, viewName );
		}
	}
}

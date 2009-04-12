using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class CheckBoxListRelationEditor : NReco.Web.ActionUserControl {

	public object PageId { get; set; }

	protected override void OnLoad(EventArgs e) {
	}

	public void ExecuteAfter_Insert(ActionContext e) {
		ExecuteAfter_Update(e);
	}
	public void ExecuteAfter_Update(ActionContext e) {
		OnDataBinding(EventArgs.Empty);

		var dalc = WebManager.GetService<IDalc>("db");
		dalc.Delete(new Query("page_visibility", (QField)"page_id" == new QConst(PageId)));
		foreach (var id in checkboxes.SelectedValues)
			dalc.Insert(new Hashtable { { "page_id", PageId }, { "account_id", id } }, "page_visibility");
	}

	public string[] GetSelectedIds() {
		// select visible ids
		var ids = (from r in WebManager.GetService<IDalc>("db").Linq<DalcRecord>("page_visibility")
				   where r["page_id"] == PageId
				   select r["account_id"]).ToArray<DalcValue>();
		return Array.ConvertAll<DalcValue, string>(ids, x => x.Value.ToString());
	}

}

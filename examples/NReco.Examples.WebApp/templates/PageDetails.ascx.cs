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

public partial class PageDetails : NReco.Web.ActionUserControl {

	protected override void OnLoad(EventArgs e) {
		var context = this.GetPageContext();
		if (context.ContainsKey("title")) {
			pagesDataSource.Condition = (QField)"title" == new QConst(context["title"]);
		} else {
			FormView.DefaultMode = FormViewMode.Insert;
		}
		base.OnLoad(e);
	}
	public void FormViewInsertedHandler(object sender, FormViewInsertedEventArgs e) {
		// ActionDataSource used that configured for transactional processing.
		// so immediate redirect will cause transaction rollback. Lets just register redirect - ActionDispatcher will take care.
		Response.Redirect(this.GetRouteUrl("pageDetails", e.Values), false);
	}

	public void DataSelectedHandler(object sender, DalcDataSourceSelectEventArgs e) {
		if (e.Data.Tables[e.SelectQuery.SourceName].Rows.Count == 0) {
			FormView.ChangeMode(FormViewMode.Insert);
		} else {
			var tbl = e.Data.Tables[e.SelectQuery.SourceName];
			var col = new DataColumn("visibility_ids", typeof(string[]));
			col.DefaultValue = new string[0];
			tbl.Columns.Add(col);

			// select visible ids
			var ids = (from r in WebManager.GetService<IDalc>("db").Linq<DalcRecord>("page_visibility")
					where r["page_id"] == tbl.Rows[0]["id"]
					select r["account_id"]).ToArray<DalcValue>();
			tbl.Rows[0]["visibility_ids"] = Array.ConvertAll<DalcValue,string>(ids, x => x.Value.ToString() );
		}
	}

	public void DataBoundHandler(object sender, EventArgs e) {
		if (FormView.CurrentMode == FormViewMode.Insert) {
			if (this.GetPageContext().ContainsKey("title"))
				((TextBox)FormView.FindControl("title")).Text = Convert.ToString(this.GetPageContext()["title"]);
			((CheckBox)FormView.FindControl("isPublic")).Checked = true;
		}
	}

	protected string PrepareContent(object contentType, object o) {
		var parsers = WebManager.GetService<IDictionary<string, IProvider<string, string>>>("pageTypeParsers");
		if (parsers.ContainsKey(contentType.ToString()))
			return parsers[contentType.ToString()].Provide(Convert.ToString(o));
		return Convert.ToString(o);
	}

	public void DataUpdatedHandler(object sender, DalcDataSourceSaveEventArgs e) {
		var pageId = FormView.CurrentMode != FormViewMode.Insert ? FormView.DataKey.Value : e.Values["id"];
		var dalc = WebManager.GetService<IDalc>("db");
		dalc.Delete(new Query("page_visibility", (QField)"page_id" == new QConst(pageId)));
		foreach (var id in (string[])e.Values["visibility_ids"])
			dalc.Insert(new Hashtable { { "page_id", pageId }, { "account_id", id } }, "page_visibility");

	}


}

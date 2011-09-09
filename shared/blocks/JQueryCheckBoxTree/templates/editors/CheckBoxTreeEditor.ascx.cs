using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;
using System.Globalization;

using NReco;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NReco.Web.Site.Controls;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

[ValidationProperty("Value")]
public partial class CheckBoxTreeEditor : CommonRelationEditor {
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	public string ParentFieldName { get; set; }
	
	public string OnCheckAncestors { get; set; }
	public string OnCheckDescendants { get; set; }

	public string OnUncheckAncestors { get; set; }
	public string OnUncheckDescendants { get; set; }
	
	public string Width { get; set; }
	
	public string Value {
		get { return String.IsNullOrEmpty(selectedValues.Value) ? null : selectedValues.Value; }
	}
	
	public CheckBoxTreeEditor() {
		OnCheckAncestors = "none";
		OnCheckDescendants = "none";
		OnUncheckAncestors = "none";
		OnUncheckDescendants = "none";
		
		RegisterJs = true;
		JsScriptName = "js/checkboxtree/jquery.checkboxtree.js";
	}
	
	protected FilterView FindFilter() {
		return this.GetParents<FilterView>().FirstOrDefault();
	}	
	
	protected void HandleFilter(object sender,EventArgs e) {
		var filter = FindFilter();
		if (filter!=null)
			filter.ApplyFilter();
	}	
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
		}
	}

	IEnumerable _Data;
	protected IEnumerable Data {
		get { return _Data ?? (_Data=DataSourceHelper.GetProviderDataSource(LookupServiceName,LookupDataContext)); }
	}
	
	protected IEnumerable GetLevelData(object parent) {
		foreach (var item in Data)
			if (String.IsNullOrEmpty(ParentFieldName) || AssertHelper.AreEquals( DataBinder.Eval(item,ParentFieldName), parent))
				yield return item;
	}
	
	protected void RenderHierarchyLevel(StringBuilder sb, object parent, bool renderList) {
		bool isFirst = true;
		foreach (var item in GetLevelData(parent)) {
			if (isFirst && renderList) {
				sb.Append("<ul>");
				isFirst = false;
			}
			var uid = Convert.ToString( DataBinder.Eval(item,ValueFieldName) );
			var title = Convert.ToString( DataBinder.Eval(item,TextFieldName) );
			sb.AppendFormat("<li><input type=\"checkbox\" id=\"{2}_{0}\" value=\"{0}\"/><label for='{2}_{0}'>{1}</label>", HttpUtility.HtmlAttributeEncode(uid), HttpUtility.HtmlEncode(title), ClientID );
			if (!String.IsNullOrEmpty(ParentFieldName)) {
				RenderHierarchyLevel( sb, uid, true );
			}
			sb.Append("</li>");
		}
		if (!isFirst && renderList)
			sb.Append("</ul>");
	}
	
	protected string RenderHierarchy() {
		var sb = new StringBuilder();
		RenderHierarchyLevel(sb, DBNull.Value,false);
		return sb.ToString();
	}
	
	
	protected override IEnumerable GetControlSelectedIds() {
		return String.IsNullOrEmpty(selectedValues.Value) ? new object[0] : JsHelper.FromJsonString<IEnumerable>( selectedValues.Value );
	}

}

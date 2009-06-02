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
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class MultiselectEditor : CommonRelationEditor {
	
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	
	public MultiselectEditor() {
		RegisterJs = true;
		JsScriptName = "js/multiselect/ui.multiselect.js";
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			var scriptTag = "<s"+"cript language='javascript' src='"+JsScriptName+"'></s"+"cript>";
			if (!Page.ClientScript.IsStartupScriptRegistered(Page.GetType(), JsScriptName)) {
				Page.ClientScript.RegisterStartupScript(Page.GetType(), JsScriptName, scriptTag, false);
			}
			// one more for update panel
			System.Web.UI.ScriptManager.RegisterClientScriptInclude(Page, Page.GetType(), JsScriptName, "ScriptLoader.axd?path="+JsScriptName);
		}
	}

	protected override IEnumerable GetControlSelectedIds() {
		return multiselect.SelectedValues;
	}

}

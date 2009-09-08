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

public partial class DropdownCheckListEditor : CommonRelationEditor {
	
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	
	public bool Sortable { get; set; }
	
	public DropdownCheckListEditor() {
		RegisterJs = true;
		JsScriptName = "js/dropdownchecklist/ui.dropdownchecklist.js";
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
		}
	}

	protected override IEnumerable GetControlSelectedIds() {
		return checklist.SelectedValues;
	}

}

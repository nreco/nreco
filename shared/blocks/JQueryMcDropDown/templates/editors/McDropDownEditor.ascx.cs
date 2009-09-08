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
using NReco.Collections;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;
using NI.Data.RelationalExpressions;

[ValidationProperty("Value")]
public partial class McDropDownEditor : System.Web.UI.UserControl {
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	
	public string LookupServiceName { get; set; }
	public string TextFieldName { get; set; }
	public string ValueFieldName { get; set; }
	public string ParentFieldName { get; set; }
	
	public string Value {
		get { return selectedValue.Value!="" ? selectedValue.Value : null; }
		set { selectedValue.Value = value; }
	}
	
	public McDropDownEditor() {
		RegisterJs = true;
		JsScriptName = "js/jquery.mcdropdown.min.js";
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
		}
	}
	
	protected string GetValueText() {
	}
	
}

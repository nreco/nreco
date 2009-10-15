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

[ValidationProperty("Text")]
public partial class JQueryMarkItUpEditor : System.Web.UI.UserControl, ITextControl {
	
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	
	public bool Sortable { get; set; }
	
	public int Rows { get; set; }
	
	public string Text {
		get { return textbox.Text; }
		set { textbox.Text = value; }
	}
	
	public JQueryMarkItUpEditor() {
		RegisterJs = true;
		JsScriptName = "js/markitup/jquery.markitup.pack.js";
		Rows = 10;
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
		}
	}

}

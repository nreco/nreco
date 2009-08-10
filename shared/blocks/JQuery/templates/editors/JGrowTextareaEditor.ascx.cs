﻿using System;
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
using NReco.Web;
using NReco.Web.Site;

[ValidationProperty("Text")]
public partial class JGrowTextareaEditor : NReco.Web.ActionUserControl {
	
	public bool RegisterJs { get; set; }
	public string JsScriptName { get; set; }
	public int Rows { get; set; }
	public int Columns { get; set; }
	public int MaxHeight { get; set; }
	
	public string Text {
		get {
			return textarea.Text;
		}
		set {
			textarea.Text = value;
		}
	}
	
	
	public JGrowTextareaEditor() {
		JsScriptName = "js/jquery.jgrow-0.3.min.js";
		RegisterJs = true;
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
		}
	}

}

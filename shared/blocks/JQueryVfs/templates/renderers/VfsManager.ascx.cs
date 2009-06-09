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

public partial class VfsManager : System.Web.UI.UserControl {
	
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	
	public string FileSystemName { get; set; }
	
	public VfsManager() {
		RegisterJs = true;
		JsScriptName = "js/jquery.uploadify.js";
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


}

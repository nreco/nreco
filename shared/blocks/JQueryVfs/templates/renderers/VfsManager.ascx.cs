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
	
	
	public string[] JsScriptNames { get; set; }
	public bool RegisterJs { get; set; }
	
	public string FileSystemName { get; set; }
	
	public VfsManager() {
		RegisterJs = true;
		JsScriptNames = new[] { "js/swfobject.js", "js/jquery.uploadify.v2.1.0.min.js" };
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			foreach (var jsName in JsScriptNames)
				JsHelper.RegisterJsFile(Page,jsName);
		}
	}


}

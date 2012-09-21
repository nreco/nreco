#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2012 Vitaliy Fedorchenko
 * Distributed under the LGPL licence
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#endregion

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
public partial class JWysiwygEditor : System.Web.UI.UserControl, ITextControl {
	
	
	public string JsScriptName { get; set; }
	public string[] PluginScriptNames { get; set; }
	public bool RegisterJs { get; set; }
	
	public string Text {
		get {
			return textbox.Text;
		}
		set { textbox.Text = value; }
	}
	
	public int Rows {
		get { return textbox.Rows; }
		set { textbox.Rows = value; }
	}

	public int Columns {
		get { return textbox.Columns; }
		set { textbox.Columns = value; }
	}
	
	public string CustomCreateLinkJsFunction { get; set; }
	public string CustomInsertImageJsFunction { get; set; }
	
	public JWysiwygEditor() {
		RegisterJs = true;
		JsScriptName = "js/jwysiwyg/jquery.wysiwyg.js";
		PluginScriptNames = new [] {
			"js/jwysiwyg/farbtastic.js",
			"js/jwysiwyg/wysiwyg.colorpicker.js", "js/jwysiwyg/wysiwyg.table.js", "js/jwysiwyg/wysiwyg.cssWrap.js",
			"js/jwysiwyg/wysiwyg.fullscreen.js", "js/jwysiwyg/wysiwyg.link.js", "js/jwysiwyg/wysiwyg.image.js", "wysiwyg.i18n.js"
		};
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
			foreach (var jsFile in PluginScriptNames)
				JsHelper.RegisterJsFile(Page,jsFile);
		}
	}

}

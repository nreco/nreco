#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008,2009 Vitaliy Fedorchenko
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

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

[ValidationProperty("Value")]
public partial class NumberTextBoxEditor : System.Web.UI.UserControl, ITextControl {

	public string PrefixText { get; set; }
	public string SuffixText { get; set; }
	
	public string Format { get; set; }
	
	public TypeCode Type { get; set; }
	
	public Unit Width {
		get { return textbox.Width; }
		set { textbox.Width = value; }
	}	
	
	public object Value {
		get {
			if (String.IsNullOrEmpty(textbox.Text))
				return null;
			return Convert.ChangeType( textbox.Text, Type);
		}
		set {
			textbox.Text = String.Format(Format,value);
		}
	}
	
	public string Text {
		get {
			return textbox.Text;
		}
		set { textbox.Text = value; }
	}
		
	public string SpinJsScriptName { get; set; }
	public bool SpinEnabled { get; set; }
	public int SpinMin { get; set; }
	public int SpinMax { get; set; }
	
	public NumberTextBoxEditor() {
		Format = "{0}";
		Type = TypeCode.Int32;
		SpinEnabled = false;
		SpinMin = Int32.MinValue;
		SpinMax = Int32.MaxValue;
		SpinJsScriptName = "js/jquery-spin.js";
	}

	protected override void OnLoad(EventArgs e) {
		if (SpinEnabled) {
			JsHelper.RegisterJsFile(Page,SpinJsScriptName);
		}
	}	
}

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

[ValidationProperty("Text")]
public partial class TextBoxEditor : System.Web.UI.UserControl, ITextControl {
	
	public bool EmptyIsNull { get; set; }
	
	public Unit Width {
		get { return textbox.Width; }
		set { textbox.Width = value; }
	}
	
	public string Text {
		get {
			if (EmptyIsNull && String.IsNullOrEmpty(textbox.Text))
				return null;
			return textbox.Text;
		}
		set {
			textbox.Text = value;
		}
	}

	
}

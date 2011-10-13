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
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web.Site.Controls {
	
	/// <summary>
	/// Extends standard CheckBoxList with SelectedValues property that can be used with 2-way databinding.
	/// </summary>
	public class CheckBoxList : System.Web.UI.WebControls.CheckBoxList {
		string[] SetSelectedValues = null;

		public string[] SelectedValues {
			get {
				return this.GetSelectedItems();
			}
			set {
				SetSelectedValues = value;
				this.SetSelectedItems(value);
			}
		}

		public CheckBoxList() {
		}

		public override void DataBind() {
			SetSelectedValues = null;
			base.DataBind();
			if (SetSelectedValues!=null)
				this.SetSelectedItems(SetSelectedValues);
		}

		// add 'value' attribute to the input type 'checkbox' (this bug is fixed already in .NET 4.0)
		private CheckBox _UnderlyingCheckbox;

		protected override void AddedControl(Control control, int index) {
			base.AddedControl(control, index);
			if (control is CheckBox) {
				_UnderlyingCheckbox = (CheckBox)control;
			}
		}

		protected override void RenderItem(ListItemType itemType, int repeatIndex, RepeatInfo repeatInfo, HtmlTextWriter writer) {
			ListItem listItem = this.Items[repeatIndex];
			if (_UnderlyingCheckbox != null) {
				_UnderlyingCheckbox.InputAttributes["value"] = listItem.Value;
			}
			base.RenderItem(itemType, repeatIndex, repeatInfo, writer);
		}
	}
}

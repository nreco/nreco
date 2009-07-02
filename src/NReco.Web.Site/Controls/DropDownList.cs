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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace NReco.Web.Site.Controls {

	/// <summary>
	/// DropDownList with selection by value support
	/// </summary>
	public class DropDownList : System.Web.UI.WebControls.DropDownList 
    {
		/// <summary>
		/// Default-non-valuable item text
		/// </summary>
		public string DefaultItemText { get; set; }

		/// <summary>
		/// Default-non-valuable item value
		/// </summary>
		public string DefaultItemValue { get; set; }

		string bindedSelectedValue = null;
		
		public override string SelectedValue {
			get {
				return base.SelectedValue;
			}
			set {
				bindedSelectedValue = value;
				if (value==null || Items.Count==0 || Items.FindByValue(value)!=null)
					base.SelectedValue = value;
			}
		}

		public DropDownList() {
		}

		public override void DataBind() {
			bindedSelectedValue = null;
			base.DataBind();
		}

		protected override void PerformDataBinding(IEnumerable dataSource) {
			var selectedValue = bindedSelectedValue ?? SelectedValue;
			SelectedValue = null;

			if (Items.Count > 0)
				Items.Clear();

			base.PerformDataBinding(dataSource);

			if (DefaultItemText != null && Items.FindByValue(DefaultItemValue) == null)
				Items.Insert(0, new ListItem(DefaultItemText, DefaultItemValue));

			// little hack - set selected by value at databind stage
			if (!String.IsNullOrEmpty(selectedValue))
				this.SetSelectedItems(new string[] { selectedValue });

		}
		
	}
}

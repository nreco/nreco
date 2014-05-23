#region License
/*
 * NReco library (http://nreco.googlecode.com/)
 * Copyright 2008-2014 Vitaliy Fedorchenko
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

namespace NReco.Dsm.WebForms {

	/// <summary>
	/// DropDownList with selection by value support
	/// </summary>
	public class DropDownList : System.Web.UI.WebControls.DropDownList 
    {
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
			
			if (dataSource != null) {
				if (Items.Count > 0)
					Items.Clear();
				// SelectedValue MUST be set to null AFTER Items are cleared 
				SelectedValue = null;
				base.PerformDataBinding(dataSource);
			} else {
				SelectedValue = null;
				base.PerformDataBinding(dataSource);
			}

			// little hack - set selected by value at databind stage
			if (!String.IsNullOrEmpty(selectedValue)) {
				var itm = Items.FindByValue(selectedValue);
				if (itm!=null)
					itm.Selected = true;
			}
		}
		
	}
}

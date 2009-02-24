#region License
/*
 * NReco library (http://code.google.com/p/nreco/)
 * Copyright 2008 Vitaliy Fedorchenko
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
				var q = from ListItem r in Items
						where r.Selected
						select r.Value;
				var res = new List<string>();
				foreach (var val in q)
					res.Add(val);
				return res.ToArray();
			}
			set {
				SetSelectedValues = value;
				SetSelectedToItems(value);
			}
		}

		public CheckBoxList() {
		}

		protected void SetSelectedToItems(string[] values) {
			foreach (ListItem itm in Items)
				itm.Selected = values.Contains(itm.Value);
		}

		public override void DataBind() {
			SetSelectedValues = null;
			base.DataBind();
			if (SetSelectedValues!=null)
				SetSelectedToItems(SetSelectedValues);
		}

	}
}

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
	/// Extends standard ListBox with SelectedValues property that can be used with 2-way databinding.
	/// </summary>
	public class ListBox : System.Web.UI.WebControls.ListBox {
		string[] SetSelectedValues = null;

		public bool PreserveOrder { get; set; }

		public string[] SelectedValues {
			get {
				return this.GetSelectedItems();
			}
			set {
				SetSelectedValues = value;
				this.SetSelectedItems(value);
			}
		}

		public ListBox() {
			PreserveOrder = false;
		}

		public override void DataBind() {
			SetSelectedValues = null;
			base.DataBind();
			if (SetSelectedValues!=null)
				this.SetSelectedItems(SetSelectedValues, PreserveOrder);
		}

	}
}

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
using System.Linq;
using System.Text;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Web.Site.Controls {
	
	/// <summary>
	/// Special placeholder with special databinding logic (used for controlling placholder visibility).
	/// </summary>
	public class VisibilityHolder : PlaceHolder {

		public bool AutoBind { get; set; }

		protected bool IsBinded {
			get { return ViewState["isBinded"] != null ? (bool)ViewState["isBinded"] : false; }
			set { ViewState["isBinded"] = value; }
		}

		public VisibilityHolder() {
			AutoBind = true;
		}

		public void RefreshVisible() {
			OnDataBinding(EventArgs.Empty);
		}

		protected override void OnDataBinding(EventArgs e) {
			IsBinded = true;
			base.OnDataBinding(e);
		}

		protected override void OnPreRender(EventArgs e) {
			if (AutoBind && !IsBinded) {
				OnDataBinding(EventArgs.Empty);
			}
			base.OnPreRender(e);
		}

	}
}

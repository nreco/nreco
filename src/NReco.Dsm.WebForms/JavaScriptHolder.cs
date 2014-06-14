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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace NReco.Dsm.WebForms {
	
	/// <summary>
	/// Special placeholder for javascript code blocks that correctly registers javascript inside update panel.
	/// </summary>
	public class JavaScriptHolder : PlaceHolder {

		public JavaScriptHolder() {
		}

		protected override void OnPreRender(EventArgs e) {
			var strWr = new StringWriter();
			var htmlWr = new HtmlTextWriter(strWr);
			base.Render(htmlWr);
			if (ScriptManager.GetCurrent(Page)!=null && ScriptManager.GetCurrent(Page).IsInAsyncPostBack) {
				ScriptManager.RegisterStartupScript(Page,this.GetType(),ClientID,strWr.ToString(),true);
			} else {
				Page.ClientScript.RegisterClientScriptBlock(this.GetType(),ClientID,strWr.ToString(),true);
			}
			base.OnPreRender(e);
		}

		protected override void Render(HtmlTextWriter writer) {
		}

	}
}

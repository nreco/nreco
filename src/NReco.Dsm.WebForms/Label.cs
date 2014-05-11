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
using System.Text;
using System.ComponentModel;
using System.Web.UI;
using System.Web;
using System.Web.UI.WebControls;

using NReco.Application.Web;

namespace NReco.Dsm.WebForms {

	[DefaultProperty("Text"), ControlValueProperty("Text"), ControlBuilder(typeof(LabelControlBuilder))]
	public class Label : System.Web.UI.WebControls.Label, ITextControl {

		public Label() {
			EnableViewState = false;
		}

		public override void DataBind() {
			base.DataBind();
		}

		protected override void Render(HtmlTextWriter writer) {
			if (!String.IsNullOrEmpty(Text)) {
				var contextControl = TemplateControl ?? NamingContainer;
				writer.Write(AppContext.GetLabel(Text, contextControl!=null ? contextControl.GetType().ToString() : null ));
			}
		}

	}
}

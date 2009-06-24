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
using System.Text;
using System.ComponentModel;
using System.Web.UI;
using System.Web;
using System.Web.UI.WebControls;

namespace NReco.Web {

	[DefaultProperty("Text"), ControlValueProperty("Text"), ControlBuilder(typeof(LiteralControlBuilder))]
	public class Label : LiteralControl {

		public Label() {
			EnableViewState = false;
		}

		protected override void Render(HtmlTextWriter writer) {
			writer.Write( WebManager.GetLabel(Text, TemplateControl ?? NamingContainer) );
		}

	}
}

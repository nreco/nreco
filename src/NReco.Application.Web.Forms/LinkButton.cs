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
using System.Web;
using System.Web.UI;

namespace NReco.Application.Web.Forms {
	
	public class LinkButton : System.Web.UI.WebControls.LinkButton {

		public string AttributeOnClick {
			get { return Attributes["onclick"]; }
			set { Attributes["onclick"] = value; }
		}
		
		public string TextPrefix {
			get { return ViewState["TextPrefix"] as string; }
			set { ViewState["TextPrefix"] = value; }
		}

		public string TextSuffix {
			get { return ViewState["TextSuffix"] as string; }
			set { ViewState["TextSuffix"] = value; }
		}		

		public LinkButton() {
		}
		
		public override void RenderBeginTag(HtmlTextWriter writer) {
			base.RenderBeginTag(writer);
			if (TextPrefix!=null)
				writer.Write(TextPrefix);
		}

		public override void RenderEndTag(HtmlTextWriter writer) {
			if (TextSuffix != null)
				writer.Write(TextSuffix);
			base.RenderEndTag(writer);
		}


		
	}
}

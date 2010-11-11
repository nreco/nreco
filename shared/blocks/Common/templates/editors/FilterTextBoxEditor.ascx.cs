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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;
using System.Web.UI.WebControls;

using NReco;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NReco.Web.Site.Controls;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

[ValidationProperty("Text")]
public partial class FilterTextBoxEditor : System.Web.UI.UserControl, ITextControl {
	
	public string Text {
		get {
			if (String.IsNullOrEmpty(textbox.Text))
				return null;
			return textbox.Text;
		}
		set {
			textbox.Text = value;
		}
	}
	
	public string ValidationGroup {
		get { return lazyFilter.ValidationGroup; }
		set { lazyFilter.ValidationGroup = value; }
	}
	
	protected FilterView FindFilter() {
		return this.GetParents<FilterView>().FirstOrDefault();
	}
	
	protected bool LazyFilterHandled = false;
	
	protected void HandleLazyFilter(object sender,EventArgs e) {
		var filter = FindFilter();
		if (filter!=null)
			filter.ApplyFilter();
		LazyFilterHandled = true;
	}
	
}

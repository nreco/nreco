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
using System.Globalization;

using NReco;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class MultiselectEditor : CommonRelationEditor {
	
	
	public string JsScriptName { get; set; }
	public bool RegisterJs { get; set; }
	
	public bool Sortable { get; set; }
	
	public MultiselectEditor() {
		RegisterJs = true;
		JsScriptName = "js/multiselect/ui.multiselect.js";
	}
	
	protected override void OnLoad(EventArgs e) {
		if (RegisterJs) {
			JsHelper.RegisterJsFile(Page,JsScriptName);
		}
	}

	protected override IEnumerable GetControlSelectedIds() {
		if (Sortable) {
			// lets preserve selected items order.
			if (Request[multiselect.UniqueID]!=null)
				return Request[multiselect.UniqueID].Split(',');
		}
		return multiselect.SelectedValues;
	}

}

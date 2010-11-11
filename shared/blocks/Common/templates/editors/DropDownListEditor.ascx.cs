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
using System.ComponentModel;

using NReco;
using NReco.Converting;
using NReco.Web;
using NReco.Web.Site;
using NReco.Web.Site.Controls;
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

[ValidationProperty("SelectedValue")]
public partial class DropDownListEditor : System.Web.UI.UserControl, IEditableTextControl, ITextControl {
	
	object _SelectedValue = null;
	public string NotSelectedText { get; set; }
	public string NotSelectedValue { get; set; }
	
	public object SelectedValue {
		get {
			if (_SelectedValue != null) {
				return _SelectedValue;
			} else if (!Visible && ViewState["selectedValue"]!=null) {
				return ViewState["selectedValue"];
			} else if (dropdownlist.SelectedIndex == 0 && !Required) {
				return NotSelectedValue;
			} else {
				return dropdownlist.SelectedValue;
			}
		}
		set {
			_SelectedValue = value;
		}
	}
	
	public string ValueFieldName { get; set; }
	public string TextFieldName { get; set; }
	public string LookupName { get; set; }
	public string ValidationGroup { get; set; }
	public object DataContext { get; set; }
	public bool Required { get; set; }
	
	// infrastructure can use IEditableTextControl for dependent controls binding
	string ITextControl.Text {
		get { return SelectedValue as string; }
		set { SelectedValue = value; }
	}
	public event EventHandler TextChanged;
	public event EventHandler BindDataContext;
	
	[TypeConverterAttribute(typeof(StringArrayConverter))]
	public string[] DependentFromControls { get; set; }
	public string DataContextControl { get; set; }

	public DropDownListEditor() {
		NotSelectedText = "-- not selected --";
		NotSelectedValue = null;
	}
	
	protected override void OnInit(EventArgs e) {
		if (DependentFromControls!=null) 
			foreach (var depCtrlId in DependentFromControls)
				if ( (NamingContainer.FindControl(depCtrlId) as IEditableTextControl)!=null) {
					((IEditableTextControl)NamingContainer.FindControl(depCtrlId)).TextChanged += new EventHandler(DependentFromControlChangedHandler);
				}
	}
	
	protected override void OnLoad(EventArgs e) {
		if (FindFilter()!=null || TextChanged!=null) {
			dropdownlist.AutoPostBack = true;
			dropdownlist.ValidationGroup = ValidationGroup;
			dropdownlist.CausesValidation = true;
		}
	}
	
	protected void DependentFromControlChangedHandler(object sender, EventArgs e) {
		// find data control
		if (DataContextControl!=null && (NamingContainer.FindControl(DataContextControl) as DataContextHolder)!=null) {
			DataContext = ((DataContextHolder)NamingContainer.FindControl(DataContextControl)).GetDataContext();
			dropdownlist.DataBind();
		}
		//DataBind();
	}
	
	public override void DataBind() {
		base.DataBind();
		// if editor is invisible, just save 
		if (!Visible) {
			ViewState["selectedValue"] = _SelectedValue;
		}
		_SelectedValue = null;
	}
	
	protected FilterView FindFilter() {
		return this.GetParents<FilterView>().FirstOrDefault();
	}

	protected void HandleSelectedIndexChanged(object sender,EventArgs e) {
		var filter = FindFilter();
		if (filter!=null)
			filter.ApplyFilter();
		if (TextChanged!=null)
			TextChanged(this,EventArgs.Empty);
	}
	
}

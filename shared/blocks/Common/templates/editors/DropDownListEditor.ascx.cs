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

[ValidationProperty("SelectedValue")]
public partial class DropDownListEditor : System.Web.UI.UserControl {
	
	object _SelectedValue = null;
	
	public object SelectedValue {
		get {
			if (_SelectedValue != null)
				return _SelectedValue;
			if (dropdownlist.SelectedIndex==0 && !Required)
				return null;
			return dropdownlist.SelectedValue;
		}
		set {
			_SelectedValue = value;
		}
	}
	public string ValueFieldName { get; set; }
	public string TextFieldName { get; set; }
	public string LookupName { get; set; }
	public object DataContext { get; set; }
	public bool Required { get; set; }

	protected override void OnLoad(EventArgs e) {
	}
	
	public override void DataBind() {
		base.DataBind();
		_SelectedValue = null;
	}
	
	protected FilterView FindFilter() {
		return this.GetParents<FilterView>().FirstOrDefault();
	}

	protected void HandleSelectedIndexChanged(object sender,EventArgs e) {
		var filter = FindFilter();
		if (filter!=null)
			filter.ApplyFilter();
	}
	
}

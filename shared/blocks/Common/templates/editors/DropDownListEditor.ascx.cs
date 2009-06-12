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
using NI.Data.Dalc;
using NI.Data.Dalc.Web;
using NI.Data.Dalc.Linq;

public partial class DropDownListEditor : System.Web.UI.UserControl {
	
	public object SelectedValue {
		get {
			if (dropdownlist.SelectedIndex==0 && !Required)
				return null;
			return dropdownlist.SelectedValue;
		}
		set {
			dropdownlist.SelectedValue = Convert.ToString( value );
		}
	}
	public string ValueFieldName { get; set; }
	public string TextFieldName { get; set; }
	public string LookupName { get; set; }
	public object DataContext { get; set; }
	public bool Required { get; set; }

	protected override void OnLoad(EventArgs e) {
	}



}

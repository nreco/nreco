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

public partial class FilterTextBoxEditor : System.Web.UI.UserControl {
	
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

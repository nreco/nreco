using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Data;

using NReco;
using NReco.Web;
using NReco.Web.Site;
using SemWeb;
using NReco.SemWeb;
using NReco.SemWeb.Model;

public partial class PropertyValueRenderer : NReco.Web.ActionUserControl {
	PropertyView _Property = null;
	
	public PropertyView Property { 
		get {
			if (_Property==null) {
				_Property = DataBinder.Eval(Parent, "Property") as PropertyView;
			}
			return _Property;
		}
	}

}

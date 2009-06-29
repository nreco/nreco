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

public partial class PropertyValue : NReco.Web.ActionUserControl {

	public PropertyView CurrentProperty { get; set; }

	public override void DataBind() {
		base.DataBind();
	}


}

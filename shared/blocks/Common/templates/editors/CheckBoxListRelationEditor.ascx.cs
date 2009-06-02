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

public partial class CheckBoxListRelationEditor : CommonRelationEditor {


	protected override void OnLoad(EventArgs e) {
	}

	protected override IEnumerable GetControlSelectedIds() {
		return checkboxes.SelectedValues;
	}

}

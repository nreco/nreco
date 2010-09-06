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

public partial class GroupedCheckBoxListRelationEditor : CommonRelationEditor {

	public string GroupFieldName { get; set; }
	public string DefaultGroup { get; set; }
	public int RepeatColumns { get; set; }
	public RepeatLayout RepeatLayout { get; set; }
	
	protected override void OnLoad(EventArgs e) {
	}

	protected override IEnumerable GetControlSelectedIds() {
		var resList = new List<string>();
		foreach (var checkboxes in this.GetChildren<NReco.Web.Site.Controls.CheckBoxList>()) {
			resList.AddRange(checkboxes.SelectedValues);
		}
		return resList.Distinct();
	}
	
	protected IEnumerable GetGroups() {
		var allRoles = GetDataSource();
		var groupRoles = new Dictionary<string, IList<object>>();
		foreach (var role in allRoles) {
			var groupName = (DataBinder.Eval(role, GroupFieldName) as string) ?? DefaultGroup;
			if (!groupRoles.ContainsKey(groupName))
				groupRoles[groupName] = new List<object>();
			groupRoles[groupName].Add(role);
		}
		return groupRoles;
	}
		
	
}

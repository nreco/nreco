<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.LookupEditorUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<script runat="server" language="c#">
public int RepeatColumns { get; set; }
public RepeatLayout RepeatLayout { get; set; }
public string GroupFieldName { get; set; }
public string DefaultGroup { get; set; }

public override object ValidationValue {
	get { return ((string[])SelectedValues).Length > 0 ? null : String.Join(",", (string[])SelectedValues); } 
}

public IEnumerable SelectedValues {
	get {
		var resList = new List<string>();
		foreach (var checkboxes in ControlUtils.GetChildren<NReco.Dsm.WebForms.CheckBoxList>(this)) {
			resList.AddRange(checkboxes.SelectedValues);
		}
		return resList.Distinct().ToArray();
	}
	set {
		BindSelectedValues = value != null ? value.Cast<object>().Select(v => v.ToString()).ToArray() : new string[0];
	}
}
string[] BindSelectedValues = null;

protected IEnumerable GetGroups() {
	var allData = GetLookupDataSource();
	var groupData = new Dictionary<string, IList<object>>();
	foreach (var data in allData) {
		var groupName = (DataBinder.Eval(data, GroupFieldName) as string) ?? (DefaultGroup??String.Empty);
		if (!groupData.ContainsKey(groupName))
			groupData[groupName] = new List<object>();
		groupData[groupName].Add(data);
	}
	return groupData;
}

</script>

<span id="<%=ClientID %>" class="checkBoxListEditor">

<asp:Repeater runat="server" id="groups" DataSource='<%# GetGroups() %>'>
	<ItemTemplate>
		<fieldset>
			<legend><%# AppContext.GetLabel( Convert.ToString( Eval("Key") ), null )%></legend>
			<NRecoWebForms:CheckBoxList runat="server" id="checkboxes" 
				DataTextField="<%# TextFieldName %>"
				DataValueField="<%# ValueFieldName %>"
				RepeatColumns="<%# RepeatColumns>0 ? RepeatColumns : 1 %>"
				RepeatLayout="<%# RepeatLayout %>"
				RepeatDirection="Horizontal"
				SelectedValues='<%# BindSelectedValues %>'
				DataSource='<%# Eval("Value") %>'/>
		</fieldset>
	</ItemTemplate>
</asp:Repeater>

</span>
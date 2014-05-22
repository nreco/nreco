<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.LookupEditorUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>

<script runat="server" language="c#">
public override object ValidationValue { 
	get { return checkboxes.SelectedValues.Length > 0 ? null : String.Join(",", checkboxes.SelectedValues); } 
}

public IEnumerable SelectedValues {
	get {
		return checkboxes.SelectedValues;
	}
	set {
		BindSelectedValues = value != null ? value.Cast<object>().Select(v => v.ToString()).ToArray() : new string[0];
	}
}
string[] BindSelectedValues = null;

</script>

<span id="<%=ClientID %>" class="checkBoxListEditor">
<NRecoWebForms:CheckBoxList runat="server" id="checkboxes" 
	DataTextField="<%# TextFieldName %>"
	DataValueField="<%# ValueFieldName %>"
	SelectedValues="<%# BindSelectedValues %>"
	DataSource='<%# GetLookupDataSource() %>'/>
</span>
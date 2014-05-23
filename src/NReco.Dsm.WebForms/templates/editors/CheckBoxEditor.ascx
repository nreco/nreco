<%@ Control Language="c#" Inherits="NReco.Dsm.WebForms.EditorUserControl" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script runat="server" language="c#">
public string Text { 
	get {
		return checkBox.Text;
	}
	set {
		checkBox.Text = value;
	}
}

public override object ValidationValue { get { return Checked ? (object)Checked : null; } }

public bool Checked {
	get {
		return checkBox.Checked;
	}
	set {
		checkBox.Checked = value;
	}
}
</script>
<span id="<%=ClientID %>" class="checkBoxEditor">
<asp:CheckBox id="checkBox" runat="server"/>
</span>
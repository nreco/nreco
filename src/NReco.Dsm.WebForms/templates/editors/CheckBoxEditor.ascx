<%@ Control Language="c#" Inherits="NReco.Dsm.WebForms.EditorUserControl" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<%@ Implements Interface="System.Web.UI.IEditableTextControl" %>
<script runat="server" language="c#">
public string LabelText { 
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

public string Text { 
	get {
		return Checked.ToString();
	}
	set {
		Checked = Convert.ToBoolean(value);
	}
}

public event EventHandler TextChanged;
protected void HandleValueChanged(object sender, EventArgs e) {
	if (TextChanged != null)
		TextChanged(this, EventArgs.Empty);
}

protected override void OnPreRender(EventArgs e) {
	if (TextChanged != null) {
		checkBox.AutoPostBack = true;
	}
	base.OnPreRender(e);
}
</script>
<span id="<%=ClientID %>" class="checkBoxEditor">
<asp:CheckBox id="checkBox" runat="server" OnCheckedChanged="HandleValueChanged"/>
</span>
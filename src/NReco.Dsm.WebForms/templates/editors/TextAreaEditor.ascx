<%@ Control Language="c#" Inherits="NReco.Dsm.WebForms.EditorUserControl" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<script runat="server" language="c#">
public bool EmptyIsNull { get; set; }

public Unit Width {
	get { return textbox.Width; }
	set { textbox.Width = value; }
}
public int Rows {
	get { return textbox.Rows; }
	set { textbox.Rows = value; }
}
public int Columns {
	get { return textbox.Columns; }
	set { textbox.Columns = value; }
}

public override object ValidationValue { get { return Text; } }

public string Text {
	get {
		if (EmptyIsNull && String.IsNullOrEmpty(textbox.Text))
			return null;
		return textbox.Text;
	}
	set {
		textbox.Text = value;
	}
}
</script>
<span id="<%=ClientID %>" class="textBoxEditor">
<asp:TextBox id="textbox" runat="server" TextMode='multiline'/>
</span>
<%@ Control Language="c#" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<script runat="server" language="c#">
public bool EmptyIsNull { get; set; }

public Unit Width {
	get { return textbox.Width; }
	set { textbox.Width = value; }
}

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
<asp:TextBox id="textbox" runat="server"/>
</span>
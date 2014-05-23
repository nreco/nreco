<%@ Control Language="c#" Inherits="NReco.Dsm.WebForms.EditorUserControl" AutoEventWireup="false" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Implements Interface="System.Web.UI.ITextControl" %>
<%@ Import Namespace="NI.Ioc" %>
<script runat="server" language="c#">
public string Text {
	get {
		if (String.IsNullOrEmpty(textbox.Text))
			return ViewState["passwordValue"] as string;
		return String.IsNullOrEmpty(PasswordEncrypterName) ? textbox.Text : PasswordEncrypter.Encrypt(textbox.Text);
	}
	set {
		ViewState["passwordValue"] = value;
		textbox.Text = String.Empty;
	}
}

public string PasswordEncrypterName { get; set; }

protected NReco.Application.Web.Security.IPasswordEncrypter PasswordEncrypter {
	get {
		return AppContext.ComponentFactory.GetComponent<NReco.Application.Web.Security.IPasswordEncrypter>(PasswordEncrypterName);
	}
}

public override object ValidationValue { get { return Text; } }

</script>
<span id="<%=ClientID %>" class="textBoxPasswordEditor">
<input type="hidden" id="<%=ClientID %>validate" value="<%=String.IsNullOrEmpty(Text) ? "" : "1"  %>"/>
<asp:TextBox id="textbox" runat="server" TextMode="Password" 
		onchange='<%# String.Format("password{0}_validate(this.value)",ClientID) %>' 
		onkeydown='<%# String.Format("password{0}_validate(this.value)",ClientID) %>'/>
<script type="text/javascript">
window.password<%=ClientID %>_validate = function(newPwd) {
	document.getElementById('<%=ClientID %>validate').value = newPwd.length>0 ? "1" : "<%=String.IsNullOrEmpty(Text) ? "" : "1"  %>";
}
</script>
</span>
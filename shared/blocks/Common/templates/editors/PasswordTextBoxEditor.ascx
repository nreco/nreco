<%@ Control Language="c#" AutoEventWireup="false" CodeFile="PasswordTextBoxEditor.ascx.cs" Inherits="PasswordTextBoxEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<span id="<%=ClientID %>" class="passwordTextBoxEditor">
	<input type="hidden" id="<%=ClientID %>validate" value="<%=String.IsNullOrEmpty(Value) ? "" : "1"  %>"/>
	<asp:TextBox id="textbox" runat="server" TextMode="Password" 
		onchange='<%# String.Format("password{0}_validate(this.value)",ClientID) %>' 
		onkeydown='<%# String.Format("password{0}_validate(this.value)",ClientID) %>'/>
	<script type="text/javascript">
	window.password<%=ClientID %>_validate = function(newPwd) {
		document.getElementById('<%=ClientID %>validate').value = newPwd.length>0 ? newPwd : "<%=String.IsNullOrEmpty(Value) ? "" : "1"  %>";
	}
	</script>
</span>
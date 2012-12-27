<%@ Control Language="c#" AutoEventWireup="false" CodeFile="NumberTextBoxEditor.ascx.cs" Inherits="NumberTextBoxEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<% if (PrefixText!=null) { %><%=PrefixText %><% } %>
<span id="<%=ClientID %>" class="numberTextBoxEditor">
<asp:TextBox id="textbox" runat="server"/>
<% if (SpinEnabled) { %>
<script type="text/javascript">
$(function() {
	$('#<%=textbox.ClientID %>').spin({
		<% if (SpinMax<Int32.MaxValue) { %>max: <%=SpinMax %>,<% } %>
		<% if (SpinMin>Int32.MinValue) { %>min: <%=SpinMin %>,<% } %>
		paramend:null
	});
});
</script>
<% } %>
</span>
<% if (SuffixText!=null) { %><%=SuffixText %><% } %>

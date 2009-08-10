<%@ Control Language="c#" AutoEventWireup="false" CodeFile="JGrowTextareaEditor.ascx.cs" Inherits="JGrowTextareaEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<span id="<%=ClientID %>">
	<asp:TextBox id="textarea" runat="server" Text='<%# Text %>' TextMode="multiline" Rows="<%# Rows>0 ? Rows : textarea.Rows %>" Columns="<%# Columns>0 ? Columns : textarea.Columns %>">
	</asp:TextBox>
	<script language="javascript">
	jQuery(function(){
		jQuery('#<%=textarea.ClientID %>').jGrow({
			<%= MaxHeight>0 ? "max_height : "+MaxHeight.ToString() : "" %>
		});
	});
	</script>
</span>
<%@ Control Language="c#" AutoEventWireup="false" CodeFile="FilterTextBoxEditor.ascx.cs" Inherits="FilterTextBoxEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<span id="<%=ClientID %>">
<input type="hidden" runat="server" id="textboxValue" value='<%# Text %>'/>
<asp:TextBox id="textbox" runat="server"/><asp:LinkButton id="lazyFilter" CausesValidation="true" runat="server" onclick="HandleLazyFilter"><img src="images/icons/search.png" alt="<%=this.GetLabel("Search") %>" title='<%=this.GetLabel("Search") %>'/></asp:LinkButton>
<script type="text/javascript">
jQuery(function(){
	if (<%=LazyFilterHandled.ToString().ToLower() %>)
		setTimeout( function() { jQuery('#<%=textbox.ClientID %>').focus(); }, 100 );

	var doFilter = function() {
		var textbox = jQuery('#<%=textbox.ClientID %>');
		if (textbox.attr('data-submitted'))
			return;
		textbox.attr('data-submitted', new Date() );
		setTimeout( function() {
			textbox[0].blur();
			<%=Page.ClientScript.GetPostBackEventReference(new PostBackOptions(lazyFilter) { PerformValidation = true, ValidationGroup =  lazyFilter.ValidationGroup },true) %>;
		}, 50 );
	};
		
	jQuery('#<%=lazyFilter.ClientID %>').click(function() {
		doFilter();
		return false;
	});
	jQuery('#<%=textbox.ClientID %>').keydown( function(e) {
		if (e.keyCode==13) {
			doFilter();
			return false;
		}
	} ).change( function() {
		doFilter();
	});
	
});
</script>
</span>
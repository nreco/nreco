<%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script language="c#" runat="server">
IProvider<string,string> _Prv;
public IProvider<string,string> Prv {
	get { return _Prv; }
	set { _Prv = value; }
}
</script>
<%=Prv.Provide(null) %>
<%=Prv %>
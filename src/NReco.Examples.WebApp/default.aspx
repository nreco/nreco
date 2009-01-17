<%@ Page Language="C#" MasterPageFile="~/Site.Master" Inherits="NReco.Web.Site.RoutePage" %>

<script runat="server" language="c#">
</script>

<asp:Content ContentPlaceHolderID="main" runat="server">
<%=WebManager.GetService<object>("db") %>
<br/>

<%@ Register TagPrefix="CTRL" Src="~/test.ascx" TagName="test"%>
<CTRL:test runat="server" Prv="<%$ service:aaa %>" Conn="<%$ service: db-DalcConnection %>"/>	   

<br/><%=WebManager.BasePath %><br/><%=WebManager.BaseUrl %><br/><%=RouteContext.RouteData.Values["var"] %>

</asp:Content>

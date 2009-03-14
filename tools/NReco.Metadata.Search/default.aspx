<%@ Page Language="C#" MasterPageFile="~/Site.Master" CodeFile="Default.aspx.cs" Inherits="Default" %>

<script runat="server" language="c#">
</script>

<asp:Content ContentPlaceHolderID="main" runat="server">

<h1>Welcome to NReco Metadata Search!</h1>

Statements: <%= RdfStore.StatementCount %>
<br/>
<pre>
<%=Result %>
</pre>

</asp:Content>

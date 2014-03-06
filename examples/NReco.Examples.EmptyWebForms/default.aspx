<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="NReco.Examples.EmptyWebForms._default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>NReco Example: Empty WebForms Application</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
		
		<%=NReco.Application.Web.AppContext.ComponentFactory.GetComponent("hello") %>
		<br />
		<%=DataBinder.Eval( Application["NReco.Application.Web.ContainerModule.ContainerConfiguration"], "Count") %>
    </div>
    </form>
</body>
</html>

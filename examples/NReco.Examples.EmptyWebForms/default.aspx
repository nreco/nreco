<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="NReco.Examples.EmptyWebForms._default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>NReco Example: Empty WebForms Application</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
		Component "hello":
		<%=NReco.Application.Web.AppContext.ComponentFactory.GetComponent("hello") %>
		<br />
		Component from file1.xml.config:
		<%=NReco.Application.Web.AppContext.ComponentFactory.GetComponent("file1") %>
		<br />
		Component from file2.xml.config:
		<%=NReco.Application.Web.AppContext.ComponentFactory.GetComponent("file2") %>
    </div>
    </form>
</body>
</html>

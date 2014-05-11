<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="NReco.Examples.EmptyWebForms._default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>NReco Example: CRUD</title>
</head>
<body>
    <form id="form1" runat="server">

	<asp:ScriptManager ID="scriptMgr" runat="server"
		AllowCustomErrorsRedirect="false">
	</asp:ScriptManager>	

    <div>
		<%@ Register TagPrefix="CTRL" TagName="BookList" Src="~/templates/generated/BookList.ascx" %>
		<CTRL:BookList runat="server" />
		
    </div>
    </form>
</body>
</html>

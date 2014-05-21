<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="NReco.Examples.EmptyWebForms._default" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>NReco Example: CRUD</title>
	<link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet"/>
	
	<script src="//code.jquery.com/jquery-2.1.1.min.js"></script>
	<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">

	<asp:ScriptManager ID="scriptMgr" runat="server"
		AllowCustomErrorsRedirect="false">
	</asp:ScriptManager>	

    <div class="container">
		<%@ Register TagPrefix="CTRL" TagName="BookList" Src="~/templates/generated/BookList.ascx" %>
		<CTRL:BookList runat="server" />
		
    </div>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="Site.Master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="main" runat="server">
		<%@ Register TagPrefix="CTRL" TagName="BookForm" Src="~/templates/generated/BookForm.ascx" %>
		<CTRL:BookForm runat="server" />
</asp:Content>

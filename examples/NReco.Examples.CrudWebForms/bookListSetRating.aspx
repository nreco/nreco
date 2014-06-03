<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="Site.Master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="main" runat="server">
		<%@ Register TagPrefix="CTRL" TagName="BookListSetRating" Src="~/templates/generated/BookListSetRating.ascx" %>
		<CTRL:BookListSetRating runat="server" />
</asp:Content>

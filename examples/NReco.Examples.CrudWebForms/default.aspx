<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="Site.Master" CodeBehind="default.aspx.cs" Inherits="NReco.Examples.EmptyWebForms._default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="main" runat="server">
		<%@ Register TagPrefix="CTRL" TagName="BookList" Src="~/templates/generated/BookList.ascx" %>
		<CTRL:BookList runat="server" />
</asp:Content>

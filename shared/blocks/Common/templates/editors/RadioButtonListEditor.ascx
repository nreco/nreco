<%@ Control Language="c#" AutoEventWireup="false" CodeFile="RadioButtonListEditor.ascx.cs" Inherits="RadioButtonListEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<span id="<%=ClientID %>">
<asp:RadioButtonList runat="server" id="radiobuttonlist" 
	RepeatLayout="Flow"
	DataSource='<%# Visible && !String.IsNullOrEmpty(LookupName) ? DataSourceHelper.GetProviderDataSource(LookupName, DataContext) : null %>'
	DataValueField="<%# ValueFieldName %>"
	DataTextField="<%# TextFieldName %>"
	OnSelectedIndexChanged="HandleSelectedIndexChanged">
</asp:RadioButtonList>
</span>
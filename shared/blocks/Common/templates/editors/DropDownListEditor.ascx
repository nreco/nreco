<%@ Control Language="c#" AutoEventWireup="false" CodeFile="DropDownListEditor.ascx.cs" Inherits="DropDownListEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>
<span id="<%=ClientID %>" class="dropDownListEditor">
<NReco:DropDownList runat="server" id="dropdownlist" 
	SelectedValue='<%# SelectedValue %>'
	DataSource='<%# Visible && !String.IsNullOrEmpty(LookupName) ? DataSourceHelper.GetProviderDataSource(LookupName, DataContext) : null %>'
	DataValueField="<%# ValueFieldName %>"
	DataTextField="<%# TextFieldName %>"
	Enabled='<%# Enabled %>'
	DefaultItemText='<%# Required ? null : WebManager.GetLabel(NotSelectedText,this) %>'
	DefaultItemValue='<%# Required ? "" : NotSelectedValue %>'
	OnSelectedIndexChanged="HandleSelectedIndexChanged">
</NReco:DropDownList>
</span>
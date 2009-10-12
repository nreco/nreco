<%@ Control Language="c#" AutoEventWireup="false" CodeFile="DropDownListEditor.ascx.cs" Inherits="DropDownListEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<NReco:DropDownList runat="server" id="dropdownlist" 
	AutoPostBack="<%# FindFilter()!=null %>"
	SelectedValue='<%# SelectedValue %>'
	DataSource='<%# Visible ? DataSourceHelper.GetProviderDataSource(LookupName, DataContext) : null %>'
	DataValueField="<%# ValueFieldName %>"
	DataTextField="<%# TextFieldName %>"
	DefaultItemText='<%# Required ? null : WebManager.GetLabel("-- not selected --",this) %>'
	DefaultItemValue='<%# Required ? "" : null %>'
	OnSelectedIndexChanged="HandleSelectedIndexChanged">
</NReco:DropDownList>

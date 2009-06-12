<%@ Control Language="c#" AutoEventWireup="false" CodeFile="DropDownListEditor.ascx.cs" Inherits="DropDownListEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<NReco:DropDownList runat="server" id="dropdownlist" 
	SelectedValue='<%# SelectedValue %>'
	DataSource='<%# DataSourceHelper.GetProviderDataSource(LookupName, DataContext) %>'
	DataValueField="<%# ValueFieldName %>"
	DataTextField="<%# TextFieldName %>"
	DefaultItemText='<%# Required ? null : "-- not selected --" %>'
	DefaultItemValue='<%# Required ? "" : null %>'>
</NReco:DropDownList>

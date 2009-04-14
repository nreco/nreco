<%@ Control Language="c#" AutoEventWireup="false" CodeFile="CheckBoxListRelationEditor.ascx.cs" Inherits="CheckBoxListRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<NReco:CheckBoxList runat="server" id="checkboxes" 
	DataTextField="Value"
	DataValueField="Key"
	RepeatColumns="3"
	SelectedValues='<%# GetSelectedIds() %>'
	DataSource='<%# WebManager.GetService<IProvider<object,IDictionary>>(LookupServiceName).Provide(null) %>'/>

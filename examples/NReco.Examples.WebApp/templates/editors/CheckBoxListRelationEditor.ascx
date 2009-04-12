<%@ Control Language="c#" AutoEventWireup="false" CodeFile="CheckBoxListRelationEditor.ascx.cs" Inherits="CheckBoxListRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>


<Dalc:DalcDataSource runat="server" id="accountsDataSource" 
	Dalc='<%$ service:db %>' SourceName="accounts"/>

<NReco:CheckBoxList runat="server" id="checkboxes" 
	DataTextField="username"
	DataValueField="id"
	RepeatColumns="3"
	SelectedValues='<%# GetSelectedIds() %>'
	DataSourceID="accountsDataSource"/>

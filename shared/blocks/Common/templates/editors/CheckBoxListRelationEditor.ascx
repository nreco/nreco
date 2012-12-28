<%@ Control Language="c#" AutoEventWireup="false" CodeFile="CheckBoxListRelationEditor.ascx.cs" Inherits="CheckBoxListRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<span id="<%=ClientID %>" class="checkBoxListRelationEditor">
<NReco:CheckBoxList runat="server" id="checkboxes" 
	DataTextField="<%# TextFieldName %>"
	DataValueField="<%# ValueFieldName %>"
	SelectedValues='<%# GetSelectedIds() %>'
	DataSource='<%# GetDataSource() %>'/>
</span>
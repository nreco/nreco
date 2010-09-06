<%@ Control Language="c#" AutoEventWireup="false" CodeFile="GroupedCheckBoxListRelationEditor.ascx.cs" Inherits="GroupedCheckBoxListRelationEditor" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<asp:Repeater runat="server" id="groups" DataSource='<%# GetGroups() %>'>
	<ItemTemplate>
		<fieldset>
			<legend><%# WebManager.GetLabel( Convert.ToString( Eval("Key") ) ) %></legend>
			<NReco:CheckBoxList runat="server" id="checkboxes" 
				DataTextField="<%# TextFieldName %>"
				DataValueField="<%# ValueFieldName %>"
				RepeatColumns="<%# RepeatColumns>0 ? RepeatColumns : 1 %>"
				RepeatLayout="<%# RepeatLayout %>"
				RepeatDirection="Horizontal"
				SelectedValues='<%# GetSelectedIds() %>'
				DataSource='<%# Eval("Value") %>'/>
		</fieldset>
	</ItemTemplate>
</asp:Repeater>


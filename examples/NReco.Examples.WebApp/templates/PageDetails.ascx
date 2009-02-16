<%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Web.ActionUserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Import namespace="System.Data" %>
<%@ Import namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="Dalc" Namespace="NI.Data.Dalc.Web" assembly="NI.Data.Dalc" %>

<script language="c#" runat="server">
protected override void OnLoad(EventArgs e) {
	var context = this.GetPageContext();
	if (context.ContainsKey("title")) {
		pagesDataSource.Condition = (QField)"title"==new QConst(context["title"]);
	} else  {
		FormView.DefaultMode = FormViewMode.Insert;
	} 
	base.OnLoad(e);
}
public void FormViewInsertedHandler(object sender, FormViewInsertedEventArgs e) {
	// ActionDataSource used that configured for transactional processing.
	// so immediate redirect will cause transaction rollback. Lets just register redirect - ActionDispatcher will take care.
	Response.Redirect( this.GetRouteUrl("pageDetails", e.Values), false);
}

public void DataSelectedHandler(object sender, DalcDataSourceSelectEventArgs e) {
	if (e.Data.Tables[e.SelectQuery.SourceName].Rows.Count==0) {
		FormView.ChangeMode(FormViewMode.Insert);
	}
}

public void DataBoundHandler(object sender, EventArgs e) {
	if (FormView.CurrentMode==FormViewMode.Insert && this.GetPageContext().ContainsKey("title") ) {
		((TextBox)FormView.FindControl("title")).Text = Convert.ToString( this.GetPageContext()["title"] );
	}
}

protected string PrepareContent(object contentType, object o) {
	var parsers = WebManager.GetService<IDictionary<string,IProvider<string,string>>>("pageTypeParsers");
	if (parsers.ContainsKey(contentType.ToString()))
		return parsers[ contentType.ToString() ].Provide( Convert.ToString(o) );
	return Convert.ToString(o);
}
</script>

<Dalc:DalcDataSource runat="server" id="pagesDataSource" 
	Dalc='<%$ service:db %>' SourceName="pages"
	OnSelected='DataSelectedHandler'/>
<NReco:ActionDataSource runat="server" id="actionPagesEntitySource" DataSourceID="pagesDataSource"/>

<Dalc:DalcDataSource runat="server" id="accountsDataSource" 
	Dalc='<%$ service:db %>' SourceName="accounts"/>

<asp:UpdatePanel runat="server" UpdateMode="Conditional">
	<ContentTemplate>

<fieldset>

<!--	
	onitemdeleted="FormViewDeletedHandler"
	onitemupdated="FormViewUpdatedHandler"-->


<asp:formview id="FormView"
	oniteminserted="FormViewInsertedHandler"
	ondatabound="DataBoundHandler"
	datasourceid="actionPagesEntitySource"
	allowpaging="false"
	datakeynames="id"
	Width="100%"
	runat="server">
		
<itemtemplate>
	<legend>Page: <%# Eval("title") %></legend>
	<div>
	<%# PrepareContent( Eval("content_type"), Eval("content") ) %>
	</div>
	<div class="toolboxContainer buttons">
		<span class="Edit">
			<asp:linkbutton id="Edit" text="Edit" commandname="Edit" runat="server"/> 
		</span>
		<span class="Delete">
			<asp:linkbutton id="Delete" text="Delete" commandname="Delete" runat="server"/> 
		</span>
	</div>
</itemtemplate>

<edititemtemplate>
	<legend>Edit Page</legend>
	<table class="FormView" width="100%">
		<tr>
			<th>Title:</th>
			<td>
				<asp:TextBox id="title" runat="server" Text='<%# Bind("title") %>'/>
				<asp:requiredfieldvalidator runat="server" Display="Dynamic"
					ErrorMessage="<%$ label: Required Field %>" controltovalidate="title" EnableClientScript="true"/>				
			</td>
		</tr>
		<tr>
			<th>Content Type:</th>
			<td>
				<asp:DropDownList runat="server" id="content_type" SelectedValue='<%# Bind("content_type") %>'
					DataSource='<%# WebManager.GetService<IDictionary<string,string>>("pageTypes") %>'
					DataValueField="Key"
					DataTextField="Value"/>
			</td>
		</tr>
		<tr>
			<th>Visibility:</th>
			<td>
				<asp:CheckBoxList runat="server" id="visibility" 
					DataTextField="username"
					DataValueField="id"
					RepeatColumns="3"
					DataSourceID="accountsDataSource"/>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<asp:TextBox id="content" TextMode="multiline" runat="server" Text='<%# Bind("content") %>'/>
			</td>
		</tr>	
	</table>
	<div class="toolboxContainer buttons">
		<asp:Placeholder runat="server" Visible='<%# FormView.CurrentMode==FormViewMode.Edit %>'>
			<span class="Save">	
				<asp:linkbutton id="Update" text="Save" commandname="Update" runat="server"/> 
			</span>
			<span class="Cancel">
				<asp:linkbutton id="Cancel" text="Cancel" commandname="Cancel" runat="server" CausesValidation="false"/> 			
			</span>
		</asp:Placeholder>
		
		<asp:Placeholder runat="server" Visible='<%# FormView.CurrentMode==FormViewMode.Insert %>'>
			<span class="Save">	
				<asp:linkbutton id="Insert" text="<%$ label: Create %>" commandname="Insert" runat="server"/> 	
			</span>
		</asp:Placeholder>
	</div>
</edititemtemplate>


</asp:formview>

</fieldset>

	</ContentTemplate>
</asp:UpdatePanel>
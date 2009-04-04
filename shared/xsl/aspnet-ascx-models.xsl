<xsl:stylesheet version='1.0' 
				xmlns:e="urn:schemas-nreco:nreco:entity:v1"
				xmlns:l="urn:schemas-nreco:nreco:web:layout:v1"
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:Dalc="urn:remove"
				xmlns:NReco="urn:remove"
				xmlns:asp="urn:remove"
				exclude-result-prefixes="msxsl">

	<xsl:output method='xml' indent='yes' />
	
	<xsl:variable name="dalcName" select="/components/dalc/@name"/>
	<xsl:variable name="entities" select="/components/entities"/>
	
	<xsl:template name="getEntityIdFields">
		<xsl:param name="name"/>
		<xsl:for-each select="$entities/e:entity[@name=$name]/e:field[@pk='true' or @pk='1']">
			<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="getEntityAutoincrementFields">
		<xsl:param name="name"/>
		<xsl:for-each select="$entities/e:entity[@name=$name]/e:field[@type='autoincrement']">
			<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
		</xsl:for-each>
	</xsl:template>	
	
	<xsl:template match='/components'>
		<files>
			<xsl:apply-templates select="l:views/*"/>
		</files>
	</xsl:template>
	
	<xsl:template match="l:form">
		<file name="templates/generated/{@name}.ascx">
			<content>
<!-- form control header -->
@@lt;%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %@@gt;

				<xsl:variable name="mainDsId">
					<xsl:choose>
						<xsl:when test="@datasource"><xsl:value-of select="@datasource"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="l:datasources/l:*[position()=1]/@id"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:apply-templates select="l:datasources/l:*" mode="form-view-datasource"/>
				<NReco:ActionDataSource runat="server" id="mainActionDataSource" DataSourceID="{$mainDsId}"/>

				<script language="c#" runat="server">
				public void FormViewInsertedHandler(object sender, FormViewInsertedEventArgs e) {
					<xsl:apply-templates select="l:action[@name='inserted']/l:*" mode="csharp-code">
						<xsl:with-param name="context">e.Values</xsl:with-param>
					</xsl:apply-templates>
				}
				protected override void OnLoad(EventArgs e) {
					var context = this.GetPageContext();
					if (context.ContainsKey("id")) {
						<xsl:value-of select="$mainDsId"/>.Condition = (QField)"id" == new QConst(context["id"]);
					} else {
						FormView.DefaultMode = FormViewMode.Insert;
					}
					base.OnLoad(e);
				}
				</script>
				
				<xsl:apply-templates select="." mode="form-view">
					<xsl:with-param name="mainDsId" select="$mainDsId"/>
				</xsl:apply-templates>
			</content>
		</file>
	</xsl:template>
	
	<xsl:template match="l:redirect" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="url">
			<xsl:choose>
				<xsl:when test="@url">"<xsl:value-of select="@url"/>"</xsl:when>
				<xsl:when test="count(l:*)>0">
					<xsl:apply-templates select="l:*" mode="csharp-string-expr">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise><xsl:message terminate = "yes">Redirect URL is required</xsl:message></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		Response.Redirect(<xsl:value-of select="$url"/>, false);
	</xsl:template>
	
	<xsl:template match="l:route" mode="csharp-string-expr">
		<xsl:param name="context"/>
		this.GetRouteUrl("<xsl:value-of select="@name"/>", NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;(<xsl:value-of select="$context"/>) )
	</xsl:template>
	
	<xsl:template match="l:form[not(@update-panel) or @update-panel='true' or @update-panel='1']" name="layout-update-panel-form" mode="form-view">
		<xsl:param name="mainDsId"/>
		<asp:UpdatePanel runat="server" UpdateMode="Conditional">
			<ContentTemplate>
				<xsl:call-template name="layout-form">
					<xsl:with-param name="mainDsId" select="$mainDsId"/>
				</xsl:call-template>
			</ContentTemplate>
		</asp:UpdatePanel>
	</xsl:template>
	
	<xsl:template match="l:form" name="layout-form" mode="form-view">
		<xsl:param name="mainDsId"/>
		<xsl:variable name="caption" select="@caption"/>
		<fieldset>
			<asp:formview id="FormView"
				oniteminserted="FormViewInsertedHandler"
				datasourceid="mainActionDataSource"
				allowpaging="false"
				Width="100%"
				runat="server">
				<xsl:attribute name="datakeynames">
					<!-- tmp solution for dalc ds only -->
					<xsl:call-template name="getEntityIdFields"><xsl:with-param name="name" select="l:datasources/l:*[@id=$mainDsId]/@sourcename"/></xsl:call-template>
				</xsl:attribute>
				
				<itemtemplate>
					<legend><xsl:value-of select="$caption"/></legend>
					
					<table class="FormView" width="100%">
						<xsl:apply-templates select="l:field" mode="plain-form-view-table-row"/>
					</table>
					
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
					<legend>Edit <xsl:value-of select="$caption"/></legend>
					<table class="FormView" width="100%">
						<xsl:apply-templates select="l:field" mode="edit-form-view-table-row"/>
					</table>
					<div class="toolboxContainer buttons">
						<span class="Save">	
							<asp:linkbutton id="Update" text="@@lt;%$ label: Save %@@gt;" commandname="Update" runat="server"/> 
						</span>
						<span class="Cancel">
							<asp:linkbutton id="Cancel" text="@@lt;%$ label: Cancel %@@gt;" commandname="Cancel" runat="server" CausesValidation="false"/> 
						</span>
					</div>
				</edititemtemplate>
				<insertitemtemplate>
					<legend>Create <xsl:value-of select="$caption"/></legend>
					<table class="FormView" width="100%">
						<xsl:apply-templates select="l:field" mode="edit-form-view-table-row"/>
					</table>
					<div class="toolboxContainer buttons">
						<span class="Save">	
							<asp:linkbutton id="Insert" text="@@lt;%$ label: Create %@@gt;" commandname="Insert" runat="server"/> 	
						</span>
					</div>					
				</insertitemtemplate>

			</asp:formview>
			
		</fieldset>
	</xsl:template>
	
	<xsl:template match="l:field" mode="plain-form-view-table-row">
		<tr>
			<th><xsl:value-of select="@caption"/>:</th>
			<td>
				<xsl:apply-templates select="." mode="form-view-renderer"/>
			</td>
		</tr>		
	</xsl:template>

	<xsl:template match="l:field" mode="edit-form-view-table-row">
		<tr>
			<th><xsl:value-of select="@caption"/>:</th>
			<td>
				<xsl:apply-templates select="." mode="form-view-editor"/>
				<xsl:apply-templates select="." mode="form-view-validator"/>
			</td>
		</tr>		
	</xsl:template>
	
	<xsl:template match="l:field" mode="form-view-renderer">
		@@lt;%# Eval("<xsl:value-of select="@name"/>") %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:textbox]" mode="form-view-editor">
		<asp:TextBox id="{@name}" runat="server" Text='@@lt;%# Bind("{@name}") %@@gt;'/>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:dropdownlist]" mode="form-view-editor">
		<xsl:variable name="lookupPrvName" select="l:editor/l:dropdownlist/@lookup"/>
		<xsl:variable name="valueName">
			<xsl:choose>
				<xsl:when test="l:editor/l:dropdownlist/@value"><xsl:value-of select="l:editor/l:dropdownlist/@value"/></xsl:when>
				<xsl:otherwise>Key</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="textName">
			<xsl:choose>
				<xsl:when test="l:editor/l:dropdownlist/@text"><xsl:value-of select="l:editor/l:dropdownlist/@text"/></xsl:when>
				<xsl:otherwise>Value</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<asp:DropDownList runat="server" id="{@name}" SelectedValue='@@lt;%# Bind("{@name}") %@@gt;'
			DataSource='@@lt;%# WebManager.GetService@@lt;IProvider@@lt;object,IEnumerable@@gt;@@gt;("{$lookupPrvName}").Provide(null) %@@gt;'
			DataValueField="{$valueName}"
			DataTextField="{$textName}"/>
	</xsl:template>

	
	<xsl:template match="l:field" mode="form-view-validator">
		<xsl:apply-templates select="l:editor/l:validators/*" mode="form-view-validator">
			<xsl:with-param name="controlId" select="@name"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:required" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<asp:requiredfieldvalidator runat="server" Display="Dynamic"
			ErrorMessage="@@lt;%$ label: Required Field %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true"/>	
	</xsl:template>

	<xsl:template match="l:regex" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationExpression="{.}"
			ErrorMessage="@@lt;%$ label: Invalid value %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true"/>	
	</xsl:template>
	
	<xsl:template match="l:dalc" mode="form-view-datasource">
		<xsl:variable name="dataSourceId" select="@id"/>
		<xsl:variable name="sourceName" select="@sourcename"/>
		
		<Dalc:DalcDataSource runat="server" id="{@id}" 
			Dalc='&lt;%$ service:{$dalcName} %>' SourceName="{$sourceName}" DataSetMode="true">
			<xsl:attribute name="DataKeyNames">
				<xsl:call-template name="getEntityIdFields"><xsl:with-param name="name" select="$sourceName"/></xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="AutoIncrementNames">
				<xsl:call-template name="getEntityAutoincrementFields"><xsl:with-param name="name" select="$sourceName"/></xsl:call-template>
			</xsl:attribute>
		</Dalc:DalcDataSource>
	</xsl:template>
	
	<xsl:template match="l:list">
		<file name="templates/generated/{@name}.ascx">
			<content>
<!-- form control header -->
@@lt;%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %@@gt;

				<xsl:variable name="mainDsId">
					<xsl:choose>
						<xsl:when test="@datasource"><xsl:value-of select="@datasource"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="l:datasources/l:*[position()=1]/@id"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:apply-templates select="l:datasources/l:*" mode="form-view-datasource"/>
				<NReco:ActionDataSource runat="server" id="mainActionDataSource" DataSourceID="{$mainDsId}"/>

				<script language="c#" runat="server">
				</script>
				
				<xsl:apply-templates select="." mode="list-view">
					<xsl:with-param name="mainDsId" select="$mainDsId"/>
				</xsl:apply-templates>
			</content>
		</file>
	</xsl:template>
	
	<xsl:template match="l:list[not(@update-panel) or @update-panel='true' or @update-panel='1']" name="layout-update-panel-list" mode="list-view">
		<xsl:param name="mainDsId"/>
		<asp:UpdatePanel runat="server" UpdateMode="Conditional">
			<ContentTemplate>
				<xsl:call-template name="layout-list">
					<xsl:with-param name="mainDsId" select="$mainDsId"/>
				</xsl:call-template>
			</ContentTemplate>
		</asp:UpdatePanel>
	</xsl:template>
	
	<xsl:template match="l:list" name="layout-list" mode="form-view">
		<xsl:param name="mainDsId"/>
		<xsl:variable name="caption" select="@caption"/>
		<h1><xsl:value-of select="$caption"/></h1>
		
		<asp:ListView ID="listView"
			DataSourceID="{$mainDsId}"
			DataKeyNames="id"
			ItemContainerID="itemPlaceholder"
			runat="server">
			<LayoutTemplate>
				<table class="listView">
					<tr>
						<xsl:apply-templates select="l:field" mode="list-view-table-header"/>
					</tr>
					<tr runat="server" id="itemPlaceholder" />
				</table>
				<table class="pager"><tr><td>
				  <asp:DataPager ID="DataPager1" runat="server">
					<Fields>
					  <asp:NumericPagerField />
					</Fields>
				  </asp:DataPager>
				</td></tr></table>
			</LayoutTemplate>
			<ItemTemplate>
				<tr>
					<xsl:apply-templates select="l:field" mode="list-view-table-cell"/>
				</tr>
			</ItemTemplate>
		</asp:ListView>
	</xsl:template>
	
	<xsl:template match="l:field[(@sort='true' or @sort='1') and @name]" mode="list-view-table-header">
		<th><asp:LinkButton runat="server" Text="{@caption}" CommandName="Sort" CommandArgument="{@name}"/></th>
	</xsl:template>
	
	<xsl:template match="l:field" mode="list-view-table-header">
		<th>
			<xsl:choose>
				<xsl:when test="@caption"><xsl:value-of select="@caption"/></xsl:when>
				<xsl:otherwise>@@nbsp;</xsl:otherwise>
			</xsl:choose>
		</th>
	</xsl:template>

	<xsl:template match="l:field[@name]" mode="list-view-table-cell">
		<td>
			@@lt;%# Eval("<xsl:value-of select="@name"/>") %@@gt;
		</td>
	</xsl:template>

	<xsl:template match="l:field[not(@name)]" mode="list-view-table-cell">
		<td>
			<xsl:for-each select="l:*">
				<xsl:if test="position()!=1">@@nbsp;</xsl:if>
				<xsl:apply-templates select="." mode="list-view-renderer"/>
			</xsl:for-each>
		</td>
	</xsl:template>

	<xsl:template match="l:linkbutton" mode="list-view-renderer">
		<asp:LinkButton runat="server" Text="{@caption}" CommandName="{@command}" />
	</xsl:template>
	
	<xsl:template match="l:link" mode="list-view-renderer">
		<xsl:variable name="url">
			<xsl:choose>
				<xsl:when test="@url">"<xsl:value-of select="@url"/>"</xsl:when>
				<xsl:when test="count(l:url/l:*)>0">
					<xsl:apply-templates select="l:url/l:*" mode="csharp-string-expr">
						<xsl:with-param name="context">Container.DataItem</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<a href="@@lt;%# {$url} %@@gt;" runat="server"><xsl:value-of select="@caption"/></a>
	</xsl:template>
	
</xsl:stylesheet>
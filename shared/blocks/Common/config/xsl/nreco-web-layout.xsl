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
	
	<xsl:variable name="dalcName" select="/components/default/services/dalc/@name"/>
	<xsl:variable name="datasetFactoryName" select="/components/default/services/datasetfactory/@name"/>
	<xsl:variable name="entities" select="/components/entities"/>
	<xsl:variable name="formDefaults" select="/components/default/form"/>

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
	<xsl:template name="view-register-controls">
		<xsl:for-each select=".//l:field[l:editor]">
			<xsl:variable name="editorName" select="name(l:editor/l:*[position()=1])"/>
			<xsl:if test="count(preceding-sibling::l:field/l:editor/l:*[name()=$editorName])=0">
				<xsl:apply-templates select="." mode="register-editor-control"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="text()" mode="register-editor-control">
	<!-- skip editors without registration -->
	</xsl:template>
	
	<xsl:template match='/components'>
		<files>
			<xsl:apply-templates select="l:views/*"/>
		</files>
	</xsl:template>
	
	<xsl:template match="l:view">
		<file name="templates/generated/{@name}.ascx">
			<content>
<!-- form control header -->
@@lt;%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %@@gt;

				<xsl:call-template name="view-register-controls"/>
				<xsl:if test="@databind='onload'">
					<script language="c#" runat="server">
					protected override void OnLoad(EventArgs e) {
						base.OnLoad(e);
						if (!IsPostBack)
							DataBind();
					}
					</script>
				</xsl:if>
				<xsl:apply-templates select="l:datasources/l:*" mode="view-datasource"/>
				<div class="dashboard">
					<xsl:apply-templates select="l:*" mode="aspnet-renderer"/>
				</div>
			</content>
		</file>
	</xsl:template>
	
	<xsl:template match="l:redirect" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="url">
			<xsl:choose>
				<xsl:when test="@url">"<xsl:value-of select="@url"/>"</xsl:when>
				<xsl:when test="count(l:*)>0">
					<xsl:apply-templates select="l:*" mode="csharp-expr">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise><xsl:message terminate = "yes">Redirect URL is required</xsl:message></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		Response.Redirect(<xsl:value-of select="$url"/>, false);
	</xsl:template>

	<xsl:template match="l:set" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="valExpr">
			<xsl:apply-templates select="l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:value-of select="$context"/>["<xsl:value-of select="@name"/>"] = <xsl:value-of select="$valExpr"/>;
	</xsl:template>
	
	<xsl:template match="l:route" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:variable name="routeContext">
			<xsl:choose>
				<xsl:when test="count(l:*)>0"><xsl:apply-templates select="l:*" mode="csharp-expr"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$context"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		this.GetRouteUrl("<xsl:value-of select="@name"/>", NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;(<xsl:value-of select="$routeContext"/>) )
	</xsl:template>
	
	<xsl:template match="l:pagecontext" mode="csharp-expr">
		this.GetPageContext()["<xsl:value-of select="@name"/>"]
	</xsl:template>

	<xsl:template match="l:request" mode="csharp-expr">
		Request["<xsl:value-of select="@name"/>"]
	</xsl:template>
	
	<xsl:template match="l:format" name="format-csharp-expr" mode="csharp-expr">
		<xsl:param name="str" select="@str"/>
		String.Format("<xsl:value-of select="$str"/>" <xsl:for-each select="l:*">,<xsl:apply-templates select="." mode="csharp-expr"/></xsl:for-each>)
	</xsl:template>

	<xsl:template match="l:lookup" name="lookup-csharp-expr" mode="csharp-expr">
		<xsl:param name="service" select="@service"/>
		WebManager.GetService@@lt;IProvider@@lt;object,object@@gt;@@gt;("<xsl:value-of select="@service"/>").Provide( <xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"/> )
	</xsl:template>
	
	<xsl:template match="l:get" name="get-csharp-code" mode="csharp-expr">
		<xsl:param name="context"></xsl:param>
		<xsl:choose>
			<xsl:when test="not($context='')">NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;(<xsl:value-of select="$context"/>)["<xsl:value-of select="@name"/>"]</xsl:when>
			<xsl:otherwise>Eval("<xsl:value-of select="@name"/>")</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="l:dictionary" name="dictionary-csharp-code" mode="csharp-expr">
		<xsl:variable name="entries">
			<xsl:for-each select="l:entry">
				<xsl:if test="position()!=1">,</xsl:if>
				{"<xsl:value-of select="@key"/>", <xsl:apply-templates select="l:*" mode="csharp-expr"/>}
			</xsl:for-each>
		</xsl:variable>
		new Dictionary@@lt;string,object@@gt;{<xsl:value-of select="$entries"/>}
	</xsl:template>
	
	<xsl:template match="l:form" name="layout-form" mode="aspnet-renderer">
		<xsl:variable name="mainDsId">
			<xsl:choose>
				<xsl:when test="@datasource"><xsl:value-of select="@datasource"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="l:datasource/l:*[position()=1]/@id"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="uniqueId" select="generate-id(.)"/>
		
		<xsl:apply-templates select="l:datasource/l:*" mode="view-datasource">
			<xsl:with-param name="viewType">FormView</xsl:with-param>
		</xsl:apply-templates>
		<NReco:ActionDataSource runat="server" id="form{$uniqueId}ActionDataSource" DataSourceID="{$mainDsId}"/>

		<script language="c#" runat="server">
		public void FormView_<xsl:value-of select="$uniqueId"/>_InsertedHandler(object sender, FormViewInsertedEventArgs e) {
			if (e.Exception==null || e.ExceptionHandled) {
				<xsl:apply-templates select="l:action[@name='inserted']/l:*" mode="csharp-code">
					<xsl:with-param name="context">e.Values</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_DeletedHandler(object sender, FormViewDeletedEventArgs e) {
			if (e.Exception==null || e.ExceptionHandled) {
				<xsl:apply-templates select="l:action[@name='deleted']/l:*" mode="csharp-code">
					<xsl:with-param name="context">e.Values</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		
		protected bool FormView_<xsl:value-of select="$uniqueId"/>_IsDataRowAdded(object o) {
			DataRow r = null;
			if (o is DataRow) r = (DataRow)o;
			else if (o is DataRowView) r = ((DataRowView)o).Row;
			return r!=null ? r.RowState==DataRowState.Added : false;
		}
		
		protected void FormView_<xsl:value-of select="$uniqueId"/>_DataBound(object sender, EventArgs e) {
			var FormView = (NReco.Web.Site.Controls.FormView)sender;
			if (FormView.DataItemCount==0 || FormView_<xsl:value-of select="$uniqueId"/>_IsDataRowAdded(FormView.DataItem) ) {
				FormView.InsertDataItem = FormView.DataItem;
				FormView.ChangeMode(FormViewMode.Insert);
			}
		}
		</script>
		
		<xsl:variable name="caption" select="@caption"/>
		<xsl:variable name="viewFormButtons">
			<xsl:choose>
				<xsl:when test="l:buttons"><xsl:copy-of select="l:buttons[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formDefaults/l:buttons[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="addFormButtons">
			<xsl:choose>
				<xsl:when test="l:buttons"><xsl:copy-of select="l:buttons[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formDefaults/l:buttons[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="editFormButtons">
			<xsl:choose>
				<xsl:when test="l:buttons"><xsl:copy-of select="l:buttons[@edit='true' or @edit='1' or not(@edit)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formDefaults/l:buttons[@edit='true' or @edit='1' or not(@edit)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<fieldset>
			<NReco:formview id="FormView{$uniqueId}"
				oniteminserted="FormView_{$uniqueId}_InsertedHandler"
				onitemdeleted="FormView_{$uniqueId}_DeletedHandler"
				ondatabound="FormView_{$uniqueId}_DataBound"
				datasourceid="form{$uniqueId}ActionDataSource"
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
						<xsl:apply-templates select="l:field[not(@view) or @view='true' or @view='1']" mode="plain-form-view-table-row"/>
					</table>
					
					<div class="toolboxContainer buttons">
						<xsl:for-each select="msxsl:node-set($viewFormButtons)/node()">
							<span>
								<xsl:if test="@icon">
									<span class="{@icon}"></span>
								</xsl:if>
								<xsl:if test="@command">
									<xsl:attribute name="class"><xsl:value-of select="@command"/></xsl:attribute>
								</xsl:if>
								<xsl:apply-templates select="." mode="aspnet-renderer">
									<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								</xsl:apply-templates>
							</span>
						</xsl:for-each>
					</div>
				</itemtemplate>
				<edititemtemplate>
					<legend>Edit <xsl:value-of select="$caption"/></legend>
					<table class="FormView" width="100%">
						<xsl:apply-templates select="l:field[not(@edit) or @edit='true' or @edit='1']" mode="edit-form-view-table-row">
							<xsl:with-param name="mode">edit</xsl:with-param>
						</xsl:apply-templates>
					</table>
					
					<div class="toolboxContainer buttons">
						<xsl:for-each select="msxsl:node-set($editFormButtons)/node()">
							<span>
								<xsl:if test="@icon">
									<span class="{@icon}"></span>
								</xsl:if>
								<xsl:if test="@command">
									<xsl:attribute name="class"><xsl:value-of select="@command"/></xsl:attribute>
								</xsl:if>
								<xsl:apply-templates select="." mode="aspnet-renderer">
									<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								</xsl:apply-templates>
							</span>
						</xsl:for-each>
					</div>
				
				</edititemtemplate>
				<insertitemtemplate>
					<legend>Create <xsl:value-of select="$caption"/></legend>
					<table class="FormView" width="100%">
						<xsl:apply-templates select="l:field[not(@add) or @add='true' or @add='1']" mode="edit-form-view-table-row">
							<xsl:with-param name="mode">add</xsl:with-param>
						</xsl:apply-templates>
					</table>
					<div class="toolboxContainer buttons">
						<xsl:for-each select="msxsl:node-set($addFormButtons)/node()">
							<span>
								<xsl:if test="@icon">
									<span class="{@icon}"></span>
								</xsl:if>
								<xsl:if test="@command">
									<xsl:attribute name="class"><xsl:value-of select="@command"/></xsl:attribute>
								</xsl:if>
								<xsl:apply-templates select="." mode="aspnet-renderer">
									<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								</xsl:apply-templates>
							</span>
						</xsl:for-each>
					</div>
				</insertitemtemplate>

			</NReco:formview>
			
		</fieldset>
	</xsl:template>
	
	<xsl:template match="l:field[not(@layout) or @layout='horizontal']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<tr class="horizontal">
			<th>
					<xsl:value-of select="@caption"/>:
			</th>
			<td>
				<xsl:apply-templates select="." mode="aspnet-renderer">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context">Container.DataItem</xsl:with-param>
				</xsl:apply-templates>
			</td>
		</tr>		
	</xsl:template>

	<xsl:template match="l:field[@layout='vertical']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:if test="@caption">
			<tr class="vertical">
				<th colspan="2">
					<xsl:value-of select="@caption"/>
				</th>
			</tr>
		</xsl:if>
		<tr class="vertical">
			<td colspan="2">
				<xsl:apply-templates select="." mode="aspnet-renderer">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context">Container.DataItem</xsl:with-param>
				</xsl:apply-templates>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="l:field[not(@layout) or @layout='horizontal']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<tr class="horizontal">
			<th>
				<xsl:value-of select="@caption"/>
				<xsl:if test="l:editor/l:validators/l:required"><span class="required">*</span></xsl:if>:
			</th>
			<td>
				<xsl:apply-templates select="." mode="form-view-editor">
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="." mode="form-view-validator">
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:apply-templates>
			</td>
		</tr>		
	</xsl:template>

	<xsl:template match="l:field[@layout='vertical']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:if test="@caption">
			<tr class="vertical">
				<th colspan="2">
					<xsl:value-of select="@caption"/>
					<xsl:if test="l:editor/l:validators/l:required">
						<span class="required">*</span>
					</xsl:if>
				</th>
			</tr>
		</xsl:if>
		<tr class="vertical">
			<td colspan="2">
				<xsl:apply-templates select="." mode="form-view-editor">
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="." mode="form-view-validator">
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:apply-templates>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="l:field[not(l:renderer)]" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:variable name="renderer">
			<xsl:choose>
				<xsl:when test="@lookup and @format"><l:format str="{@format}"><l:lookup service="{@lookup}"><l:get name="{@name}"/></l:lookup></l:format></xsl:when>
				<xsl:when test="@format"><l:format str="{@format}"><l:get name="{@name}"/></l:format></xsl:when>
				<xsl:when test="@lookup"><l:lookup service="{@lookup}"><l:get name="{@name}"/></l:lookup></xsl:when>
				<xsl:otherwise><l:get name="{@name}"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="code"><xsl:apply-templates select="msxsl:node-set($renderer)" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
		@@lt;%# <xsl:value-of select="$code"/> %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:renderer]" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="l:expression" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:variable name="code">
			<xsl:apply-templates select="l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		@@lt;%# <xsl:value-of select="$code"/> %@@gt;
	</xsl:template>

	<xsl:template match="l:linkbutton" mode="aspnet-renderer">
		<asp:LinkButton id="linkBtn{generate-id(.)}" runat="server" Text="{@caption}" CommandName="{@command}" />
	</xsl:template>
	
	<xsl:template match="l:link" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:variable name="url">
			<xsl:choose>
				<xsl:when test="@url">"<xsl:value-of select="@url"/>"</xsl:when>
				<xsl:when test="count(l:url/l:*)>0">
					<xsl:apply-templates select="l:url/l:*" mode="csharp-expr">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<a href="@@lt;%# {$url} %@@gt;" runat="server">
			<xsl:choose>
				<xsl:when test="@caption"><xsl:value-of select="@caption"/></xsl:when>
				<xsl:when test="l:caption/l:*">
					<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</a>
	</xsl:template>
	
	<xsl:template match="l:field[not(l:editor)]" mode="form-view-editor">
		<xsl:param name="mode"/>
		<!-- lets just render this item if editor is not specific -->
		<xsl:apply-templates select="." mode="aspnet-renderer">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context">Container.DataItem</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:textbox or l:editor/l:textarea]" mode="form-view-editor">
		<asp:TextBox id="{@name}" runat="server" Text='@@lt;%# Bind("{@name}") %@@gt;'>
			<xsl:if test="l:editor/l:textarea">
				<xsl:attribute name="TextMode">multiline</xsl:attribute>
				<xsl:if test="l:editor/l:textarea/@rows">
					<xsl:attribute name="Rows"><xsl:value-of select="l:editor/l:textarea/@rows"/></xsl:attribute>
				</xsl:if>
			</xsl:if>
		</asp:TextBox>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:checkbox]" mode="form-view-editor">
		<asp:CheckBox id="{@name}" runat="server" Checked='@@lt;%# Bind("{@name}") %@@gt;'/>
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
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="CheckBoxListRelationEditor" src="~/templates/editors/CheckBoxListRelationEditor.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="form-view-editor">
		<Plugin:CheckBoxListRelationEditor xmlns:Plugin="urn:remove" runat="server" 
			DalcServiceName="{$dalcName}"
			LookupServiceName="{l:editor/l:checkboxlist/@lookup}"
			RelationSourceName="{l:editor/l:checkboxlist/l:relation/@sourcename}"
			LFieldName="{l:editor/l:checkboxlist/l:relation/@left}"
			RFieldName="{l:editor/l:checkboxlist/l:relation/@right}">
			<xsl:choose>
				<xsl:when test="l:editor/l:checkboxlist/@id">
					<xsl:attribute name="EntityId">@@lt;%# DataBinder.Eval(Container.DataItem, "<xsl:value-of select="l:editor/l:checkboxlist/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# "<xsl:value-of select="l:editor/l:checkboxlist/@id"/>" %@@gt;</xsl:attribute>
				</xsl:when>
				<!--xsl:otherwise>
					<xsl:attribute name="EntityId">@@lt;%# FormView.DataKey.Value %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# FormView.DataKeyNames[0] %@@gt;</xsl:attribute>
				</xsl:otherwise-->
			</xsl:choose>
			
		</Plugin:CheckBoxListRelationEditor>
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
	
	<xsl:template match="l:dalc" mode="view-datasource">
		<xsl:param name="viewType"/>
		<xsl:variable name="dataSourceId" select="@id"/>
		<xsl:variable name="sourceName" select="@sourcename"/>
		<xsl:variable name="selectSourceName">
			<xsl:choose>
				<xsl:when test="@selectsourcename"><xsl:value-of select="@selectsourcename"/></xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="conditionRelex">
			<xsl:choose>
				<xsl:when test="@condition"><xsl:value-of select="@condition"/></xsl:when>
				<xsl:when test="condition"><xsl:value-of select="condition"/></xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<Dalc:DalcDataSource runat="server" id="{@id}" 
			Dalc='&lt;%$ service:{$dalcName} %&gt;' SourceName="{$sourceName}" DataSetMode="true">
			<xsl:if test="not($selectSourceName='')">
				<xsl:attribute name="SelectSourceName"><xsl:value-of select="$selectSourceName"/></xsl:attribute>
			</xsl:if>
			<xsl:attribute name="DataKeyNames">
				<xsl:call-template name="getEntityIdFields"><xsl:with-param name="name" select="$sourceName"/></xsl:call-template>
			</xsl:attribute>
			<xsl:attribute name="AutoIncrementNames">
				<xsl:call-template name="getEntityAutoincrementFields"><xsl:with-param name="name" select="$sourceName"/></xsl:call-template>
			</xsl:attribute>
			<xsl:if test="not($conditionRelex='')">
				<xsl:attribute name="OnInit"><xsl:value-of select="@id"/>_OnInit</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@datasetfactory">
					<xsl:attribute name="DataSetProvider">&lt;%$ service:<xsl:value-of select="@datasetfactory"/> %&gt;</xsl:attribute>
				</xsl:when>
				<xsl:when test="not($datasetFactoryName)=''">
					<xsl:attribute name="DataSetProvider">&lt;%$ service:<xsl:value-of select="$datasetFactoryName"/> %&gt;</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:attribute name="InsertMode">
				<xsl:choose>
					<xsl:when test="@insertmode='true' or @insertmode='1'">true</xsl:when>
					<xsl:when test="$viewType='FormView' and not(@insertmode)">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</Dalc:DalcDataSource>
		<!-- condition -->
		<xsl:if test="not($conditionRelex='')">
			<input type="hidden" runat="server" value="{$conditionRelex}" id="{@id}_relex" EnableViewState="false" Visible="false"/>
			<script language="c#" runat="server">
			protected void <xsl:value-of select="@id"/>_OnInit(object sender,EventArgs e) {
				var prv = new NI.Data.RelationalExpressions.RelExQueryNodeProvider() {
					RelExQueryParser = new NI.Data.RelationalExpressions.RelExQueryParser(false),
					RelExCondition = <xsl:value-of select="@id"/>_relex.Value,
					ExprResolver = WebManager.GetService@@lt;NI.Common.Expressions.IExpressionResolver@@gt;("defaultExprResolver")
				};
				var context = this.GetPageContext();
				<xsl:value-of select="@id"/>.Condition = prv.GetQueryNode( NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;(context) );
			}
			</script>
		</xsl:if>
	</xsl:template>
		
	<xsl:template match="l:updatepanel" name="updatepanel" mode="aspnet-renderer">
		<asp:UpdatePanel runat="server" UpdateMode="Conditional">
			<ContentTemplate>
				<xsl:apply-templates select="node()" mode="aspnet-renderer"/>
			</ContentTemplate>
		</asp:UpdatePanel>
	</xsl:template>
	
	<xsl:template match="l:list" mode="aspnet-renderer">
		<xsl:variable name="listUniqueId" select="generate-id(.)"/>
		<xsl:variable name="mainDsId">
			<xsl:choose>
				<xsl:when test="@datasource"><xsl:value-of select="@datasource"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="l:datasource/l:*[position()=1]/@id"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:apply-templates select="l:datasource/l:*" mode="view-datasource">
			<xsl:with-param name="viewType">ListView</xsl:with-param>
		</xsl:apply-templates>
		<NReco:ActionDataSource runat="server" id="list{$listUniqueId}ActionDataSource" DataSourceID="{$mainDsId}"/>
		
		<asp:ListView ID="listView{$listUniqueId}"
			DataSourceID="list{$listUniqueId}ActionDataSource"
			DataKeyNames="id"
			ItemContainerID="itemPlaceholder"
			OnLoad="listView{$listUniqueId}_OnLoad"
			runat="server">
			<xsl:if test="@add='true' or @add='1'">
				<xsl:attribute name="InsertItemPosition">LastItem</xsl:attribute>
				<xsl:attribute name="OnItemInserting">listView<xsl:value-of select="$listUniqueId"/>_OnItemInserting</xsl:attribute>
			</xsl:if>
			<LayoutTemplate>
				<table class="listView">
					<tr>
						<xsl:apply-templates select="l:field[not(@view) or @view='true' or @view='1']" mode="list-view-table-header"/>
					</tr>
					<tr runat="server" id="itemPlaceholder" />
				</table>
				<xsl:if test="not(l:pager/@allow='false' or l:pager/@allow='0')">
					<table class="pager"><tr><td>
					  <asp:DataPager ID="DataPager1" runat="server">
						<xsl:if test="l:pager/@pagesize">
							<xsl:attribute name="PageSize"><xsl:value-of select="l:pager/@pagesize"/></xsl:attribute>
						</xsl:if>
						<Fields>
						  <asp:NumericPagerField />
						</Fields>
					  </asp:DataPager>
					</td></tr></table>
				</xsl:if>
			</LayoutTemplate>
			<ItemTemplate>
				<tr>
					<xsl:apply-templates select="l:field[not(@view) or @view='true' or @view='1']" mode="list-view-table-cell"/>
				</tr>
			</ItemTemplate>
			<xsl:if test="@edit='true' or @edit='1'">
				<EditItemTemplate>
					<tr>
						<xsl:apply-templates select="l:field[not(@edit) or @edit='true' or @edit='1']" mode="list-view-table-cell-editor">
							<xsl:with-param name="mode">edit</xsl:with-param>
						</xsl:apply-templates>
					</tr>
				</EditItemTemplate>
			</xsl:if>
			<xsl:if test="@add='true' or @add='1'">
				<InsertItemTemplate>
					<tr>
						<xsl:apply-templates select="l:field[not(@add) or @add='true' or @add='1']" mode="list-view-table-cell-editor">
							<xsl:with-param name="mode">add</xsl:with-param>
						</xsl:apply-templates>
					</tr>
				</InsertItemTemplate>
			</xsl:if>
		</asp:ListView>
		<script language="c#" runat="server">
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnLoad(Object sender, EventArgs e) {
			<xsl:if test="l:sort">
				<xsl:variable name="directionResolved">
					<xsl:choose>
						<xsl:when test="l:sort/@direction='asc'">Ascending</xsl:when>
						<xsl:otherwise>Descending</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				((ListView)sender).Sort( "<xsl:value-of select="l:sort/@field"/>", SortDirection.<xsl:value-of select="$directionResolved"/> );
			</xsl:if>
		}
		</script>
		<xsl:if test="@add='true' or @add='1'">
			<script language="c#" runat="server">
			protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemInserting(Object sender, ListViewInsertEventArgs e) {
				<xsl:apply-templates select="l:action[@name='inserting']/l:*" mode="csharp-code">
					<xsl:with-param name="context">e.Values</xsl:with-param>
				</xsl:apply-templates>
			}
			</script>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="l:field[(@sort='true' or @sort='1') and @name]" mode="list-view-table-header">
		<th><asp:LinkButton id="sortBtn{generate-id(.)}" runat="server" Text="{@caption}" CommandName="Sort" CommandArgument="{@name}"/></th>
	</xsl:template>
	
	<xsl:template match="l:field" mode="list-view-table-header">
		<th>
			<xsl:choose>
				<xsl:when test="@caption"><xsl:value-of select="@caption"/></xsl:when>
				<xsl:otherwise>@@nbsp;</xsl:otherwise>
			</xsl:choose>
		</th>
	</xsl:template>

	<xsl:template match="l:field[l:editor]" mode="list-view-table-cell-editor">
		<xsl:param name="mode"/>
		<td>
			<xsl:apply-templates select="." mode="form-view-editor">
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="." mode="form-view-validator">
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>
		</td>
	</xsl:template>
	
	<xsl:template match="l:field[not(l:editor)]" mode="list-view-table-cell-editor">
		<xsl:apply-templates select="." mode="list-view-table-cell"/>
	</xsl:template>
	
	<xsl:template match="l:field[@name and not(l:renderer)]" mode="list-view-table-cell">
		<td>
			<xsl:apply-templates select="." mode="aspnet-renderer">
				<xsl:with-param name="context">Container.DataItem</xsl:with-param>
			</xsl:apply-templates>
		</td>
	</xsl:template>

	<xsl:template match="l:field[l:renderer]" mode="list-view-table-cell">
		<td>
			<xsl:for-each select="l:renderer/l:*">
				<xsl:if test="position()!=1">@@nbsp;</xsl:if>
				<xsl:apply-templates select="." mode="aspnet-renderer">
					<xsl:with-param name="context">Container.DataItem</xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
		</td>
	</xsl:template>
	
</xsl:stylesheet>
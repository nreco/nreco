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
	
	<xsl:template match='/components'>
		<files>
			<xsl:apply-templates select="l:views/*"/>
		</files>
	</xsl:template>
	
	<xsl:template match="l:form|l:list" name="registerCommonRenderers" mode="register-controls">
		@@lt;%@ Register TagPrefix="Plugin" tagName="CheckBoxListRelationEditor" src="~/templates/editors/CheckBoxListRelationEditor.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:form">
		<file name="templates/generated/{@name}.ascx">
			<content>
<!-- form control header -->
@@lt;%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %@@gt;
<xsl:apply-templates select="." mode="register-controls"/>

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
					if (e.Exception==null || e.ExceptionHandled) {
						<xsl:apply-templates select="l:action[@name='inserted']/l:*" mode="csharp-code">
							<xsl:with-param name="context">e.Values</xsl:with-param>
						</xsl:apply-templates>
					}
				}
				public void FormViewDeletedHandler(object sender, FormViewDeletedEventArgs e) {
					if (e.Exception==null || e.ExceptionHandled) {
						<xsl:apply-templates select="l:action[@name='deleted']/l:*" mode="csharp-code">
							<xsl:with-param name="context">e.Values</xsl:with-param>
						</xsl:apply-templates>
					}
				}
				
				protected void FormViewDataBound(object sender, EventArgs e) {
					if (FormView.DataItemCount==0) {
						FormView.ChangeMode(FormViewMode.Insert);
					}
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
			<asp:formview id="FormView"
				oniteminserted="FormViewInsertedHandler"
				onitemdeleted="FormViewDeletedHandler"
				ondatabound="FormViewDataBound"
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
						<xsl:apply-templates select="l:field[not(@view) or @view='true' or @view='1']" mode="plain-form-view-table-row"/>
					</table>
					
					<div class="toolboxContainer buttons">
						<xsl:for-each select="msxsl:node-set($viewFormButtons)/node()">
							<span>
								<xsl:if test="@command">
									<xsl:attribute name="class"><xsl:value-of select="@command"/></xsl:attribute>
								</xsl:if>
								<xsl:apply-templates select="." mode="aspnet-renderer"/>
							</span>
						</xsl:for-each>
					</div>
				</itemtemplate>
				<edititemtemplate>
					<legend>Edit <xsl:value-of select="$caption"/></legend>
					<table class="FormView" width="100%">
						<xsl:apply-templates select="l:field[not(@edit) or @edit='true' or @edit='1']" mode="edit-form-view-table-row"/>
					</table>
					
					<div class="toolboxContainer buttons">
						<xsl:for-each select="msxsl:node-set($editFormButtons)/node()">
							<span>
								<xsl:if test="@command">
									<xsl:attribute name="class"><xsl:value-of select="@command"/></xsl:attribute>
								</xsl:if>
								<xsl:apply-templates select="." mode="aspnet-renderer"/>
							</span>
						</xsl:for-each>
					</div>
				
				</edititemtemplate>
				<insertitemtemplate>
					<legend>Create <xsl:value-of select="$caption"/></legend>
					<table class="FormView" width="100%">
						<xsl:apply-templates select="l:field[not(@add) or @add='true' or @add='1']" mode="edit-form-view-table-row"/>
					</table>
					<div class="toolboxContainer buttons">
						<xsl:for-each select="msxsl:node-set($addFormButtons)/node()">
							<span>
								<xsl:if test="@command">
									<xsl:attribute name="class"><xsl:value-of select="@command"/></xsl:attribute>
								</xsl:if>
								<xsl:apply-templates select="." mode="aspnet-renderer"/>
							</span>
						</xsl:for-each>
					</div>
				</insertitemtemplate>

			</asp:formview>
			
		</fieldset>
	</xsl:template>
	
	<xsl:template match="l:field[not(@layout) or @layout='horizontal']" mode="plain-form-view-table-row">
		<tr class="horizontal">
			<th>
					<xsl:value-of select="@caption"/>:
			</th>
			<td>
				<xsl:apply-templates select="." mode="aspnet-renderer"/>
			</td>
		</tr>		
	</xsl:template>

	<xsl:template match="l:field[@layout='vertical']" mode="plain-form-view-table-row">
		<xsl:if test="@caption">
			<tr class="vertical">
				<th colspan="2">
					<xsl:value-of select="@caption"/>
				</th>
			</tr>
		</xsl:if>
		<tr class="vertical">
			<td colspan="2">
				<xsl:apply-templates select="." mode="aspnet-renderer"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="l:field[not(@layout) or @layout='horizontal']" mode="edit-form-view-table-row">
		<tr class="horizontal">
			<th>
				<xsl:value-of select="@caption"/>
				<xsl:if test="l:editor/l:validators/l:required"><span class="required">*</span></xsl:if>:
			</th>
			<td>
				<xsl:apply-templates select="." mode="form-view-editor"/>
				<xsl:apply-templates select="." mode="form-view-validator"/>
			</td>
		</tr>		
	</xsl:template>

	<xsl:template match="l:field[@layout='vertical']" mode="edit-form-view-table-row">
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
				<xsl:apply-templates select="." mode="form-view-editor"/>
				<xsl:apply-templates select="." mode="form-view-validator"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="l:field[not(l:renderer)]" mode="aspnet-renderer">
		<xsl:variable name="renderer">
			<xsl:choose>
				<xsl:when test="@lookup and @format"><l:format str="{@format}"><l:lookup service="{@lookup}"><l:get name="{@name}"/></l:lookup></l:format></xsl:when>
				<xsl:when test="@format"><l:format str="{@format}"><l:get name="{@name}"/></l:format></xsl:when>
				<xsl:when test="@lookup"><l:lookup service="{@lookup}"><l:get name="{@name}"/></l:lookup></xsl:when>
				<xsl:otherwise><l:get name="{@name}"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="code"><xsl:apply-templates select="msxsl:node-set($renderer)" mode="csharp-expr"/></xsl:variable>
		@@lt;%# <xsl:value-of select="$code"/> %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:renderer]" mode="aspnet-renderer">
		<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer"/>
	</xsl:template>

	<xsl:template match="l:expression" mode="aspnet-renderer">
		<xsl:variable name="code">
			<xsl:apply-templates select="l:*" mode="csharp-expr"/>
		</xsl:variable>
		@@lt;%# <xsl:value-of select="$code"/> %@@gt;
	</xsl:template>

	<xsl:template match="l:linkbutton" mode="aspnet-renderer">
		<asp:LinkButton id="linkBtn{generate-id(.)}" runat="server" Text="{@caption}" CommandName="{@command}" />
	</xsl:template>
	
	<xsl:template match="l:link" mode="aspnet-renderer">
		<xsl:variable name="url">
			<xsl:choose>
				<xsl:when test="@url">"<xsl:value-of select="@url"/>"</xsl:when>
				<xsl:when test="count(l:url/l:*)>0">
					<xsl:apply-templates select="l:url/l:*" mode="csharp-expr">
						<xsl:with-param name="context">Container.DataItem</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<a href="@@lt;%# {$url} %@@gt;" runat="server">
			<xsl:choose>
				<xsl:when test="@caption"><xsl:value-of select="@caption"/></xsl:when>
				<xsl:when test="l:caption/l:*">
					<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer"/>
				</xsl:when>
			</xsl:choose>
		</a>
	</xsl:template>
	
	<xsl:template match="l:field[not(l:editor)]" mode="form-view-editor">
		<!-- lets just render this item if editor is not specific -->
		<xsl:apply-templates select="." mode="aspnet-renderer"/>
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
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="form-view-editor">
		<Plugin:CheckBoxListRelationEditor xmlns:Plugin="urn:remove" runat="server" 
			DalcServiceName="{$dalcName}"
			EntityId='@@lt;%# FormView.DataKey.Value %@@gt;'
			EntityIdField='@@lt;%# FormView.DataKeyNames[0] %@@gt;'
			LookupServiceName="{l:editor/l:checkboxlist/@lookup}"
			RelationSourceName="{l:editor/l:checkboxlist/l:relation/@sourcename}"
			LFieldName="{l:editor/l:checkboxlist/l:relation/@left}"
			RFieldName="{l:editor/l:checkboxlist/l:relation/@right}">
			<xsl:choose>
				<xsl:when test="l:editor/l:checkboxlist/@id">
					<xsl:attribute name="EntityId">@@lt;%# DataBinder.Eval(FormView.DataItem, "<xsl:value-of select="l:editor/l:checkboxlist/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# "<xsl:value-of select="l:editor/l:checkboxlist/@id"/>" %@@gt;</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="EntityId">@@lt;%# FormView.DataKey.Value %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# FormView.DataKeyNames[0] %@@gt;</xsl:attribute>
				</xsl:otherwise>
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
	
	<xsl:template match="l:dalc" mode="form-view-datasource">
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
			Dalc='&lt;%$ service:{$dalcName} %>' SourceName="{$sourceName}" DataSetMode="true">
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
	
	<xsl:template match="l:list">
		<file name="templates/generated/{@name}.ascx">
			<content>
<!-- form control header -->
@@lt;%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %@@gt;
<xsl:apply-templates select="." mode="register-controls"/>

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
				
				<xsl:variable name="caption" select="@caption"/>
				<h1><xsl:value-of select="$caption"/></h1>
					
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
	
	<xsl:template match="l:list" mode="aspnet-renderer">
		<xsl:call-template name="layout-list"/>
	</xsl:template>
	
	<xsl:template match="l:list[@update-panel='false' or @update-panel='0']" name="layout-list" mode="list-view">
		<xsl:param name="mainDsId" select="@datasource"/>
		<xsl:variable name="listUniqueId" select="generate-id(.)"/>
		<asp:ListView ID="listView{$listUniqueId}"
			DataSourceID="{$mainDsId}"
			DataKeyNames="id"
			ItemContainerID="itemPlaceholder"
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
					<xsl:apply-templates select="l:field[not(@view) or @view='true' or @view='1']" mode="list-view-table-cell"/>
				</tr>
			</ItemTemplate>
			<xsl:if test="@edit='true' or @edit='1'">
				<EditItemTemplate>
					<tr>
						<xsl:apply-templates select="l:field[not(@edit) or @edit='true' or @edit='1']" mode="list-view-table-cell-editor"/>
					</tr>
				</EditItemTemplate>
			</xsl:if>
			<xsl:if test="@add='true' or @add='1'">
				<InsertItemTemplate>
					<tr>
						<xsl:apply-templates select="l:field[not(@add) or @add='true' or @add='1']" mode="list-view-table-cell-editor"/>
					</tr>
				</InsertItemTemplate>
			</xsl:if>
		</asp:ListView>
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
		<td>
			<xsl:apply-templates select="." mode="form-view-editor"/>
			<xsl:apply-templates select="." mode="form-view-validator"/>
		</td>
	</xsl:template>
	
	<xsl:template match="l:field[not(l:editor)]" mode="list-view-table-cell-editor">
		<xsl:apply-templates select="." mode="list-view-table-cell"/>
	</xsl:template>
	
	<xsl:template match="l:field[@name and not(l:renderer)]" mode="list-view-table-cell">
		<td>
			<xsl:apply-templates select="." mode="aspnet-renderer"/>
		</td>
	</xsl:template>

	<xsl:template match="l:field[l:renderer]" mode="list-view-table-cell">
		<td>
			<xsl:for-each select="l:renderer/l:*">
				<xsl:if test="position()!=1">@@nbsp;</xsl:if>
				<xsl:apply-templates select="." mode="aspnet-renderer"/>
			</xsl:for-each>
		</td>
	</xsl:template>
	
</xsl:stylesheet>
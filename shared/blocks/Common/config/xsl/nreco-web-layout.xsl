<!--
NReco library (http://nreco.googlecode.com/)
Copyright 2008,2009 Vitaliy Fedorchenko
Distributed under the LGPL licence
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->	
<xsl:stylesheet version='1.0' 
				xmlns:e="urn:schemas-nreco:nreco:entity:v1"
				xmlns:l="urn:schemas-nreco:nreco:web:layout:v1"
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:Dalc="urn:remove"
				xmlns:NReco="urn:remove"
				xmlns:asp="urn:remove"
				xmlns:UserControl="urn:remove"
				xmlns:UserControlEditor="urn:remove"
				exclude-result-prefixes="msxsl">

	<xsl:output method='xml' indent='yes' />
	
	<xsl:variable name="dalcName" select="/components/default/services/dalc/@name"/>
	<xsl:variable name="datasetFactoryName" select="/components/default/services/datasetfactory/@name"/>
	<xsl:variable name="entities" select="/components/entities"/>
	<xsl:variable name="formDefaults" select="/components/default/form"/>
	<xsl:variable name="listDefaults" select="/components/default/list"/>

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
		<xsl:variable name="editorScope"><xsl:copy-of select=".//l:field[l:editor]"/></xsl:variable>
		<xsl:variable name="editorScopeNode" select="msxsl:node-set($editorScope)"/>
		<!-- register procedure for editors -->
		<xsl:for-each select="$editorScopeNode/l:field">
			<xsl:variable name="editorName" select="name(l:editor/l:*[position()=1])"/>
			<xsl:if test="count(following-sibling::l:field/l:editor/l:*[name()=$editorName])=0">
				<xsl:apply-templates select="." mode="register-editor-control">
					<xsl:with-param name="instances" select="preceding-sibling::l:field[name(l:editor/l:*)=$editorName]"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		<!-- register procedure for renderers -->
		<xsl:variable name="rendererScope"><xsl:copy-of select=".//l:renderer//l:*"/></xsl:variable>
		<xsl:variable name="rendererScopeNode" select="msxsl:node-set($rendererScope)"/>
		<xsl:for-each select="$rendererScopeNode/l:*">
			<xsl:variable name="rendererName" select="name()"/>
			<xsl:if test="count(following-sibling::l:*[name()=$rendererName])=0">
				<xsl:apply-templates select="." mode="register-renderer-control">
					<xsl:with-param name="instances" select="preceding-sibling::l:*[name()=$rendererName]"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="*|text()" mode="register-editor-control">
	<!-- skip editors without registration -->
	</xsl:template>
	<xsl:template match="*|text()" mode="register-renderer-control">
	<!-- skip renderers without registration -->
	</xsl:template>	
	
	<xsl:template name="view-register-css">
		<xsl:variable name="scope"><xsl:copy-of select="."/></xsl:variable>
		<xsl:variable name="scopeNode" select="msxsl:node-set($scope)"/>	
		<xsl:for-each select="$scopeNode//l:field[l:editor]">
			<xsl:variable name="editorName" select="name(l:editor/l:*[position()=1])"/>
			<xsl:if test="count(preceding::l:field/l:editor/l:*[name()=$editorName])=0">
				<xsl:apply-templates select="." mode="register-editor-css"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="text()" mode="register-editor-css">
	<!-- skip editors without registration -->
	</xsl:template>	
	
	<xsl:template name="apply-visibility">
		<xsl:param name="content"/>
		<xsl:param name="expr"/>
		<xsl:choose>
			<xsl:when test="$expr">
				<xsl:variable name="exprStr">IsFuzzyTrue(<xsl:apply-templates select="$expr" mode="csharp-expr"/>)</xsl:variable>
				<NReco:VisibilityHolder runat="server" Visible="@@lt;%# {translate($exprStr, '&#xA;&#xD;&#x9;', '')} %@@gt;">
					<xsl:copy-of select="$content"/>
				</NReco:VisibilityHolder>
			</xsl:when>
			<xsl:otherwise><xsl:copy-of select="$content"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match='/components'>
		<files>
			<xsl:apply-templates select="l:views/*"/>
		</files>
	</xsl:template>
	
	<xsl:template match="l:view">
<!-- form control header -->
<xsl:variable name="sessionContext">
	<xsl:choose>
		<xsl:when test="@sessiondatacontext='1' or @sessiondatacontext='true'">true</xsl:when>
		<xsl:otherwise>false</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
@@lt;%@ Control Language="c#" AutoEventWireup="false" Inherits="GenericView" UseSessionDataContext="<xsl:value-of select="$sessionContext"/>" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %@@gt;

				<xsl:call-template name="view-register-controls"/>
				<xsl:call-template name="view-register-css"/>
				
				<script language="c#" runat="server">
				protected override void OnLoad(EventArgs e) {
					base.OnLoad(e);
					<xsl:apply-templates select="l:action[@name='load']/l:*" mode="csharp-code"/>
				}
				protected override void OnPreRender(EventArgs e) {
					base.OnPreRender(e);
					<xsl:apply-templates select="l:action[@name='prerender']/l:*" mode="csharp-code"/>
				}
				<xsl:for-each select="l:action[not(@name='load') and not(@name='prerender')]">
					public void Execute_<xsl:value-of select="@name"/>(ActionContext context) {
						<xsl:apply-templates select="l:*" mode="csharp-code">
							<xsl:with-param name="context">context</xsl:with-param>
						</xsl:apply-templates>
					}
				</xsl:for-each>
				</script>
				<xsl:apply-templates select="l:datasources/l:*" mode="view-datasource"/>
				<xsl:apply-templates select="l:*[not(name()='datasources' or name()='action')]" mode="aspnet-renderer"/>
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
	
	<xsl:template match="l:databind" mode="csharp-code">
		<xsl:if test="(not(@mode) and not(l:*)) or @mode='notpostback'">if (!IsPostBack) {</xsl:if>
			<xsl:choose>
				<xsl:when test="l:*">
					<xsl:apply-templates select="l:*" mode="control-instance-expr"/>.DataBind();
				</xsl:when>
				<xsl:otherwise>
					DataBind();
					foreach (var updatePanel in this.GetChildren@@lt;System.Web.UI.UpdatePanel@@gt;())
						if (updatePanel.UpdateMode==UpdatePanelUpdateMode.Conditional)
							updatePanel.Update();
				</xsl:otherwise>
			</xsl:choose>
		<xsl:if test="(not(@mode) and not(l:*)) or @mode='notpostback'">}</xsl:if>
	</xsl:template>
	
	<xsl:template match="l:list" mode="control-instance-expr">
		this.GetChildren@@lt;Control@@gt;().Where(c=@@gt;c.ID=="listView<xsl:value-of select="@name"/>").FirstOrDefault()
	</xsl:template>

	<xsl:template match="l:code" mode="csharp-code">
		<xsl:value-of select="." disable-output-escaping="yes"/>
	</xsl:template>
	
	<xsl:template match="l:operation" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="operationContext">
			<xsl:choose>
				<xsl:when test="l:*">
					<xsl:apply-templates select="l:*" mode="csharp-expr">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$context"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		WebManager.GetService@@lt;IOperation@@lt;object@@gt;@@gt;("<xsl:value-of select="@name"/>").Execute( <xsl:value-of select="$operationContext"/> );
	</xsl:template>	
	
	<xsl:template match="l:set" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="valExpr">
			<xsl:apply-templates select="l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:value-of select="$context"/>["<xsl:value-of select="@name"/>"] = (object)<xsl:value-of select="$valExpr"/> ?? DBNull.Value;
	</xsl:template>
	
	<xsl:template match="l:importdatacontext" mode="csharp-code">
		if (!IsPostBack)
			this.GetContext().ImportDataContext(NReco.Web.Site.ControlContext.SourceType.<xsl:value-of select="@from"/>);
	</xsl:template>
	
	<xsl:template match="l:jscallback" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="callbackFunctionExpr">
			<xsl:apply-templates select="l:function/l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="callbackArgExpr">
			<xsl:apply-templates select="l:arg/l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		var callbackScript = String.Format("var wnd; if (parent) wnd = parent;if (opener) wnd = opener; wnd.{0}({1}); window.close();", <xsl:value-of select="$callbackFunctionExpr"/>, JsHelper.ToJsonString( <xsl:value-of select="$callbackArgExpr"/>) );
		if (System.Web.UI.ScriptManager.GetCurrent(Page)!=null @@amp;@@amp; System.Web.UI.ScriptManager.GetCurrent(Page).IsInAsyncPostBack) {
			System.Web.UI.ScriptManager.RegisterStartupScript(Page,this.GetType(),callbackScript,callbackScript,true);
		} else {
			Response.Write("@@lt;html@@gt;@@lt;body@@gt;@@lt;script type=\"text/javascript\"@@gt;");
			Response.Write(callbackScript);
			Response.Write("@@lt;/sc"+"ript@@gt;@@lt;/body@@gt;@@lt;/html@@gt;");
			Response.End();
		}
	</xsl:template>
	
	<xsl:template match="l:route" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:variable name="routeContext">
			<xsl:choose>
				<xsl:when test="count(l:*)>0"><xsl:apply-templates select="l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:when>
				<xsl:when test="not($context='')"><xsl:value-of select="$context"/></xsl:when>
				<xsl:otherwise>null</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		this.GetRouteUrlSafe("<xsl:value-of select="@name"/>", NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;(<xsl:value-of select="$routeContext"/>) )
	</xsl:template>
	
	<xsl:template match="l:context" mode="csharp-expr">
		this.GetContext()["<xsl:value-of select="@name"/>"]
	</xsl:template>
	
	<xsl:template match="l:code" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:value-of select="." disable-output-escaping="yes"/>
	</xsl:template>
	
	<xsl:template match="l:not" mode="csharp-expr">
		!IsFuzzyTrue(<xsl:apply-templates select="node()" mode="csharp-expr"/>)
	</xsl:template>

	<xsl:template match="l:or" mode="csharp-expr">
		<xsl:for-each select="l:*">
			<xsl:if test="position()>1">||</xsl:if>
			IsFuzzyTrue(<xsl:apply-templates select="." mode="csharp-expr"/>)
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="l:and" mode="csharp-expr">
		<xsl:for-each select="l:*">
			<xsl:if test="position()>1">@@amp;@@amp;</xsl:if>
			IsFuzzyTrue(<xsl:apply-templates select="." mode="csharp-expr"/>)
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="l:isempty" mode="csharp-expr">
		IsFuzzyEmpty(<xsl:apply-templates select="node()" mode="csharp-expr"/>)
	</xsl:template>
	
	<xsl:template match="l:eq" mode="csharp-expr">
		AreEquals(<xsl:apply-templates select="node()[position()=1]" mode="csharp-expr"/>,<xsl:apply-templates select="node()[position()=2]" mode="csharp-expr"/>)
	</xsl:template>
	
	<xsl:template match="l:request" mode="csharp-expr">
		Request["<xsl:value-of select="@name"/>"]
	</xsl:template>
	
	<xsl:template match="l:const" mode="csharp-expr">"<xsl:value-of select="."/>"</xsl:template>
	
	<xsl:template match="l:format" name="format-csharp-expr" mode="csharp-expr">
		<xsl:param name="str" select="@str"/>
		String.Format(WebManager.GetLabel("<xsl:value-of select="$str"/>",this) <xsl:for-each select="l:*">,<xsl:apply-templates select="." mode="csharp-expr"/></xsl:for-each>)
	</xsl:template>

	<xsl:template match="l:listrowcount" mode="csharp-expr">
		String.Format("@@lt;span class='listRowCount<xsl:value-of select="@name"/>'@@gt;{0}@@lt;/span@@gt;", GetListViewRowCount( this.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;().Where( c=@@gt;c.ID=="listView<xsl:value-of select="@name"/>").FirstOrDefault() ) )
	</xsl:template>
	
	<xsl:template match="l:lookup" name="lookup-csharp-expr" mode="csharp-expr">
		<xsl:param name="service" select="@service"/>
		WebManager.GetService@@lt;IProvider@@lt;object,object@@gt;@@gt;("<xsl:value-of select="@service"/>").Provide( <xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"/> )
	</xsl:template>
	
	<xsl:template match="l:field" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:choose>
			<xsl:when test="not($context='')">NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;(<xsl:value-of select="$context"/>)["<xsl:value-of select="@name"/>"]</xsl:when>
			<xsl:otherwise>Eval("<xsl:value-of select="@name"/>")</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="l:control" mode="csharp-expr">
		GetControlValue(Container, "<xsl:value-of select="@name"/>")
	</xsl:template>
	
	<xsl:template match="l:provider" mode="csharp-expr">
		<xsl:param name="context"/>
		DataSourceHelper.GetProviderObject("<xsl:value-of select="@name"/>", <xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"/>,true)</xsl:template>
	
	<xsl:template match="l:get" mode="csharp-expr">
		<xsl:param name="context"/>
		NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;(<xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"/>??new Hashtable())["<xsl:value-of select="@name"/>"]</xsl:template>	

	<xsl:template match="l:ognl" mode="csharp-expr">
		<xsl:param name="context"/>
		EvalOgnlExpression(@"<xsl:value-of select="l:expression"/>", <xsl:apply-templates select="l:context/l:*[position()=1]" mode="csharp-expr"/>)</xsl:template>	
		
	<xsl:template match="l:isinrole" name="isinrole-csharp-code" mode="csharp-expr">
		Context.User.IsInRole("<xsl:value-of select="."/>")
	</xsl:template>
	
	<xsl:template match="l:dictionary" name="dictionary-csharp-code" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:variable name="entries">
			<xsl:for-each select="l:entry">
				<xsl:if test="position()!=1">,</xsl:if>
				{"<xsl:value-of select="@key"/>", <xsl:apply-templates select="l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>}
			</xsl:for-each>
		</xsl:variable>
		new Dictionary@@lt;string,object@@gt;{<xsl:value-of select="$entries"/>}
	</xsl:template>
	
	<xsl:template match="l:usercontrol" mode="register-renderer-control">
		<xsl:param name="instances"/>
		<xsl:param name="prefix">UserControl</xsl:param>
		<xsl:variable name="instancesCopy">
			<xsl:if test="$instances"><xsl:copy-of select="$instances"/></xsl:if>
			<xsl:copy-of select="."/>
		</xsl:variable>
		<xsl:for-each select="msxsl:node-set($instancesCopy)/l:usercontrol">
			<xsl:variable name="ucName" select="@name"/>
			<xsl:if test="count(preceding-sibling::l:usercontrol[@name=$ucName])=0">
				@@lt;%@ Register TagPrefix="<xsl:value-of select="$prefix"/>" tagName="<xsl:value-of select="$ucName"/>" src="<xsl:value-of select="@src"/>" %@@gt;
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:usercontrol]" mode="register-editor-control">
		<xsl:param name="instances"/>
		<xsl:param name="prefix">UserControlEditor</xsl:param>
		<xsl:variable name="instancesCopy">
			<xsl:if test="$instances"><xsl:copy-of select="$instances"/></xsl:if>
			<xsl:copy-of select="."/>
		</xsl:variable>
		<xsl:for-each select="msxsl:node-set($instancesCopy)/l:field/l:editor/l:usercontrol">
			<xsl:variable name="ucName" select="@name"/>
			<xsl:if test="count(preceding::l:field/l:editor/l:usercontrol[@name=$ucName])=0">
				@@lt;%@ Register TagPrefix="<xsl:value-of select="$prefix"/>" tagName="<xsl:value-of select="$ucName"/>" src="<xsl:value-of select="@src"/>" %@@gt;
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	

	<xsl:template match="l:newline" mode="aspnet-renderer">
		<br/>
	</xsl:template>

	<xsl:template match="l:usercontrol" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:element name="UserControl:{@name}">
			<xsl:attribute name="runat">server</xsl:attribute>
			<xsl:attribute name="ViewContext">@@lt;%# this.GetContext() %@@gt;</xsl:attribute>
			<xsl:if test="not($context='') and $context">
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$context"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="attribute::*|l:*">
				<xsl:if test="not(name()='src' or name()='name')">
					<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="l:toolbox" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>

		<div class="toolboxContainer">
			<xsl:for-each select="node()">
				<span>
					<xsl:if test="@icon">
						<span class="{@icon}">@@amp;nbsp;</span>
					</xsl:if>
					<xsl:apply-templates select="." mode="aspnet-renderer">
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="formUid" select="$formUid"/>
						<xsl:with-param name="mode" select="$mode"/>
					</xsl:apply-templates>
				</span>
			</xsl:for-each>
			@@lt;div style='clear:both;'@@gt;@@lt;/div@@gt;
		</div>
	</xsl:template>
	
	<xsl:template match="l:toolboxitem" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>	
		<span>
			<xsl:if test="@icon">
				<span class="{@icon}">@@amp;nbsp;</span>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="aspnet-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>
		</span>
	</xsl:template>
	
	<xsl:template match="l:placeholder" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">
				<xsl:apply-templates select="l:renderer/node()" mode="aspnet-renderer">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:apply-templates>	
			</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="l:form" name="layout-form" mode="aspnet-renderer">
		<xsl:variable name="mainDsId">
			<xsl:choose>
				<xsl:when test="@datasource"><xsl:value-of select="@datasource"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="l:datasource/l:*[position()=1]/@id"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="uniqueId" select="generate-id(.)"/>
		<xsl:variable name="viewEnabled">
			<xsl:choose>
				<xsl:when test="@view='true' or @view='1' or not(@view)">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="editEnabled">
			<xsl:choose>
				<xsl:when test="@edit='true' or @edit='1' or not(@edit)">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="addEnabled">
			<xsl:choose>
				<xsl:when test="@add='true' or @add='1' or not(@add)">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:apply-templates select="l:datasource/l:*" mode="view-datasource">
			<xsl:with-param name="viewType">FormView</xsl:with-param>
		</xsl:apply-templates>
		<NReco:ActionDataSource runat="server" id="form{$uniqueId}ActionDataSource" DataSourceID="{$mainDsId}"/>

		<script language="c#" runat="server">
		IDictionary FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = null;
		
		public void FormView_<xsl:value-of select="$uniqueId"/>_InsertedHandler(object sender, FormViewInsertedEventArgs e) {
			if (e.Exception==null || e.ExceptionHandled) {
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.Values;
				<xsl:apply-templates select="l:action[@name='inserted']/l:*" mode="form-operation">
					<xsl:with-param name="context">e.Values</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_InsertingHandler(object sender, FormViewInsertEventArgs e) {
			((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("form<xsl:value-of select="$uniqueId"/>ActionDataSource")).ActionSourceControl = (System.Web.UI.Control)sender;
			
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.Values;
			<xsl:apply-templates select="l:action[@name='inserting']/l:*" mode="form-operation">
				<xsl:with-param name="context">e.Values</xsl:with-param>
				<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
			</xsl:apply-templates>
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_UpdatingHandler(object sender, FormViewUpdateEventArgs e) {
			((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("form<xsl:value-of select="$uniqueId"/>ActionDataSource")).ActionSourceControl = (System.Web.UI.Control)sender;
		
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.NewValues;
			<xsl:apply-templates select="l:action[@name='updating']/l:*" mode="form-operation">
				<xsl:with-param name="context">e.NewValues</xsl:with-param>
				<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
			</xsl:apply-templates>
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_DeletingHandler(object sender, FormViewDeleteEventArgs e) {
			((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("form<xsl:value-of select="$uniqueId"/>ActionDataSource")).ActionSourceControl = (System.Web.UI.Control)sender;
		
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.Keys;
			<xsl:apply-templates select="l:action[@name='deleting']/l:*" mode="form-operation">
				<xsl:with-param name="context">e.Keys</xsl:with-param>
				<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
			</xsl:apply-templates>
		}		
		public void FormView_<xsl:value-of select="$uniqueId"/>_DeletedHandler(object sender, FormViewDeletedEventArgs e) {
			if (e.Exception==null || e.ExceptionHandled) {
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.Values;
				<xsl:apply-templates select="l:action[@name='deleted']/l:*" mode="form-operation">
					<xsl:with-param name="context">e.Values</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_UpdatedHandler(object sender, FormViewUpdatedEventArgs e) {
			if (e.Exception==null || e.ExceptionHandled) {
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.NewValues;
				<xsl:apply-templates select="l:action[@name='updated']/l:*" mode="form-operation">
					<xsl:with-param name="context">e.NewValues</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_CommandHandler(object sender, FormViewCommandEventArgs e) {
			<xsl:for-each select="l:action[not(@name='inserted' or @name='inserting' or @name='deleted' or @name='deleting' or @name='updated' or @name='updating' or @name='initialize')]">
				if (e.CommandName.ToLower()=="<xsl:value-of select="@name"/>".ToLower()) {
					<xsl:apply-templates select="l:*" mode="form-operation">
						<xsl:with-param name="context">FormView_<xsl:value-of select="$uniqueId"/>_ActionContext</xsl:with-param>
						<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
					</xsl:apply-templates>
					if (Response.IsRequestBeingRedirected)
						Response.End();
				}
			</xsl:for-each>
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
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;( FormView.DataItem);
				<xsl:apply-templates select="l:action[@name='initialize']/l:*" mode="form-operation">
					<xsl:with-param name="context">FormView_<xsl:value-of select="$uniqueId"/>_ActionContext</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
				
				FormView.InsertDataItem = FormView.DataItem;
				FormView.ChangeMode(FormViewMode.Insert);
			}
		}
		</script>
		
		<xsl:variable name="viewHeader">
			<xsl:choose>
				<xsl:when test="l:header[@view='true' or @view='1' or not(@view)]"><xsl:copy-of select="l:header[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formDefaults/l:header[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="viewFooter">
			<xsl:choose>
				<xsl:when test="l:footer[@view='true' or @view='1' or not(@view)]"><xsl:copy-of select="l:footer[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formDefaults/l:footer[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="addHeader">
			<xsl:choose>
				<xsl:when test="l:header[@add='true' or @add='1' or not(@add)]"><xsl:copy-of select="l:header[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formDefaults/l:header[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="addFooter">
			<xsl:choose>
				<xsl:when test="l:footer[@add='true' or @add='1' or not(@add)]"><xsl:copy-of select="l:footer[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formDefaults/l:footer[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="editHeader">
			<xsl:choose>
				<xsl:when test="l:header[@edit='true' or @edit='1' or not(@edit)]">
					<xsl:copy-of select="l:header[@edit='true' or @edit='1' or not(@edit)]/l:*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$formDefaults/l:header[@edit='true' or @edit='1' or not(@edit)]/l:*"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="editFooter">
			<xsl:choose>
				<xsl:when test="l:footer[@edit='true' or @edit='1' or not(@edit)]">
					<xsl:copy-of select="l:footer[@edit='true' or @edit='1' or not(@edit)]/l:*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$formDefaults/l:footer[@edit='true' or @edit='1' or not(@edit)]/l:*"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<NReco:formview id="FormView{$uniqueId}"
			oniteminserted="FormView_{$uniqueId}_InsertedHandler"
			oniteminserting="FormView_{$uniqueId}_InsertingHandler"
			onitemdeleted="FormView_{$uniqueId}_DeletedHandler"
			onitemdeleting="FormView_{$uniqueId}_DeletingHandler"
			onitemupdated="FormView_{$uniqueId}_UpdatedHandler"
			onitemupdating="FormView_{$uniqueId}_UpdatingHandler"
			onitemcommand="FormView_{$uniqueId}_CommandHandler"
			ondatabound="FormView_{$uniqueId}_DataBound"
			datasourceid="form{$uniqueId}ActionDataSource"
			CssClass="FormView wrapper"
			RowStyle-CssClass="FormView wrapper"
			allowpaging="false"
			runat="server">
			<xsl:attribute name="DefaultMode">
				<xsl:choose>
					<xsl:when test="$viewEnabled='true'">ReadOnly</xsl:when>
					<xsl:when test="$editEnabled='true'">Edit</xsl:when>
					<xsl:when test="$addEnabled='true'">Insert</xsl:when>
					<xsl:otherwise><xsl:message terminate="yes">Form should have at least one enabled mode (view/add/edit)</xsl:message></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="datakeynames">
				<!-- tmp solution for dalc ds only -->
				<xsl:call-template name="getEntityIdFields"><xsl:with-param name="name" select="l:datasource/l:*[@id=$mainDsId]/@sourcename"/></xsl:call-template>
			</xsl:attribute>
			
			<xsl:if test="$viewEnabled='true'">
				<itemtemplate>
					<xsl:if test="not(@widget) or @widget='1' or @widget='true'">
						<div class="ui-widget-header ui-corner-top formview">
							<div class="nreco-widget-header">
								<xsl:choose>
									<xsl:when test="@caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></xsl:when>
									<xsl:when test="l:caption">
										<xsl:variable name="code"><xsl:apply-templates select="l:caption/node()" mode="csharp-expr"><xsl:with-param name="context">Container.DataItem</xsl:with-param></xsl:apply-templates></xsl:variable>
										@@lt;%# <xsl:value-of select="$code"/> %@@gt;
									</xsl:when>
								</xsl:choose>
							</div>
						</div>
						@@lt;div class="ui-widget-content ui-corner-bottom formview"@@gt;@@lt;div class="nreco-widget-content"@@gt;
					</xsl:if>
					<table class="FormView">
						<xsl:if test="count(msxsl:node-set($viewHeader)/*)>0">
							<tr class="formheader">
								<td colspan="2">
									<xsl:apply-templates select="msxsl:node-set($viewHeader)/l:*" mode="aspnet-renderer">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid">FormView<xsl:value-of select="$uniqueId"/></xsl:with-param>
										<xsl:with-param name="mode">FormHeader</xsl:with-param>
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:if>
						
						<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="plain-form-view-table-row">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid">FormView<xsl:value-of select="$uniqueId"/></xsl:with-param>
									</xsl:apply-templates>								
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>								
						</xsl:for-each>

						<xsl:if test="count(msxsl:node-set($viewFooter)/*)>0">
							<tr class="formfooter">
								<td colspan="2">
									<xsl:apply-templates select="msxsl:node-set($viewFooter)/l:*" mode="aspnet-renderer">
											<xsl:with-param name="context">Container.DataItem</xsl:with-param>
											<xsl:with-param name="formUid">FormView<xsl:value-of select="$uniqueId"/></xsl:with-param>
											<xsl:with-param name="mode">FormFooter</xsl:with-param>
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:if>

					</table>
					<xsl:if test="not(@widget) or @widget='1' or @widget='true'">
						@@lt;/div@@gt;@@lt;/div@@gt;
					</xsl:if>
				</itemtemplate>
			</xsl:if>
			
			<xsl:if test="$editEnabled='true'">
				<edititemtemplate>
					<xsl:if test="not(@widget) or @widget='1' or @widget='true'">
						<div class="ui-widget-header ui-corner-top formview">
							<div class="nreco-widget-header">
								<xsl:choose>
									<xsl:when test="@caption"><NReco:Label runat="server">Edit <xsl:value-of select="@caption"/></NReco:Label></xsl:when>
									<xsl:when test="l:caption">
										<xsl:variable name="code"><xsl:apply-templates select="l:caption/node()" mode="csharp-expr"><xsl:with-param name="context">Container.DataItem</xsl:with-param></xsl:apply-templates></xsl:variable>
										@@lt;%# String.Format(WebManager.GetLabel("Edit {0}",this), <xsl:value-of select="$code"/>) %@@gt;
									</xsl:when>
								</xsl:choose>						
							</div>
						</div>
						@@lt;div class="ui-widget-content ui-corner-bottom formview"@@gt;@@lt;div class="nreco-widget-content"@@gt;
					</xsl:if>
					
					<table class="FormView">

						<xsl:if test="count(msxsl:node-set($editHeader)/*)>0">
							<tr class="formheader">
								<td colspan="2">
									<xsl:apply-templates select="msxsl:node-set($editHeader)/l:*" mode="aspnet-renderer">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
										<xsl:with-param name="mode">FormHeader</xsl:with-param>
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:if>

						<xsl:for-each select="l:field[not(@edit) or @edit='true' or @edit='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="edit-form-view-table-row">
										<xsl:with-param name="mode">edit</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid" select="$uniqueId"/>
									</xsl:apply-templates>								
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>						
						</xsl:for-each>

						<xsl:if test="count(msxsl:node-set($editFooter)/*)>0">
							<tr class="formfooter">
								<td colspan="2">
									<xsl:apply-templates select="msxsl:node-set($editFooter)/l:*" mode="aspnet-renderer">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
										<xsl:with-param name="mode">FormFooter</xsl:with-param>
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:if>

					</table>
					<xsl:if test="not(@widget) or @widget='1' or @widget='true'">
						@@lt;/div@@gt;@@lt;/div@@gt;
					</xsl:if>
				</edititemtemplate>
			</xsl:if>
			
			<xsl:if test="$addEnabled='true'">
				<insertitemtemplate>
					<xsl:if test="not(@widget) or @widget='1' or @widget='true'">
						<div class="ui-widget-header ui-corner-top formview">
							<div class="nreco-widget-header">
								<xsl:choose>
									<xsl:when test="@caption"><NReco:Label runat="server">Create <xsl:value-of select="@caption"/></NReco:Label></xsl:when>
									<xsl:when test="l:caption">
										<xsl:variable name="code"><xsl:apply-templates select="l:container/node()" mode="csharp-expr"><xsl:with-param name="context">Container.DataItem</xsl:with-param></xsl:apply-templates></xsl:variable>
										@@lt;%# String.Format(WebManager.GetLabel("Create {0}",this), <xsl:value-of select="$code"/>) %@@gt;
									</xsl:when>
								</xsl:choose>						
							</div>
						</div>
						@@lt;div class="ui-widget-content ui-corner-bottom formview"@@gt;@@lt;div class="nreco-widget-content"@@gt;
					</xsl:if>
					
					<table class="FormView">
						
						<xsl:if test="count(msxsl:node-set($addHeader)/*)>0">
							<tr class="formheader">
								<td colspan="2">
									<xsl:apply-templates select="msxsl:node-set($addHeader)/l:*" mode="aspnet-renderer">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
										<xsl:with-param name="mode">FormHeader</xsl:with-param>
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:if>						
						
						<xsl:for-each select="l:field[not(@add) or @add='true' or @add='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="edit-form-view-table-row">
										<xsl:with-param name="mode">add</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid" select="$uniqueId"/>
									</xsl:apply-templates>								
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>							
						</xsl:for-each>
						
						<xsl:if test="count(msxsl:node-set($addFooter)/*)>0">
							<tr class="formfooter">
								<td colspan="2">
									<xsl:apply-templates select="msxsl:node-set($addFooter)/l:*" mode="aspnet-renderer">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
										<xsl:with-param name="mode">FormFooter</xsl:with-param>
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:if>		
						
					</table>
					<xsl:if test="not(@widget) or @widget='1' or @widget='true'">
						@@lt;/div@@gt;@@lt;/div@@gt;
					</xsl:if>
				</insertitemtemplate>
			</xsl:if>
		</NReco:formview>
			
	</xsl:template>

	<xsl:template match="l:save" mode="form-operation">
		<xsl:param name="formView"/>
		if (<xsl:value-of select="$formView"/>.CurrentMode==FormViewMode.Insert) {
			<xsl:value-of select="$formView"/>.InsertItem(true);
			if (!Page.IsValid) return;
		} else if (<xsl:value-of select="$formView"/>.CurrentMode==FormViewMode.Edit) {
			<xsl:value-of select="$formView"/>.UpdateItem(true);
			if (!Page.IsValid) return;
		}
	</xsl:template>
	
	<xsl:template match="l:*" mode="form-operation">
		<xsl:param name="context"/>
		<xsl:apply-templates select="." mode="csharp-code">
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:field[not(@layout) or @layout='horizontal']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<tr class="horizontal">
			<th>
				<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>:
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
					<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
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
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		
		<tr class="horizontal">
			<th>
				<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
				<xsl:if test=".//l:editor/l:validators/l:required"><span class="required">*</span></xsl:if>:
			</th>
			<td>
				<xsl:apply-templates select="." mode="edit-form-view">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
				</xsl:apply-templates>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="l:field[@layout='vertical']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		
		<xsl:if test="@caption">
			<tr class="vertical">
				<th colspan="2">
					<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
					<xsl:if test="l:editor/l:validators/l:required">
						<span class="required">*</span>
					</xsl:if>
				</th>
			</tr>
		</xsl:if>
		<tr class="vertical">
			<td colspan="2">
				<xsl:apply-templates select="." mode="edit-form-view">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
				</xsl:apply-templates>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="l:field[not(l:group)]" mode="edit-form-view">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:apply-templates select="." mode="form-view-editor">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="form-view-validator">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:field[l:group]" mode="edit-form-view">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		
		<xsl:for-each select="l:group/l:field">
			<div class="formview groupentry">
				<xsl:if test="@caption">
					<span class="caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>:</span>
				</xsl:if>
				<span class="editor">
					<xsl:apply-templates select="." mode="form-view-editor">
						<xsl:with-param name="mode" select="$mode"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="formUid" select="$formUid"/>
					</xsl:apply-templates>
				</span>
				@@lt;div class="validators"@@gt;
					<xsl:apply-templates select="." mode="form-view-validator">
						<xsl:with-param name="mode" select="$mode"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="formUid" select="$formUid"/>
					</xsl:apply-templates>
				@@lt;/div@@gt; <!-- prevent <div/> that makes browsers crazy-->
			</div>
		</xsl:for-each>
	</xsl:template>
	

	<xsl:template match="l:field[not(l:renderer)]" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:variable name="renderer">
			<xsl:choose>
				<xsl:when test="@lookup and @format"><l:format str="{@format}"><l:lookup service="{@lookup}"><l:field name="{@name}"/></l:lookup></l:format></xsl:when>
				<xsl:when test="@format"><l:format str="{@format}"><l:field name="{@name}"/></l:format></xsl:when>
				<xsl:when test="@lookup"><l:lookup service="{@lookup}"><l:field name="{@name}"/></l:lookup></xsl:when>
				<xsl:otherwise><l:field name="{@name}"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="code"><xsl:apply-templates select="msxsl:node-set($renderer)" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">@@lt;%# <xsl:value-of select="$code"/> %@@gt;</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="l:field[l:renderer]" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">		
				<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="l:field[l:group and not(l:renderer)]" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		
		<xsl:apply-templates select="l:group/l:*" mode="aspnet-renderer">
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
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid">Form</xsl:param>
		<NReco:LinkButton ValidationGroup="{$formUid}" id="linkBtn{$mode}{generate-id(.)}" 
			runat="server" CommandName="{@command}" command="{@command}"><!-- command attr for html element as metadata -->
			<xsl:attribute name="Text">
				<xsl:choose>
					<xsl:when test="@caption">@@lt;%$ label:<xsl:value-of select="@caption"/> %@@gt;</xsl:when>
					<xsl:when test="l:caption">@@lt;%# <xsl:apply-templates select="l:caption/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates> %@@gt;</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="CausesValidation">
				<xsl:choose>
					<xsl:when test="@validate='1' or @validate='true'">True</xsl:when>
					<xsl:otherwise>False</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="l:arg/l:*">
				<xsl:variable name="argCode">
					<xsl:apply-templates select="l:arg/l:*" mode="csharp-expr">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:attribute name="CommandArgument">@@lt;%# <xsl:value-of select="$argCode"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="@confirm or @command='delete' or @command='Delete'">
				<xsl:attribute name="AttributeOnClick">
					<xsl:choose>
						<xsl:when test="@confirm">@@lt;%$ label:return confirm("<xsl:value-of select="@confirm"/>") %@@gt;</xsl:when>
						<xsl:otherwise>@@lt;%$ label:return confirm("Are you sure?") %@@gt;</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
		</NReco:LinkButton>
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
			<xsl:if test="@target and not(@target='popup')">
				<xsl:attribute name="target">_<xsl:value-of select="@target"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@target='popup'">
				<xsl:attribute name="onclick">return window.open(this.href,"popup","status=0,toolbar=0,location=0,width=800,height=600") @@amp;@@amp;false</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></xsl:when>
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
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<!-- lets just render this item if editor is not specific -->
		<xsl:apply-templates select="." mode="aspnet-renderer">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:textbox]" mode="form-view-editor">
		<Plugin:TextBoxEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" Text='@@lt;%# Bind("{@name}") %@@gt;'>
			<xsl:if test="l:editor/l:textbox/@empty-is-null='1' or l:editor/l:textbox/@empty-is-null='true'">
				<xsl:attribute name="EmptyIsNull">True</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textbox/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:textbox/@width"/></xsl:attribute>
			</xsl:if>
		</Plugin:TextBoxEditor>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:usercontrol]" mode="form-view-editor">
		<xsl:element name="UserControlEditor:{l:editor/l:usercontrol/@name}">
			<xsl:attribute name="runat">server</xsl:attribute>
			<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
			<xsl:if test="@name">
				<xsl:attribute name="Value">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="l:editor/l:usercontrol/@*|l:editor/l:usercontrol/l:*">
				<xsl:if test="not(name()='src' or name()='name' or name()='')">
					<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>		
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:textbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="TextBoxEditor" src="~/templates/editors/TextBoxEditor.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:textarea]" mode="form-view-editor">
		<asp:TextBox id="{@name}" runat="server" Text='@@lt;%# Bind("{@name}") %@@gt;' TextMode='multiline'>
			<xsl:if test="l:editor/l:textarea/@rows">
				<xsl:attribute name="Rows"><xsl:value-of select="l:editor/l:textarea/@rows"/></xsl:attribute>
			</xsl:if>
		</asp:TextBox>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:numbertextbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="NumberTextBoxEditor" src="~/templates/editors/NumberTextBoxEditor.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:numbertextbox]" mode="form-view-editor">
		<Plugin:NumberTextBoxEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" Value='@@lt;%# Bind("{@name}") %@@gt;'>
			<xsl:if test="l:editor/l:numbertextbox/@format">
				<xsl:attribute name="Format"><xsl:value-of select="l:editor/l:numbertextbox/@format"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:numbertextbox/@type">
				<xsl:attribute name="Type">
					<xsl:choose>
						<xsl:when test="l:editor/l:numbertextbox/@type='integer'">Int32</xsl:when>
						<xsl:when test="l:editor/l:numbertextbox/@type='decimal'">Decimal</xsl:when>
						<xsl:when test="l:editor/l:numbertextbox/@type='double'">Double</xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:numbertextbox/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:numbertextbox/@width"/></xsl:attribute>
			</xsl:if>			
		</Plugin:NumberTextBoxEditor>
	</xsl:template>	

	<xsl:template match="l:field[l:editor/l:checkbox]" mode="form-view-editor">
		<asp:CheckBox id="{@name}" runat="server" Checked='@@lt;%# Bind("{@name}") %@@gt;'/>
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:filtertextbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="FilterTextBoxEditor" src="~/templates/editors/FilterTextBoxEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:filtertextbox]" mode="form-view-editor">
		<Plugin:FilterTextBoxEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" Text='@@lt;%# Bind("{@name}") %@@gt;'/>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:passwordtextbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="PasswordTextBoxEditor" src="~/templates/editors/PasswordTextBoxEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:passwordtextbox]" mode="form-view-editor">
		<Plugin:PasswordTextBoxEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" 
			Value='@@lt;%# Bind("{@name}") %@@gt;'
			PasswordEncrypterName="{l:editor/l:passwordtextbox/@encrypter}"/>
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:dropdownlist]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="DropDownListEditor" src="~/templates/editors/DropDownListEditor.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:dropdownlist]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<xsl:param name="formUid"/>
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
		<Plugin:DropDownListEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" SelectedValue='@@lt;%# Bind("{@name}") %@@gt;'
			LookupName='{$lookupPrvName}'
			ValueFieldName="{$valueName}"
			TextFieldName="{$textName}">
			<xsl:attribute name="Required">
				<xsl:choose>
					<xsl:when test="l:editor/l:validators/l:required">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="l:editor/l:dropdownlist/l:context">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:dropdownlist/l:context/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:dropdownlist/l:context//l:control">
				<xsl:attribute name="DependentFromControls">
					<xsl:for-each select="l:editor/l:dropdownlist/l:context//l:control">
						<xsl:if test="position()!=1">,</xsl:if>
						<xsl:value-of select="@name"/>
					</xsl:for-each>
				</xsl:attribute>
				<xsl:attribute name="DataContextControl"><xsl:value-of select="@name"/>DataContextHolder</xsl:attribute>
			</xsl:if>
		</Plugin:DropDownListEditor>
		<xsl:if test="l:editor/l:dropdownlist/l:context//l:control">
			<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:dropdownlist/l:context/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
			<NReco:DataContextHolder id="{@name}DataContextHolder" runat="server">
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</NReco:DataContextHolder>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="CheckBoxListRelationEditor" src="~/templates/editors/CheckBoxListRelationEditor.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="form-view-editor">
		<Plugin:CheckBoxListRelationEditor xmlns:Plugin="urn:remove" runat="server" 
			DalcServiceName="{$dalcName}"
			LookupServiceName="{l:editor/l:checkboxlist/l:lookup/@name}"
			TextFieldName="{l:editor/l:checkboxlist/l:lookup/@text}"
			ValueFieldName="{l:editor/l:checkboxlist/l:lookup/@value}"
			RelationSourceName="{l:editor/l:checkboxlist/l:relation/@sourcename}"
			LFieldName="{l:editor/l:checkboxlist/l:relation/@left}"
			RFieldName="{l:editor/l:checkboxlist/l:relation/@right}">
			<xsl:choose>
				<xsl:when test="l:editor/l:checkboxlist/@id">
					<xsl:attribute name="EntityId">@@lt;%# Eval("<xsl:value-of select="l:editor/l:checkboxlist/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField"><xsl:value-of select="l:editor/l:checkboxlist/@id"/></xsl:attribute>
				</xsl:when>
				<!--xsl:otherwise>
					<xsl:attribute name="EntityId">@@lt;%# FormView.DataKey.Value %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# FormView.DataKeyNames[0] %@@gt;</xsl:attribute>
				</xsl:otherwise-->
			</xsl:choose>
			
		</Plugin:CheckBoxListRelationEditor>
	</xsl:template>
	
	<xsl:template match="l:field" mode="form-view-validator">
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:apply-templates select="l:editor/l:validators/*" mode="form-view-validator">
			<xsl:with-param name="controlId" select="@name"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:required" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:requiredfieldvalidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			ErrorMessage="@@lt;%$ label: Required Field %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true"/>	
	</xsl:template>

	<xsl:template match="l:regex" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			ValidationExpression="{.}"
			ErrorMessage="@@lt;%$ label: Invalid value %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true"/>	
	</xsl:template>
	
	<xsl:template match="l:email" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}" 
			ErrorMessage="@@lt;%$ label: Invalid email %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true">
			<xsl:attribute name="ValidationExpression">[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}</xsl:attribute>
		</asp:RegularExpressionValidator>
	</xsl:template>
	
	<xsl:template match="l:decimal" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			ErrorMessage="@@lt;%$ label: Invalid number %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true">
			<xsl:attribute name="ValidationExpression">@@lt;%# "[0-9]{1,10}(["+System.Globalization.CultureInfo.CurrentCulture.NumberFormat.NumberDecimalSeparator+"][0-9]{1,10}){0,1}" %@@gt;</xsl:attribute>
		</asp:RegularExpressionValidator>
	</xsl:template>	

	<xsl:template match="l:maxlength" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			ErrorMessage="@@lt;%$ label: Too long %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true">
			<xsl:attribute name="ValidationExpression">[\w\s\W]{0,<xsl:value-of select="."/>}</xsl:attribute>
		</asp:RegularExpressionValidator>
	</xsl:template>

	
	<xsl:template match="l:chooseone" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:customvalidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			ChooseOneGroup="{@group}"
			OnServerValidate="ChooseOneServerValidate"
			ErrorMessage="@@lt;%$ label: Choose one %@@gt;" controltovalidate="{$controlId}" EnableClientScript="false">
		</asp:customvalidator>
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
				<xsl:when test="l:condition"><xsl:value-of select="l:condition"/></xsl:when>
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
				<xsl:attribute name="OnSelecting"><xsl:value-of select="@id"/>_OnSelecting</xsl:attribute>
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
			protected void <xsl:value-of select="@id"/>_OnSelecting(object sender,DalcDataSourceSelectEventArgs e) {
				var prv = new NI.Data.RelationalExpressions.RelExQueryNodeProvider() {
					RelExQueryParser = new NI.Data.RelationalExpressions.RelExQueryParser(false),
					RelExCondition = <xsl:value-of select="@id"/>_relex.Value,
					ExprResolver = WebManager.GetService@@lt;NI.Common.Expressions.IExpressionResolver@@gt;("defaultExprResolver")
				};
				var context = this.GetContext();
				e.SelectQuery.Root = prv.GetQueryNode( NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;(context) );
			}
			</script>
		</xsl:if>
	</xsl:template>
		
	<xsl:template match="l:updatepanel" name="updatepanel" mode="aspnet-renderer">
		<asp:UpdatePanel runat="server">
			<xsl:attribute name="UpdateMode">
				<xsl:choose>
					<xsl:when test="@refresh='conditional'">Conditional</xsl:when>
					<xsl:when test="@refresh='always'">Always</xsl:when>
					<xsl:otherwise>Conditional</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<ContentTemplate>
				<xsl:apply-templates select="node()" mode="aspnet-renderer"/>
			</ContentTemplate>
		</asp:UpdatePanel>
	</xsl:template>

	<xsl:template match="l:ul" mode="aspnet-renderer">
		<xsl:call-template name="repeater-aspnet-renderer">
			<xsl:with-param name="header">@@lt;ul@@gt;</xsl:with-param>
			<xsl:with-param name="footer">@@lt;/ul@@gt;</xsl:with-param>
			<xsl:with-param name="itemHeader">@@lt;li@@gt;</xsl:with-param>
			<xsl:with-param name="itemFooter">@@lt;/li@@gt;</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="l:ol" mode="aspnet-renderer">
		<xsl:call-template name="repeater-aspnet-renderer">
			<xsl:with-param name="header">@@lt;ol@@gt;</xsl:with-param>
			<xsl:with-param name="footer">@@lt;/ol@@gt;</xsl:with-param>
			<xsl:with-param name="itemHeader">@@lt;li@@gt;</xsl:with-param>
			<xsl:with-param name="itemFooter">@@lt;/li@@gt;</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="l:repeater" name="repeater-aspnet-renderer" mode="aspnet-renderer">
		<xsl:param name="header" select="l:header"/>
		<xsl:param name="footer" select="l:footer"/>
		<xsl:param name="itemHeader"/>
		<xsl:param name="itemFooter"/>
		<xsl:param name="separator">
			<xsl:choose>
				<xsl:when test="@separator"><xsl:value-of select="@separator"/></xsl:when>
				<xsl:when test="l:separator"><xsl:value-of select="l:separator"/></xsl:when>
			</xsl:choose>
		</xsl:param>
		<asp:Repeater runat="server">
			<xsl:choose>
				<xsl:when test="@datasource"><xsl:attribute name="DataSourceID"><xsl:value-of select="@datasource"/></xsl:attribute></xsl:when>
				<xsl:when test="l:provider">
					<xsl:variable name="prvContext">
						<xsl:choose>
							<xsl:when test="l:provider/l:*"><xsl:apply-templates select="l:provider/l:*" mode="csharp-expr"/></xsl:when>
							<xsl:otherwise>null</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:attribute name="DataSource">@@lt;%# DataSourceHelper.GetProviderDataSource("<xsl:value-of select="l:provider/@name"/>", <xsl:value-of select="$prvContext"/>) %@@gt;</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="not($header='')">
				<HeaderTemplate><xsl:value-of select="$header"/></HeaderTemplate>
			</xsl:if>
			<ItemTemplate>
				<xsl:value-of select="$itemHeader"/>
				<xsl:choose>
					<xsl:when test="l:item">
						<xsl:apply-templates select="l:item/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context">Container.DataItem</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>@@lt;%# Container.DataItem %@@gt;</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$itemFooter"/>
			</ItemTemplate>
			<xsl:if test="not($separator='')">
				<SeparatorTemplate><xsl:value-of select="$separator"/></SeparatorTemplate>
			</xsl:if>
			<xsl:if test="not($footer='')">
				<FooterTemplate><xsl:value-of select="$footer"/></FooterTemplate>
			</xsl:if>
		</asp:Repeater>
	</xsl:template>
	
	<xsl:template match="l:listdisplayindex" mode="aspnet-renderer">
		@@lt;%# (Container is ListViewDataItem ? (object)(((ListViewDataItem)Container).DisplayIndex+1) : null) %@@gt;
	</xsl:template>
	
	<xsl:template match="l:list" mode="aspnet-renderer">
		<xsl:variable name="listUniqueId">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
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


		<xsl:if test="l:filter">
			<xsl:variable name="filterForm">filterForm<xsl:value-of select="$listUniqueId"/></xsl:variable>
			<NReco:FilterView runat="server" id="listFilterView{$listUniqueId}"
				OnDataBinding="listFilter{$listUniqueId}_OnDataBinding"
				OnFilter="listFilter{$listUniqueId}_OnFilter">
				<Template>
					<div class="ui-state-default listViewFilter">
						<xsl:for-each select="l:filter/l:field">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="list-view-filter-editor">
										<xsl:with-param name="mode">filter</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid">listFilter<xsl:value-of select="$listUniqueId"/></xsl:with-param>
									</xsl:apply-templates>									
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>								
						</xsl:for-each>						
						<div class="clear" style="font-size:1px;">@@amp;nbsp;</div>
					</div>
				</Template>
			</NReco:FilterView>
		</xsl:if>
				
		<NReco:ListView ID="listView{$listUniqueId}"
			DataSourceID="list{$listUniqueId}ActionDataSource"
			DataKeyNames="id"
			ItemContainerID="itemPlaceholder"
			OnLoad="listView{$listUniqueId}_OnLoad"
			OnDataBinding="listView{$listUniqueId}_OnDataBinding"
			OnItemCommand="listView{$listUniqueId}_OnItemCommand"
			ConvertEmptyStringToNull="false"
			OnItemDeleting="listView{$listUniqueId}_OnItemDeleting"
			OnItemDeleted="listView{$listUniqueId}_OnItemDeleted"
			OnItemUpdating="listView{$listUniqueId}_OnItemUpdating"
			OnItemUpdated="listView{$listUniqueId}_OnItemUpdated"
			runat="server">
			<xsl:attribute name="DataKeyNames">
				<xsl:choose>
					<xsl:when test="@datakey"><xsl:value-of select="@datakey"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$listDefaults/@datakey"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="@add='true' or @add='1'">
				<xsl:attribute name="InsertItemPosition">LastItem</xsl:attribute>
				<xsl:attribute name="OnItemInserting">listView<xsl:value-of select="$listUniqueId"/>_OnItemInserting</xsl:attribute>
				<xsl:attribute name="OnItemInserted">listView<xsl:value-of select="$listUniqueId"/>_OnItemInserted</xsl:attribute>
			</xsl:if>
			<LayoutTemplate>
				
				<table class="listView">
					<xsl:if test="@name">
						<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
					</xsl:if>
					<tr>
						<xsl:if test="not(@headers) or @headers='1' or @headers='true'">
							<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
								<xsl:call-template name="apply-visibility">
									<xsl:with-param name="content"><xsl:apply-templates select="." mode="list-view-table-header"/></xsl:with-param>
									<xsl:with-param name="expr" select="l:visible/node()"/>
								</xsl:call-template>								
							</xsl:for-each>
						</xsl:if>
					</tr>
					<tr runat="server" id="itemPlaceholder" />
					
					<xsl:if test="not(l:pager/@allow='false' or l:pager/@allow='0')">
						<tr class="pager"><td class="ui-state-default listcell" colspan="{count(l:field[not(@view) or @view='true' or @view='1'])}">
						  <asp:DataPager ID="DataPager1" runat="server">
							<xsl:if test="l:pager/@pagesize">
								<xsl:attribute name="PageSize"><xsl:value-of select="l:pager/@pagesize"/></xsl:attribute>
							</xsl:if>
							<Fields>
							  <asp:NumericPagerField />
							</Fields>
						  </asp:DataPager>
						</td></tr>
					</xsl:if>
				</table>
			</LayoutTemplate>
			<ItemTemplate>
				<tr class="item">
					<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
						<xsl:call-template name="apply-visibility">
							<xsl:with-param name="content">
								<xsl:apply-templates select="." mode="list-view-table-cell">
									<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								</xsl:apply-templates>								
							</xsl:with-param>
							<xsl:with-param name="expr" select="l:visible/node()"/>
						</xsl:call-template>								
					</xsl:for-each>			
				</tr>
			</ItemTemplate>
			<xsl:if test="@edit='true' or @edit='1'">
				<EditItemTemplate>
					<tr class="editItem">
						<xsl:for-each select="l:field[not(@edit) or @edit='true' or @edit='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">					
									<xsl:apply-templates select="." mode="list-view-table-cell-editor">
										<xsl:with-param name="mode">edit</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid">@@lt;%# String.Format("ListForm{0}", Container.DataItem.GetHashCode() ) %@@gt;</xsl:with-param>
									</xsl:apply-templates>
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>
						</xsl:for-each>
					</tr>
				</EditItemTemplate>
			</xsl:if>
			<xsl:if test="@add='true' or @add='1'">
				<InsertItemTemplate>
					<tr class="insertItem">
						<xsl:for-each select="l:field[not(@add) or @add='true' or @add='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">						
									<xsl:apply-templates select="." mode="list-view-table-cell-editor">
										<xsl:with-param name="mode">add</xsl:with-param>
										<xsl:with-param name="context">(Container is IDataItemContainer ? ((IDataItemContainer)Container).DataItem : new object() )</xsl:with-param>
										<xsl:with-param name="formUid">ListForm<xsl:value-of select="$listUniqueId"/></xsl:with-param>
									</xsl:apply-templates>
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>
						</xsl:for-each>
					</tr>
				</InsertItemTemplate>
			</xsl:if>
		</NReco:ListView>
		<xsl:if test="@name">
			<script type="text/javascript">
			$(function() {
				var listRowCnt = @@lt;%=GetListViewRowCount( this.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;().Where( c=@@gt;c.ID=="listView<xsl:value-of select="@name"/>").FirstOrDefault() ) %@@gt;;
				if (listRowCnt@@gt;=0)
					$('.listRowCount<xsl:value-of select="$listUniqueId"/>').html(listRowCnt);
			});
			</script>
		</xsl:if>
		
		<script language="c#" runat="server">
		<xsl:if test="l:filter">
			protected void listFilter<xsl:value-of select="$listUniqueId"/>_OnDataBinding(object sender, EventArgs e) {
				var filter = (NReco.Web.Site.Controls.FilterView)sender;
				// init filter properties
				var viewContext = this.GetContext();
				<xsl:for-each select="l:filter//l:field[@name]">
					filter.Values["<xsl:value-of select="@name"/>"] = viewContext["<xsl:value-of select="@name"/>"];
				</xsl:for-each>
			}
			protected void listFilter<xsl:value-of select="$listUniqueId"/>_OnFilter(object sender, EventArgs e) {
				var filter = (NReco.Web.Site.Controls.FilterView)sender;
				if (DataContext!=null)
					foreach (DictionaryEntry entry in filter.Values)
						DataContext[entry.Key.ToString()] = entry.Value;
				filter.NamingContainer.FindControl("listView<xsl:value-of select="$listUniqueId"/>").DataBind();
			}
		</xsl:if>
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnDataBinding(Object sender, EventArgs e) {
			<!-- initializing data-related settings (key names, insert data item etc) -->
			<!-- heuristics for DALC data source (refactor TODO) -->
			var dataSource = <xsl:value-of select="$mainDsId"/>;
			if (dataSource is NI.Data.Dalc.Web.DalcDataSource) {
				var dalcDataSource = (NI.Data.Dalc.Web.DalcDataSource)dataSource;
				if (dalcDataSource.DataKeyNames!=null @@amp;@@amp; dalcDataSource.DataKeyNames.Length @@gt; 0)
					((System.Web.UI.WebControls.ListView)sender).DataKeyNames = dalcDataSource.DataKeyNames;
				if (dalcDataSource.DataSetProvider!=null) {
					var ds = dalcDataSource.DataSetProvider.GetDataSet(dalcDataSource.SourceName);
					if (ds!=null) {
						var newItem = new NReco.Collections.DictionaryView( 
							NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;( ds.Tables[0].NewRow() ) );
						((NReco.Web.Site.Controls.ListView)sender).InsertDataItem = newItem;
						<!-- initialize action -->
						<xsl:apply-templates select="l:action[@name='initialize']/l:*" mode="csharp-code">
							<xsl:with-param name="context">newItem</xsl:with-param>
						</xsl:apply-templates>
					}
				}
			}
		}
		
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnLoad(Object sender, EventArgs e) {
			<!-- applying initial sorting -->
			<xsl:if test="l:sort">
				<xsl:variable name="directionResolved">
					<xsl:choose>
						<xsl:when test="l:sort/@direction='asc'">Ascending</xsl:when>
						<xsl:otherwise>Descending</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				if ( String.IsNullOrEmpty( ((System.Web.UI.WebControls.ListView)sender).SortExpression ) )
					((System.Web.UI.WebControls.ListView)sender).Sort( "<xsl:value-of select="l:sort/@field"/>", SortDirection.<xsl:value-of select="$directionResolved"/> );
			</xsl:if>
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemCommand(Object sender, ListViewCommandEventArgs  e) {
			if (e.CommandName!="Update" @@amp;@@amp; e.CommandName!="Insert" @@amp;@@amp; e.CommandName!="Delete") {
				ActionContext context = new ActionContext(e) { Sender = sender, Origin = this };
				WebManager.ExecuteAction(context);
			}
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemDeleting(Object sender, ListViewDeleteEventArgs e) {
			((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("list<xsl:value-of select="$listUniqueId"/>ActionDataSource")).ActionSourceControl = ((System.Web.UI.WebControls.ListView)sender).Items[e.ItemIndex];
			<xsl:apply-templates select="l:action[@name='deleting']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e.Keys</xsl:with-param>
			</xsl:apply-templates>
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemDeleted(Object sender, ListViewDeletedEventArgs e) {
			<xsl:apply-templates select="l:action[@name='deleted']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e.Keys</xsl:with-param>
			</xsl:apply-templates>
		}	
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemUpdating(Object sender, ListViewUpdateEventArgs e) {
			((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("list<xsl:value-of select="$listUniqueId"/>ActionDataSource")).ActionSourceControl = ((System.Web.UI.WebControls.ListView)sender).Items[e.ItemIndex];
			<xsl:apply-templates select="l:action[@name='updating']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e.Keys</xsl:with-param>
			</xsl:apply-templates>
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemUpdated(Object sender, ListViewUpdatedEventArgs e) {
			<xsl:apply-templates select="l:action[@name='updated']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e.Keys</xsl:with-param>
			</xsl:apply-templates>
		}			
		</script>
		<xsl:if test="@add='true' or @add='1'">
			<script language="c#" runat="server">
			protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemInserting(Object sender, ListViewInsertEventArgs e) {
				((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("list<xsl:value-of select="$listUniqueId"/>ActionDataSource")).ActionSourceControl = e.Item;
				<xsl:apply-templates select="l:action[@name='inserting']/l:*" mode="csharp-code">
					<xsl:with-param name="context">e.Values</xsl:with-param>
				</xsl:apply-templates>
			}
			protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemInserted(Object sender, ListViewInsertedEventArgs e) {
				<xsl:apply-templates select="l:action[@name='inserted']/l:*" mode="csharp-code">
					<xsl:with-param name="context">e.Values</xsl:with-param>
				</xsl:apply-templates>
			}
			</script>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="l:field" mode="list-view-filter-editor">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<div class="listViewFilterField">
			<xsl:if test="@caption">
				<div class="caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></div>
			</xsl:if>
			<xsl:apply-templates select="." mode="form-view-editor">
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>		

	<xsl:template match="l:field[l:group]" mode="list-view-filter-editor">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<div class="listViewFilterField" style="width:100%">
			<fieldset>
				<xsl:if test="@caption">
					<legend><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></legend>
				</xsl:if>
				<xsl:for-each select="l:group/l:field">
					<xsl:apply-templates select="." mode="list-view-filter-editor">
						<xsl:with-param name="mode" select="$mode"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="formUid" select="$formUid"/>
					</xsl:apply-templates>
				</xsl:for-each>
				<div class="clear" style="font-size:1px;">@@amp;nbsp;</div>
			</fieldset>				
		</div>
	</xsl:template>
	
	<xsl:template match="l:field[(@sort='true' or @sort='1') and @name]" mode="list-view-table-header">
		<th class="ui-state-default"><asp:LinkButton id="sortBtn{generate-id(.)}" CausesValidation="false" runat="server" Text="@@lt;%$ label:{@caption} %@@gt;" CommandName="Sort" CommandArgument="{@name}" OnPreRender="ListViewSortButtonPreRender"/></th>
	</xsl:template>
	
	<xsl:template match="l:field" mode="list-view-table-header">
		<th class="ui-state-default">
			<xsl:choose>
				<xsl:when test="@caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></xsl:when>
				<xsl:otherwise>@@amp;nbsp;</xsl:otherwise>
			</xsl:choose>
		</th>
	</xsl:template>

	<xsl:template match="l:field[l:editor]" mode="list-view-table-cell-editor">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<td class="ui-state-default listcell">
			<xsl:apply-templates select="." mode="form-view-editor">
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
			</xsl:apply-templates>
			<div class="validators">
				<xsl:apply-templates select="." mode="form-view-validator">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
				</xsl:apply-templates>
			</div>
		</td>
	</xsl:template>
	
	<xsl:template match="l:field[not(l:editor)]" mode="list-view-table-cell-editor">
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:apply-templates select="." mode="list-view-table-cell">
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:field[l:group]" mode="list-view-table-cell-editor" priority="10">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<td class="ui-state-default listcell edit">
		<xsl:for-each select="l:group/l:field">
			<xsl:call-template name="apply-visibility">
				<xsl:with-param name="content">					
					<div class="listview groupentry">
						<xsl:if test="@caption">
							<span class="caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>:</span>
						</xsl:if>
						<span class="editor">
							<xsl:apply-templates select="." mode="form-view-editor">
								<xsl:with-param name="mode" select="$mode"/>
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="formUid" select="$formUid"/>
							</xsl:apply-templates>
						</span>
						@@lt;div class="validators"@@gt;
							<xsl:apply-templates select="." mode="form-view-validator">
								<xsl:with-param name="mode" select="$mode"/>
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="formUid" select="$formUid"/>
							</xsl:apply-templates>
						@@lt;/div@@gt; <!-- prevent <div/> that makes browsers crazy-->
					</div>
				</xsl:with-param>
				<xsl:with-param name="expr" select="l:visible/node()"/>
			</xsl:call-template>		
		</xsl:for-each>
		</td>
	</xsl:template>	
	
	<xsl:template match="l:field[@name and not(l:renderer)]" mode="list-view-table-cell">
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<td class="ui-state-default listcell">
			<xsl:apply-templates select="." mode="aspnet-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
			</xsl:apply-templates>
		</td>
	</xsl:template>

	<xsl:template match="l:field[l:group]" mode="list-view-table-cell">
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>	
		<td class="ui-state-default listcell">
		<xsl:for-each select="l:group/l:field">
			<xsl:call-template name="apply-visibility">
				<xsl:with-param name="content">			
					<div class="listview groupentry">
						<xsl:if test="@caption">
							<span class="caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>:</span>
						</xsl:if>			
						<xsl:apply-templates select="." mode="aspnet-renderer">
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="formUid" select="$formUid"/>
						</xsl:apply-templates>
					</div>
				</xsl:with-param>
				<xsl:with-param name="expr" select="l:visible/node()"/>
			</xsl:call-template>			
		</xsl:for-each>			
		</td>
	</xsl:template>
	
	<xsl:template match="l:field[l:renderer]" mode="list-view-table-cell">
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<td class="ui-state-default listcell">
			<xsl:for-each select="l:renderer/l:*">
				<xsl:if test="position()!=1">@@amp;nbsp;</xsl:if>
				<xsl:apply-templates select="." mode="aspnet-renderer">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</td>
	</xsl:template>
	
	<xsl:template match="l:dashboard" mode="aspnet-renderer">
		<xsl:variable name="uniqueId">dashboard<xsl:value-of select="generate-id(.)"/></xsl:variable>
		<div class="dashboard" id="{$uniqueId}">
			<xsl:apply-templates select="l:*" mode="dashboard-widget"/>
			@@lt;div style="clear:both;"@@gt;@@lt;/div@@gt;
		</div>
	</xsl:template>
	<xsl:template match="l:row" mode="dashboard-widget">
		<xsl:variable name="uniqueId">dashboard_row_<xsl:value-of select="generate-id(.)"/></xsl:variable>
		<div id="{$uniqueId}" style="clear:both;">
			<xsl:apply-templates select="l:*" mode="dashboard-widget"/>
		</div>
		<script type="text/javascript">
			if (jQuery) jQuery(function(){
				var maxHeight = 0;
				jQuery('#<xsl:value-of select="$uniqueId"/>@@gt;*').each(function() { maxHeight=Math.max(maxHeight, jQuery(this).height() );  }).height(maxHeight);
			});
		</script>
	</xsl:template>
	<xsl:template match="l:widget" mode="dashboard-widget">
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">
				<fieldset>
					<xsl:if test="@caption">
						<legend><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></legend>
					</xsl:if>
					<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer"/>
				</fieldset>				
			</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
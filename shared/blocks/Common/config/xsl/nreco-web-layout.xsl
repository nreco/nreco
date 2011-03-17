<!--
NReco library (http://nreco.googlecode.com/)
Copyright 2008-2011 Vitaliy Fedorchenko
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
	<xsl:variable name="linkButtonDefaults" select="/components/default/linkbutton"/>

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
					<xsl:if test="$expr//l:control">
						<xsl:attribute name="DependentFromControls">
							<xsl:for-each select="$expr//l:control">
								<xsl:if test="position()!=1">,</xsl:if>
								<xsl:value-of select="@name"/>
							</xsl:for-each>
						</xsl:attribute>
					</xsl:if>
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
		<xsl:choose>
			<xsl:when test="@mode='clientside'">
				ScriptManager.RegisterClientScriptBlock( Page,typeof(System.Web.UI.Page),"redirectScript",
					String.Format("location.assign(\"{0}\");",<xsl:value-of select="$url"/>), true);
			</xsl:when>
			<xsl:otherwise>Response.Redirect(<xsl:value-of select="$url"/>, false);</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="l:databind" mode="csharp-code">
		<xsl:if test="(not(@mode) and not(l:*)) or @mode='notpostback'">if (!IsPostBack) {</xsl:if>
			<xsl:choose>
				<xsl:when test="l:*">
					<xsl:apply-templates select="l:*" mode="control-instance-expr"/>.DataBind();
				</xsl:when>
				<xsl:otherwise>
					DataBind();
					if (ScriptManager.GetCurrent(Page).IsInAsyncPostBack) {
						foreach (var updatePanel in this.GetChildren@@lt;System.Web.UI.UpdatePanel@@gt;())
							if (updatePanel.UpdateMode==UpdatePanelUpdateMode.Conditional)
								updatePanel.Update();
					}
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
		WebManager.GetService@@lt;NReco.IOperation@@lt;object@@gt;@@gt;("<xsl:value-of select="@name"/>").Execute( <xsl:value-of select="$operationContext"/> );
	</xsl:template>	
	
	<xsl:template match="l:set" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="valExpr">
			<xsl:apply-templates select="l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		CastToDictionary(<xsl:value-of select="$context"/>)["<xsl:value-of select="@name"/>"] = (object)(<xsl:value-of select="$valExpr"/>) ?? DBNull.Value;
	</xsl:template>

	<xsl:template match="l:if" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="testExpr">
			<xsl:apply-templates select="l:test/l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		if (Convert.ToBoolean(<xsl:value-of select="$testExpr"/>)) {
			<xsl:apply-templates select="l:then/l:*" mode="csharp-code">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>			
		} <xsl:if test="l:else">
			else {
				<xsl:apply-templates select="l:else/l:*" mode="csharp-code">
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>					
			}
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="l:setdatacontext" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="valExpr">
			<xsl:apply-templates select="l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		this.DataContext["<xsl:value-of select="@name"/>"] = (object)(<xsl:value-of select="$valExpr"/>);
	</xsl:template>	
	
	<xsl:template match="l:setformcurrentmode" mode="csharp-code">
		this.GetChildren@@lt;System.Web.UI.WebControls.FormView@@gt;().Where( c=@@gt;c.ID=="FormView<xsl:value-of select="@name"/>").FirstOrDefault().ChangeMode(FormViewMode.<xsl:value-of select="@mode"/>);
	</xsl:template>

	<xsl:template match="l:saveform" mode="csharp-code">
		<xsl:variable name="tmpVarName" select="generate-id(.)"/>
		var form<xsl:value-of select="$tmpVarName"/> = this.GetChildren@@lt;System.Web.UI.WebControls.FormView@@gt;().Where( c=@@gt;c.ID=="FormView<xsl:value-of select="@name"/>").FirstOrDefault();
		if (form<xsl:value-of select="$tmpVarName"/>.CurrentMode==FormViewMode.Insert) {
			form<xsl:value-of select="$tmpVarName"/>.InsertItem(true);
		} else if (form<xsl:value-of select="$tmpVarName"/>.CurrentMode==FormViewMode.Edit) {
			form<xsl:value-of select="$tmpVarName"/>.UpdateItem(true);
		}
		if (!Page.IsValid) return;
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
		this.GetRouteUrlSafe("<xsl:value-of select="@name"/>", CastToDictionary(<xsl:value-of select="$routeContext"/>) )
	</xsl:template>
	
	<xsl:template match="l:context" mode="csharp-expr">
		this.GetContext()<xsl:if test="@name">["<xsl:value-of select="@name"/>"]</xsl:if>
	</xsl:template>
	
	<xsl:template match="l:code" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:value-of select="." disable-output-escaping="yes"/>
	</xsl:template>
	
	<xsl:template match="l:not" mode="csharp-expr">
		<xsl:param name="context"/>
		!IsFuzzyTrue(<xsl:apply-templates select="node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)
	</xsl:template>

	<xsl:template match="l:or" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:for-each select="l:*">
			<xsl:if test="position()>1">||</xsl:if>
			IsFuzzyTrue(<xsl:apply-templates select="." mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="l:and" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:for-each select="l:*">
			<xsl:if test="position()>1">@@amp;@@amp;</xsl:if>
			IsFuzzyTrue(<xsl:apply-templates select="." mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="l:isempty" mode="csharp-expr">
		<xsl:param name="context"/>
		IsFuzzyEmpty(<xsl:apply-templates select="node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)
	</xsl:template>
	
	<xsl:template match="l:eq" mode="csharp-expr">
		<xsl:param name="context"/>
		AreEquals(<xsl:apply-templates select="node()[position()=1]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>,<xsl:apply-templates select="node()[position()=2]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)
	</xsl:template>
	
	<xsl:template match="l:request" mode="csharp-expr">
		Request["<xsl:value-of select="@name"/>"]
	</xsl:template>
	
	<xsl:template match="l:const" mode="csharp-expr">"<xsl:value-of select="."/>"</xsl:template>
	
	<xsl:template match="l:format" name="format-csharp-expr" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:param name="str" select="@str"/>
		String.Format(WebManager.GetLabel("<xsl:value-of select="$str"/>",this) <xsl:for-each select="l:*">,<xsl:apply-templates select="." mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:for-each>)
	</xsl:template>

	<xsl:template match="l:listrowcount" mode="csharp-expr">
		String.Format("@@lt;span class='listRowCount<xsl:value-of select="@name"/>'@@gt;{0}@@lt;/span@@gt;", GetListViewRowCount( this.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;().Where( c=@@gt;c.ID=="listView<xsl:value-of select="@name"/>").FirstOrDefault() ) )
	</xsl:template>

	<xsl:template match="l:listselectedkeys" mode="csharp-expr">
		GetListSelectedKeys( this.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;().Where( c=@@gt;c.ID=="listView<xsl:value-of select="@name"/>").FirstOrDefault() ) 
	</xsl:template>
	
	<xsl:template match="l:formcurrentmode" mode="csharp-expr">
		this.GetChildren@@lt;System.Web.UI.WebControls.FormView@@gt;().Where( c=@@gt;c.ID=="FormView<xsl:value-of select="@name"/>").FirstOrDefault().CurrentMode.ToString()
	</xsl:template>

	<xsl:template match="l:lookup" name="lookup-csharp-expr" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:param name="service" select="@service"/>
		WebManager.GetService@@lt;NReco.IProvider@@lt;object,object@@gt;@@gt;("<xsl:value-of select="@service"/>").Provide( <xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates> )
	</xsl:template>
	
	<xsl:template match="l:field" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:choose>
			<xsl:when test="not($context='')">CastToDictionary(<xsl:value-of select="$context"/>)["<xsl:value-of select="@name"/>"]</xsl:when>
			<xsl:otherwise>Eval("<xsl:value-of select="@name"/>")</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="l:dataitem" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:choose>
			<xsl:when test="not($context='')">CastToDictionary(<xsl:value-of select="$context"/>)</xsl:when>
			<xsl:otherwise>CastToDictionary(Container.DataItem)</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="@name">["<xsl:value-of select="@name"/>"]</xsl:if>
	</xsl:template>
	
	<xsl:template match="l:control" mode="csharp-expr">
		GetControlValue(Container, "<xsl:value-of select="@name"/>")
	</xsl:template>
	
	<xsl:template match="l:provider" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:variable name="usecache">
			<xsl:choose>
				<xsl:when test="@cache='true'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>			
		</xsl:variable>
		DataSourceHelper.GetProviderObject("<xsl:value-of select="@name"/>", <xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>, <xsl:value-of select="$usecache"/>)</xsl:template>
	
	<xsl:template match="l:get" mode="csharp-expr">
		<xsl:param name="context"/>
		CastToDictionary(<xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"/>??new Hashtable())["<xsl:value-of select="@name"/>"]</xsl:template>	

	<xsl:template match="l:ognl" mode="csharp-expr">
		<xsl:param name="context"/>
		EvalOgnlExpression(@"<xsl:value-of select="l:expression"/>", <xsl:apply-templates select="l:context/l:*[position()=1]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)</xsl:template>	
		
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
		new System.Collections.Generic.Dictionary@@lt;string,object@@gt;{<xsl:value-of select="$entries"/>}
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
	
	<xsl:template match="l:html" mode="aspnet-renderer">
		<xsl:copy-of select="."/>
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
		<xsl:variable name="uniqueId">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
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
		<NReco:ActionDataSource runat="server" id="form{$uniqueId}ActionDataSource" DataSourceID="{$mainDsId}" />

		<script language="c#" runat="server">
		IDictionary FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = null;
		
		public void FormView_<xsl:value-of select="$uniqueId"/>_InsertedHandler(object sender, FormViewInsertedEventArgs e) {
			if (e.Exception==null || e.ExceptionHandled) {
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.Values;
				var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
				var Container = (System.Web.UI.WebControls.FormView)sender;
				<xsl:apply-templates select="l:action[@name='inserted']/l:*" mode="form-operation">
					<xsl:with-param name="context">e.Values</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_InsertingHandler(object sender, FormViewInsertEventArgs e) {
			((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("form<xsl:value-of select="$uniqueId"/>ActionDataSource")).ActionSourceControl = (System.Web.UI.Control)sender;
			
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.Values;
			var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
			var Container = (System.Web.UI.WebControls.FormView)sender;
			<xsl:apply-templates select="l:action[@name='inserting']/l:*" mode="form-operation">
				<xsl:with-param name="context">e.Values</xsl:with-param>
				<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
			</xsl:apply-templates>
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_UpdatingHandler(object sender, FormViewUpdateEventArgs e) {
			((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("form<xsl:value-of select="$uniqueId"/>ActionDataSource")).ActionSourceControl = (System.Web.UI.Control)sender;
		
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.NewValues;
			var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
			var Container = (System.Web.UI.WebControls.FormView)sender;
			<xsl:apply-templates select="l:action[@name='updating']/l:*" mode="form-operation">
				<xsl:with-param name="context">new NI.Common.Collections.CompositeDictionary() { MasterDictionary = e.NewValues, SatelliteDictionaries = new []{ e.Keys} }</xsl:with-param>
				<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
			</xsl:apply-templates>
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_DeletingHandler(object sender, FormViewDeleteEventArgs e) {
			((NReco.Web.ActionDataSource)((Control)sender).NamingContainer.FindControl("form<xsl:value-of select="$uniqueId"/>ActionDataSource")).ActionSourceControl = (System.Web.UI.Control)sender;
		
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = new Hashtable( e.Keys );
			var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
			var Container = (System.Web.UI.WebControls.FormView)sender;
			<xsl:apply-templates select="l:action[@name='deleting']/l:*" mode="form-operation">
				<xsl:with-param name="context">e.Keys</xsl:with-param>
				<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
			</xsl:apply-templates>
		}		
		public void FormView_<xsl:value-of select="$uniqueId"/>_DeletedHandler(object sender, FormViewDeletedEventArgs e) {
			if (e.Exception==null || e.ExceptionHandled) {
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = new Hashtable( e.Keys );
				var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
				var Container = (System.Web.UI.WebControls.FormView)sender;
				<xsl:apply-templates select="l:action[@name='deleted']/l:*" mode="form-operation">
					<xsl:with-param name="context">e.Keys</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_UpdatedHandler(object sender, FormViewUpdatedEventArgs e) {
			if (e.Exception==null || e.ExceptionHandled) {
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.NewValues;
				var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
				var Container = (System.Web.UI.WebControls.FormView)sender;
				<xsl:apply-templates select="l:action[@name='updated']/l:*" mode="form-operation">
					<xsl:with-param name="context">new NI.Common.Collections.CompositeDictionary() { MasterDictionary = e.NewValues, SatelliteDictionaries = new []{ e.Keys} }</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_CommandHandler(object sender, FormViewCommandEventArgs e) {
			var Container = (System.Web.UI.WebControls.FormView)sender;
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = Container.DataKey!=null ? new Hashtable(Container.DataKey.Values) : new Hashtable();
			var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;

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
			System.Data.DataRow r = null;
			if (o is System.Data.DataRow) r = (System.Data.DataRow)o;
			else if (o is System.Data.DataRowView) r = ((System.Data.DataRowView)o).Row;
			return r!=null ? r.RowState==System.Data.DataRowState.Added : false;
		}
		
		protected void FormView_<xsl:value-of select="$uniqueId"/>_DataBound(object sender, EventArgs e) {
			var FormView = (NReco.Web.Site.Controls.FormView)sender;
			<xsl:choose>
				<xsl:when test="l:insertmodecondition">var insertMode = Convert.ToBoolean(<xsl:apply-templates select="l:insertmodecondition/l:*" mode="csharp-expr"/>);</xsl:when>
				<xsl:when test="$formDefaults/l:insertmodecondition">var insertMode = Convert.ToBoolean(<xsl:apply-templates select="$formDefaults/l:insertmodecondition/l:*" mode="csharp-expr"/>);</xsl:when>
				<xsl:otherwise>var insertMode = false;</xsl:otherwise>
			</xsl:choose>
			if (insertMode || FormView.DataItemCount==0 || FormView_<xsl:value-of select="$uniqueId"/>_IsDataRowAdded(FormView.DataItem) ) {
				FormView.InsertDataItem = FormView.DataItem ?? new NReco.Collections.DictionaryView( new System.Collections.Hashtable() );
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = CastToDictionary( FormView.InsertDataItem );
				var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
				<xsl:apply-templates select="l:action[@name='initialize']/l:*[name()!='setcontrol']" mode="form-operation">
					<xsl:with-param name="context">FormView_<xsl:value-of select="$uniqueId"/>_ActionContext</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
				FormView.ChangeMode(FormViewMode.Insert);
				
				<xsl:apply-templates select="l:action[@name='initialize']/l:*[name()='setcontrol']" mode="form-operation">
					<xsl:with-param name="context">FormView_<xsl:value-of select="$uniqueId"/>_ActionContext</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
			}
			<xsl:apply-templates select="l:action[@name='databound']/l:*" mode="form-operation">
				<xsl:with-param name="context">CastToDictionary( FormView.DataItem )</xsl:with-param>
				<xsl:with-param name="formView">FormView</xsl:with-param>
			</xsl:apply-templates>			
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
			allowpaging="false"
			runat="server">
			<xsl:attribute name="CssClass">
				<xsl:choose>
					<xsl:when test="l:styles/l:maintable/@class"><xsl:value-of select="l:styles/l:maintable/@class"/></xsl:when>
					<xsl:when test="$formDefaults/l:styles/l:maintable/@class"><xsl:value-of select="$formDefaults/l:styles/l:maintable/@class"/></xsl:when>
					<xsl:otherwise>FormView wrapper</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>			
			<xsl:attribute name="RowStyle-CssClass">
				<xsl:choose>
					<xsl:when test="l:styles/l:maintable/@rowclass"><xsl:value-of select="l:styles/l:maintable/@rowclass"/></xsl:when>
					<xsl:when test="$formDefaults/l:styles/l:maintable/@rowclass"><xsl:value-of select="$formDefaults/l:styles/l:maintable/@rowclass"/></xsl:when>
					<xsl:otherwise>FormView wrapper</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
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
				<xsl:variable name="detectedSourceName"><xsl:value-of select="l:datasource/l:dalc[@id=$mainDsId]/@sourcename"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="not($detectedSourceName='') and $entities/e:entity[@name=$detectedSourceName]">
						<xsl:call-template name="getEntityIdFields"><xsl:with-param name="name" select="$detectedSourceName"/></xsl:call-template>
					</xsl:when>
					<xsl:when test="@datakey"><xsl:value-of select="@datakey"/></xsl:when>
					<xsl:when test="$formDefaults/@datakey"><xsl:value-of select="$formDefaults/@datakey"/></xsl:when>
					<xsl:otherwise>id</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:if test="$viewEnabled='true'">
				<itemtemplate>
					<xsl:variable name="itemTemplateHeader">
						<xsl:choose>
							<xsl:when test="@caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></xsl:when>
							<xsl:when test="l:caption">
								<xsl:variable name="code"><xsl:apply-templates select="l:caption/node()" mode="csharp-expr"><xsl:with-param name="context">Container.DataItem</xsl:with-param></xsl:apply-templates></xsl:variable>
								@@lt;%# <xsl:value-of select="$code"/> %@@gt;
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="not(@widget) or @widget='1' or @widget='true'">
							<div class="ui-widget-header ui-corner-top formview">
								<div class="nreco-widget-header"><xsl:copy-of select="$itemTemplateHeader"/></div>
							</div>
							@@lt;div class="ui-widget-content ui-corner-bottom formview"@@gt;@@lt;div class="nreco-widget-content"@@gt;
						</xsl:when>
						<xsl:when test="@caption or l:caption">
							<div class="formviewheader"><xsl:copy-of select="$itemTemplateHeader"/></div>
						</xsl:when>
					</xsl:choose>
					<table>
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="l:styles/l:fieldtable/@class"><xsl:value-of select="l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:when test="$formDefaults/l:styles/l:fieldtable/@class"><xsl:value-of select="$formDefaults/l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>					
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
										<xsl:with-param name="viewFilter">view</xsl:with-param>
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
					<xsl:variable name="editItemTemplateHeader">
						<xsl:choose>
							<xsl:when test="@caption"><NReco:Label runat="server">Edit <xsl:value-of select="@caption"/></NReco:Label></xsl:when>
							<xsl:when test="l:caption">
								<xsl:variable name="code"><xsl:apply-templates select="l:caption/node()" mode="csharp-expr"><xsl:with-param name="context">Container.DataItem</xsl:with-param></xsl:apply-templates></xsl:variable>
								@@lt;%# String.Format(WebManager.GetLabel("Edit {0}",this), <xsl:value-of select="$code"/>) %@@gt;
							</xsl:when>
						</xsl:choose>	
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="not(@widget) or @widget='1' or @widget='true'">
							<div class="ui-widget-header ui-corner-top formview">
								<div class="nreco-widget-header"><xsl:copy-of select="$editItemTemplateHeader"/></div>
							</div>
							@@lt;div class="ui-widget-content ui-corner-bottom formview"@@gt;@@lt;div class="nreco-widget-content"@@gt;
						</xsl:when>
						<xsl:when test="@caption or l:caption">
							<div class="formviewheader"><xsl:copy-of select="$editItemTemplateHeader"/></div>
						</xsl:when>
					</xsl:choose>			
				
					<table>
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="l:styles/l:fieldtable/@class"><xsl:value-of select="l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:when test="$formDefaults/l:styles/l:fieldtable/@class"><xsl:value-of select="$formDefaults/l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>					
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
										<xsl:with-param name="viewFilter">edit</xsl:with-param>
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
					<xsl:variable name="insertItemTemplateHeader">
						<xsl:choose>
							<xsl:when test="@caption"><NReco:Label runat="server">Create <xsl:value-of select="@caption"/></NReco:Label></xsl:when>
							<xsl:when test="l:caption">
								<xsl:variable name="code"><xsl:apply-templates select="l:container/node()" mode="csharp-expr"><xsl:with-param name="context">Container.DataItem</xsl:with-param></xsl:apply-templates></xsl:variable>
								@@lt;%# String.Format(WebManager.GetLabel("Create {0}",this), <xsl:value-of select="$code"/>) %@@gt;
							</xsl:when>
						</xsl:choose>						
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="not(@widget) or @widget='1' or @widget='true'">
							<div class="ui-widget-header ui-corner-top formview">
								<div class="nreco-widget-header"><xsl:copy-of select="$insertItemTemplateHeader"/></div>
							</div>
							@@lt;div class="ui-widget-content ui-corner-bottom formview"@@gt;@@lt;div class="nreco-widget-content"@@gt;
						</xsl:when>
						<xsl:when test="@caption or l:caption">
							<div class="formviewheader"><xsl:copy-of select="$insertItemTemplateHeader"/></div>
						</xsl:when>
					</xsl:choose>						
					
					<table>
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="l:styles/l:fieldtable/@class"><xsl:value-of select="l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:when test="$formDefaults/l:styles/l:fieldtable/@class"><xsl:value-of select="$formDefaults/l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>						
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
										<xsl:with-param name="viewFilter">add</xsl:with-param>
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
	
	<xsl:template match="l:loaddataitem" mode="form-operation">
		<xsl:param name="context"/>
		<xsl:param name="formView"/>
		foreach (DictionaryEntry entry in (CastToDictionary( ((NReco.Web.Site.Controls.FormView)sender).LoadDataItem() ) ?? new Hashtable() ) ) {
			var currentDataContext = CastToDictionary( <xsl:value-of select="$context"/> );
			if (currentDataContext!=null @@amp;@@amp; !currentDataContext.Contains(entry.Key) @@amp;@@amp; !currentDataContext.IsReadOnly)
				currentDataContext[entry.Key] = entry.Value;
		}
	</xsl:template>
	
	<xsl:template match="l:setcontrol" mode="form-operation">
		<xsl:param name="context"/>
		<xsl:param name="formView"/>
		SetControlValue(<xsl:value-of select="$formView"/>, "<xsl:value-of select="@name"/>", <xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>);
	</xsl:template>
	
	<xsl:template match="l:*" mode="form-operation">
		<xsl:param name="context"/>
		<xsl:apply-templates select="." mode="csharp-code">
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:field[not(@layout) or @layout='horizontal']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<tr class="horizontal">
			<th>
				<xsl:choose>
					<xsl:when test="@caption">
						<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>:
					</xsl:when>
					<xsl:when test="l:caption/l:*">
						<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>:
					</xsl:when>
				</xsl:choose>
			</th>
			<td>
				<xsl:apply-templates select="." mode="aspnet-renderer">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context">Container.DataItem</xsl:with-param>
				</xsl:apply-templates>
			</td>
		</tr>		
	</xsl:template>

	<xsl:template match="l:field[@layout='section']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:param name="viewFilter"/>
		<xsl:if test="@caption or l:caption/l:*">
			<tr class="section header">
				<th colspan="2">
					<xsl:choose>
						<xsl:when test="@caption">
							<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
						</xsl:when>
						<xsl:when test="l:caption/l:*">
							<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
				</th>
			</tr>
		</xsl:if>		
		<tr class="section body">
			<td colspan="2" valign="top">
				<table class="section container">
					<tr>
						<xsl:for-each select="l:group">
							<td class="section column" valign="top">
								<xsl:if test="@widget='1' or @widget='true'">
									<div class="ui-widget-header ui-corner-top sectioncolumn">
										<div class="nreco-widget-header"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></div>
									</div>
									@@lt;div class="ui-widget-content ui-corner-bottom sectioncolumn"@@gt;
								</xsl:if>
								
								<table class="section column">
									
									<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
										<xsl:call-template name="apply-visibility">
											<xsl:with-param name="content">
												<xsl:apply-templates select="." mode="plain-form-view-table-row">
													<xsl:with-param name="mode" select="$mode"/>
													<xsl:with-param name="context" select="$context"/>
													<xsl:with-param name="formUid" select="$formUid"/>
													<xsl:with-param name="viewFilter" select="$viewFilter"/>
												</xsl:apply-templates>								
											</xsl:with-param>
											<xsl:with-param name="expr" select="l:visible/node()"/>
										</xsl:call-template>								
									</xsl:for-each>
									
								</table>
								
								<xsl:if test="@widget='1' or @widget='true'">
									@@lt;/div@@gt;
								</xsl:if>
							</td>
						</xsl:for-each>
					</tr>
				</table>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="l:field[@layout='vertical']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:if test="@caption or l:caption/l:*">
			<tr class="vertical">
				<th colspan="2">
					<xsl:choose>
						<xsl:when test="@caption">
							<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
						</xsl:when>
						<xsl:when test="l:caption/l:*">
							<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
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
				<xsl:choose>
					<xsl:when test="@caption">
						<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label><xsl:if test=".//l:editor/l:validators/l:required"><span class="required">*</span></xsl:if>:
					</xsl:when>
					<xsl:when test="l:caption/l:*">
						<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates><xsl:if test=".//l:editor/l:validators/l:required"><span class="required">*</span></xsl:if>:
					</xsl:when>
				</xsl:choose>
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

	<xsl:template match="l:field[@layout='section']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:param name="viewFilter"/>
		
		<xsl:if test="@caption or l:caption/l:*">
			<tr>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="$formDefaults/l:styles/l:section/@headerclass"><xsl:value-of select="$formDefaults/l:styles/l:section/@headerclass"/></xsl:when>
						<xsl:otherwise>section header</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<th colspan="2">
					<xsl:choose>
						<xsl:when test="@caption">
							<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
						</xsl:when>
						<xsl:when test="l:caption/l:*">
							<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
				</th>
			</tr>
		</xsl:if>		
		<tr>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$formDefaults/l:styles/l:section/@bodyclass"><xsl:value-of select="$formDefaults/l:styles/l:section/@bodyclass"/></xsl:when>
					<xsl:otherwise>section body</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<td colspan="2" valign="top">
				<table class="section container">
					<tr>
						<xsl:for-each select="l:group">
							<td class="section column" valign="top">
								<xsl:if test="@widget='1' or @widget='true'">
									<div class="ui-widget-header ui-corner-top sectioncolumn">
										<div class="nreco-widget-header"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></div>
									</div>
									@@lt;div class="ui-widget-content ui-corner-bottom sectioncolumn"@@gt;
								</xsl:if>
							
								<table class="section column">
									
									<xsl:for-each select="l:field[($viewFilter='edit' and (not(@edit) or @edit='true' or @edit='1')) or ($viewFilter='add' and (not(@add) or @add='true' or @add='1'))]">
										<xsl:call-template name="apply-visibility">
											<xsl:with-param name="content">
												<xsl:apply-templates select="." mode="edit-form-view-table-row">
													<xsl:with-param name="viewFilter" select="$viewFilter"/>
													<xsl:with-param name="mode" select="$mode"/>
													<xsl:with-param name="context" select="$context"/>
													<xsl:with-param name="formUid" select="$formUid"/>
												</xsl:apply-templates>								
											</xsl:with-param>
											<xsl:with-param name="expr" select="l:visible/node()"/>
										</xsl:call-template>						
									</xsl:for-each>
								</table>
								
								<xsl:if test="@widget='1' or @widget='true'">
									@@lt;/div@@gt;
								</xsl:if>								
								
							</td>
						</xsl:for-each>
					</tr>
				</table>
			</td>
		</tr>
	</xsl:template>	
	
	<xsl:template match="l:field[@layout='vertical']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		
		<xsl:if test="@caption or l:caption/l:*">
			<tr class="vertical">
				<th colspan="2">
					<xsl:choose>
						<xsl:when test="@caption">
							<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
						</xsl:when>
						<xsl:when test="l:caption/l:*">
							<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
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
		<xsl:if test="@hint or l:hint">
			<div class="fieldHint"><NReco:Label runat="server">
				<xsl:choose>
					<xsl:when test="@hint"><xsl:value-of select="@hint"/></xsl:when>
					<xsl:when test="l:hint"><xsl:value-of select="l:hint"/></xsl:when>
				</xsl:choose>
			</NReco:Label></div>
		</xsl:if>
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
				<xsl:if test="@hint or l:hint">
					<div class="fieldHint"><NReco:Label runat="server">
						<xsl:choose>
							<xsl:when test="@hint"><xsl:value-of select="@hint"/></xsl:when>
							<xsl:when test="l:hint"><xsl:value-of select="l:hint"/></xsl:when>
						</xsl:choose>
					</NReco:Label></div>
				</xsl:if>				
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
		<xsl:param name="textPrefix" select="$linkButtonDefaults/@prefix"/>
		<xsl:param name="textSuffix" select="$linkButtonDefaults/@suffix"/>
		<NReco:DataBindHolder runat="server">
		<NReco:LinkButton ValidationGroup="{$formUid}" id="linkBtn{$mode}{generate-id(.)}" 
			runat="server" CommandName="{@command}" command="{@command}"><!-- command attr for html element as metadata -->
			<xsl:if test="$textPrefix">
				<xsl:attribute name="TextPrefix"><xsl:value-of select="$textPrefix"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="$textSuffix">
				<xsl:attribute name="TextSuffix"><xsl:value-of select="$textSuffix"/></xsl:attribute>
			</xsl:if>
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
		</NReco:DataBindHolder>
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
		<NReco:DataBindHolder runat="server">
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
		</NReco:DataBindHolder>
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
		<xsl:param name="context"/>
		<xsl:param name="formUid">Form</xsl:param>
		<xsl:element name="UserControlEditor:{l:editor/l:usercontrol/@name}">
			<xsl:attribute name="runat">server</xsl:attribute>
			<xsl:attribute name="ValidationGroup"><xsl:value-of select="$formUid"/></xsl:attribute>
			<xsl:attribute name="ViewContext">@@lt;%# this.GetContext() %@@gt;</xsl:attribute>
			<xsl:if test="not($context='') and $context">
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$context"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="@name">
				<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
				<xsl:choose>
					<xsl:when test="l:editor/l:usercontrol/@bind='false' or l:editor/l:usercontrol/@bind='0'"><xsl:attribute name="FieldName"><xsl:value-of select="@name"/></xsl:attribute></xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="Value">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
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
			<xsl:if test="l:editor/l:textarea/@cols">
				<xsl:attribute name="Columns"><xsl:value-of select="l:editor/l:textarea/@cols"/></xsl:attribute>
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
			<xsl:if test="l:editor/l:numbertextbox/l:spin">
				<xsl:attribute name="SpinEnabled">True</xsl:attribute>
			</xsl:if>			
			<xsl:if test="l:editor/l:numbertextbox/l:spin/@max">
				<xsl:attribute name="SpinMax"><xsl:value-of select="l:editor/l:numbertextbox/l:spin/@max"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:numbertextbox/l:spin/@min">
				<xsl:attribute name="SpinMin"><xsl:value-of select="l:editor/l:numbertextbox/l:spin/@min"/></xsl:attribute>
			</xsl:if>				
			<xsl:if test="l:editor/l:numbertextbox/@prefix">
				<xsl:attribute name="PrefixText"><xsl:value-of select="l:editor/l:numbertextbox/l:prefix"/></xsl:attribute>
			</xsl:if>			
			<xsl:if test="l:editor/l:numbertextbox/@suffix">
				<xsl:attribute name="SuffixText"><xsl:value-of select="l:editor/l:numbertextbox/l:suffix"/></xsl:attribute>
			</xsl:if>	
		</Plugin:NumberTextBoxEditor>
	</xsl:template>	

	<xsl:template match="l:field[l:editor/l:checkbox]" mode="form-view-editor">
		<asp:CheckBox id="{@name}" runat="server">
			<xsl:if test="not(l:editor/l:checkbox/@bind) or l:editor/l:checkbox/@bind='true' or l:editor/l:checkbox/@bind='1'">
				<xsl:attribute name="Checked">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			</xsl:if>
		</asp:CheckBox>
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:filtertextbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="FilterTextBoxEditor" src="~/templates/editors/FilterTextBoxEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:filtertextbox]" mode="form-view-editor">
		<xsl:param name="formUid">Form</xsl:param>
		<Plugin:FilterTextBoxEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" Text='@@lt;%# Bind("{@name}") %@@gt;'>
			<xsl:attribute name="ValidationGroup"><xsl:value-of select="$formUid"/></xsl:attribute>
		</Plugin:FilterTextBoxEditor>
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
		<Plugin:DropDownListEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}"
			LookupName='{$lookupPrvName}'
			ValueFieldName="{$valueName}"
			TextFieldName="{$textName}" ValidationGroup="{$formUid}">
			<xsl:if test="not(l:editor/l:dropdownlist/@bind) or l:editor/l:dropdownlist/@bind='true' or l:editor/l:dropdownlist/@bind='1'">
				<xsl:attribute name="SelectedValue">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			</xsl:if>
			
			<xsl:attribute name="Required">
				<xsl:choose>
					<xsl:when test="l:editor/l:validators/l:required and not(l:editor/l:dropdownlist/l:notselected)">true</xsl:when>
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
			<xsl:if test="l:editor/l:dropdownlist/l:notselected/@value">
				<xsl:attribute name="NotSelectedValue">
					<xsl:value-of select="l:editor/l:dropdownlist/l:notselected/@value"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:dropdownlist/l:notselected/@text">
				<xsl:attribute name="NotSelectedText">
					<xsl:value-of select="l:editor/l:dropdownlist/l:notselected/@text"/>
				</xsl:attribute>
			</xsl:if>			
		</Plugin:DropDownListEditor>
		<xsl:if test="l:editor/l:dropdownlist/l:context//l:control">
			<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:dropdownlist/l:context/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
			<NReco:DataContextHolder id="{@name}DataContextHolder" runat="server">
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</NReco:DataContextHolder>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="l:field[l:editor/l:radiobuttonlist]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="RadioButtonListEditor" src="~/templates/editors/RadioButtonListEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:radiobuttonlist]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<xsl:param name="formUid"/>
		<xsl:variable name="lookupPrvName" select="l:editor/l:radiobuttonlist/@lookup"/>
		<xsl:variable name="valueName">
			<xsl:choose>
				<xsl:when test="l:editor/l:radiobuttonlist/@value"><xsl:value-of select="l:editor/l:radiobuttonlist/@value"/></xsl:when>
				<xsl:otherwise>Key</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="textName">
			<xsl:choose>
				<xsl:when test="l:editor/l:radiobuttonlist/@text"><xsl:value-of select="l:editor/l:radiobuttonlist/@text"/></xsl:when>
				<xsl:otherwise>Value</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<Plugin:RadioButtonListEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}"
			LookupName='{$lookupPrvName}'
			ValueFieldName="{$valueName}"
			TextFieldName="{$textName}" ValidationGroup="{$formUid}">
			<xsl:attribute name="SelectedValue">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			<xsl:if test="l:editor/l:radiobuttonlist/l:context">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:radiobuttonlist/l:context/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:radiobuttonlist/l:context//l:control">
				<xsl:attribute name="DependentFromControls">
					<xsl:for-each select="l:editor/l:radiobuttonlist/l:context//l:control">
						<xsl:if test="position()!=1">,</xsl:if>
						<xsl:value-of select="@name"/>
					</xsl:for-each>
				</xsl:attribute>
				<xsl:attribute name="DataContextControl"><xsl:value-of select="@name"/>DataContextHolder</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:radiobuttonlist/@repeat-direction">
				<xsl:attribute name="RepeatDirection"><xsl:value-of select="l:editor/l:radiobuttonlist/@repeat-direction"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:radiobuttonlist/l:notselected/@value">
				<xsl:attribute name="NotSelectedValue">
					<xsl:value-of select="l:editor/l:radiobuttonlist/l:notselected/@value"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:radiobuttonlist/l:notselected/@text">
				<xsl:attribute name="NotSelectedText">
					<xsl:value-of select="l:editor/l:radiobuttonlist/l:notselected/@text"/>
				</xsl:attribute>
			</xsl:if>			
		</Plugin:RadioButtonListEditor>
		<xsl:if test="l:editor/l:radiobuttonlist/l:context//l:control">
			<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:radiobuttonlist/l:context/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
			<NReco:DataContextHolder id="{@name}DataContextHolder" runat="server">
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</NReco:DataContextHolder>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="CheckBoxListRelationEditor" src="~/templates/editors/CheckBoxListRelationEditor.ascx" %@@gt;
		@@lt;%@ Register TagPrefix="Plugin" tagName="GroupedCheckBoxListRelationEditor" src="~/templates/editors/GroupedCheckBoxListRelationEditor.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<Plugin:CheckBoxListRelationEditor xmlns:Plugin="urn:remove" runat="server" 
			DalcServiceName="{$dalcName}"
			DsFactoryServiceName="{$datasetFactoryName}"
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
			</xsl:choose>
			<xsl:if test="l:editor/l:checkboxlist/l:relation/@editor">
				<xsl:attribute name="RelationEditor">@@lt;%$ service:<xsl:value-of select="l:editor/l:checkboxlist/l:relation/@editor"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/l:default/l:*">
				<xsl:variable name="defaultValueContextExpr"><xsl:apply-templates select="l:editor/l:checkboxlist/l:default/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="DefaultDataContext">@@lt;%# <xsl:value-of select="$defaultValueContextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/l:default/@provider">
				<xsl:attribute name="DefaultValueServiceName"><xsl:value-of select="l:editor/l:checkboxlist/l:default/@provider"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@name">
				<xsl:attribute name="Id"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/l:lookup/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:checkboxlist/l:lookup/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="LookupDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>			
		</Plugin:CheckBoxListRelationEditor>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:checkboxlist and l:editor/l:checkboxlist/l:lookup/@group]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<Plugin:GroupedCheckBoxListRelationEditor xmlns:Plugin="urn:remove" runat="server" 
			DalcServiceName="{$dalcName}"
			DsFactoryServiceName="{$datasetFactoryName}"
			LookupServiceName="{l:editor/l:checkboxlist/l:lookup/@name}"
			TextFieldName="{l:editor/l:checkboxlist/l:lookup/@text}"
			ValueFieldName="{l:editor/l:checkboxlist/l:lookup/@value}"
			GroupFieldName="{l:editor/l:checkboxlist/l:lookup/@group}"
			RelationSourceName="{l:editor/l:checkboxlist/l:relation/@sourcename}"
			LFieldName="{l:editor/l:checkboxlist/l:relation/@left}"
			RFieldName="{l:editor/l:checkboxlist/l:relation/@right}">
			<xsl:choose>
				<xsl:when test="l:editor/l:checkboxlist/@id">
					<xsl:attribute name="EntityId">@@lt;%# Eval("<xsl:value-of select="l:editor/l:checkboxlist/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField"><xsl:value-of select="l:editor/l:checkboxlist/@id"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="l:editor/l:checkboxlist/l:group/@default">
				<xsl:attribute name="DefaultGroup"><xsl:value-of select="l:editor/l:checkboxlist/l:group/@default"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/@columns">
				<xsl:attribute name="RepeatColumns"><xsl:value-of select="l:editor/l:checkboxlist/@columns"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/@layout">
				<xsl:attribute name="RepeatLayout"><xsl:value-of select="l:editor/l:checkboxlist/@layout"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/l:default/l:*">
				<xsl:variable name="defaultValueContextExpr"><xsl:apply-templates select="l:editor/l:checkboxlist/l:default/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="DefaultDataContext">@@lt;%# <xsl:value-of select="$defaultValueContextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>			
			<xsl:if test="l:editor/l:checkboxlist/l:default/@provider">
				<xsl:attribute name="DefaultValueServiceName"><xsl:value-of select="l:editor/l:checkboxlist/l:default/@provider"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/l:relation/@editor">
				<xsl:attribute name="RelationEditor">@@lt;%$ service:<xsl:value-of select="l:editor/l:checkboxlist/l:relation/@editor"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/l:lookup/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:checkboxlist/l:lookup/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="LookupDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>			
		</Plugin:GroupedCheckBoxListRelationEditor>
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
		<xsl:variable name="errMsg">
			<xsl:choose>
				<xsl:when test="@message"><xsl:value-of select="@message"/></xsl:when>
				<xsl:otherwise>Invalid value</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			ValidationExpression="{.}"
			ErrorMessage="@@lt;%$ label: {$errMsg} %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true"/>	
	</xsl:template>
	
	<xsl:template match="l:email" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<xsl:variable name="errMsg">
			<xsl:choose>
				<xsl:when test="@message"><xsl:value-of select="@message"/></xsl:when>
				<xsl:otherwise>Invalid email</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}" 
			ErrorMessage="@@lt;%$ label: {$errMsg} %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true">
			<xsl:attribute name="ValidationExpression">[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}</xsl:attribute>
		</asp:RegularExpressionValidator>
	</xsl:template>
	
	<xsl:template match="l:url" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}" 
			ErrorMessage="@@lt;%$ label: Invalid URL %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true">
			<xsl:attribute name="ValidationExpression">^((http|https|ftp)\://)<xsl:if test="@require-protocol='false' or @require-protocol='0'">{0,1}</xsl:if>[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?/?([a-zA-Z0-9\-\._\?\,\'/\\\+&amp;%\$#\=~])*[^\.\,\)\(\s]$</xsl:attribute>
		</asp:RegularExpressionValidator>
	</xsl:template>	
	
	<xsl:template match="l:decimal" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:RegularExpressionValidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			controltovalidate="{$controlId}" EnableClientScript="true">
			<xsl:attribute name="ValidationExpression">@@lt;%# "[0-9]{1,10}(["+System.Globalization.CultureInfo.CurrentCulture.NumberFormat.NumberDecimalSeparator+"][0-9]{1,10}){0,1}" %@@gt;</xsl:attribute>
			<xsl:attribute name="ErrorMessage">@@lt;%# String.Format( WebManager.GetLabel( "Invalid number (use {0} as decimal separator)" ), System.Globalization.CultureInfo.CurrentCulture.NumberFormat.NumberDecimalSeparator ) %@@gt;</xsl:attribute>
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
		<xsl:variable name="dataSourceDalc">
			<xsl:choose>
				<xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$dalcName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		
		<Dalc:DalcDataSource runat="server" id="{@id}" 
			Dalc='&lt;%$ service:{$dataSourceDalc} %&gt;' SourceName="{$sourceName}" DataSetMode="true">
			<xsl:if test="not($selectSourceName='')">
				<xsl:attribute name="SelectSourceName"><xsl:value-of select="$selectSourceName"/></xsl:attribute>
			</xsl:if>
			<xsl:attribute name="DataKeyNames">
				<xsl:choose>
					<xsl:when test="@datakeynames"><xsl:value-of select="@datakeynames"/></xsl:when>
					<xsl:otherwise><xsl:call-template name="getEntityIdFields"><xsl:with-param name="name" select="$sourceName"/></xsl:call-template></xsl:otherwise>
				</xsl:choose>			
			</xsl:attribute>
			<xsl:attribute name="AutoIncrementNames">
				<xsl:choose>
					<xsl:when test="@autoincrementnames"><xsl:value-of select="@autoincrementnames"/></xsl:when>
					<xsl:otherwise><xsl:call-template name="getEntityAutoincrementFields"><xsl:with-param name="name" select="$sourceName"/></xsl:call-template></xsl:otherwise>
				</xsl:choose>
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
			<xsl:if test="l:action[@name='select' or @name='selected']">
				<xsl:attribute name="OnSelected"><xsl:value-of select="@id"/>_OnSelected</xsl:attribute>
			</xsl:if>			
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
				e.SelectQuery.Root = prv.GetQueryNode( CastToDictionary(context) );
				
				<xsl:apply-templates select="l:action[@name='selecting']/l:*" mode="csharp-code">
					<xsl:with-param name="context">e</xsl:with-param>
				</xsl:apply-templates>
			}
			protected void <xsl:value-of select="@id"/>_OnSelected(object sender,DalcDataSourceSelectEventArgs e) {
				<xsl:apply-templates select="l:action[@name='select' or @name='selected']/l:*" mode="csharp-code">
					<xsl:with-param name="context">e</xsl:with-param>
				</xsl:apply-templates>
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
	
	<xsl:template match="l:actionform" mode="aspnet-renderer">
		<xsl:variable name="actionForm">
			<xsl:choose>
				<xsl:when test="@name">actionForm<xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>actionForm<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<NReco:DataBindHolder runat="server">
			<NReco:ActionView runat="server" id="{$actionForm}"
				OnDataBinding="{$actionForm}_OnDataBinding">
				<Template>
					<table>
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="l:styles/l:maintable/@class"><xsl:value-of select="l:styles/l:maintable/@class"/></xsl:when>
								<xsl:when test="$formDefaults/l:styles/l:maintable/@class"><xsl:value-of select="$formDefaults/l:styles/l:maintable/@class"/></xsl:when>
								<xsl:otherwise>FormView wrapper</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>					
						<tr><td>
						
						<table>
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="l:styles/l:fieldtable/@class"><xsl:value-of select="l:styles/l:fieldtable/@class"/></xsl:when>
									<xsl:when test="$formDefaults/l:styles/l:fieldtable/@class"><xsl:value-of select="$formDefaults/l:styles/l:fieldtable/@class"/></xsl:when>
									<xsl:otherwise>FormView</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:if test="count(l:header/*)>0">
								<tr class="formheader">
									<td colspan="2">
										<xsl:apply-templates select="l:header/l:*" mode="aspnet-renderer">
											<xsl:with-param name="context">Container.DataItem</xsl:with-param>
											<xsl:with-param name="formUid"><xsl:value-of select="$actionForm"/></xsl:with-param>
											<xsl:with-param name="mode">FormHeader</xsl:with-param>
										</xsl:apply-templates>
									</td>
								</tr>
							</xsl:if>
							<xsl:for-each select="l:field">
								<xsl:call-template name="apply-visibility">
									<xsl:with-param name="content">
										<xsl:apply-templates select="." mode="edit-form-view-table-row">
											<xsl:with-param name="viewFilter">edit</xsl:with-param>
											<xsl:with-param name="mode">edit</xsl:with-param>
											<xsl:with-param name="context">Container.DataItem</xsl:with-param>
											<xsl:with-param name="formUid" select="$actionForm"/>
										</xsl:apply-templates>								
									</xsl:with-param>
									<xsl:with-param name="expr" select="l:visible/node()"/>
								</xsl:call-template>						
							</xsl:for-each>						
							<xsl:if test="count(l:footer/*)>0">
								<tr class="formfooter">
									<td colspan="2">
										<xsl:apply-templates select="l:footer/l:*" mode="aspnet-renderer">
											<xsl:with-param name="context">Container.DataItem</xsl:with-param>
											<xsl:with-param name="formUid"><xsl:value-of select="$actionForm"/></xsl:with-param>
											<xsl:with-param name="mode">FormFooter</xsl:with-param>
										</xsl:apply-templates>
									</td>
								</tr>
							</xsl:if>						
						</table>
						
						</td></tr>
					</table>
				</Template>
			</NReco:ActionView>
		</NReco:DataBindHolder>
		<script language="c#" runat="server">
		protected void <xsl:value-of select="$actionForm"/>_OnDataBinding(object sender, EventArgs e) {
			var filter = (NReco.Web.Site.Controls.ActionView)sender;
			// init data item
			var viewContext = this.GetContext();
			<xsl:for-each select=".//l:field[@name]">
				filter.Values["<xsl:value-of select="@name"/>"] = viewContext["<xsl:value-of select="@name"/>"];
			</xsl:for-each>
			<xsl:apply-templates select="l:action[@name='initialize']/l:*" mode="form-operation">
				<xsl:with-param name="context">filter.Values</xsl:with-param>
			</xsl:apply-templates>
		}
		</script>
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
		<xsl:variable name="showItemSelector" select="l:operations"/>
		<xsl:variable name="listNode" select="."/>
		
		<xsl:apply-templates select="l:datasource/l:*" mode="view-datasource">
			<xsl:with-param name="viewType">ListView</xsl:with-param>
		</xsl:apply-templates>
		<NReco:ActionDataSource runat="server" id="list{$listUniqueId}ActionDataSource" DataSourceID="{$mainDsId}" />

		<xsl:if test="l:filter">
			<xsl:variable name="filterForm">filterForm<xsl:value-of select="$listUniqueId"/></xsl:variable>
			<NReco:FilterView runat="server" id="listFilterView{$listUniqueId}"
				OnDataBinding="listFilter{$listUniqueId}_OnDataBinding"
				OnFilter="listFilter{$listUniqueId}_OnFilter">
				<Template>
					<xsl:apply-templates select="l:filter/l:header/l:*" mode="aspnet-renderer">
						<xsl:with-param name="context">Container.DataItem</xsl:with-param>
						<xsl:with-param name="formUid">listFilter<xsl:value-of select="$listUniqueId"/></xsl:with-param>
						<xsl:with-param name="mode">filter</xsl:with-param>
					</xsl:apply-templates>
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
					<xsl:apply-templates select="l:filter/l:footer/l:*" mode="aspnet-renderer">
						<xsl:with-param name="context">Container.DataItem</xsl:with-param>
						<xsl:with-param name="formUid">listFilter<xsl:value-of select="$listUniqueId"/></xsl:with-param>
						<xsl:with-param name="mode">filter</xsl:with-param>
					</xsl:apply-templates>
				</Template>
			</NReco:FilterView>
		</xsl:if>
				
		<xsl:variable name="insertItemPosition">
			<xsl:choose>
				<xsl:when test="l:addrow/@position = 'top'">FirstItem</xsl:when>
				<xsl:when test="l:addrow/@position = 'bottom' or not(l:addrow/@position)">LastItem</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<NReco:ListView ID="listView{$listUniqueId}"
			DataSourceID="list{$listUniqueId}ActionDataSource"
			ItemContainerID="itemPlaceholder"
			OnDataBinding="listView{$listUniqueId}_OnDataBinding"
			OnDataBound="listView{$listUniqueId}_OnDataBound"
			OnItemCommand="listView{$listUniqueId}_OnItemCommand"
			ConvertEmptyStringToNull="false"
			OnItemDeleting="listView{$listUniqueId}_OnItemDeleting"
			OnItemDeleted="listView{$listUniqueId}_OnItemDeleted"
			OnItemUpdating="listView{$listUniqueId}_OnItemUpdating"
			OnItemUpdated="listView{$listUniqueId}_OnItemUpdated"
			OnPagePropertiesChanged="listView{$listUniqueId}_OnPagePropertiesChanged"
			OnSorted="listView{$listUniqueId}_OnSorted"
			OnInitSelectArguments="listView{$listUniqueId}_OnInitSelectArguments"
			runat="server">
			<xsl:attribute name="DataKeyNames">
				<!-- tmp solution for dalc ds only -->
				<xsl:variable name="detectedSourceName"><xsl:value-of select="l:datasource/l:dalc[@id=$mainDsId]/@sourcename"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="not($detectedSourceName='') and $entities/e:entity[@name=$detectedSourceName]">
						<xsl:call-template name="getEntityIdFields"><xsl:with-param name="name" select="$detectedSourceName"/></xsl:call-template>
					</xsl:when>
					<xsl:when test="@datakey"><xsl:value-of select="@datakey"/></xsl:when>
					<xsl:when test="$listDefaults/@datakey"><xsl:value-of select="$listDefaults/@datakey"/></xsl:when>
					<xsl:otherwise>id</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="@add='true' or @add='1'">
				<xsl:attribute name="InsertItemPosition"><xsl:value-of select="$insertItemPosition"/></xsl:attribute>
				<xsl:attribute name="OnItemInserting">listView<xsl:value-of select="$listUniqueId"/>_OnItemInserting</xsl:attribute>
				<xsl:attribute name="OnItemInserted">listView<xsl:value-of select="$listUniqueId"/>_OnItemInserted</xsl:attribute>
			</xsl:if>
			<LayoutTemplate>
				
				<table class="listView">
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="$listNode/l:styles/l:listtable/@class"><xsl:value-of select="$listNode/l:styles/l:listtable/@class"/></xsl:when>
							<xsl:when test="$listDefaults/l:styles/l:listtable/@class"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@class"/></xsl:when>
							<xsl:otherwise>listView</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>					
					<xsl:if test="@name">
						<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="not(@headers) or @headers='1' or @headers='true'">
						<tr>
							<xsl:if test="$showItemSelector">
								<th width="25px;">
									<xsl:attribute name="class">
										<xsl:choose>
											<xsl:when test="$listNode/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@headerclass"/></xsl:when>
											<xsl:when test="$listDefaults/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@headerclass"/></xsl:when>
											<xsl:otherwise>ui-state-default</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>		
									<input id="checkAll" type="checkbox" runat="server" class="listSelectorCheckAll"/>
								</th>
							</xsl:if>
							
							<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
								<xsl:call-template name="apply-visibility">
									<xsl:with-param name="content"><xsl:apply-templates select="." mode="list-view-table-header"><xsl:with-param name="listNode" select="$listNode"/></xsl:apply-templates></xsl:with-param>
									<xsl:with-param name="expr" select="l:visible/node()"/>
								</xsl:call-template>								
							</xsl:for-each>
						</tr>
					</xsl:if>
					<tr runat="server" id="itemPlaceholder" />
					
					<xsl:if test="l:footer">
						<!-- ListView doesn't call DataBind for LayoutTemplate, so lets use special placeholder with self-databinding logic -->
						<NReco:DataBindHolder runat="server" EnableViewState="false">
							<xsl:for-each select="l:footer/l:row">
								<tr class="footer">
									<xsl:for-each select="l:cell">
										<td>
											<xsl:attribute name="class">
												<xsl:choose>
													<xsl:when test="$listNode/l:styles/l:listtable/@customcellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@customcellclass"/></xsl:when>												
													<xsl:when test="$listDefaults/l:styles/l:listtable/@customcellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@customcellclass"/></xsl:when>
													<xsl:when test="@css-class"><xsl:value-of select="@css-class"/></xsl:when>
													<xsl:otherwise>ui-state-default customlistcell</xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
											
											<xsl:if test="@colspan"><xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute></xsl:if>
											<xsl:if test="@rowspan"><xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute></xsl:if>
											<xsl:if test="@align"><xsl:attribute name="style">text-align:<xsl:value-of select="@align"/>;</xsl:attribute></xsl:if>
											<xsl:apply-templates select="l:*" mode="aspnet-renderer"/>
										</td>
									</xsl:for-each>
								</tr>
							</xsl:for-each>
						</NReco:DataBindHolder>
					</xsl:if>
					
					<xsl:if test="$showItemSelector">
						<NReco:DataBindHolder runat="server" EnableViewState="false">
							<tr id="massOperations" class="footer massoperations" runat="server" style="display:none;">
								<xsl:if test="not(l:operations/@showselectedcount='false' or l:operations/@showselectedcount='0')">
									<td>
										<xsl:attribute name="class">
											<xsl:choose>
												<xsl:when test="$listNode/l:styles/l:listtable/@pagerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@pagerclass"/> selecteditemslistcell</xsl:when>
												<xsl:when test="$listDefaults/l:styles/l:listtable/@pagerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@pagerclass"/> selecteditemslistcell</xsl:when>
												<xsl:otherwise>ui-state-default customlistcell selecteditemslistcell</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>									
										<div class="selecteditemslistContainer">
											<div class="selectedText">@@lt;%=WebManager.GetLabel("list:selecteditems:selected")!="list:selecteditems:selected" ? WebManager.GetLabel("list:selecteditems:selected") : "" %@@gt;</div>
											<span class="listSelectedItemsCount"></span>
										</div>
									</td>
								</xsl:if>
								<td>
									<xsl:attribute name="colspan">
										<xsl:choose>
											<xsl:when test="not(l:operations/@showselectedcount='false' or l:operations/@showselectedcount='0')">
												<xsl:value-of select="count(l:field[not(@view) or @view='true' or @view='1'])"/>
											</xsl:when>
											<xsl:otherwise><xsl:value-of select="count(l:field[not(@view) or @view='true' or @view='1'])+1"/></xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:attribute name="class">
										<xsl:choose>
											<xsl:when test="$listNode/l:styles/l:listtable/@pagerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@pagerclass"/></xsl:when>
											<xsl:when test="$listDefaults/l:styles/l:listtable/@pagerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@pagerclass"/></xsl:when>
											<xsl:otherwise>ui-state-default customlistcell</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:apply-templates select="l:operations/l:*" mode="aspnet-renderer"/>
								</td>
							</tr>
						</NReco:DataBindHolder>
					</xsl:if>
					
					<xsl:if test="not(l:pager/@allow='false' or l:pager/@allow='0')">
						<xsl:variable name="pagerColspanCount">
							<xsl:choose>
								<xsl:when test="$showItemSelector"><xsl:value-of select="count(l:field[not(@view) or @view='true' or @view='1'])+1"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="count(l:field[not(@view) or @view='true' or @view='1'])"/></xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<asp:DataPager ID="ListDataPager" runat="server">
							<xsl:choose>
								<xsl:when test="l:pager/@pagesize">
									<xsl:attribute name="PageSize"><xsl:value-of select="l:pager/@pagesize"/></xsl:attribute>
								</xsl:when>
								<xsl:when test="$listDefaults/l:pager/@pagesize">
									<xsl:attribute name="PageSize"><xsl:value-of select="$listDefaults/l:pager/@pagesize"/></xsl:attribute>
								</xsl:when>
							</xsl:choose>
							<Fields>
							  <asp:TemplatePagerField>
							   <PagerTemplate>
								@@lt;tr class="pager"@@gt;@@lt;td 
									colspan="<xsl:value-of select="$pagerColspanCount"/>"
										<xsl:choose>
											<xsl:when test="$listNode/l:styles/l:listtable/@pagerclass">class="<xsl:value-of select="$listNode/l:styles/l:listtable/@pagerclass"/>"</xsl:when>
											<xsl:when test="$listDefaults/l:styles/l:listtable/@pagerclass">class="<xsl:value-of select="$listDefaults/l:styles/l:listtable/@pagerclass"/>"</xsl:when>
											<xsl:otherwise>class="ui-state-default listcell"</xsl:otherwise>
										</xsl:choose>
									@@gt;
							   </PagerTemplate>
							  </asp:TemplatePagerField>
							
								<xsl:choose>
									<xsl:when test="l:pager/l:template">
										<xsl:copy-of select="l:pager/l:template/node()"/>
									</xsl:when>
									<xsl:when test="$listDefaults/l:pager/l:template">
										<xsl:copy-of select="$listDefaults/l:pager/l:template/node()"/>
									</xsl:when>
									<xsl:otherwise>
										<asp:NumericPagerField 
											PreviousPageText="&lt;&lt;"
											NextPageText="&gt;&gt;"/>
									</xsl:otherwise>
								</xsl:choose>
								
							  <asp:TemplatePagerField>
							   <PagerTemplate>
								@@lt;/td@@gt;@@lt;/tr@@gt;
							   </PagerTemplate>
							  </asp:TemplatePagerField>								
								
							</Fields>
						</asp:DataPager>
						
					</xsl:if>
				</table>
			</LayoutTemplate>
			<ItemTemplate>
				<xsl:if test="l:group">
					<tr class="item listgroup" runat="server" visible='@@lt;%# ListRenderGroupField(Container.DataItem, "{l:group/@field}", ref listView{$listUniqueId}_CurrentGroupValue, true)!=null %@@gt;'>
						<td colspan="1000">
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="$listNode/l:styles/l:listtable/@groupcellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@groupcellclass"/></xsl:when>
									<xsl:when test="$listDefaults/l:styles/l:listtable/@groupcellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@groupcellclass"/></xsl:when>
									<xsl:otherwise>ui-state-default listcell</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>						
							<div class="groupTitle">
								<xsl:choose>
									<xsl:when test="l:group/l:renderer">
										<xsl:apply-templates select="l:group/l:renderer/l:*" mode="aspnet-renderer">
											<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										@@lt;%# listView<xsl:value-of select="$listUniqueId"/>_CurrentGroupValue %@@gt;
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</td>					
					</tr>
				</xsl:if>
				<tr class="item">
					<xsl:if test="$showItemSelector">
						<td>
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/></xsl:when>
									<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/></xsl:when>
									<xsl:otherwise>ui-state-default listcell</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>	
							<input id="checkItem" type="checkbox" runat="server" class="listSelector" value='@@lt;%# Container.DisplayIndex %@@gt;'/>
						</td>
					</xsl:if>
				
					<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
						<xsl:call-template name="apply-visibility">
							<xsl:with-param name="content">
								<xsl:apply-templates select="." mode="list-view-table-cell">
									<xsl:with-param name="context">Container.DataItem</xsl:with-param>
									<xsl:with-param name="listNode" select="$listNode"/>
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
						<!-- mass operations selector placeholder -->
						<xsl:if test="l:operations">
							<td>
								<xsl:attribute name="class">
									<xsl:choose>
										<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/></xsl:when>
										<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/></xsl:when>
										<xsl:otherwise>ui-state-default listcell</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>							
								@@amp;nbsp;
							</td>
						</xsl:if>
					
						<xsl:for-each select="l:field[not(@edit) or @edit='true' or @edit='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">					
									<xsl:apply-templates select="." mode="list-view-table-cell-editor">
										<xsl:with-param name="mode">edit</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid">@@lt;%# String.Format("ListForm{0}", Container.DataItem.GetHashCode() ) %@@gt;</xsl:with-param>
										<xsl:with-param name="listNode" select="$listNode"/>
									</xsl:apply-templates>
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>
						</xsl:for-each>
					</tr>
				</EditItemTemplate>
			</xsl:if>
			 
			 <xsl:if test="@add='true' or @add='1'">
				<xsl:variable name="insertItemTemplateContent">
					<tr class="insertItem">
						<!-- mass operations selector placeholder -->
						<xsl:if test="$showItemSelector">
							<td>
								<xsl:attribute name="class">
									<xsl:choose>
										<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/></xsl:when>
										<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/></xsl:when>
										<xsl:otherwise>ui-state-default listcell</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>							
								@@amp;nbsp;
							</td>
						</xsl:if>
					
						<xsl:for-each select="l:field[not(@add) or @add='true' or @add='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">						
									<xsl:apply-templates select="." mode="list-view-table-cell-editor">
										<xsl:with-param name="mode">add</xsl:with-param>
										<xsl:with-param name="context">(Container is IDataItemContainer ? ((IDataItemContainer)Container).DataItem : new object() )</xsl:with-param>
										<xsl:with-param name="formUid">ListForm<xsl:value-of select="$listUniqueId"/></xsl:with-param>
										<xsl:with-param name="listNode" select="$listNode"/>
									</xsl:apply-templates>
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>
						</xsl:for-each>
					</tr>
				</xsl:variable>
			 
				<InsertItemTemplate>
					<xsl:choose>
						<xsl:when test="l:addrow/l:visible">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">						
									<xsl:copy-of select="$insertItemTemplateContent"/>
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:addrow/l:visible/node()"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="$insertItemTemplateContent"/>
						</xsl:otherwise>
					</xsl:choose>
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
		<xsl:if test="$showItemSelector">
			<script type="text/javascript">
			$(function() {
				var listElemPrefix = '@@lt;%=this.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;().Where( c=@@gt;c.ID=="listView<xsl:value-of select="$listUniqueId"/>").FirstOrDefault().ClientID %@@gt;';
				var $checkAllElem = $('input[id^='+listElemPrefix+'].listSelectorCheckAll');
				var $checkItemElems = $('input[id^='+listElemPrefix+'].listSelector');
				var $massOpRow = $('tr[id^='+listElemPrefix+'].massoperations');
				var showMassOpRow = function() {
					var selectedCount = $checkItemElems.filter(':checked').length;
					if (selectedCount@@gt;0) {
						$massOpRow.show();
						$massOpRow.find('.listSelectedItemsCount').html(selectedCount);
					} else
						$massOpRow.hide();
				};
				var refreshShowAllState = function() {
					$checkAllElem.attr('checked', $checkItemElems.filter(':checked').length==$checkItemElems.length );
				};
				$checkAllElem.click(function() {
					$checkItemElems.attr('checked', $checkAllElem.is(':checked'));
					showMassOpRow();
				});
				$checkItemElems.click(function() {
					refreshShowAllState();
					showMassOpRow();
				});
				refreshShowAllState();
				showMassOpRow();
			});
			</script>
		</xsl:if>		
		
		<xsl:variable name="showPager">
			<xsl:choose>
				<xsl:when test="l:pager/@show"><xsl:value-of select="l:pager/@show"/></xsl:when>
				<xsl:when test="$listDefaults/l:pager/@show"><xsl:value-of select="$listDefaults/l:pager/@show"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
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
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnPagePropertiesChanged(Object sender, EventArgs e) {
			DataContext["listView<xsl:value-of select="$listUniqueId"/>_StartRowIndex"] = ((IPageableItemContainer)sender).StartRowIndex;
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnSorted(Object sender, EventArgs e) {
			var listView = (System.Web.UI.WebControls.ListView)sender;
			DataContext["listView<xsl:value-of select="$listUniqueId"/>_SortExpression"] = String.IsNullOrEmpty(listView.SortExpression) ? null 
				: String.Format("{0} {1}", listView.SortExpression, listView.SortDirection==System.Web.UI.WebControls.SortDirection.Descending ? "desc" : "asc" );
		}
		
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnDataBound(Object sender, EventArgs e) {
			<xsl:if test="$showPager='ifpagingpossible'">
				foreach (var dataPager in ((Control)sender).GetChildren@@lt;DataPager@@gt;() ) {
					dataPager.Visible = (dataPager.PageSize @@lt; dataPager.TotalRowCount);
				}
			</xsl:if>
			<xsl:if test="$showPager='no'">
				foreach (var dataPager in ((Control)sender).GetChildren@@lt;DataPager@@gt;() )
					dataPager.Visible = false;
			</xsl:if>
		}
		
		protected object listView<xsl:value-of select="$listUniqueId"/>_CurrentGroupValue = null;
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnDataBinding(Object sender, EventArgs e) {		
			listView<xsl:value-of select="$listUniqueId"/>_CurrentGroupValue = null;
			<!-- initializing data-related settings (key names, insert data item etc) -->
			<!-- heuristics for DALC data source (refactor TODO) -->
			var dalcDataSource = ((NReco.Web.ActionDataSource) ((Control)sender).NamingContainer.FindControl("list<xsl:value-of select="$listUniqueId"/>ActionDataSource") ).UnderlyingSource as NI.Data.Dalc.Web.DalcDataSource;
			if (dalcDataSource!=null) {
				if (dalcDataSource.DataKeyNames!=null @@amp;@@amp; dalcDataSource.DataKeyNames.Length @@gt; 0)
					((System.Web.UI.WebControls.ListView)sender).DataKeyNames = dalcDataSource.DataKeyNames;
			}
			<xsl:if test="@add='true' or @add='1'">
				object newItem = null;
				<xsl:choose>
					<xsl:when test="l:insertdataitem">
						newItem = <xsl:apply-templates select="l:insertdataitem/l:*" mode="csharp-expr"/>;
					</xsl:when>
					<xsl:when test="$listDefaults/l:insertdataitem">
						newItem = <xsl:apply-templates select="$listDefaults/l:insertdataitem/l:*" mode="csharp-expr"/>;
					</xsl:when>
					<xsl:otherwise>
						<!-- heuristics for DALC data source -->
						if (dalcDataSource!=null @@amp;@@amp; dalcDataSource.DataSetProvider!=null) {
							var ds = dalcDataSource.DataSetProvider.GetDataSet(dalcDataSource.SourceName);
							if (ds!=null) {
								newItem = new NReco.Collections.DictionaryView( NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;( ds.Tables[0].NewRow() ) );
							}
						}
					</xsl:otherwise>
				</xsl:choose>
				if (newItem!=null) {
					((NReco.Web.Site.Controls.ListView)sender).InsertDataItem = newItem;
					<!-- initialize action -->
					<xsl:apply-templates select="l:action[@name='initialize']/l:*" mode="csharp-code">
						<xsl:with-param name="context">newItem</xsl:with-param>
					</xsl:apply-templates>
				}
			</xsl:if>
		}
		
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnInitSelectArguments(Object sender, EventArgs e) {
			<!-- applying initial sorting -->
			string defaultSortExpression = DataContext.ContainsKey("listView<xsl:value-of select="$listUniqueId"/>_SortExpression") ? DataContext["listView<xsl:value-of select="$listUniqueId"/>_SortExpression"] as string : null;
			<xsl:if test="l:sort">
				<xsl:variable name="directionSuffix">
					<xsl:choose>
						<xsl:when test="l:sort/@direction='asc'"> asc</xsl:when>
						<xsl:when test="l:sort/@direction='desc'"> desc</xsl:when>
						<xsl:otherwise></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				if (String.IsNullOrEmpty(defaultSortExpression))
					defaultSortExpression = "<xsl:value-of select="l:sort/@field"/><xsl:value-of select="$directionSuffix"/>";
			</xsl:if>
			if ( String.IsNullOrEmpty( ((System.Web.UI.WebControls.ListView)sender).SortExpression ) @@amp;@@amp; !String.IsNullOrEmpty(defaultSortExpression)) {
				var defSortExprParts = defaultSortExpression.Split(',');
				var lastPartQSort = new NI.Data.Dalc.QSortField(defSortExprParts[defSortExprParts.Length-1]);
				defSortExprParts[defSortExprParts.Length-1] = lastPartQSort.Name;
				((System.Web.UI.WebControls.ListView)sender).Sort( String.Join(",",defSortExprParts), lastPartQSort.SortDirection==System.ComponentModel.ListSortDirection.Descending ? System.Web.UI.WebControls.SortDirection.Descending : System.Web.UI.WebControls.SortDirection.Ascending );
			}
			
			<!-- restore start row index (if available) -->
			if (DataContext.ContainsKey("listView<xsl:value-of select="$listUniqueId"/>_StartRowIndex")) {
				var pageableContainer = (IPageableItemContainer)sender;
				var savedStartRowIndex = Convert.ToInt32(DataContext["listView<xsl:value-of select="$listUniqueId"/>_StartRowIndex"]);
				if (savedStartRowIndex!=pageableContainer.StartRowIndex)
					pageableContainer.SetPageProperties( savedStartRowIndex, pageableContainer.MaximumRows@@gt;0 ? pageableContainer.MaximumRows : 20, true);
			}		
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
				<xsl:with-param name="context">new NI.Common.Collections.CompositeDictionary() { MasterDictionary = e.NewValues, SatelliteDictionaries = new []{ e.Keys} }</xsl:with-param>
			</xsl:apply-templates>
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemUpdated(Object sender, ListViewUpdatedEventArgs e) {
			<xsl:apply-templates select="l:action[@name='updated']/l:*" mode="csharp-code">
				<xsl:with-param name="context">new NI.Common.Collections.CompositeDictionary() { MasterDictionary = e.NewValues, SatelliteDictionaries = new []{ e.Keys} }</xsl:with-param>
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
			@@lt;div class="validators"@@gt;
				<xsl:apply-templates select="." mode="form-view-validator">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
				</xsl:apply-templates>
			@@lt;/div@@gt;
		</div>
	</xsl:template>		
	
	<xsl:template match="l:field[not(l:editor) and l:renderer]" mode="list-view-filter-editor">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>		
		<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>		
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
	
	<xsl:template match="l:field[l:caption/l:renderer]" mode="list-view-table-header" priority="10">
		<xsl:param name="listNode"/>
		<th>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@headerclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@headerclass"/></xsl:when>
					<xsl:otherwise>ui-state-default</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>		
			<xsl:if test="@width">
				<xsl:attribute name="style">width:<xsl:value-of select="@width"/>;</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="l:caption/l:renderer/l:*" mode="aspnet-renderer">
				<xsl:with-param name="context">this.GetContext()</xsl:with-param>
			</xsl:apply-templates>
		</th>
	</xsl:template>
	
	<xsl:template match="l:field[(@sort='true' or @sort='1') and @name]" mode="list-view-table-header">
		<xsl:param name="listNode"/>
		<th>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@headerclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@headerclass"/></xsl:when>
					<xsl:otherwise>ui-state-default</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>		
			<xsl:if test="@width">
				<xsl:attribute name="style">width:<xsl:value-of select="@width"/>;</xsl:attribute>
			</xsl:if>
			<asp:LinkButton id="sortBtn{generate-id(.)}" CausesValidation="false" runat="server" Text="@@lt;%$ label:{@caption} %@@gt;" CommandName="Sort" CommandArgument="{@name}" OnPreRender="ListViewSortButtonPreRender"/>
		</th>
	</xsl:template>
	
	<xsl:template match="l:field" mode="list-view-table-header">
		<xsl:param name="listNode"/>
		<th>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@headerclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@headerclass"/></xsl:when>
					<xsl:otherwise>ui-state-default</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>		
			<xsl:if test="@width">
				<xsl:attribute name="style">width:<xsl:value-of select="@width"/>;</xsl:attribute>
			</xsl:if>
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
		<xsl:param name="listNode"/>
		<td>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/></xsl:when>
					<xsl:otherwise>ui-state-default listcell</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
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
		<xsl:param name="listNode"/>
		<xsl:param name="formUid"/>
		<xsl:apply-templates select="." mode="list-view-table-cell">
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
			<xsl:with-param name="listNode" select="$listNode"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:field[l:group]" mode="list-view-table-cell-editor" priority="10">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:param name="listNode"/>
		<td>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/> edit</xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/> edit</xsl:when>
					<xsl:otherwise>ui-state-default listcell edit</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>		
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
		<xsl:param name="listNode"/>		
		<td>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/></xsl:when>
					<xsl:otherwise>ui-state-default listcell</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>		
			<xsl:apply-templates select="." mode="aspnet-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
			</xsl:apply-templates>
		</td>
	</xsl:template>

	<xsl:template match="l:field[l:group]" mode="list-view-table-cell">
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>	
		<xsl:param name="listNode"/>
		<td>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/></xsl:when>
					<xsl:otherwise>ui-state-default listcell</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>				
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
		<xsl:param name="listNode"/>
		<xsl:param name="formUid"/>
		<td>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/></xsl:when>
					<xsl:otherwise>ui-state-default listcell</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>			
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
	</xsl:template>
	<xsl:template match="l:widget" mode="dashboard-widget">
		<xsl:variable name="width">
			<xsl:choose>
				<xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
				<xsl:otherwise>auto</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="height">
			<xsl:choose>
				<xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
				<xsl:otherwise>auto</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">
				<xsl:choose>
					<xsl:when test="@style='jqueryui'">
						<div style="float:left;margin:5px;width:{$width};">
							<div class="ui-widget-header ui-corner-top" style="width:{$width};">
								<div class="nreco-widget-header">
									<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
								</div>
							</div>
							<div class="ui-widget-content ui-corner-bottom" style="width:{$width};height:{$height};">
								<div class="nreco-widget-content">
									<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer"/>
								</div>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<fieldset style="width:{$width};height:{$height};">
							<xsl:if test="@caption">
								<legend><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></legend>
							</xsl:if>
							<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer"/>
						</fieldset>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
<!--
NReco library (http://nreco.googlecode.com/)
Copyright 2008-2014 Vitaliy Fedorchenko
Distributed under the LGPL licence
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->	
<xsl:stylesheet version='1.0' 
				xmlns:l="urn:schemas-nreco:webforms:layout:v2"
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:NIData="urn:remove/NIData"
				xmlns:NRecoWebForms="urn:remove/NRecoWebForms"
				xmlns:asp="urn:remove/AspNet"
				xmlns:UserControl="urn:remove/UserControl"
				xmlns:UserControlEditor="urn:remove/UserControlEditor"
				exclude-result-prefixes="msxsl">

	<xsl:output method='xml' indent='yes' />
	
	<xsl:variable name="dalcName" select="/l:model/l:settings/l:services/l:dalc/@name"/>
	<xsl:variable name="datasetFactoryName" select="/l:model/l:settings/l:services/l:datasetfactory/@name"/>
	<xsl:variable name="formDefaults" select="/l:model/l:settings/l:form"/>
	<xsl:variable name="listDefaults" select="/l:model/l:settings/l:list"/>
	<xsl:variable name="linkButtonDefaults" select="/l:model/l:settings/l:linkbutton"/>

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
		<xsl:variable name="rendererScope"><xsl:copy-of select=".//l:*"/></xsl:variable>
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

	<xsl:template name="view-register-control-code">
		<xsl:variable name="editorScope">
			<xsl:copy-of select=".//l:field[l:editor]"/>
		</xsl:variable>
		<xsl:variable name="editorScopeNode" select="msxsl:node-set($editorScope)"/>
		<!-- procedure for editors -->
		<xsl:for-each select="$editorScopeNode/l:field">
			<xsl:variable name="editorName" select="name(l:editor/l:*[position()=1])"/>
			<xsl:if test="count(following-sibling::l:field/l:editor/l:*[name()=$editorName])=0">
				<xsl:apply-templates select="." mode="register-editor-code">
					<xsl:with-param name="instances" select="preceding-sibling::l:field[name(l:editor/l:*)=$editorName]"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		<!-- procedure for renderers -->
		<xsl:variable name="rendererScope">
			<xsl:copy-of select=".//l:*"/>
		</xsl:variable>
		<xsl:variable name="rendererScopeNode" select="msxsl:node-set($rendererScope)"/>
		<xsl:for-each select="$rendererScopeNode/l:*">
			<xsl:variable name="rendererName" select="name()"/>
			<xsl:if test="count(following-sibling::l:*[name()=$rendererName])=0">
				<xsl:apply-templates select="." mode="register-renderer-code">
					<xsl:with-param name="instances" select="preceding-sibling::l:*[name()=$rendererName]"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- skip editors without registration -->
	<xsl:template match="*|text()" mode="register-editor-control"/>
	<!-- skip editors without external js -->
	<xsl:template match="*|text()" mode="register-editor-code"/>

	
	<!-- skip renderers without registration -->
	<xsl:template match="*|text()" mode="register-renderer-control"/>
	<!-- skip renderers without external js -->
	<xsl:template match="*|text()" mode="register-renderer-code"/>

	<xsl:template name="apply-visibility">
		<xsl:param name="content"/>
		<xsl:param name="expr"/>
		<xsl:choose>
			<xsl:when test="$expr">
				<xsl:variable name="exprStr">IsFuzzyTrue(<xsl:apply-templates select="$expr" mode="csharp-expr"/>)</xsl:variable>
				<NRecoWebForms:VisibilityHolder runat="server" Visible="@@lt;%# {translate($exprStr, '&#xA;&#xD;&#x9;', '')} %@@gt;">
					<xsl:if test="$expr/descendant-or-self::l:control">
						<xsl:attribute name="DependentFromControls">
							<xsl:for-each select="$expr/descendant-or-self::l:control">
								<xsl:if test="position()!=1">,</xsl:if>
								<xsl:value-of select="@name"/>
							</xsl:for-each>
						</xsl:attribute>
					</xsl:if>
					<xsl:copy-of select="$content"/>
				</NRecoWebForms:VisibilityHolder>
			</xsl:when>
			<xsl:otherwise><xsl:copy-of select="$content"/></xsl:otherwise>
		</xsl:choose>
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
			<xsl:otherwise>Response.Redirect( Convert.ToString( <xsl:value-of select="$url"/> ), false);</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="l:databind" mode="csharp-code">
		<xsl:choose>
			<xsl:when test="l:*">
				<xsl:apply-templates select="l:*" mode="control-instance-expr"/>.DataBind();
			</xsl:when>
			<xsl:otherwise>
				DataBind();
				if (ScriptManager.GetCurrent(Page)!=null @@amp;@@amp; ScriptManager.GetCurrent(Page).IsInAsyncPostBack) {
					foreach (var updatePanel in ControlUtils.GetChildren@@lt;System.Web.UI.UpdatePanel@@gt;(this))
						if (updatePanel.UpdateMode==UpdatePanelUpdateMode.Conditional)
							updatePanel.Update();
				}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="l:list" mode="control-instance-expr">
		ControlUtils.GetChildren@@lt;Control@@gt;(this).Where(c=@@gt;c.ID=="<xsl:value-of select="@name"/>").FirstOrDefault()
	</xsl:template>

	<xsl:template match="l:code" mode="csharp-code">
		<xsl:value-of select="." disable-output-escaping="yes"/>
	</xsl:template>
	
	<xsl:template match="l:action" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="actionParams">
			<xsl:for-each select="l:*"><xsl:if test="position()>1">,</xsl:if><xsl:apply-templates select="." mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:for-each>
		</xsl:variable>
		<xsl:variable name="genericParams">
			<xsl:for-each select="l:*"><xsl:if test="position()>1">,</xsl:if>object</xsl:for-each>
		</xsl:variable>
		AppContext.ComponentFactory.GetComponent@@lt;Action@@lt;<xsl:value-of select="$genericParams"/>@@gt;@@gt;("<xsl:value-of select="@name"/>")(<xsl:value-of select="$actionParams"/>);
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
	
	<xsl:template match="l:if" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:variable name="testExpr">
			<xsl:apply-templates select="l:test/l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="thenExpr">
			<xsl:apply-templates select="l:then/l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="elseExpr">
			<xsl:apply-templates select="l:else/l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		(Convert.ToBoolean(<xsl:value-of select="$testExpr"/>)?<xsl:value-of select="$thenExpr"/>:<xsl:value-of select="$elseExpr"/>)
	</xsl:template>	

	<xsl:template match="l:label" mode="csharp-expr">
		<xsl:param name="context"/>	
		AppContext.GetLabel(Convert.ToString(<xsl:apply-templates select="l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>))
	</xsl:template>
	
	<xsl:template match="l:emptyfallback" mode="csharp-expr">
		<xsl:param name="context"/>	
		EmptyFallback( <xsl:for-each select="l:*"><xsl:if test="position()>1">,</xsl:if> <xsl:apply-templates select="." mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:for-each>)
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
		ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.FormView@@gt;(this).Where( c=@@gt;c.ID=="<xsl:value-of select="@name"/>").FirstOrDefault().ChangeMode(FormViewMode.<xsl:value-of select="@mode"/>);
	</xsl:template>

	<xsl:template match="l:saveform" mode="csharp-code">
		<xsl:variable name="tmpVarName" select="generate-id(.)"/>
		var form<xsl:value-of select="$tmpVarName"/> = ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.FormView@@gt;().Where( c=@@gt;c.ID=="<xsl:value-of select="@name"/>").FirstOrDefault();
		if (form<xsl:value-of select="$tmpVarName"/>.CurrentMode==FormViewMode.Insert) {
			form<xsl:value-of select="$tmpVarName"/>.InsertItem(true);
		} else if (form<xsl:value-of select="$tmpVarName"/>.CurrentMode==FormViewMode.Edit) {
			form<xsl:value-of select="$tmpVarName"/>.UpdateItem(true);
		}
		if (!Page.IsValid) return;
	</xsl:template>
	
	<xsl:template match="l:jscallback" mode="csharp-code">
		<xsl:param name="context"/>
		<xsl:variable name="callbackFunctionExpr">
			<xsl:choose>
				<xsl:when test="l:function">
					<xsl:apply-templates select="l:function/l:*" mode="csharp-expr">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>null</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="callbackArgFormatted">
			<xsl:choose>
				<xsl:when test="l:arg/l:*">
					<xsl:for-each select="l:arg">
						<xsl:if test="position()>1">,</xsl:if> JsUtils.ToJsonString(<xsl:apply-templates select="l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>""</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="callbackArgFmtPlaceholders">
			<xsl:choose>
				<xsl:when test="l:arg/l:*"><xsl:for-each select="l:arg"><xsl:if test="position()>1">,</xsl:if>{<xsl:value-of select="position()"/>}</xsl:for-each></xsl:when>
				<xsl:otherwise>{1}</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		var callbackScript = String.Format("var wnd; if (parent) wnd = parent;if (opener) wnd = opener; <xsl:if test="l:function/l:*">wnd.{0}(<xsl:value-of select="$callbackArgFmtPlaceholders"/>);</xsl:if> <xsl:if test="not(@close) or @close='true'">window.close();</xsl:if> ", <xsl:value-of select="$callbackFunctionExpr"/>, <xsl:value-of select="$callbackArgFormatted"/> );
		if (System.Web.UI.ScriptManager.GetCurrent(Page)!=null @@amp;@@amp; System.Web.UI.ScriptManager.GetCurrent(Page).IsInAsyncPostBack) {
			System.Web.UI.ScriptManager.RegisterStartupScript(Page,this.GetType(),callbackScript,callbackScript,true);
		} else {
			Response.Write("@@lt;html@@gt;@@lt;body@@gt;@@lt;script type=\"text/javascript\"@@gt;");
			Response.Write(callbackScript);
			Response.Write("@@lt;/sc"+"ript@@gt;@@lt;/body@@gt;@@lt;/html@@gt;");
			if (<xsl:value-of select="$context"/> is NReco.Dsm.WebForms.ActionEventArgs) {
				( (NReco.Dsm.WebForms.ActionEventArgs) ((object)<xsl:value-of select="$context"/>) ).ResponseEndRequested = true;
			} else { 
				Response.End();
			}
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
	
	<xsl:template match="l:datacontext" mode="csharp-expr">
		DataContext<xsl:if test="@name">["<xsl:value-of select="@name"/>"]</xsl:if>
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
		AreEqual(<xsl:apply-templates select="node()[position()=1]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>,<xsl:apply-templates select="node()[position()=2]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)
	</xsl:template>
	
	<xsl:template match="l:request" mode="csharp-expr">
		Request["<xsl:value-of select="@name"/>"]
	</xsl:template>

	<xsl:template match="l:routedata" mode="csharp-expr">
		Page.RouteData.Values["<xsl:value-of select="@name"/>"]
	</xsl:template>

	<xsl:template match="l:const" mode="csharp-expr">"<xsl:value-of select="."/>"</xsl:template>
	
	<xsl:template match="l:format" name="format-csharp-expr" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:param name="str" select="@str"/>
		String.Format(AppContext.GetLabel("<xsl:value-of select="$str"/>",this.GetType().ToString()) <xsl:for-each select="l:*">,<xsl:apply-templates select="." mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:for-each>)
	</xsl:template>

	<xsl:template match="l:listrowcount" mode="csharp-expr">
		String.Format("@@lt;span class='listRowCount<xsl:value-of select="@name"/>'@@gt;{0}@@lt;/span@@gt;", GetListViewRowCount( ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;(this).Where( c=@@gt;c.ID=="<xsl:value-of select="@name"/>").FirstOrDefault() ) )
	</xsl:template>

	<xsl:template match="l:listselectedkeys" mode="csharp-expr">
		GetListSelectedKeys( ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;(this).Where( c=@@gt;c.ID=="<xsl:value-of select="@name"/>").FirstOrDefault() ) 
	</xsl:template>
	
	<xsl:template match="l:formcurrentmode" mode="csharp-expr">
		ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.FormView@@gt;(this).Where( c=@@gt;c.ID=="<xsl:value-of select="@name"/>").FirstOrDefault().CurrentMode.ToString()
	</xsl:template>

	<xsl:template match="l:lookup" name="lookup-csharp-expr" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:param name="service" select="@name"/>
		AppContext.ComponentFactory.GetComponent@@lt;Func@@lt;object,object@@gt;@@gt;("<xsl:value-of select="$service"/>")( <xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates> )
	</xsl:template>
	
	<xsl:template match="l:field" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:choose>
			<xsl:when test="not($context='')">GetContextFieldValue(<xsl:value-of select="$context"/>, "<xsl:value-of select="@name"/>")</xsl:when>
			<xsl:otherwise>Eval("<xsl:value-of select="@name"/>")</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="l:dataitem" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:variable name="contextExpr">
			<xsl:choose>
				<xsl:when test="not($context='')"><xsl:value-of select="$context"/></xsl:when>
				<xsl:otherwise>Container.DataItem</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@name">CastToDictionary(<xsl:value-of select="$contextExpr"/>)["<xsl:value-of select="@name"/>"]</xsl:when>
			<xsl:otherwise><xsl:value-of select="$contextExpr"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="l:control" mode="csharp-expr">
		GetControlValue(Container, "<xsl:value-of select="@name"/>")
	</xsl:template>
	
	<xsl:template match="l:func" mode="csharp-expr">
		<xsl:param name="context"/>
		<xsl:variable name="cache">
			<xsl:choose>
				<xsl:when test="@cache='true'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>			
		</xsl:variable>
		<xsl:variable name="genericParams">
			object<xsl:for-each select="l:*">,object</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="funcParams">
			<xsl:for-each select="l:*">,<xsl:apply-templates select="." mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:for-each>
		</xsl:variable>
		GetFuncResult( AppContext.ComponentFactory.GetComponent@@lt;Func@@lt;<xsl:value-of select="$genericParams"/>@@gt;@@gt;("<xsl:value-of select="@name"/>"), "<xsl:value-of select="@name"/>", <xsl:value-of select="$cache"/> <xsl:value-of select="$funcParams"/>)</xsl:template>
	
	<xsl:template match="l:get" mode="csharp-expr">
		<xsl:param name="context"/>
		CastToDictionary(<xsl:apply-templates select="l:*[position()=1]" mode="csharp-expr"/>??new Hashtable())["<xsl:value-of select="@name"/>"]</xsl:template>	

	<xsl:template match="l:lambda" mode="csharp-expr">
		<xsl:param name="context"/>
		EvalLambdaExpression(@"<xsl:value-of select="l:expression"/>", <xsl:apply-templates select="l:context/l:*[position()=1]" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)
	</xsl:template>	
		
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
		<xsl:copy-of select="node()|text()"/>
	</xsl:template>

	<xsl:template match="l:usercontrol" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:element name="UserControl:{@name}">
			<xsl:attribute name="runat">server</xsl:attribute>
			<xsl:for-each select="attribute::*">
				<xsl:if test="not(name()='src' or name()='name')">
					<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="l:property">
				<xsl:variable name="bindingExpr"><xsl:apply-templates select="l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="{@name}">@@lt;%# <xsl:value-of select="$bindingExpr"/> %@@gt;</xsl:attribute>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="l:placeholder" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">
				<xsl:apply-templates select="l:content/node()" mode="aspnet-renderer">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:apply-templates>	
			</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="l:placeholder[@class]" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">
				<div class="{@class}">
					<xsl:apply-templates select="l:content/node()" mode="aspnet-renderer">
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="formUid" select="$formUid"/>
						<xsl:with-param name="mode" select="$mode"/>
					</xsl:apply-templates>
				</div>
			</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="l:table" mode="aspnet-renderer">
		<table border="0" cellpadding="0" cellspacing="0">
			<xsl:if test="@class">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
			<xsl:for-each select="l:row">
				<tr>
					<xsl:for-each select="l:cell">
						<td>
							<xsl:if test="@colspan">
								<xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute>
							</xsl:if>
							<xsl:if test="@width">
								<xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
							</xsl:if>
							<xsl:apply-templates select="l:*" mode="aspnet-renderer"/>
						</td>
					</xsl:for-each>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template match="l:image" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<NRecoWebForms:DataBindHolder runat="server">
			<xsl:variable name="urlExpr"><xsl:apply-templates select="l:url/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
			<image runat="server">
				<xsl:attribute name="src">@@lt;%# <xsl:value-of select="$urlExpr"/> %@@gt;</xsl:attribute>
				<xsl:if test="@class">
					<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="@width">
					<xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="@height">
					<xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
				</xsl:if>
			</image>
		</NRecoWebForms:DataBindHolder>
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
				<xsl:otherwise>formView<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
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
		<NRecoWebForms:ActionDataSource runat="server" id="{$uniqueId}ActionDataSource" DataSourceID="{$mainDsId}" />
			
		<xsl:call-template name="layout-form-generate-actions-code">
			<xsl:with-param name="uniqueId" select="$uniqueId"/>
		</xsl:call-template>
					
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
		
		<NRecoWebForms:formview id="{$uniqueId}"
			oniteminserted="FormView_{$uniqueId}_InsertedHandler"
			oniteminserting="FormView_{$uniqueId}_InsertingHandler"
			onitemdeleted="FormView_{$uniqueId}_DeletedHandler"
			onitemdeleting="FormView_{$uniqueId}_DeletingHandler"
			onitemupdated="FormView_{$uniqueId}_UpdatedHandler"
			onitemupdating="FormView_{$uniqueId}_UpdatingHandler"
			onitemcommand="FormView_{$uniqueId}_CommandHandler"
			ondatabound="FormView_{$uniqueId}_DataBound"
			datasourceid="{$uniqueId}ActionDataSource"
			allowpaging="false"
			RenderOuterTable="false"
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
				<xsl:choose>
					<xsl:when test="@datakey"><xsl:value-of select="@datakey"/></xsl:when>
					<xsl:when test="$formDefaults/@datakey"><xsl:value-of select="$formDefaults/@datakey"/></xsl:when>
					<xsl:otherwise>id</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:if test="$viewEnabled='true'">
				<itemtemplate>
					<xsl:apply-templates select="." mode="layout-form-template">
						<xsl:with-param name="formClass">
							<xsl:choose>
								<xsl:when test="l:styles/l:table/@class"><xsl:value-of select="l:styles/l:table/@class"/></xsl:when>
								<xsl:when test="$formDefaults/l:styles/l:table/@class"><xsl:value-of select="$formDefaults/l:styles/l:table/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
							readOnlyMode							
						</xsl:with-param>
						<xsl:with-param name="renderFormHeader" select="count(msxsl:node-set($viewHeader)/*)>0"/>
						<xsl:with-param name="formHeader">
							<xsl:apply-templates select="msxsl:node-set($viewHeader)/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormHeader</xsl:with-param>
							</xsl:apply-templates>
						</xsl:with-param>
						<xsl:with-param name="renderFormFooter" select="count(msxsl:node-set($viewFooter)/*)>0"/>
						<xsl:with-param name="formFooter">
							<xsl:apply-templates select="msxsl:node-set($viewFooter)/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormFooter</xsl:with-param>
							</xsl:apply-templates>							
						</xsl:with-param>
						<xsl:with-param name="formBody">
							<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
								<xsl:call-template name="apply-visibility">
									<xsl:with-param name="content">
										<xsl:apply-templates select="." mode="plain-form-view-table-row">
											<xsl:with-param name="viewFilter">view</xsl:with-param>
											<xsl:with-param name="context">Container.DataItem</xsl:with-param>
											<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
										</xsl:apply-templates>								
									</xsl:with-param>
									<xsl:with-param name="expr" select="l:visible/node()"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:with-param>
					</xsl:apply-templates>
				</itemtemplate>
			</xsl:if>
			
			<xsl:if test="$editEnabled='true'">
				<edititemtemplate>
					
					<xsl:apply-templates select="." mode="layout-form-template">
						<xsl:with-param name="formClass">
							<xsl:choose>
								<xsl:when test="l:styles/l:table/@class"><xsl:value-of select="l:styles/l:table/@class"/></xsl:when>
								<xsl:when test="$formDefaults/l:styles/l:table/@class"><xsl:value-of select="$formDefaults/l:styles/l:table/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
							editMode						
						</xsl:with-param>
						<xsl:with-param name="renderFormHeader" select="count(msxsl:node-set($editHeader)/*)>0"/>
						<xsl:with-param name="formHeader">
								<xsl:apply-templates select="msxsl:node-set($editHeader)/l:*" mode="aspnet-renderer">
									<xsl:with-param name="context">Container.DataItem</xsl:with-param>
									<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
									<xsl:with-param name="mode">FormHeader</xsl:with-param>
								</xsl:apply-templates>
						</xsl:with-param>
						<xsl:with-param name="renderFormFooter" select="count(msxsl:node-set($editFooter)/*)>0"/>
						<xsl:with-param name="formFooter">
							<xsl:apply-templates select="msxsl:node-set($editFooter)/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormFooter</xsl:with-param>
							</xsl:apply-templates>
						</xsl:with-param>
						<xsl:with-param name="formBody">
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
						</xsl:with-param>
					</xsl:apply-templates>
					
				</edititemtemplate>
			</xsl:if>
			
			<xsl:if test="$addEnabled='true'">
				<insertitemtemplate>
					<xsl:apply-templates select="." mode="layout-form-template">
						<xsl:with-param name="formClass">
							<xsl:choose>
								<xsl:when test="l:styles/l:table/@class"><xsl:value-of select="l:styles/l:table/@class"/></xsl:when>
								<xsl:when test="$formDefaults/l:styles/l:table/@class"><xsl:value-of select="$formDefaults/l:styles/l:table/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
							insertMode
						</xsl:with-param>
						<xsl:with-param name="renderFormHeader" select="count(msxsl:node-set($addHeader)/*)>0"/>
						<xsl:with-param name="formHeader">
									<xsl:apply-templates select="msxsl:node-set($addHeader)/l:*" mode="aspnet-renderer">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
										<xsl:with-param name="mode">FormHeader</xsl:with-param>
									</xsl:apply-templates>
						</xsl:with-param>
						<xsl:with-param name="renderFormFooter" select="count(msxsl:node-set($addFooter)/*)>0"/>
						<xsl:with-param name="formFooter">
									<xsl:apply-templates select="msxsl:node-set($addFooter)/l:*" mode="aspnet-renderer">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
										<xsl:with-param name="mode">FormFooter</xsl:with-param>
									</xsl:apply-templates>
						</xsl:with-param>
						<xsl:with-param name="formBody">
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
						</xsl:with-param>
					</xsl:apply-templates>					
				</insertitemtemplate>
			</xsl:if>
		</NRecoWebForms:formview>
			
	</xsl:template>

	<xsl:template match="l:*" mode="layout-form-template">
		<xsl:param name="formClass"/>
		<xsl:param name="renderFormHeader"/>
		<xsl:param name="formHeader"/>
		<xsl:param name="renderFormFooter"/>
		<xsl:param name="formFooter"/>
		<xsl:param name="formBody"/>
		<table class="{$formClass}">
			<xsl:if test="$renderFormHeader">
				<tr class="formheader">
					<td colspan="2">
						<xsl:copy-of select="$formHeader"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:copy-of select="$formBody"/>
			<xsl:if test="$renderFormFooter">
				<tr class="formfooter">
					<td colspan="2">
						<xsl:copy-of select="$formFooter"/>
					</td>
				</tr>
			</xsl:if>
		</table>
	</xsl:template>
	
	<xsl:template name="layout-form-generate-actions-code">
		<xsl:param name="uniqueId"/>
		
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
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.Values;
			var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
			var Container = (System.Web.UI.WebControls.FormView)sender;
			<xsl:apply-templates select="l:action[@name='inserting']/l:*" mode="form-operation">
				<xsl:with-param name="context">e.Values</xsl:with-param>
				<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
			</xsl:apply-templates>
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_UpdatingHandler(object sender, FormViewUpdateEventArgs e) {
			FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = e.NewValues;
			var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
			var Container = (System.Web.UI.WebControls.FormView)sender;
			<xsl:apply-templates select="l:action[@name='updating']/l:*" mode="form-operation">
				<xsl:with-param name="context">new NReco.Dsm.WebForms.CompositeDictionary(e.NewValues, e.Keys)</xsl:with-param>
				<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
			</xsl:apply-templates>
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_DeletingHandler(object sender, FormViewDeleteEventArgs e) {
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
					<xsl:with-param name="context">new NReco.Dsm.WebForms.CompositeDictionary( e.NewValues, e.Keys)</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
			}
		}
		public void FormView_<xsl:value-of select="$uniqueId"/>_CommandHandler(object sender, FormViewCommandEventArgs e) {
			if (!(new[]{"Update","Insert","Delete","Cancel","Edit","New","Page"}).Contains(e.CommandName)) {
				CommandHandler(sender, e);
			}
			<xsl:if test="l:action[@name='cancel']">
			if (e.CommandName.ToLower()=="cancel") {
				var senderForm = (System.Web.UI.WebControls.FormView)sender;
				var dataContext = senderForm.DataKey!=null ? new Hashtable(senderForm.DataKey.Values) : new Hashtable();
				<xsl:apply-templates select="l:action[@name='cancel']/l:*" mode="form-operation">
					<xsl:with-param name="context">dataContext</xsl:with-param>
					<xsl:with-param name="formView">senderForm</xsl:with-param>
				</xsl:apply-templates>
				if (Response.IsRequestBeingRedirected)
					Response.End();				
			}
			</xsl:if>
		}

		protected bool FormView_<xsl:value-of select="$uniqueId"/>_IsDataRowAdded(object o) {
			System.Data.DataRow r = null;
			if (o is System.Data.DataRow) r = (System.Data.DataRow)o;
			else if (o is System.Data.DataRowView) r = ((System.Data.DataRowView)o).Row;
			return r!=null ? r.RowState==System.Data.DataRowState.Added : false;
		}
		
		protected void FormView_<xsl:value-of select="$uniqueId"/>_DataBound(object sender, EventArgs e) {
			var FormView = (NReco.Dsm.WebForms.FormView)sender;
			<xsl:choose>
				<xsl:when test="l:insertmodecondition">var insertMode = Convert.ToBoolean(<xsl:apply-templates select="l:insertmodecondition/l:*" mode="csharp-expr"/>);</xsl:when>
				<xsl:when test="$formDefaults/l:insertmodecondition">var insertMode = Convert.ToBoolean(<xsl:apply-templates select="$formDefaults/l:insertmodecondition/l:*" mode="csharp-expr"/>);</xsl:when>
				<xsl:otherwise>var insertMode = false;</xsl:otherwise>
			</xsl:choose>
			if (insertMode || FormView.DataItemCount==0 || FormView_<xsl:value-of select="$uniqueId"/>_IsDataRowAdded(FormView.DataItem) ) {
				NReco.Collections.DictionaryView newItem = new NReco.Collections.DictionaryView( new System.Collections.Hashtable() );
				
				var dalcDataSource = ((NReco.Dsm.WebForms.ActionDataSource) ((Control)sender).NamingContainer.FindControl("<xsl:value-of select="$uniqueId"/>ActionDataSource") ).UnderlyingSource as NI.Data.Web.DalcDataSource;
				
				System.Data.DataView dsView = null;
				((IDataSource)dalcDataSource).GetView(dalcDataSource.TableName).Select( 
						new DataSourceSelectArguments(0,0),
						(data) =@@gt; { dsView = data as System.Data.DataView; } );
				if (dsView!=null) {
					newItem = new NReco.Collections.DictionaryView( NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;( dsView.Table.NewRow() ) );
				}
				
				var forceDataBind = FormView.CurrentMode==FormViewMode.Insert @@amp;@@amp; FormView.InsertDataItem==null;
				FormView.InsertDataItem = FormView.DataItem ?? newItem;
				FormView_<xsl:value-of select="$uniqueId"/>_ActionContext = CastToDictionary( FormView.InsertDataItem );
				var dataContext = FormView_<xsl:value-of select="$uniqueId"/>_ActionContext;
				<xsl:apply-templates select="l:action[@name='initialize']/l:*[name()!='setcontrol']" mode="form-operation">
					<xsl:with-param name="context">FormView_<xsl:value-of select="$uniqueId"/>_ActionContext</xsl:with-param>
					<xsl:with-param name="formView">((System.Web.UI.WebControls.FormView)sender)</xsl:with-param>
				</xsl:apply-templates>
				FormView.ChangeMode(FormViewMode.Insert);
				if (forceDataBind) {
					FormView.DataBind();
				}				

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
		foreach (DictionaryEntry entry in (CastToDictionary( ((NReco.Dsm.WebForms.FormView)sender).LoadDataItem() ) ?? new Hashtable() ) ) {
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
						<span class="fieldcaption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></span><xsl:call-template name="renderFormFieldCaptionSuffix"/>
					</xsl:when>
					<xsl:when test="l:caption/l:*">
						<span class="fieldcaption"><xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates></span><xsl:call-template name="renderFormFieldCaptionSuffix"/>
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

	<xsl:template match="l:field[@layout='raw']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:param name="viewFilter"/>
		<xsl:apply-templates select="." mode="aspnet-renderer">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context">Container.DataItem</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:field[@layout='vertical']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:if test="@caption or l:caption/l:*">
			<tr class="vertical">
				<th colspan="2">
					<span class="fieldcaption">
						<xsl:choose>
							<xsl:when test="@caption">
								<NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label>
							</xsl:when>
							<xsl:when test="l:caption/l:*">
								<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
									<xsl:with-param name="context" select="$context"/>
								</xsl:apply-templates>
							</xsl:when>
						</xsl:choose>
					</span>
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
						<span class="fieldcaption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></span><xsl:if test=".//l:editor/l:validators/l:required"><xsl:call-template name="renderFormFieldCaptionRequiredSuffix"/></xsl:if><xsl:call-template name="renderFormFieldCaptionSuffix"/>
					</xsl:when>
					<xsl:when test="l:caption/l:*">
						<span class="fieldcaption"><xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates></span><xsl:if test=".//l:editor/l:validators/l:required"><xsl:call-template name="renderFormFieldCaptionRequiredSuffix"/></xsl:if><xsl:call-template name="renderFormFieldCaptionSuffix"/>
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

	<xsl:template match="l:field[@layout='raw']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:apply-templates select="." mode="edit-form-view">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:field[@layout='vertical']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		
		<xsl:if test="@caption or l:caption/l:*">
			<tr class="vertical">
				<th colspan="2">
					<span class="fieldcaption">
					<xsl:choose>
						<xsl:when test="@caption">
							<NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label>
						</xsl:when>
						<xsl:when test="l:caption/l:*">
							<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
					</span>
					<xsl:if test="l:editor/l:validators/l:required">
						<xsl:call-template name="renderFormFieldCaptionRequiredSuffix"/>
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
	
	<xsl:template match="l:field" mode="edit-form-view">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
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
		<xsl:if test="@hint or l:hint">
			<div class="fieldHint">
				<xsl:choose>
					<xsl:when test="@hint"><NRecoWebForms:Label runat="server"><xsl:value-of select="@hint"/></NRecoWebForms:Label></xsl:when>
					<xsl:when test="l:hint/l:*">
						<xsl:apply-templates select="l:hint/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="formUid" select="$formUid"/>
						</xsl:apply-templates>
					</xsl:when>					
					<xsl:when test="l:hint"><NRecoWebForms:Label runat="server"><xsl:value-of select="l:hint"/></NRecoWebForms:Label></xsl:when>
				</xsl:choose>
			</div>
		</xsl:if>
	</xsl:template>
	

	<xsl:template match="l:field[not(l:renderer)]" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:variable name="renderer">
			<xsl:choose>
				<xsl:when test="@lookup and @format"><l:format str="{@format}"><l:lookup service="{@lookup}"><l:field name="{@name}"/></l:lookup></l:format></xsl:when>
				<xsl:when test="@format"><l:format str="{@format}"><l:field name="{@name}"/></l:format></xsl:when>
				<xsl:when test="@lookup"><l:lookup name="{@lookup}"><l:field name="{@name}"/></l:lookup></xsl:when>
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
		<xsl:param name="formUid"/>
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">		
				<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
				</xsl:apply-templates>
			</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="l:form-section" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		<xsl:if test="not(//parent::l:form)">
			<xsl:message terminate="yes">form-section can be used only inside form element</xsl:message>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$mode='add' or $mode='edit'">
				<xsl:for-each select="l:field[($mode='add' and (not(@add) or @add='true' or @add='1')) or ($mode='edit' and (not(@edit) or @edit='true' or @edit='1')) ]">
					<xsl:call-template name="apply-visibility">
						<xsl:with-param name="content">
							<xsl:apply-templates select="." mode="edit-form-view-table-row">
								<xsl:with-param name="mode" select="$mode"/>
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="formUid" select="$formUid"/>
							</xsl:apply-templates>							
						</xsl:with-param>
						<xsl:with-param name="expr" select="l:visible/node()"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
					<xsl:call-template name="apply-visibility">
						<xsl:with-param name="content">
							<xsl:apply-templates select="." mode="plain-form-view-table-row">
								<xsl:with-param name="mode" select="$mode"/>
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="formUid" select="$formUid"/>
							</xsl:apply-templates>								
						</xsl:with-param>
						<xsl:with-param name="expr" select="l:visible/node()"/>
					</xsl:call-template>
				</xsl:for-each>				
			</xsl:otherwise>
		</xsl:choose>
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
		<NRecoWebForms:DataBindHolder runat="server">
		<NRecoWebForms:LinkButton ValidationGroup="{$formUid}" id="linkBtn{$mode}{generate-id(.)}" 
			runat="server" CommandName="{@command}" command="{@command}"><!-- command attr for html element as metadata -->
			<xsl:if test="$linkButtonDefaults/@class or @class">
				<xsl:attribute name="CssClass">
					<xsl:choose>
						<xsl:when test="@class"><xsl:value-of select="@class"/></xsl:when>
						<xsl:when test="$linkButtonDefaults/@class"><xsl:value-of select="$linkButtonDefaults/@class"/></xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
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
		</NRecoWebForms:LinkButton>
		</NRecoWebForms:DataBindHolder>
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
		<NRecoWebForms:DataBindHolder runat="server">
		<a href="@@lt;%# {$url} %@@gt;" runat="server">
			<xsl:if test="@target and not(@target='popup')">
				<xsl:attribute name="target">_<xsl:value-of select="@target"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@class">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@target='popup'">
				<xsl:attribute name="onclick">return window.open(this.href,"popup","status=0,toolbar=0,location=0,width=800,height=600") @@amp;@@amp;false</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@caption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></xsl:when>
				<xsl:when test="l:caption/l:*">
					<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</a>
		</NRecoWebForms:DataBindHolder>
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
		<Plugin:TextBoxEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}">
			<xsl:if test="not(l:editor/l:textbox/@bind) or l:editor/l:textbox/@bind='true' or l:editor/l:textbox/@bind='1'">
				<xsl:attribute name="Value">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textbox/@empty-is-null='1' or l:editor/l:textbox/@empty-is-null='true'">
				<xsl:attribute name="EmptyIsNull">True</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textbox/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:textbox/@width"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textbox/@prefix">
				<xsl:attribute name="PrefixText">@@lt;%$ label: <xsl:value-of select="l:editor/l:textbox/@prefix"/> %@@gt;</xsl:attribute>
			</xsl:if>			
			<xsl:if test="l:editor/l:textbox/@suffix">
				<xsl:attribute name="SuffixText">@@lt;%$ label: <xsl:value-of select="l:editor/l:textbox/@suffix"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textbox/@format">
				<xsl:attribute name="Format">
					<xsl:value-of select="l:editor/l:textbox/@format"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="DataType">
				<xsl:choose>
					<xsl:when test="l:editor/l:textbox/@datatype='integer'">Int32</xsl:when>
					<xsl:when test="l:editor/l:textbox/@datatype='decimal'">Decimal</xsl:when>
					<xsl:when test="l:editor/l:textbox/@datatype='double'">Double</xsl:when>
					<xsl:when test="l:editor/l:textbox/@datatype='datetime'">DateTime</xsl:when>
					<xsl:otherwise>String</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="l:editor/l:textbox/@placeholder">
				<xsl:attribute name="Placeholder">@@lt;%$ label: <xsl:value-of select="l:editor/l:textbox/@placeholder"/> %@@gt;</xsl:attribute>
			</xsl:if>
		</Plugin:TextBoxEditor>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:usercontrol]" mode="form-view-editor">
		<xsl:param name="context"/>
		<xsl:param name="formUid">Form</xsl:param>
		<xsl:element name="UserControlEditor:{l:editor/l:usercontrol/@name}">
			<xsl:attribute name="runat">server</xsl:attribute>
			<xsl:attribute name="ValidationGroup"><xsl:value-of select="$formUid"/></xsl:attribute>

			<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
			<xsl:if test="not(l:editor/l:usercontrol/@bind) or l:editor/l:usercontrol/@bind='true' or l:editor/l:usercontrol/@bind='1'">
				<xsl:attribute name="Value">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			</xsl:if>

			<xsl:for-each select="l:editor/l:usercontrol">
				<xsl:for-each select="attribute::*">
					<xsl:if test="not(name()='src' or name()='name')">
						<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="l:property">
					<xsl:variable name="bindingExpr"><xsl:apply-templates select="l:*" mode="csharp-expr"/></xsl:variable>
					<xsl:attribute name="{@name}">@@lt;%# <xsl:value-of select="$bindingExpr"/> %@@gt;</xsl:attribute>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:element>		
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:textbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="TextBoxEditor" src="~/templates/editors/TextBoxEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:textarea]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="TextAreaEditor" src="~/templates/editors/TextAreaEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:textarea]" mode="form-view-editor">
		<Plugin:TextAreaEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}">
			<xsl:if test="not(l:editor/l:textarea/@bind) or l:editor/l:textarea/@bind='true' or l:editor/l:textarea/@bind='1'">
				<xsl:attribute name="Text">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textarea/@empty-is-null='1' or l:editor/l:textarea/@empty-is-null='true'">
				<xsl:attribute name="EmptyIsNull">True</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textarea/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:textarea/@width"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textarea/@rows">
				<xsl:attribute name="Rows"><xsl:value-of select="l:editor/l:textarea/@rows"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:textarea/@cols">
				<xsl:attribute name="Columns"><xsl:value-of select="l:editor/l:textarea/@cols"/></xsl:attribute>
			</xsl:if>
		</Plugin:TextAreaEditor>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:checkbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="CheckBoxEditor" src="~/templates/editors/CheckBoxEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:checkbox]" mode="form-view-editor">
		<Plugin:CheckBoxEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}">
			<xsl:attribute name="Checked">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			<xsl:if test="l:editor/l:checkbox/@text">
				<xsl:attribute name="LabelText">@@lt;%$ label: <xsl:value-of select="l:editor/l:checkbox/@text"/> %@@gt;</xsl:attribute>
			</xsl:if>
		</Plugin:CheckBoxEditor>
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:textboxpassword]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="TextBoxPasswordEditor" src="~/templates/editors/TextBoxPasswordEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:textboxpassword]" mode="form-view-editor">
		<Plugin:TextBoxPasswordEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" 
			Text='@@lt;%# Bind("{@name}") %@@gt;'
			PasswordEncrypterName="{l:editor/l:textboxpassword/@encrypter}"/>
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:dropdownlist]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="DropDownListEditor" src="~/templates/editors/DropDownListEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:dropdownlist]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<xsl:param name="formUid"/>
		<Plugin:DropDownListEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}"
			LookupName="{l:editor/l:dropdownlist/l:lookup/@name}"
			TextFieldName="{l:editor/l:dropdownlist/l:lookup/@text}"
			ValueFieldName="{l:editor/l:dropdownlist/l:lookup/@value}"
			ValidationGroup="{$formUid}">
			<xsl:if test="not(l:editor/l:dropdownlist/@bind) or l:editor/l:dropdownlist/@bind='true' or l:editor/l:dropdownlist/@bind='1'">
				<xsl:attribute name="SelectedValue">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:dropdownlist/l:lookup/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:dropdownlist/l:lookup/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="LookupDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:dropdownlist/l:lookup//l:control">
				<xsl:attribute name="DependentFromControls">
					<xsl:for-each select="l:editor/l:dropdownlist/l:lookup//l:control">
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
		<xsl:if test="l:editor/l:dropdownlist/l:lookup//l:control">
			<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:dropdownlist/l:lookup/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
			<NRecoWebForms:DataContextHolder id="{@name}DataContextHolder" runat="server">
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</NRecoWebForms:DataContextHolder>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:radiobuttonlist]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="RadioButtonListEditor" src="~/templates/editors/RadioButtonListEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:radiobuttonlist]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<xsl:param name="formUid"/>
		<xsl:variable name="lookupPrvName" select="l:editor/l:radiobuttonlist/@lookup"/>
		<Plugin:RadioButtonListEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}"
			LookupName="{l:editor/l:radiobuttonlist/l:lookup/@name}"
			TextFieldName="{l:editor/l:radiobuttonlist/l:lookup/@text}"
			ValueFieldName="{l:editor/l:radiobuttonlist/l:lookup/@value}"
			ValidationGroup="{$formUid}">
			<xsl:attribute name="SelectedValue">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			<xsl:if test="l:editor/l:radiobuttonlist/l:lookup/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:radiobuttonlist/l:lookup/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="LookupDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:radiobuttonlist/l:lookup//l:control">
				<xsl:attribute name="DependentFromControls">
					<xsl:for-each select="l:editor/l:radiobuttonlist/l:lookup//l:control">
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
		<xsl:if test="l:editor/l:radiobuttonlist/l:lookup//l:control">
			<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:radiobuttonlist/l:lookup/node()" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
			<NRecoWebForms:DataContextHolder id="{@name}DataContextHolder" runat="server">
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</NRecoWebForms:DataContextHolder>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="CheckBoxListEditor" src="~/templates/editors/CheckBoxListEditor.ascx" %@@gt;
		@@lt;%@ Register TagPrefix="Plugin" tagName="CheckBoxListGroupedEditor" src="~/templates/editors/CheckBoxListGroupedEditor.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:checkboxlist]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<Plugin:CheckBoxListEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}"
			LookupName="{l:editor/l:checkboxlist/l:lookup/@name}"
			TextFieldName="{l:editor/l:checkboxlist/l:lookup/@text}"
			ValueFieldName="{l:editor/l:checkboxlist/l:lookup/@value}">
			<xsl:attribute name="SelectedValues">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			<xsl:if test="l:editor/l:checkboxlist/l:lookup/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:checkboxlist/l:lookup/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="LookupDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>		
			<xsl:if test="l:editor/l:checkboxlist/@columns">
				<xsl:attribute name="RepeatColumns"><xsl:value-of select="l:editor/l:checkboxlist/@columns"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/@layout">
				<xsl:attribute name="RepeatLayout"><xsl:value-of select="l:editor/l:checkboxlist/@layout"/></xsl:attribute>
			</xsl:if>
		</Plugin:CheckBoxListEditor>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:checkboxlist and l:editor/l:checkboxlist/l:lookup/@group]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<Plugin:CheckBoxListGroupedEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" 
			LookupName="{l:editor/l:checkboxlist/l:lookup/@name}"
			TextFieldName="{l:editor/l:checkboxlist/l:lookup/@text}"
			ValueFieldName="{l:editor/l:checkboxlist/l:lookup/@value}"
			GroupFieldName="{l:editor/l:checkboxlist/l:lookup/@group}"
			>
			<xsl:attribute name="SelectedValues">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			<xsl:if test="l:editor/l:checkboxlist/l:group/@default">
				<xsl:attribute name="DefaultGroup"><xsl:value-of select="l:editor/l:checkboxlist/l:group/@default"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/@columns">
				<xsl:attribute name="RepeatColumns"><xsl:value-of select="l:editor/l:checkboxlist/@columns"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/@layout">
				<xsl:attribute name="RepeatLayout"><xsl:value-of select="l:editor/l:checkboxlist/@layout"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxlist/l:lookup/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:checkboxlist/l:lookup/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="LookupDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>			
		</Plugin:CheckBoxListGroupedEditor>
	</xsl:template>

	<xsl:template match="l:dialoglink" mode="register-renderer-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="DialogLink" src="~/templates/renderers/DialogLink.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:dialoglink" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:variable name="url">
			<xsl:choose>
				<xsl:when test="@url">
					"<xsl:value-of select="@url"/>"
				</xsl:when>
				<xsl:when test="count(l:url/l:*)>0">
					<xsl:apply-templates select="l:url/l:*" mode="csharp-expr">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="width">
			<xsl:choose>
				<xsl:when test="l:dialog/@width">
					<xsl:value-of select="l:dialog/@width"/>
				</xsl:when>
				<xsl:otherwise>800</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<NRecoWebForms:DataBindHolder runat="server">
			<Plugin:DialogLink runat="server" HRef="@@lt;%# {$url} %@@gt;" Width="{$width}" xmlns:Plugin="urn:remove">
				<xsl:attribute name="DialogCaption">
					<xsl:choose>
						<xsl:when test="l:dialog/@caption">
							@@lt;%$ label:<xsl:value-of select="l:dialog/@caption"/>%@@gt;
						</xsl:when>
						<xsl:when test="l:dialog/l:caption/l:*">
							@@lt;%#<xsl:apply-templates select="l:dialog/l:caption/l:*" mode="csharp-expr">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>%@@gt;
						</xsl:when>
						<xsl:when test="l:caption/l:*">
							@@lt;%#<xsl:apply-templates select="l:caption/l:*" mode="csharp-expr">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>%@@gt;
						</xsl:when>						
						<xsl:otherwise>
							@@lt;%$ label:<xsl:value-of select="@caption"/> %@@gt;
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="Caption">
					<xsl:choose>
						<xsl:when test="@caption">
							<xsl:value-of select="@caption"/>
						</xsl:when>
						<xsl:when test="l:caption/l:*">
							@@lt;%#<xsl:apply-templates select="l:caption/l:*" mode="csharp-expr">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>%@@gt;
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="l:dialog/@height">
					<xsl:attribute name="Height"><xsl:value-of select="l:dialog/@height"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="l:callback/@command">
					<xsl:attribute name="CallbackCommandName"><xsl:value-of select="l:callback/@command"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="@class">
					<xsl:attribute name="CssClass"><xsl:value-of select="@class"/></xsl:attribute>
				</xsl:if>
			</Plugin:DialogLink>
		</NRecoWebForms:DataBindHolder>
	</xsl:template>	
	
	<xsl:template match="l:field" mode="form-view-validator">
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:param name="mode"/>
		<xsl:apply-templates select="l:editor/l:validators/*" mode="form-view-validator">
			<xsl:with-param name="controlId" select="@name"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
			<xsl:with-param name="mode" select="$mode"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:required" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<asp:requiredfieldvalidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}" ID="{$controlId}RequiredValidator"
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
			ErrorMessage="@@lt;%$ label: {$errMsg} %@@gt;" controltovalidate="{$controlId}" EnableClientScript="true">
			<xsl:attribute name="ValidationExpression">
				<xsl:choose>
					<xsl:when test="count(l:expression/*)">@@lt;%#<xsl:apply-templates select="l:expression" mode="csharp-expr"></xsl:apply-templates>%@@gt;</xsl:when>
					<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</asp:RegularExpressionValidator>
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
			<xsl:attribute name="ValidationExpression"><![CDATA[^([a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?){0,1}$]]></xsl:attribute>
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
			<xsl:attribute name="ErrorMessage">@@lt;%# String.Format( AppContext.GetLabel( "Invalid number (use {0} as decimal separator)" ), System.Globalization.CultureInfo.CurrentCulture.NumberFormat.NumberDecimalSeparator ) %@@gt;</xsl:attribute>
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
		<xsl:variable name="errMsg">
			<xsl:choose>
				<xsl:when test="@message"><xsl:value-of select="@message"/></xsl:when>
				<xsl:otherwise>Choose one</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		<asp:customvalidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			ChooseOneGroup="{@group}"
			OnServerValidate="ChooseOneServerValidate"
			ValidateEmptyText="True"
			controltovalidate="{$controlId}" EnableClientScript="false">
			<xsl:if test="$errMsg!=''">
				<xsl:attribute name="ErrorMessage">@@lt;%$ label: <xsl:value-of select="$errMsg"/> %@@gt;</xsl:attribute>
			</xsl:if>
		</asp:customvalidator>
	</xsl:template>
	
	<xsl:template match="l:custom" mode="form-view-validator">
		<xsl:param name="controlId" select="@ctrl-id"/>
		<xsl:param name="formUid">Form</xsl:param>
		<xsl:param name="mode"/>
		<xsl:variable name="validateMethodName">customValidate_<xsl:value-of select="$controlId"/>_<xsl:value-of select="$mode"/></xsl:variable>
		<asp:customvalidator runat="server" Display="Dynamic"
			ValidationGroup="{$formUid}"
			ChooseOneGroup="{@group}"
			OnServerValidate="{$validateMethodName}" ValidateEmptyText="True"
			ErrorMessage="@@lt;%$ label: {@message} %@@gt;" controltovalidate="{$controlId}" EnableClientScript="false">
		</asp:customvalidator>
		<script runat="server" language="c#">
		protected void <xsl:value-of select="$validateMethodName"/>(object sender, ServerValidateEventArgs args) {
			args.IsValid = <xsl:apply-templates select="l:isvalid/l:*" mode="csharp-expr">
				<xsl:with-param name="context">args</xsl:with-param>
			</xsl:apply-templates>;
		}
		</script>
	</xsl:template>	
	
	<xsl:template match="l:provider" mode="view-datasource">
		<xsl:variable name="dataSourceId" select="@id"/>
		<xsl:variable name="providerName" select="@from"/>
		
		<NRecoWebForms:ProviderDataSource runat="server" id="{$dataSourceId}" ProviderName="{$providerName}" OnSelecting="{$dataSourceId}_OnSelecting">
		</NRecoWebForms:ProviderDataSource>
		<script language="c#" runat="server">
		protected void <xsl:value-of select="$dataSourceId"/>_OnSelecting(object sender,ProviderDataSourceSelectEventArgs e) {
			<xsl:if test="l:context">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:context/node()" mode="csharp-expr"></xsl:apply-templates></xsl:variable>
				e.ProviderContext = <xsl:value-of select="$contextExpr" disable-output-escaping="yes"/>;
			</xsl:if>
		}
		</script>
	</xsl:template>
	
	<xsl:template match="l:dalc" mode="view-datasource">
		<xsl:param name="viewType"/>
		<xsl:variable name="dataSourceId" select="@id"/>
		<xsl:variable name="tableName" select="@tablename"/>
		<xsl:variable name="selectTableName">
			<xsl:choose>
				<xsl:when test="@selecttablename"><xsl:value-of select="@selecttablename"/></xsl:when>
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
				<xsl:when test="not($dalcName)=''"><xsl:value-of select="$dalcName"/></xsl:when>
				<xsl:otherwise><xsl:message terminate="yes">dalc element requires @from</xsl:message></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dataSourceDsFactory">
			<xsl:choose>
				<xsl:when test="@datasetfactory"><xsl:value-of select="@datasetfactory"/></xsl:when>
				<xsl:when test="not($datasetFactoryName)=''"><xsl:value-of select="$datasetFactoryName"/></xsl:when>
				<xsl:otherwise><xsl:message terminate="yes">dalc element requires @datasetfactory</xsl:message></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<NIData:DalcDataSource runat="server" id="{@id}"
			Dalc='&lt;%$ component:{$dataSourceDalc} %&gt;'
			DataSetFactory='&lt;%$ component:{$dataSourceDsFactory} %&gt;'
			TableName="{$tableName}" DataSetMode="true">
			<xsl:if test="not($selectTableName='')">
				<xsl:attribute name="SelectTableName"><xsl:value-of select="$selectTableName"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@datakeynames">
				<xsl:attribute name="DataKeyNames"><xsl:value-of select="@datakeynames"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@autoincrementnames">
				<xsl:attribute name="AutoIncrementNames"><xsl:value-of select="@autoincrementnames"/></xsl:attribute>
			</xsl:if>
			<xsl:attribute name="OnSelecting"><xsl:value-of select="@id"/>_OnSelecting</xsl:attribute>
			<xsl:if test="l:action[@name='selected'] or l:relation">
				<xsl:attribute name="OnSelected"><xsl:value-of select="@id"/>_OnSelected</xsl:attribute>
			</xsl:if>		
			<xsl:if test="l:action[@name='inserting']">
				<xsl:attribute name="OnInserting"><xsl:value-of select="@id"/>_OnInserting</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:action[@name='inserted'] or l:relation">
				<xsl:attribute name="OnInserted"><xsl:value-of select="@id"/>_OnInserted</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:action[@name='updating']">
				<xsl:attribute name="OnUpdating"><xsl:value-of select="@id"/>_OnUpdating</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:action[@name='updated'] or l:relation">
				<xsl:attribute name="OnUpdated"><xsl:value-of select="@id"/>_OnUpdated</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:action[@name='deleting']">
				<xsl:attribute name="OnDeleting"><xsl:value-of select="@id"/>_OnDeleting</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:action[@name='deleted']">
				<xsl:attribute name="OnDeleted"><xsl:value-of select="@id"/>_OnDeleted</xsl:attribute>
			</xsl:if>
		</NIData:DalcDataSource>
		<!-- condition -->
		<xsl:if test="not($conditionRelex='')">
			<input type="hidden" runat="server" value="{$conditionRelex}" id="{@id}_relex" EnableViewState="false" Visible="false"/>
		</xsl:if>
		
		<script language="c#" runat="server">
		protected void <xsl:value-of select="@id"/>_OnSelecting(object sender,DalcDataSourceSelectEventArgs e) {
			<xsl:if test="not($conditionRelex='')">
			 var conditionRelex = new NI.Data.SimpleStringTemplate( <xsl:value-of select="@id"/>_relex.Value ).FormatTemplate( DataContext );
			 var conditionNode = new NI.Data.RelationalExpressions.RelExParser().ParseCondition(conditionRelex);
			 if (conditionNode!=null)
				NI.Data.DataHelper.SetQueryVariables( conditionNode, (varNode) =@@gt; {
					if (DataContext.ContainsKey(varNode.Name))
						varNode.Set( DataContext[varNode.Name] );
					else
						varNode.Unset();
				});
			 e.SelectQuery.Condition = conditionNode;
			</xsl:if>
			
			<xsl:apply-templates select="l:action[@name='selecting']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e</xsl:with-param>
			</xsl:apply-templates>
		}
		protected void <xsl:value-of select="@id"/>_OnSelected(object sender,DalcDataSourceSelectEventArgs e) {
			<xsl:for-each select="l:relation">
				var <xsl:value-of select="@name"/>Mapper = <xsl:apply-templates select="." mode="dalc-relation-mapper">
					<xsl:with-param name="dalcComponentName" select="$dataSourceDalc"/>
					<xsl:with-param name="dsFactoryComponentName" select="$dataSourceDsFactory"/>
				</xsl:apply-templates>;
				e.Data.Tables[e.SelectQuery.Table.Name].Columns.Add("<xsl:value-of select="@name"/>", typeof(object[]) ).DefaultValue = new object[0];
				foreach (DataRow r in e.Data.Tables[e.SelectQuery.Table.Name].Rows) {
					r["<xsl:value-of select="@name"/>"] =  <xsl:value-of select="@name"/>Mapper.Load( r["<xsl:value-of select="@datakeyname"/>"] );
				}
			</xsl:for-each>

			<xsl:apply-templates select="l:action[@name='selected']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e</xsl:with-param>
			</xsl:apply-templates>
		}
		<xsl:if test="l:action[@name='inserting']">
		protected void <xsl:value-of select="@id"/>_OnInserting(object sender,DalcDataSourceChangeEventArgs e) {
			<xsl:apply-templates select="l:action[@name='inserting']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e</xsl:with-param>
			</xsl:apply-templates>				
		}
		</xsl:if>
		<xsl:if test="l:action[@name='inserted'] or l:relation">
		protected void <xsl:value-of select="@id"/>_OnInserted(object sender,DalcDataSourceChangeEventArgs e) {
			<xsl:for-each select="l:relation">
				var <xsl:value-of select="@name"/>Mapper = <xsl:apply-templates select="." mode="dalc-relation-mapper">
					<xsl:with-param name="dalcComponentName" select="$dataSourceDalc"/>
					<xsl:with-param name="dsFactoryComponentName" select="$dataSourceDsFactory"/>
				</xsl:apply-templates>;
				if ( (e.Values["<xsl:value-of select="@name"/>"] as IEnumerable)!=null) {
					<xsl:value-of select="@name"/>Mapper.Update( e.Values["<xsl:value-of select="@datakeyname"/>"], e.Values["<xsl:value-of select="@name"/>"] as IEnumerable );
				}
			</xsl:for-each>

			<xsl:apply-templates select="l:action[@name='inserted']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e</xsl:with-param>
			</xsl:apply-templates>				
		}
		</xsl:if>
		<xsl:if test="l:action[@name='updating']">
		protected void <xsl:value-of select="@id"/>_OnUpdating(object sender,DalcDataSourceChangeEventArgs e) {
			<xsl:apply-templates select="l:action[@name='updating']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e</xsl:with-param>
			</xsl:apply-templates>				
		}
		</xsl:if>
		<xsl:if test="l:action[@name='updated'] or l:relation">
		protected void <xsl:value-of select="@id"/>_OnUpdated(object sender,DalcDataSourceChangeEventArgs e) {
			<xsl:for-each select="l:relation">
				var <xsl:value-of select="@name"/>Mapper = <xsl:apply-templates select="." mode="dalc-relation-mapper">
					<xsl:with-param name="dalcComponentName" select="$dataSourceDalc"/>
					<xsl:with-param name="dsFactoryComponentName" select="$dataSourceDsFactory"/>
				</xsl:apply-templates>;
				if ( (e.Values["<xsl:value-of select="@name"/>"] as IEnumerable)!=null) {
					<xsl:value-of select="@name"/>Mapper.Update( e.Values["<xsl:value-of select="@datakeyname"/>"], e.Values["<xsl:value-of select="@name"/>"] as IEnumerable );
				}
			</xsl:for-each>

			<xsl:apply-templates select="l:action[@name='updated']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e</xsl:with-param>
			</xsl:apply-templates>
		}
		</xsl:if>
		<xsl:if test="l:action[@name='deleting']">
		protected void <xsl:value-of select="@id"/>_OnDeleting(object sender,DalcDataSourceChangeEventArgs e) {
			<xsl:apply-templates select="l:action[@name='deleting']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e</xsl:with-param>
			</xsl:apply-templates>				
		}
		</xsl:if>
		<xsl:if test="l:action[@name='deleted']">
		protected void <xsl:value-of select="@id"/>_OnDeleted(object sender,DalcDataSourceChangeEventArgs e) {
			<xsl:apply-templates select="l:action[@name='deleted']/l:*" mode="csharp-code">
				<xsl:with-param name="context">e</xsl:with-param>
			</xsl:apply-templates>				
		}
		</xsl:if>			
		</script>

	</xsl:template>

	<xsl:template match="l:relation" mode="dalc-relation-mapper">
		<xsl:param name="dalcComponentName"/>
		<xsl:param name="dsFactoryComponentName"/>
		<xsl:choose>
			<xsl:when test="@mapper">AppContext.ComponentFactory.GetComponent@@lt;NReco.Dsm.Data.IRelationMapper@@gt;("<xsl:value-of select="@mapper"/>")</xsl:when>
			<xsl:when test="l:mapper">new NReco.Dsm.Data.DalcRelationMapper(
				AppContext.ComponentFactory.GetComponent@@lt;NI.Data.IDalc@@gt;("<xsl:value-of select="$dalcComponentName"/>"),
				AppContext.ComponentFactory.GetComponent@@lt;NI.Data.IDataSetFactory@@gt;("<xsl:value-of select="$dsFactoryComponentName"/>"),
				"<xsl:value-of select="l:mapper/@table"/>",
				"<xsl:value-of select="l:mapper/@fromfield"/>",
				"<xsl:value-of select="l:mapper/@tofield"/>"
				) <xsl:if test="l:mapper/@positionfield">{ PositionFieldName = "<xsl:value-of select="l:mapper/@positionfield"/>" }</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">relation element requires mapper</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
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
		<xsl:param name="itemRenderer">
			<xsl:apply-templates select="l:item/l:*" mode="aspnet-renderer">
				<xsl:with-param name="context">Container.DataItem</xsl:with-param>
			</xsl:apply-templates>			
		</xsl:param>
		<asp:Repeater runat="server">
			<xsl:choose>
				<xsl:when test="@datasource"><xsl:attribute name="DataSourceID"><xsl:value-of select="@datasource"/></xsl:attribute></xsl:when>
				<xsl:when test="l:data">
					<xsl:attribute name="DataSource">@@lt;%# ControlUtils.WrapWithDictionaryView( <xsl:apply-templates select="l:data/node()" mode="csharp-expr"/> as IEnumerable ) %@@gt;</xsl:attribute>
				</xsl:when>
				<xsl:otherwise><xsl:message terminate="yes">repeater needs @datasource or data element</xsl:message></xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not($header='')">
				<HeaderTemplate><xsl:value-of select="$header"/></HeaderTemplate>
			</xsl:if>
			<ItemTemplate>
				<xsl:value-of select="$itemHeader"/>
				<xsl:choose>
					<xsl:when test="l:item">
						<xsl:copy-of select="$itemRenderer"/>
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
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>actionForm<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<NRecoWebForms:DataBindHolder runat="server">
			<NRecoWebForms:ActionView runat="server" id="{$actionForm}"
				OnDataBinding="{$actionForm}_OnDataBinding">
				<xsl:if test="@viewstate='true' or @viewstate='1'">
					<xsl:attribute name="EnableViewState">True</xsl:attribute>
				</xsl:if>
				<Template>
					<xsl:apply-templates select="." mode="layout-form-template">
						<xsl:with-param name="formClass">
							<xsl:choose>
								<xsl:when test="l:styles/l:table/@class"><xsl:value-of select="l:styles/l:table/@class"/></xsl:when>
								<xsl:when test="$formDefaults/l:styles/l:table/@class"><xsl:value-of select="$formDefaults/l:styles/l:table/@class"/></xsl:when>
								<xsl:otherwise>ActionView</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="renderFormHeader" select="count(l:header/*)>0"/>
						<xsl:with-param name="formHeader">
							<xsl:apply-templates select="l:header/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid">
									<xsl:value-of select="$actionForm"/>
								</xsl:with-param>
								<xsl:with-param name="mode">FormHeader</xsl:with-param>
							</xsl:apply-templates>
						</xsl:with-param>
						<xsl:with-param name="renderFormFooter" select="count(l:footer/*)>0"/>
						<xsl:with-param name="formFooter">
							<xsl:apply-templates select="l:footer/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$actionForm"/></xsl:with-param>
								<xsl:with-param name="mode">FormFooter</xsl:with-param>
							</xsl:apply-templates>
						</xsl:with-param>
						<xsl:with-param name="formBody">
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
						</xsl:with-param>
					</xsl:apply-templates>
				</Template>
			</NRecoWebForms:ActionView>
		</NRecoWebForms:DataBindHolder>
		<script language="c#" runat="server">
		protected void <xsl:value-of select="$actionForm"/>_OnDataBinding(object sender, EventArgs e) {
			var form = (NReco.Dsm.WebForms.ActionView)sender;
			// init data item
			<xsl:for-each select=".//l:field[@name]">
				form.Values["<xsl:value-of select="@name"/>"] = DataContext.ContainsKey("<xsl:value-of select="@name"/>")?DataContext["<xsl:value-of select="@name"/>"]:null;
			</xsl:for-each>
			<xsl:apply-templates select="l:action[@name='initialize']/l:*" mode="form-operation">
				<xsl:with-param name="context">form.Values</xsl:with-param>
			</xsl:apply-templates>
		}
		</script>
	</xsl:template>
	
	<xsl:template match="l:list" mode="aspnet-renderer">
		<xsl:variable name="listUniqueId">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>listView<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
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
		<NRecoWebForms:ActionDataSource runat="server" id="{$listUniqueId}ActionDataSource" DataSourceID="{$mainDsId}" />

		<xsl:if test="l:filter">
			<xsl:variable name="filterForm">filterForm<xsl:value-of select="$listUniqueId"/></xsl:variable>
			<NRecoWebForms:FilterView runat="server" id="listFilterView{$listUniqueId}"
				OnDataBinding="listFilter{$listUniqueId}_OnDataBinding"
				OnFilter="listFilter{$listUniqueId}_OnFilter">
				<Template>
					<xsl:apply-templates select="l:filter/l:header/l:*" mode="aspnet-renderer">
						<xsl:with-param name="context">Container.DataItem</xsl:with-param>
						<xsl:with-param name="formUid">listFilter<xsl:value-of select="$listUniqueId"/></xsl:with-param>
						<xsl:with-param name="mode">filter</xsl:with-param>
					</xsl:apply-templates>
					<div>
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="$listNode/l:styles/l:filter/@class"><xsl:value-of select="$listNode/l:styles/l:filter/@class"/></xsl:when>
								<xsl:when test="$listDefaults/l:styles/l:filter/@class"><xsl:value-of select="$listDefaults/l:styles/l:filter/@class"/></xsl:when>
								<xsl:otherwise>listViewFilter</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:for-each select="l:filter/l:field">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="list-view-filter-editor">
										<xsl:with-param name="mode">filter</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid">listFilter<xsl:value-of select="$listUniqueId"/></xsl:with-param>
										<xsl:with-param name="filterFieldClass">
											<xsl:choose>
												<xsl:when test="$listNode/l:styles/l:filter/@fieldclass"><xsl:value-of select="$listNode/l:styles/l:filter/@fieldclass"/></xsl:when>
												<xsl:when test="$listDefaults/l:styles/l:filter/@fieldclass"><xsl:value-of select="$listDefaults/l:styles/l:filter/@fieldclass"/></xsl:when>
												<xsl:otherwise>listViewFilterField</xsl:otherwise>
											</xsl:choose>											
										</xsl:with-param>
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
			</NRecoWebForms:FilterView>
		</xsl:if>
				
		<xsl:variable name="insertItemPosition">
			<xsl:choose>
				<xsl:when test="l:addrow/@position = 'top'">FirstItem</xsl:when>
				<xsl:when test="l:addrow/@position = 'bottom' or not(l:addrow/@position)">LastItem</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="pagerColspanCount">
			<xsl:choose>
				<xsl:when test="$showItemSelector"><xsl:value-of select="count(l:field[not(@view) or @view='true' or @view='1'])+1"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="count(l:field[not(@view) or @view='true' or @view='1'])"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		
		<NRecoWebForms:ListView ID="{$listUniqueId}"
			ClientIDMode="AutoID"
			DataSourceID="{$listUniqueId}ActionDataSource"
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
				<xsl:choose>
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
						<NRecoWebForms:DataBindHolder runat="server" EnableViewState="false">
							<tr>
								<xsl:if test="$showItemSelector">
									<th>
										<xsl:attribute name="class">
											<xsl:choose>
												<xsl:when test="$listNode/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@headerclass"/></xsl:when>
												<xsl:when test="$listDefaults/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@headerclass"/></xsl:when>
											</xsl:choose> listSelectorColumn
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
						</NRecoWebForms:DataBindHolder>
					</xsl:if>
					
					<xsl:if test="$showItemSelector and l:operations/@top='true'">
						<xsl:call-template name="listRenderOperationsRow">
							<xsl:with-param name="listNode" select="$listNode"/>
							<xsl:with-param name="mode" select="'top'"/>
						</xsl:call-template>
					</xsl:if>
					
					<tr runat="server" id="itemPlaceholder" />
					
					<xsl:if test="l:footer">
						<!-- ListView doesn't call DataBind for LayoutTemplate, so lets use special placeholder with self-databinding logic -->
						<NRecoWebForms:DataBindHolder runat="server" EnableViewState="false">
							<xsl:for-each select="l:footer/l:*">
								<xsl:choose>
									<xsl:when test="name() = 'row'">
										<tr class="footer">
											<xsl:for-each select="l:cell">
												<td>
													<xsl:attribute name="class">
														<xsl:choose>
															<xsl:when test="$listNode/l:styles/l:listtable/@customcellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@customcellclass"/></xsl:when>												
															<xsl:when test="$listDefaults/l:styles/l:listtable/@customcellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@customcellclass"/></xsl:when>
															<xsl:when test="@css-class"><xsl:value-of select="@css-class"/></xsl:when>
															<xsl:otherwise>customlistcell</xsl:otherwise>
														</xsl:choose>
													</xsl:attribute>
													
													<xsl:if test="@colspan"><xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute></xsl:if>
													<xsl:if test="@rowspan"><xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute></xsl:if>
													<xsl:if test="@align"><xsl:attribute name="style">text-align:<xsl:value-of select="@align"/>;</xsl:attribute></xsl:if>
													<xsl:apply-templates select="l:*" mode="aspnet-renderer"/>
												</td>
											</xsl:for-each>
										</tr>
									</xsl:when>
									<xsl:when test="name() = 'renderer'">
										<xsl:apply-templates select="l:*" mode="aspnet-renderer"/>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</NRecoWebForms:DataBindHolder>
					</xsl:if>
					
					<xsl:if test="$showItemSelector and (l:operations/@bottom='true' or not(l:operations/@bottom))">
						<xsl:call-template name="listRenderOperationsRow">
							<xsl:with-param name="listNode" select="$listNode"/>
							<xsl:with-param name="mode" select="'bottom'"/>
						</xsl:call-template>
					</xsl:if>
					
					<xsl:if test="not(l:pager/@allow='false' or l:pager/@allow='0')">
						<NRecoWebForms:DataPager ID="ListDataPager" runat="server" CustomTagKey="Tr">
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="$listNode/l:styles/l:listtable/@pagerrowclass">
										<xsl:value-of select="$listNode/l:styles/l:listtable/@pagerrowclass"/>
									</xsl:when>
									<xsl:when test="$listDefaults/l:styles/l:listtable/@pagerrowclass">
										<xsl:value-of select="$listDefaults/l:styles/l:listtable/@pagerrowclass"/>
									</xsl:when>
									<xsl:otherwise>pager</xsl:otherwise>
								</xsl:choose>							
							</xsl:attribute>
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
								@@lt;td colspan="<xsl:value-of select="$pagerColspanCount"/>" <xsl:choose>
											<xsl:when test="$listNode/l:styles/l:listtable/@pagercellclass">class="<xsl:value-of select="$listNode/l:styles/l:listtable/@pagercellclass"/>"</xsl:when>
											<xsl:when test="$listDefaults/l:styles/l:listtable/@pagercellclass">class="<xsl:value-of select="$listDefaults/l:styles/l:listtable/@pagercellclass"/>"</xsl:when>
											<xsl:otherwise>class="listcell"</xsl:otherwise>
										</xsl:choose>@@gt;
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
								@@lt;/td@@gt;
							   </PagerTemplate>
							  </asp:TemplatePagerField>								
								
							</Fields>
						</NRecoWebForms:DataPager>
						
					</xsl:if>
				</table>
			</LayoutTemplate>
			
			<xsl:if test="l:emptydata/@show='true' or l:emptydata/@show='1' or not(l:emptydata/@show)">
				<EmptyDataTemplate>
					<table>
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="$listNode/l:styles/l:listtable/@class"><xsl:value-of select="$listNode/l:styles/l:listtable/@class"/></xsl:when>
								<xsl:when test="$listDefaults/l:styles/l:listtable/@class"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@class"/></xsl:when>
								<xsl:otherwise>listView</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						
						<xsl:if test="not(@headers) or @headers='1' or @headers='true'">
							<tr>
								<xsl:if test="$showItemSelector">
									<th>
										<xsl:attribute name="class">
											<xsl:choose>
												<xsl:when test="$listNode/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@headerclass"/></xsl:when>
												<xsl:when test="$listDefaults/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@headerclass"/></xsl:when>
											</xsl:choose> listSelectorColumn
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
						
						<tr>
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="$listNode/l:styles/l:listtable/@pagerrowclass">
										<xsl:value-of select="$listNode/l:styles/l:listtable/@pagerrowclass"/>
									</xsl:when>
									<xsl:when test="$listDefaults/l:styles/l:listtable/@pagerrowclass">
										<xsl:value-of select="$listDefaults/l:styles/l:listtable/@pagerrowclass"/>
									</xsl:when>
									<xsl:otherwise>pager</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
								<td colspan="{$pagerColspanCount}">
									<xsl:attribute name="class">
										<xsl:choose>
											<xsl:when test="$listNode/l:styles/l:listtable/@pagerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@pagerclass"/></xsl:when>
											<xsl:when test="$listDefaults/l:styles/l:listtable/@pagerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@pagerclass"/></xsl:when>
											<xsl:otherwise>customlistcell</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<NRecoWebForms:Label runat="server">
										<xsl:choose>
											<xsl:when test="l:emptydata/@message"><xsl:value-of select="l:emptydata/@message"/></xsl:when>
											<xsl:otherwise>No data</xsl:otherwise>
										</xsl:choose>
									</NRecoWebForms:Label>
								</td>
						</tr>
						
					</table>
				</EmptyDataTemplate>
			</xsl:if>
			
			<ItemTemplate>
				<xsl:if test="l:group">
					<tr class="item listgroup" runat="server" visible='@@lt;%# ListRenderGroupField(Container.DataItem, "{l:group/@field}", ref listView{$listUniqueId}_CurrentGroupValue, true)!=null %@@gt;'>
						<td colspan="1000">
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="$listNode/l:styles/l:listtable/@groupcellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@groupcellclass"/></xsl:when>
									<xsl:when test="$listDefaults/l:styles/l:listtable/@groupcellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@groupcellclass"/></xsl:when>
									<xsl:otherwise>listcell</xsl:otherwise>
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
									<xsl:otherwise>listcell</xsl:otherwise>
								</xsl:choose> listSelectorColumn
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
						<xsl:if test="$showItemSelector">
							<td>
								<xsl:attribute name="class">
									<xsl:choose>
										<xsl:when test="$listNode/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@cellclass"/></xsl:when>
										<xsl:when test="$listDefaults/l:styles/l:listtable/@cellclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@cellclass"/></xsl:when>
										<xsl:otherwise>listcell</xsl:otherwise>
									</xsl:choose> listSelectorColumn
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
										<xsl:with-param name="formUid">@@lt;%# String.Format("ListForm{0}", Container.ClientID ) %@@gt;</xsl:with-param>
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
										<xsl:otherwise>listcell</xsl:otherwise>
									</xsl:choose> listSelectorColumn
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
										<xsl:with-param name="formUid">@@lt;%# String.Format("ListFormInsert{0}", Container.ClientID ) %@@gt;</xsl:with-param>
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
		</NRecoWebForms:ListView>
		<xsl:if test="@name">
			<NRecoWebForms:JavaScriptHolder runat="server">
				if ($) {
					$(function() {
						var listRowCnt = @@lt;%=GetListViewRowCount( ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;(this).Where( c=@@gt;c.ID=="<xsl:value-of select="@name"/>").FirstOrDefault() ) %@@gt;;
						if (listRowCnt@@gt;=0)
							$('.listRowCount<xsl:value-of select="$listUniqueId"/>').text(listRowCnt);
					});
				}
			</NRecoWebForms:JavaScriptHolder>
		</xsl:if>
		<xsl:if test="$showItemSelector">
			<NRecoWebForms:JavaScriptHolder runat="server">
			if ($) {
				$(function() {
					var listElemPrefix = '@@lt;%=ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.ListView@@gt;(this).Where( c=@@gt;c.ID=="<xsl:value-of select="$listUniqueId"/>").FirstOrDefault().ClientID %@@gt;';
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
						$checkAllElem.attr('checked', $checkItemElems.filter(':checked').length==$checkItemElems.length ).trigger('change');
					};
					$checkAllElem.click(function() {
						$checkItemElems.prop('checked', $checkAllElem.is(':checked') ).trigger('change');
						showMassOpRow();
					});
					$checkItemElems.click(function() {
						refreshShowAllState();
						showMassOpRow();
					});
					refreshShowAllState();
					showMassOpRow();
				});
			}
			</NRecoWebForms:JavaScriptHolder>
		</xsl:if>		
		
		<xsl:variable name="showPager">
			<xsl:choose>
				<xsl:when test="l:pager/@show"><xsl:value-of select="l:pager/@show"/></xsl:when>
				<xsl:when test="$listDefaults/l:pager/@show"><xsl:value-of select="$listDefaults/l:pager/@show"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:call-template name="layout-list-generate-actions-code">
			<xsl:with-param name="listUniqueId" select="$listUniqueId"/>
			<xsl:with-param name="showPager" select="$showPager"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="layout-list-generate-actions-code">
		<xsl:param name="listUniqueId"/>
		<xsl:param name="showPager"/>
		
		<script language="c#" runat="server">
		<xsl:if test="l:filter">
			protected void listFilter<xsl:value-of select="$listUniqueId"/>_OnDataBinding(object sender, EventArgs e) {
				var filter = (NReco.Dsm.WebForms.FilterView)sender;
				// init filter properties
				<xsl:for-each select="l:filter//l:field[@name]">
					filter.Values["<xsl:value-of select="@name"/>"] = DataContext.ContainsKey("<xsl:value-of select="@name"/>") ? DataContext["<xsl:value-of select="@name"/>"] : null;
				</xsl:for-each>
			}
			protected void listFilter<xsl:value-of select="$listUniqueId"/>_OnFilter(object sender, EventArgs e) {
				var filter = (NReco.Dsm.WebForms.FilterView)sender;
				if (DataContext!=null)
					foreach (DictionaryEntry entry in filter.Values)
						DataContext[entry.Key.ToString()] = entry.Value;
				<xsl:apply-templates select="l:action[@name='filter']/l:*" mode="csharp-code">
					<xsl:with-param name="context">filter.Values</xsl:with-param>
				</xsl:apply-templates>
				filter.NamingContainer.FindControl("<xsl:value-of select="$listUniqueId"/>").DataBind();
			}
		</xsl:if>
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnPagePropertiesChanged(Object sender, EventArgs e) {
			DataContext["listView<xsl:value-of select="$listUniqueId"/>_StartRowIndex"] = ((IPageableItemContainer)sender).StartRowIndex;
			DataContext["listView<xsl:value-of select="$listUniqueId"/>_MaximumRows"] = ((IPageableItemContainer)sender).MaximumRows;
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnSorted(Object sender, EventArgs e) {
			var listView = (System.Web.UI.WebControls.ListView)sender;
			DataContext["listView<xsl:value-of select="$listUniqueId"/>_SortExpression"] = String.IsNullOrEmpty(listView.SortExpression) ? null 
				: String.Format("{0} {1}", listView.SortExpression, listView.SortDirection==System.Web.UI.WebControls.SortDirection.Descending ? "desc" : "asc" );
		}
		
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnDataBound(Object sender, EventArgs e) {
			<xsl:if test="$showPager='ifpagingpossible'">
				foreach (var dataPager in ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.DataPager@@gt;((Control)sender) ) {
					dataPager.Visible = (dataPager.PageSize @@lt; dataPager.TotalRowCount);
				}
			</xsl:if>
			<xsl:if test="$showPager='no'">
				foreach (var dataPager in ControlUtils.GetChildren@@lt;System.Web.UI.WebControls.DataPager@@gt;((Control)sender) ) {
					dataPager.Visible = false;
				}
			</xsl:if>
		}
		
		protected object listView<xsl:value-of select="$listUniqueId"/>_CurrentGroupValue = null;
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnDataBinding(Object sender, EventArgs e) {		
			listView<xsl:value-of select="$listUniqueId"/>_CurrentGroupValue = null;
			<!-- initializing data-related settings (key names, insert data item etc) -->
			<!-- heuristics for DALC data source (refactor TODO) -->
			var dalcDataSource = ((NReco.Dsm.WebForms.ActionDataSource) ((Control)sender).NamingContainer.FindControl("<xsl:value-of select="$listUniqueId"/>ActionDataSource") ).UnderlyingSource as NI.Data.Web.DalcDataSource;
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
						if (dalcDataSource!=null) {
							System.Data.DataView dsView = null;
							((IDataSource)dalcDataSource).GetView(dalcDataSource.TableName).Select( 
									new DataSourceSelectArguments(0,0),
									(data) =@@gt; { dsView = data as System.Data.DataView; } );
							if (dsView!=null) {
								newItem = new NReco.Collections.DictionaryView( NReco.Converting.ConvertManager.ChangeType@@lt;IDictionary@@gt;( dsView.Table.NewRow() ) );
							}
						}
					</xsl:otherwise>
				</xsl:choose>
				if (newItem!=null) {
					((NReco.Dsm.WebForms.ListView)sender).InsertDataItem = newItem;
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
				var lastPartQSort = new NI.Data.QSort(defSortExprParts[defSortExprParts.Length-1]);
				defSortExprParts[defSortExprParts.Length-1] = lastPartQSort.Field.Name;
				((System.Web.UI.WebControls.ListView)sender).Sort( String.Join(",",defSortExprParts), lastPartQSort.SortDirection==System.ComponentModel.ListSortDirection.Descending ? System.Web.UI.WebControls.SortDirection.Descending : System.Web.UI.WebControls.SortDirection.Ascending );
			}
			
			<!-- restore start row index (if available) -->
			if (DataContext.ContainsKey("listView<xsl:value-of select="$listUniqueId"/>_StartRowIndex")) {
				var pageableContainer = (IPageableItemContainer)sender;
				var savedStartRowIndex = Convert.ToInt32(DataContext["listView<xsl:value-of select="$listUniqueId"/>_StartRowIndex"]);
				var savedMaxRows = Convert.ToInt32( DataContext["listView<xsl:value-of select="$listUniqueId"/>_MaximumRows"] ?? (object) pageableContainer.MaximumRows); 
				if (savedStartRowIndex!=pageableContainer.StartRowIndex || savedMaxRows!=pageableContainer.MaximumRows)
					pageableContainer.SetPageProperties( savedStartRowIndex, savedMaxRows@@gt;0 ? savedMaxRows : 20, true);
			}		
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemCommand(Object sender, ListViewCommandEventArgs  e) {
			if (!(new[]{"Update","Insert","Delete","Cancel","Edit","Page"}).Contains(e.CommandName)) {
				CommandHandler(sender, e);
			}
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemDeleting(Object sender, ListViewDeleteEventArgs e) {
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
			<xsl:apply-templates select="l:action[@name='updating']/l:*" mode="csharp-code">
				<xsl:with-param name="context">new NReco.Dsm.WebForms.CompositeDictionary(e.NewValues,e.Keys)</xsl:with-param>
			</xsl:apply-templates>
		}
		protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemUpdated(Object sender, ListViewUpdatedEventArgs e) {
			<xsl:apply-templates select="l:action[@name='updated']/l:*" mode="csharp-code">
				<xsl:with-param name="context">new NReco.Dsm.WebForms.CompositeDictionary(e.NewValues)</xsl:with-param>
			</xsl:apply-templates>
		}			
		</script>
		<xsl:if test="@add='true' or @add='1'">
			<script language="c#" runat="server">
			protected void listView<xsl:value-of select="$listUniqueId"/>_OnItemInserting(Object sender, ListViewInsertEventArgs e) {
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
	
	<xsl:template name="listRenderOperationsRow">
		<xsl:param name="mode"/>
		<xsl:param name="listNode"/>
		<NRecoWebForms:DataBindHolder runat="server" EnableViewState="false">
			<tr class="footer massoperations" runat="server" style="display:none;">
				<xsl:attribute name="id"><xsl:value-of select="$mode"/>_massOperations</xsl:attribute>
				<xsl:if test="not(l:operations/@showselectedcount='false' or l:operations/@showselectedcount='0')">
					<td>
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="$listNode/l:styles/l:listtable/@selected-count-cell-class"><xsl:value-of select="$listNode/l:styles/l:listtable/@selected-count-cell-class"/></xsl:when>
								<xsl:when test="$listDefaults/l:styles/l:listtable/@selected-count-cell-class"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@selected-count-cell-class"/></xsl:when>
								<xsl:otherwise>selectedCountListCell</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>									
						<div>
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="$listNode/l:styles/l:listtable/@selected-count-container-class"><xsl:value-of select="$listNode/l:styles/l:listtable/@selected-count-container-class"/></xsl:when>
									<xsl:when test="$listDefaults/l:styles/l:listtable/@selected-count-container-class"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@selected-count-container-class"/></xsl:when>
									<xsl:otherwise>listSelectedItemsCountContainer</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<div class="selectedText">@@lt;%=AppContext.GetLabel("list:selectedcount:prefix")!="list:selectedcount:prefix" ? AppContext.GetLabel("list:selecteditems:selected") : "" %@@gt;</div>
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
							<xsl:otherwise>customlistcell</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:apply-templates select="l:operations/l:*" mode="aspnet-renderer">
						<xsl:with-param name="mode" select="$mode"/>
					</xsl:apply-templates>
				</td>
			</tr>
		</NRecoWebForms:DataBindHolder>
		
	</xsl:template>
	
	<xsl:template match="l:field" mode="list-view-filter-editor">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:param name="filterFieldClass"/>
		<div class="{$filterFieldClass}">
			<xsl:if test="@caption">
				<label class="caption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></label>
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
		<xsl:param name="filterFieldClass"/>
		<div class="{$filterFieldClass}">
			<fieldset>
				<xsl:if test="@caption">
					<legend><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></legend>
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
	
	<xsl:template match="l:field" mode="list-view-table-header">
		<xsl:param name="listNode"/>
		<th>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@headerclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@headerclass"/></xsl:when>
				</xsl:choose>
			</xsl:attribute>		
			<xsl:if test="@width">
				<xsl:attribute name="style">width:<xsl:value-of select="@width"/>;</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="l:caption/l:*">
					<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
						<xsl:with-param name="context">DataContext</xsl:with-param>
					</xsl:apply-templates>					
				</xsl:when>
				<xsl:when test="@caption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></xsl:when>
				<xsl:otherwise>@@amp;nbsp;</xsl:otherwise>
			</xsl:choose>
		</th>
	</xsl:template>	
	
	<xsl:template match="l:field[(@sort='true' or @sort='1') and @name]" mode="list-view-table-header">
		<xsl:param name="listNode"/>
		<th>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$listNode/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listNode/l:styles/l:listtable/@headerclass"/></xsl:when>
					<xsl:when test="$listDefaults/l:styles/l:listtable/@headerclass"><xsl:value-of select="$listDefaults/l:styles/l:listtable/@headerclass"/></xsl:when>
				</xsl:choose>
			</xsl:attribute>		
			<xsl:if test="@width">
				<xsl:attribute name="style">width:<xsl:value-of select="@width"/>;</xsl:attribute>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="l:caption/l:*">
					<asp:LinkButton id="sortBtn{generate-id(.)}" CausesValidation="false" runat="server" CommandName="Sort" CommandArgument="{@name}" OnPreRender="ListViewSortButtonPreRender">
						<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context">DataContext</xsl:with-param>
						</xsl:apply-templates>					
					</asp:LinkButton>
				</xsl:when>
				<xsl:when test="@caption">
					<asp:LinkButton id="sortBtn{generate-id(.)}" CausesValidation="false" runat="server" Text="@@lt;%$ label:{@caption} %@@gt;" CommandName="Sort" CommandArgument="{@name}" OnPreRender="ListViewSortButtonPreRender"/>
				</xsl:when>
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
					<xsl:otherwise>listcell</xsl:otherwise>
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
			<xsl:if test="@hint or l:hint">
				<div class="fieldHint">
					<xsl:choose>
						<xsl:when test="@hint"><NRecoWebForms:Label runat="server"><xsl:value-of select="@hint"/></NRecoWebForms:Label></xsl:when>
						<xsl:when test="l:hint/l:*">
							<xsl:apply-templates select="l:hint/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="formUid" select="$formUid"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="l:hint"><NRecoWebForms:Label runat="server"><xsl:value-of select="l:hint"/></NRecoWebForms:Label></xsl:when>
					</xsl:choose>
				</div>
			</xsl:if>	
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
					<xsl:otherwise>listcell edit</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>		
		<xsl:for-each select="l:group/l:field">
			<xsl:call-template name="apply-visibility">
				<xsl:with-param name="content">					
					<div class="listview groupentry">
						<xsl:if test="@caption">
							<span class="caption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label>:</span>
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
							<div class="fieldHint">
								<xsl:choose>
									<xsl:when test="@hint"><NRecoWebForms:Label runat="server"><xsl:value-of select="@hint"/></NRecoWebForms:Label></xsl:when>
									<xsl:when test="l:hint/l:*">
										<xsl:apply-templates select="l:hint/l:*" mode="aspnet-renderer">
											<xsl:with-param name="context" select="$context"/>
											<xsl:with-param name="formUid" select="$formUid"/>
										</xsl:apply-templates>
									</xsl:when>
									<xsl:when test="l:hint"><NRecoWebForms:Label runat="server"><xsl:value-of select="l:hint"/></NRecoWebForms:Label></xsl:when>
								</xsl:choose>
							</div>
						</xsl:if>
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
					<xsl:otherwise>listcell</xsl:otherwise>
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
					<xsl:otherwise>listcell</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>				
		<xsl:for-each select="l:group/l:field">
			<xsl:call-template name="apply-visibility">
				<xsl:with-param name="content">			
					<div class="listview groupentry">
						<xsl:if test="@caption">
							<span class="caption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label>:</span>
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
					<xsl:otherwise>listcell</xsl:otherwise>
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
		
	<xsl:template name="renderFormFieldCaptionSuffix"><xsl:choose><xsl:when test="$formDefaults/l:field/l:caption/@suffix"><xsl:value-of select="$formDefaults/l:field/l:caption/@suffix"/></xsl:when><xsl:otherwise>:</xsl:otherwise></xsl:choose></xsl:template>

	<xsl:template name="renderFormFieldCaptionRequiredSuffix"><span class="required"><xsl:choose><xsl:when test="$formDefaults/l:field/l:caption/@required"><xsl:value-of select="$formDefaults/l:field/l:caption/@required"/></xsl:when><xsl:otherwise>*</xsl:otherwise></xsl:choose></span></xsl:template>
	
	
	
</xsl:stylesheet>
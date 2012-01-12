<!--
NReco library (http://nreco.googlecode.com/)
Copyright 2008-2012 Vitaliy Fedorchenko
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
	
	<xsl:variable name="formMobileDefaults" select="/components/default/mobile/form"/>
	<xsl:variable name="listMobileDefaults" select="/components/default/mobile/list"/>
	
	<xsl:template match="l:view-mobile">
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
				<xsl:if test="l:action[@name='init']">
					protected override void OnInit(EventArgs e) {
						base.OnInit(e);
						<xsl:apply-templates select="l:action[@name='init']/l:*" mode="csharp-code"/>
					}
				</xsl:if>
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
				<xsl:apply-templates select="l:*[not(name()='datasources' or name()='action')]" mode="aspnet-mobile-renderer"/>
	</xsl:template>

	<xsl:template match="l:newline|l:html|l:usercontrol|l:listdisplayindex" mode="aspnet-mobile-renderer">
		<xsl:apply-templates select="." mode="aspnet-renderer"/>
		<br/>
	</xsl:template>

	<xsl:template match="l:repeater" mode="aspnet-mobile-renderer">
		<xsl:call-template name="repeater-aspnet-renderer">
			<xsl:with-param name="itemRenderer">
				<xsl:apply-templates select="l:item/l:*" mode="aspnet-mobile-renderer">
					<xsl:with-param name="context">Container.DataItem</xsl:with-param>
				</xsl:apply-templates>					
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	
	<xsl:template match="l:uibar" mode="aspnet-mobile-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		<div class="ui-bar">
			<xsl:apply-templates select="l:*" mode="aspnet-mobile-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>				
		</div>
	</xsl:template>
	
	<xsl:template match="l:controlgroup" mode="aspnet-mobile-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		<div data-role="controlgroup">
			<xsl:apply-templates select="l:*" mode="aspnet-mobile-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>				
		</div>
	</xsl:template>
	
	
	<xsl:template match="l:ul" mode="aspnet-mobile-renderer">
		<xsl:call-template name="repeater-aspnet-renderer">
			<xsl:with-param name="header">@@lt;ul@@gt;</xsl:with-param>
			<xsl:with-param name="footer">@@lt;/ul@@gt;</xsl:with-param>
			<xsl:with-param name="itemHeader">@@lt;li@@gt;</xsl:with-param>
			<xsl:with-param name="itemFooter">@@lt;/li@@gt;</xsl:with-param>
			<xsl:with-param name="itemRenderer">
				<xsl:apply-templates select="l:item/l:*" mode="aspnet-mobile-renderer">
					<xsl:with-param name="context">Container.DataItem</xsl:with-param>
				</xsl:apply-templates>					
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="l:ol" mode="aspnet-mobile-renderer">
		<xsl:call-template name="repeater-aspnet-renderer">
			<xsl:with-param name="header">@@lt;ol@@gt;</xsl:with-param>
			<xsl:with-param name="footer">@@lt;/ol@@gt;</xsl:with-param>
			<xsl:with-param name="itemHeader">@@lt;li@@gt;</xsl:with-param>
			<xsl:with-param name="itemFooter">@@lt;/li@@gt;</xsl:with-param>
			<xsl:with-param name="itemRenderer">
				<xsl:apply-templates select="l:item/l:*" mode="aspnet-mobile-renderer">
					<xsl:with-param name="context">Container.DataItem</xsl:with-param>
				</xsl:apply-templates>					
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	
	<xsl:template match="l:placeholder" mode="aspnet-mobile-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		<xsl:call-template name="apply-visibility">
			<xsl:with-param name="content">
				<xsl:apply-templates select="l:renderer/node()" mode="aspnet-mobile-renderer">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:apply-templates>	
			</xsl:with-param>
			<xsl:with-param name="expr" select="l:visible/node()"/>
		</xsl:call-template>
	</xsl:template>
		
	<xsl:template match="l:toolbox" mode="aspnet-mobile-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>

		<div data-role="navbar">
			<ul>
			<xsl:for-each select="l:*">
				<xsl:apply-templates select="." mode="aspnet-mobile-renderer">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:apply-templates>
			</xsl:for-each>
			</ul>
		</div>
	</xsl:template>
	
	<xsl:template match="l:toolboxitem" mode="aspnet-mobile-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>	
		<li>
			<xsl:if test="@class">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="aspnet-mobile-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>
		</li>
	</xsl:template>
	
	<xsl:template match="l:selectmenu" mode="aspnet-mobile-renderer">
		<xsl:param name="uniqueId"><xsl:value-of select="generate-id(.)"/></xsl:param>
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>	

		<a href="javascript:void(0)" data-role="button">
			<xsl:attribute name="onclick">
				$("select[name='selectmenu<xsl:value-of select="$uniqueId"/>']").selectmenu('open');
			</xsl:attribute>
			<xsl:if test="@icon">
				<xsl:attribute name="data-icon"><xsl:value-of select="@icon"/></xsl:attribute>
			</xsl:if>
		<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></a> 
		
		<div id="selectMenuPH{$uniqueId}" class="selectmenuhidewrapper" style="visibility:hidden;height:0px;">
			<select name="selectmenu{$uniqueId}" id="selectmenu{$uniqueId}" data-theme="a" data-icon="gear" data-inline="true" data-native-menu="false" onchange="$('#selectMenuLinkPH{$uniqueId} a:eq('+$(this).val()+')').click(); $(this).get(0).selectedIndex=-1; $(this).selectmenu('refresh')">
				<option><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></option>
			</select>
			<div id="selectMenuLinkPH{$uniqueId}">
				<xsl:apply-templates select="l:link|l:linkbutton" mode="aspnet-mobile-renderer">
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="formUid" select="$formUid"/>
					<xsl:with-param name="mode" select="$mode"/>			
				</xsl:apply-templates>
			</div>
			<script type="text/javascript">
			
				$('#selectmenu<xsl:value-of select="$uniqueId"/>')[0].options.length = 1;
				$('#selectMenuLinkPH<xsl:value-of select="$uniqueId"/> a').each(function() {
					var $a = $(this);
					if ($a.attr('href').indexOf('javascript:')==0) {
						$a.unbind('click');
						$a[0].onclick2 = $a[0].onclick;
						$a[0].onclick = null;
						$a.click(function() { if (typeof(this.onclick2)=='function') { if (!this.onclick2()) return; }  eval( $(this).attr('href').substring(11) ); return false; });
					}
					
					$('#selectmenu<xsl:value-of select="$uniqueId"/>').each(function() {
						this.options[this.options.length] = new Option( $a.text(), this.options.length-1 );
					});
				});
				try {
					$('#selectmenu<xsl:value-of select="$uniqueId"/>').selectmenu('refresh');
				} catch(e) { }
			
			</script>			
		</div>

	</xsl:template>
	
	<xsl:template match="l:form" name="layout-mobile-form" mode="aspnet-mobile-renderer">
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

		<xsl:call-template name="layout-form-generate-actions-code">
			<xsl:with-param name="uniqueId" select="$uniqueId"/>
		</xsl:call-template>
		
		<xsl:variable name="viewHeader">
			<xsl:choose>
				<xsl:when test="l:header[@view='true' or @view='1' or not(@view)]"><xsl:copy-of select="l:header[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formMobileDefaults/l:header[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="viewFooter">
			<xsl:choose>
				<xsl:when test="l:footer[@view='true' or @view='1' or not(@view)]"><xsl:copy-of select="l:footer[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formMobileDefaults/l:footer[@view='true' or @view='1' or not(@view)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="addHeader">
			<xsl:choose>
				<xsl:when test="l:header[@add='true' or @add='1' or not(@add)]"><xsl:copy-of select="l:header[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formMobileDefaults/l:header[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="addFooter">
			<xsl:choose>
				<xsl:when test="l:footer[@add='true' or @add='1' or not(@add)]"><xsl:copy-of select="l:footer[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$formMobileDefaults/l:footer[@add='true' or @add='1' or not(@add)]/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="editHeader">
			<xsl:choose>
				<xsl:when test="l:header[@edit='true' or @edit='1' or not(@edit)]">
					<xsl:copy-of select="l:header[@edit='true' or @edit='1' or not(@edit)]/l:*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$formMobileDefaults/l:header[@edit='true' or @edit='1' or not(@edit)]/l:*"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="editFooter">
			<xsl:choose>
				<xsl:when test="l:footer[@edit='true' or @edit='1' or not(@edit)]">
					<xsl:copy-of select="l:footer[@edit='true' or @edit='1' or not(@edit)]/l:*"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$formMobileDefaults/l:footer[@edit='true' or @edit='1' or not(@edit)]/l:*"/>
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
			RenderOuterTable="true"
			CssClass="FormView"
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
				<xsl:variable name="detectedSourceName"><xsl:value-of select="l:datasource/l:dalc[@id=$mainDsId]/@sourcename"/></xsl:variable>
				<xsl:choose>
					<xsl:when test="not($detectedSourceName='') and $entities/e:entity[@name=$detectedSourceName]">
						<xsl:call-template name="getEntityIdFields"><xsl:with-param name="name" select="$detectedSourceName"/></xsl:call-template>
					</xsl:when>
					<xsl:when test="@datakey"><xsl:value-of select="@datakey"/></xsl:when>
					<xsl:when test="$formMobileDefaults/@datakey"><xsl:value-of select="$formMobileDefaults/@datakey"/></xsl:when>
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
					<div data-role="header">
						<h1><xsl:copy-of select="$itemTemplateHeader"/></h1>
						
						<xsl:if test="count(msxsl:node-set($viewHeader)/*)>0">
							<xsl:apply-templates select="msxsl:node-set($viewHeader)/l:*" mode="aspnet-mobile-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid">FormView<xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormHeader</xsl:with-param>
							</xsl:apply-templates>
						</xsl:if>
						
					</div>
					<div data-role="content">
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="l:styles/l:content/@class"><xsl:value-of select="l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:when test="$formMobileDefaults/l:styles/l:content/@class"><xsl:value-of select="$formMobileDefaults/l:styles/l:content/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>					
						
						<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="plain-form-mobile-view-field">
										<xsl:with-param name="viewFilter">view</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid">FormView<xsl:value-of select="$uniqueId"/></xsl:with-param>
									</xsl:apply-templates>								
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>								
						</xsl:for-each>

					</div>
					
					<xsl:if test="count(msxsl:node-set($viewFooter)/*)>0">
						<div data-role="footer">
							<xsl:apply-templates select="msxsl:node-set($viewFooter)/l:*" mode="aspnet-mobile-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid">FormView<xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormFooter</xsl:with-param>
							</xsl:apply-templates>
						</div>
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
					<div data-role="header">
						<h1><xsl:copy-of select="$editItemTemplateHeader"/></h1>
						
						<xsl:if test="count(msxsl:node-set($editHeader)/*)>0">
							<xsl:apply-templates select="msxsl:node-set($editHeader)/l:*" mode="aspnet-mobile-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormHeader</xsl:with-param>
							</xsl:apply-templates>
						</xsl:if>								
					</div>
				
					<div data-role="content">
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="l:styles/l:content/@class"><xsl:value-of select="l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:when test="$formMobileDefaults/l:styles/l:content/@class"><xsl:value-of select="$formMobileDefaults/l:styles/l:content/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						
						<xsl:for-each select="l:field[not(@edit) or @edit='true' or @edit='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="edit-form-mobile-view-field">
										<xsl:with-param name="viewFilter">edit</xsl:with-param>
										<xsl:with-param name="mode">edit</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid" select="$uniqueId"/>
									</xsl:apply-templates>								
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>						
						</xsl:for-each>
					</div>
					
					<xsl:if test="count(msxsl:node-set($editFooter)/*)>0">
						<div data-role="footer">
							<xsl:apply-templates select="msxsl:node-set($editFooter)/l:*" mode="aspnet-mobile-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormFooter</xsl:with-param>
							</xsl:apply-templates>
						</div>
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
					<div data-role="header">
						<h1><xsl:copy-of select="$insertItemTemplateHeader"/></h1>
						
						<xsl:if test="count(msxsl:node-set($addHeader)/*)>0">
							<xsl:apply-templates select="msxsl:node-set($addHeader)/l:*" mode="aspnet-mobile-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormHeader</xsl:with-param>
							</xsl:apply-templates>
						</xsl:if>						
					</div>
					
					<div data-role="content">
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="l:styles/l:content/@class"><xsl:value-of select="l:styles/l:fieldtable/@class"/></xsl:when>
								<xsl:when test="$formMobileDefaults/l:styles/l:content/@class"><xsl:value-of select="$formMobileDefaults/l:styles/l:content/@class"/></xsl:when>
								<xsl:otherwise>FormView</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						
						<xsl:for-each select="l:field[not(@add) or @add='true' or @add='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="edit-form-mobile-view-field">
										<xsl:with-param name="viewFilter">add</xsl:with-param>
										<xsl:with-param name="mode">add</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid" select="$uniqueId"/>
									</xsl:apply-templates>								
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>							
						</xsl:for-each>
						
					</div>
					
					<xsl:if test="count(msxsl:node-set($addFooter)/*)>0">
						<div data-role="footer">
							<xsl:apply-templates select="msxsl:node-set($addFooter)/l:*" mode="aspnet-mobile-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$uniqueId"/></xsl:with-param>
								<xsl:with-param name="mode">FormFooter</xsl:with-param>
							</xsl:apply-templates>
						</div>
					</xsl:if>
					
				</insertitemtemplate>
			</xsl:if>
		</NReco:formview>
		<script type="text/javascript">
		(function() {
			var formTbl = $('#@@lt;%=FormView<xsl:value-of select="$uniqueId"/>.ClientID %@@gt;');
			formTbl.find('div[data-role="header"],div[data-role="content"],div[data-role="footer"]').insertAfter(formTbl);
			formTbl.remove();
		})();
		</script>
	</xsl:template>
	
	<xsl:template match="l:field" mode="plain-form-mobile-view-field">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		
		<div data-role="fieldcontain">
			<xsl:choose>
				<xsl:when test="@caption">
					<label><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>:</label>
				</xsl:when>
				<xsl:when test="l:caption/l:*">
					<label>
						<xsl:apply-templates select="l:caption/l:*" mode="aspnet-mobile-renderer">
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>:
					</label>
				</xsl:when>
			</xsl:choose>
				
			<xsl:apply-templates select="." mode="aspnet-mobile-renderer">
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="context">Container.DataItem</xsl:with-param>
			</xsl:apply-templates>
		</div>		
	</xsl:template>

	<xsl:template match="l:field" mode="edit-form-mobile-view-field">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>

		<div data-role="fieldcontain">		
			<xsl:choose>
				<xsl:when test="@caption">
					<label>
						<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label><xsl:if test=".//l:editor/l:validators/l:required"><span class="required">*</span></xsl:if>:
					</label>
				</xsl:when>
				<xsl:when test="l:caption/l:*">
					<label>
						<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates><xsl:if test=".//l:editor/l:validators/l:required"><span class="required">*</span></xsl:if>:
					</label>
				</xsl:when>
			</xsl:choose>
			
			<xsl:apply-templates select="." mode="edit-form-view">
				<xsl:with-param name="mode" select="$mode"/>
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>
	
	<xsl:template match="l:field|l:expression" mode="aspnet-mobile-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:apply-templates select="." mode="aspnet-renderer">
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="mode" select="$mode"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="l:linkbutton" mode="aspnet-mobile-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid">Form</xsl:param>
		<xsl:param name="textPrefix" select="$linkButtonDefaults/@prefix"/>
		<xsl:param name="textSuffix" select="$linkButtonDefaults/@suffix"/>
		<NReco:DataBindHolder runat="server">
		<NReco:LinkButton ValidationGroup="{$formUid}" id="linkBtn{$mode}{generate-id(.)}" 
			data-inline="true"
			runat="server" CommandName="{@command}" command="{@command}"><!-- command attr for html element as metadata -->
			<xsl:if test="$textPrefix">
				<xsl:attribute name="TextPrefix"><xsl:value-of select="$textPrefix"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="$textSuffix">
				<xsl:attribute name="TextSuffix"><xsl:value-of select="$textSuffix"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@icon">
				<xsl:attribute name="data-icon"><xsl:value-of select="@icon"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@iconpos">
				<xsl:attribute name="data-iconpos"><xsl:value-of select="@iconpos"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@role">
				<xsl:attribute name="data-role"><xsl:value-of select="@role"/></xsl:attribute>
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
	
	<xsl:template match="l:link" mode="aspnet-mobile-renderer">
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
		<a href="@@lt;%# {$url} %@@gt;" runat="server" data-inline="true">
			<xsl:if test="@icon">
				<xsl:attribute name="data-icon"><xsl:value-of select="@icon"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@iconpos">
				<xsl:attribute name="data-iconpos"><xsl:value-of select="@iconpos"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="@role">
				<xsl:attribute name="data-role"><xsl:value-of select="@role"/></xsl:attribute>
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
	
	<xsl:template match="l:field[not(l:editor)]" mode="form-mobile-view-editor">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<!-- lets just render this item if editor is not specific -->
		<xsl:apply-templates select="." mode="aspnet-mobile-renderer">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:textbox]|l:field[l:editor/l:textarea]|l:field[l:editor/l:passwordtextbox]|l:field[l:editor/l:usercontrol]|l:field[l:editor/l:dropdownlist]|l:field[l:editor/l:checkbox]" mode="form-mobile-view-editor">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid">Form</xsl:param>
		
		<xsl:apply-templates select="." mode="form-view-editor">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="formUid" select="$formUid"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:actionform" mode="aspnet-mobile-renderer">
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
				
					<xsl:variable name="actionFormHeader">
						<xsl:choose>
							<xsl:when test="@caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></xsl:when>
							<xsl:when test="l:caption">
								<xsl:variable name="code"><xsl:apply-templates select="l:container/node()" mode="csharp-expr"><xsl:with-param name="context">Container.DataItem</xsl:with-param></xsl:apply-templates></xsl:variable>
								@@lt;%# WebManager.GetLabel( Convert.ToString(<xsl:value-of select="$code"/>),this) %@@gt;
							</xsl:when>
						</xsl:choose>						
					</xsl:variable>
				
					<div data-role="header">
						<h1><xsl:copy-of select="$actionFormHeader"/></h1>
						<xsl:apply-templates select="l:header/l:*" mode="aspnet-mobile-renderer">
							<xsl:with-param name="context">Container.DataItem</xsl:with-param>
							<xsl:with-param name="formUid"><xsl:value-of select="$actionForm"/></xsl:with-param>
							<xsl:with-param name="mode">FormHeader</xsl:with-param>
						</xsl:apply-templates>
					</div>
				
					<div data-role="content">
						<xsl:for-each select="l:field">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="edit-form-mobile-view-field">
										<xsl:with-param name="viewFilter">edit</xsl:with-param>
										<xsl:with-param name="mode">edit</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid" select="$actionForm"/>
									</xsl:apply-templates>								
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>						
						</xsl:for-each>	
					</div>
							
					<xsl:if test="count(l:footer/*)>0">
						<div data-role="footer" class="ui-bar">
							<xsl:apply-templates select="l:footer/l:*" mode="aspnet-mobile-renderer">
								<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								<xsl:with-param name="formUid"><xsl:value-of select="$actionForm"/></xsl:with-param>
								<xsl:with-param name="mode">FormFooter</xsl:with-param>
							</xsl:apply-templates>
						</div>
					</xsl:if>						
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
	
	
	<xsl:template match="l:list" mode="aspnet-mobile-renderer">
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
		<xsl:variable name="listNode" select="."/>
		
		<xsl:apply-templates select="l:datasource/l:*" mode="view-datasource">
			<xsl:with-param name="viewType">ListView</xsl:with-param>
		</xsl:apply-templates>
		<NReco:ActionDataSource runat="server" id="list{$listUniqueId}ActionDataSource" DataSourceID="{$mainDsId}" />
				
		<xsl:variable name="insertItemPosition">
			<xsl:choose>
				<xsl:when test="l:addrow/@position = 'top'">FirstItem</xsl:when>
				<xsl:when test="l:addrow/@position = 'bottom' or not(l:addrow/@position)">LastItem</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="listHeader">
			<xsl:choose>
				<xsl:when test="l:header"><xsl:copy-of select="l:header/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$listMobileDefaults/l:header/l:*"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="listFooter">
			<xsl:choose>
				<xsl:when test="l:footer"><xsl:copy-of select="l:footer/l:*"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="$listMobileDefaults/l:footer/l:*"/></xsl:otherwise>
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
				<div data-role="header">
					<h1><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></h1>
					
					<xsl:apply-templates select="msxsl:node-set($listHeader)/l:*" mode="aspnet-mobile-renderer">
						<xsl:with-param name="context">Container.DataItem</xsl:with-param>
						<xsl:with-param name="formUid"><xsl:value-of select="$listUniqueId"/></xsl:with-param>
						<xsl:with-param name="mode">ListHeader</xsl:with-param>
					</xsl:apply-templates>						
				</div>

				
				<div data-role="content">
				<ul data-role="listview">
					<xsl:if test="@name">
						<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
					</xsl:if>
					
					<li runat="server" id="itemPlaceholder" />
				</ul>
				</div>
				<div data-role="footer" class="ui-bar">
					<xsl:apply-templates select="msxsl:node-set($listFooter)/l:*" mode="aspnet-mobile-renderer">
						<xsl:with-param name="context">Container.DataItem</xsl:with-param>
						<xsl:with-param name="formUid"><xsl:value-of select="$listUniqueId"/></xsl:with-param>
						<xsl:with-param name="mode">ListFooter</xsl:with-param>
					</xsl:apply-templates>
				</div>				
				<div data-role="footer">
					<xsl:if test="not(l:pager/@allow='false' or l:pager/@allow='0')">
						<asp:DataPager ID="ListDataPager" runat="server" class="datapager ui-grid-a">
							<xsl:choose>
								<xsl:when test="l:pager/@pagesize">
									<xsl:attribute name="PageSize"><xsl:value-of select="l:pager/@pagesize"/></xsl:attribute>
								</xsl:when>
								<xsl:when test="$listMobileDefaults/l:pager/@pagesize">
									<xsl:attribute name="PageSize"><xsl:value-of select="$listMobileDefaults/l:pager/@pagesize"/></xsl:attribute>
								</xsl:when>
							</xsl:choose>
							<Fields>
							  <asp:TemplatePagerField>
							   <PagerTemplate>
								
							   </PagerTemplate>
							  </asp:TemplatePagerField>
							
								<xsl:choose>
									<xsl:when test="l:pager/l:template">
										<xsl:copy-of select="l:pager/l:template/node()"/>
									</xsl:when>
									<xsl:when test="$listMobileDefaults/l:pager/l:template">
										<xsl:copy-of select="$listMobileDefaults/l:pager/l:template/node()"/>
									</xsl:when>
									<xsl:otherwise>
										<asp:NumericPagerField 
											PreviousPageText="&lt;&lt;"
											NextPageText="&gt;&gt;"/>
									</xsl:otherwise>
								</xsl:choose>
								
							  <asp:TemplatePagerField>
							   <PagerTemplate>
								  
							   </PagerTemplate>
							  </asp:TemplatePagerField>								
								
							</Fields>
						</asp:DataPager>
					</xsl:if>
				</div>

			</LayoutTemplate>
			<ItemTemplate>
				<li class="item">
					<xsl:variable name="viewItemContent">
						<xsl:for-each select="l:field[not(@view) or @view='true' or @view='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">
									<xsl:apply-templates select="." mode="list-mobile-view-field">
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="listNode" select="$listNode"/>
									</xsl:apply-templates>								
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>								
						</xsl:for-each>			
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="l:url">
							<xsl:variable name="href">
								<xsl:apply-templates select="l:url/l:*" mode="csharp-expr">
									<xsl:with-param name="context">Container.DataItem</xsl:with-param>
								</xsl:apply-templates> 
							</xsl:variable>
							<a runat="server" href="@@lt;%# {$href} %@@gt;">
								<xsl:copy-of select="$viewItemContent"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="$viewItemContent"/>
						</xsl:otherwise>
					</xsl:choose>
					
				</li>
			</ItemTemplate>
			<xsl:if test="@edit='true' or @edit='1'">
				<EditItemTemplate>
					<li class="editItem">
						<xsl:for-each select="l:field[not(@edit) or @edit='true' or @edit='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">					
									<xsl:apply-templates select="." mode="list-mobile-view-field-editor">
										<xsl:with-param name="mode">edit</xsl:with-param>
										<xsl:with-param name="context">Container.DataItem</xsl:with-param>
										<xsl:with-param name="formUid">@@lt;%# String.Format("ListForm{0}", Container.ClientID ) %@@gt;</xsl:with-param>
										<xsl:with-param name="listNode" select="$listNode"/>
									</xsl:apply-templates>
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>
						</xsl:for-each>
					</li>
				</EditItemTemplate>
			</xsl:if>
			 
			 <xsl:if test="@add='true' or @add='1'">
				<xsl:variable name="insertItemTemplateContent">
					<li class="insertItem">
						<xsl:for-each select="l:field[not(@add) or @add='true' or @add='1']">
							<xsl:call-template name="apply-visibility">
								<xsl:with-param name="content">						
									<xsl:apply-templates select="." mode="list-mobile-view-field-editor">
										<xsl:with-param name="mode">add</xsl:with-param>
										<xsl:with-param name="context">(Container is IDataItemContainer ? ((IDataItemContainer)Container).DataItem : new object() )</xsl:with-param>
										<xsl:with-param name="formUid">@@lt;%# String.Format("ListFormInsert{0}", Container.ClientID ) %@@gt;</xsl:with-param>
										<xsl:with-param name="listNode" select="$listNode"/>
									</xsl:apply-templates>
								</xsl:with-param>
								<xsl:with-param name="expr" select="l:visible/node()"/>
							</xsl:call-template>
						</xsl:for-each>
					</li>
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
		
		<xsl:variable name="showPager">
			<xsl:choose>
				<xsl:when test="l:pager/@show"><xsl:value-of select="l:pager/@show"/></xsl:when>
				<xsl:when test="$listMobileDefaults/l:pager/@show"><xsl:value-of select="$listMobileDefaults/l:pager/@show"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:call-template name="layout-list-generate-actions-code">
			<xsl:with-param name="listUniqueId" select="$listUniqueId"/>
			<xsl:with-param name="showPager" select="$showPager"/>
		</xsl:call-template>
	</xsl:template>
	
	
	<xsl:template match="l:field[l:editor]" mode="list-mobile-view-field-editor">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:param name="listNode"/>
		<div data-role="fieldcontain" class="ui-hide-label">
			<label><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></label>
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
		</div>
	</xsl:template>
	
	<xsl:template match="l:field[not(l:editor)]" mode="list-mobile-view-field-editor">
		<xsl:param name="context"/>
		<xsl:param name="listNode"/>
		<xsl:param name="formUid"/>
		<p>
			<xsl:if test="@class">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
		
			<xsl:apply-templates select="." mode="list-mobile-view-field">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
				<xsl:with-param name="listNode" select="$listNode"/>
			</xsl:apply-templates>
		</p>
	</xsl:template>

	<xsl:template match="l:field" mode="list-mobile-view-field">
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>
		<xsl:param name="listNode"/>		
		
		<xsl:variable name="elem">
			<xsl:choose>
				<xsl:when test="@header='true'">h3</xsl:when>
				<xsl:otherwise>p</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:element name="{$elem}">
			<xsl:if test="@css-class">
				<xsl:attribute name="class"><xsl:value-of select="@css-class"/></xsl:attribute>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="l:renderer">
					<xsl:for-each select="l:renderer/l:*">
						<xsl:if test="position()!=1">@@amp;nbsp;</xsl:if>
						<xsl:apply-templates select="." mode="aspnet-mobile-renderer">
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="formUid" select="$formUid"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="aspnet-mobile-renderer">
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="formUid" select="$formUid"/>
					</xsl:apply-templates>				
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	
</xsl:stylesheet>
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

	<xsl:template match="l:newline|l:html|l:usercontrol|l:placeholder|l:ul|l:ol|l:repeater|l:listdisplayindex" mode="aspnet-mobile-renderer">
		<xsl:apply-templates select="." mode="aspnet-renderer"/>
		<br/>
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
			<xsl:if test="@icon">
				<xsl:attribute name="icon"><xsl:value-of select="@icon"/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="aspnet-mobile-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>
		</li>
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
			RenderOuterTable="false"
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
								<xsl:when test="$formDefaults/l:styles/l:mobile/l:content/@class"><xsl:value-of select="$formDefaults/l:styles/l:mobile/l:content/@class"/></xsl:when>
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
								<xsl:when test="$formDefaults/l:styles/l:mobile/l:content/@class"><xsl:value-of select="$formDefaults/l:styles/l:mobile/l:content/@class"/></xsl:when>
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
								<xsl:when test="$formDefaults/l:styles/l:mobile/l:content/@class"><xsl:value-of select="$formDefaults/l:styles/l:mobile/l:content/@class"/></xsl:when>
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
		
		<xsl:apply-templates select="." mode="aspnet-renderer">
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="formUid" select="$formUid"/>
			<xsl:with-param name="textPrefix" select="$textPrefix"/>
			<xsl:with-param name="textSuffix" select="$textSuffix"/>			
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:link" mode="aspnet-mobile-renderer">
		<xsl:param name="context"/>
		<xsl:apply-templates select="." mode="aspnet-renderer">
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
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

	<xsl:template match="l:field[l:editor/l:textbox]|l:field[l:editor/l:textarea]|l:field[l:editor/l:passwordtextbox]|l:field[l:editor/l:usercontrol]|l:field[l:editor/l:dropdownlist]" mode="form-mobile-view-editor">
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
						<div data-role="footer">
							<xsl:apply-templates select="l:footer/l:*" mode="aspnet-renderer">
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
	
</xsl:stylesheet>
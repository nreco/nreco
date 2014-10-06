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

	<!--override form layout -->
	<xsl:template match="l:form" mode="layout-form-template">
		<xsl:param name="formClass"/>
		<xsl:param name="renderFormHeader"/>
		<xsl:param name="formHeader"/>
		<xsl:param name="renderFormFooter"/>
		<xsl:param name="formFooter"/>
		<xsl:param name="formBody"/>
		<div class="{$formClass}" role="form">
			<xsl:if test="$renderFormHeader">
				<div class="formheader">
					<xsl:copy-of select="$formHeader"/>
				</div>
			</xsl:if>
			<xsl:copy-of select="$formBody"/>
			<xsl:if test="$renderFormFooter">
				<div class="formfooter">
					<xsl:copy-of select="$formFooter"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!--override form form readonly row layout -->
	<xsl:template match="l:field[not(@layout) or @layout='horizontal']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<div class="form-row form-horizontal">
			<div class="form-group">
				<xsl:choose>
					<xsl:when test="@caption">
						<label class="col-sm-4 control-label">
							<span class="fieldcaption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></span><xsl:call-template name="renderFormFieldCaptionSuffix"/>
						</label>
					</xsl:when>
					<xsl:when test="l:caption/l:*">
						<label class="col-sm-4 control-label">
							<span class="fieldcaption"><xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates></span><xsl:call-template name="renderFormFieldCaptionSuffix"/>
						</label>
					</xsl:when>
				</xsl:choose>
				<div class="col-sm-8">
					<div class="form-control-static">
						<xsl:apply-templates select="." mode="aspnet-renderer">
							<xsl:with-param name="mode" select="$mode"/>
							<xsl:with-param name="context">Container.DataItem</xsl:with-param>
						</xsl:apply-templates>
					</div>
				</div>
			</div>
		</div>		
	</xsl:template>

	<xsl:template match="l:field[@layout='vertical']" mode="plain-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<div class="form-group form-row">
				<xsl:choose>
					<xsl:when test="@caption">
						<label class="control-label">
							<span class="fieldcaption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></span><xsl:call-template name="renderFormFieldCaptionSuffix"/>
						</label>
					</xsl:when>
					<xsl:when test="l:caption/l:*">
						<label class="control-label">
							<span class="fieldcaption">
								<xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
									<xsl:with-param name="context" select="$context"/>
								</xsl:apply-templates>
							</span><xsl:call-template name="renderFormFieldCaptionSuffix"/>
						</label>
					</xsl:when>
				</xsl:choose>
				<div class="form-control-static">
				<xsl:apply-templates select="." mode="aspnet-renderer">
					<xsl:with-param name="mode" select="$mode"/>
					<xsl:with-param name="context">Container.DataItem</xsl:with-param>
				</xsl:apply-templates>
			</div>
		</div>
	</xsl:template>

	<!--override form edit row layout -->
	<xsl:template match="l:field[not(@layout) or @layout='horizontal']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>

		<div class="form-row form-horizontal">
			<div class="form-group">
				<xsl:choose>
					<xsl:when test="@caption">
						<label class="col-sm-4 control-label">
							<span class="fieldcaption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></span><xsl:if test=".//l:editor/l:validators/l:required"><xsl:call-template name="renderFormFieldCaptionRequiredSuffix"/></xsl:if><xsl:call-template name="renderFormFieldCaptionSuffix"/>
						</label>
					</xsl:when>
					<xsl:when test="l:caption/l:*">
						<label class="col-sm-4 control-label">
							<span class="fieldcaption"><xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates></span><xsl:if test=".//l:editor/l:validators/l:required"><xsl:call-template name="renderFormFieldCaptionRequiredSuffix"/></xsl:if><xsl:call-template name="renderFormFieldCaptionSuffix"/>
						</label>
					</xsl:when>
				</xsl:choose>
				<div>
					<xsl:attribute name="class">
						<xsl:choose>
							<xsl:when test="@caption or l:caption">col-sm-8</xsl:when>
							<xsl:otherwise>col-sm-12</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:choose>
						<xsl:when test="l:editor">
							<xsl:apply-templates select="." mode="edit-form-view">
								<xsl:with-param name="mode" select="$mode"/>
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="formUid" select="$formUid"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<div class="form-control-static">
								<xsl:apply-templates select="." mode="edit-form-view">
									<xsl:with-param name="mode" select="$mode"/>
									<xsl:with-param name="context" select="$context"/>
									<xsl:with-param name="formUid" select="$formUid"/>
								</xsl:apply-templates>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>
	</xsl:template>	

	<xsl:template match="l:field[@layout='vertical']" mode="edit-form-view-table-row">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:param name="formUid"/>

		<div class="form-group form-row">
			<xsl:choose>
				<xsl:when test="@caption">
					<label class="control-label">
						<span class="fieldcaption"><NRecoWebForms:Label runat="server"><xsl:value-of select="@caption"/></NRecoWebForms:Label></span><xsl:if test=".//l:editor/l:validators/l:required"><xsl:call-template name="renderFormFieldCaptionRequiredSuffix"/></xsl:if><xsl:call-template name="renderFormFieldCaptionSuffix"/>
					</label>
				</xsl:when>
				<xsl:when test="l:caption/l:*">
					<label class="control-label">
						<span class="fieldcaption"><xsl:apply-templates select="l:caption/l:*" mode="aspnet-renderer">
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates></span><xsl:if test=".//l:editor/l:validators/l:required"><xsl:call-template name="renderFormFieldCaptionRequiredSuffix"/></xsl:if><xsl:call-template name="renderFormFieldCaptionSuffix"/>
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

	<xsl:template match="l:tabs" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		
		<xsl:variable name="uniqueId">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>tabs<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<ul id="{$uniqueId}" class="nav nav-tabs" role="tablist">
			<xsl:for-each select="l:tab">
				<xsl:variable name="tabUniqueId"><xsl:value-of select="$uniqueId"/>_<xsl:value-of select="position()"/></xsl:variable>

				<xsl:call-template name="apply-visibility">
					<xsl:with-param name="content">
						<li>
							<a href="#{$tabUniqueId}" role="tab" data-toggle="tab">
								<xsl:choose>
									<xsl:when test="@header">
										<NRecoWebForms:Label runat="server"><xsl:value-of select="@header"/></NRecoWebForms:Label>
									</xsl:when>
									<xsl:when test="l:header">
										<xsl:apply-templates select="l:header/l:*" mode="aspnet-renderer">
											<xsl:with-param name="context" select="$context"/>
											<xsl:with-param name="formUid" select="$formUid"/>
											<xsl:with-param name="mode" select="$mode"/>
										</xsl:apply-templates>										
									</xsl:when>
								</xsl:choose>								
							</a>
						</li>
					</xsl:with-param>
					<xsl:with-param name="expr" select="l:visible/node()"/>
				</xsl:call-template>
			</xsl:for-each>
		</ul>

		<div id="{$uniqueId}_content" class="tab-content">
			<xsl:for-each select="l:tab">
				<xsl:variable name="tabUniqueId"><xsl:value-of select="$uniqueId"/>_<xsl:value-of select="position()"/></xsl:variable>
				<xsl:call-template name="apply-visibility">
					<xsl:with-param name="content">
						<div class="tab-pane" id="{$tabUniqueId}">
							<xsl:apply-templates select="l:content/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="formUid" select="$formUid"/>
								<xsl:with-param name="mode" select="$mode"/>
							</xsl:apply-templates>
						</div>
					</xsl:with-param>
					<xsl:with-param name="expr" select="l:visible/node()"/>
				</xsl:call-template>
			</xsl:for-each>
		</div>
		<NRecoWebForms:JavaScriptHolder runat="server">$(function() {
			$('#<xsl:value-of select="$uniqueId"/>@@gt;li:first,#<xsl:value-of select="$uniqueId"/>_content@@gt;div.tab-pane:first').addClass('active');
		});</NRecoWebForms:JavaScriptHolder>

	</xsl:template>
	
	<xsl:template match="l:accordion" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>

		<xsl:variable name="uniqueId">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>accordion<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<NRecoWebForms:DataBindHolder runat="server">
		<div class="panel-group" id="{$uniqueId}">
			<xsl:for-each select="l:panel">
				<xsl:variable name="panelUniqueId"><xsl:value-of select="$uniqueId"/>_<xsl:value-of select="position()"/></xsl:variable>
				<xsl:variable name="collapsedClass">@@lt;%# Convert.ToBoolean(<xsl:apply-templates select="l:collapsed/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates>)?"":"in" %@@gt;</xsl:variable>
				
				<xsl:call-template name="apply-visibility">
					<xsl:with-param name="content">

						<div class="panel">
							<xsl:attribute name="class">
								panel <xsl:if test="@style">panel-<xsl:value-of select="@style"/></xsl:if> <xsl:if test="not(@style)">panel-default</xsl:if>
							</xsl:attribute>
							<div class="panel-heading">
								<h4 class="panel-title">
									<a data-toggle="collapse" data-parent="#{$uniqueId}" href="#{$panelUniqueId}">
										<xsl:choose>
											<xsl:when test="@header">
												<NRecoWebForms:Label runat="server"><xsl:value-of select="@header"/></NRecoWebForms:Label>
											</xsl:when>
											<xsl:when test="l:header">
												<xsl:apply-templates select="l:header/l:*" mode="aspnet-renderer">
													<xsl:with-param name="context" select="$context"/>
													<xsl:with-param name="formUid" select="$formUid"/>
													<xsl:with-param name="mode" select="$mode"/>
												</xsl:apply-templates>										
											</xsl:when>
										</xsl:choose>
									</a>
								</h4>
							</div>
							@@lt;div id="<xsl:value-of select="$panelUniqueId"/>" class="panel-collapse collapse <xsl:if test="l:collapsed"><xsl:value-of select="$collapsedClass" disable-output-escaping="yes"/></xsl:if>"@@gt;
								<div class="panel-body">
									<xsl:apply-templates select="l:body/l:*" mode="aspnet-renderer">
										<xsl:with-param name="context" select="$context"/>
										<xsl:with-param name="formUid" select="$formUid"/>
										<xsl:with-param name="mode" select="$mode"/>
									</xsl:apply-templates>							
								</div>
								<xsl:if test="l:footer">
									<div class="panel-footer">
										<xsl:apply-templates select="l:footer/l:*" mode="aspnet-renderer">
											<xsl:with-param name="context" select="$context"/>
											<xsl:with-param name="formUid" select="$formUid"/>
											<xsl:with-param name="mode" select="$mode"/>
										</xsl:apply-templates>
									</div>
								</xsl:if>						
							@@lt;/div@@gt;
						</div>
					</xsl:with-param>
					<xsl:with-param name="expr" select="l:visible/node()"/>
				</xsl:call-template>
			</xsl:for-each>
		</div>
		</NRecoWebForms:DataBindHolder>
	</xsl:template>
	
	
	<xsl:template match="l:panel" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>

		<NRecoWebForms:DataBindHolder runat="server">
		<div class="panel">
			<xsl:attribute name="class">
				panel <xsl:if test="@style">panel-<xsl:value-of select="@style"/></xsl:if> <xsl:if test="not(@style)">panel-default</xsl:if>
			</xsl:attribute>

			<xsl:if test="l:header or @header">
				<div class="panel-heading">
					<xsl:choose>
						<xsl:when test="@header">
							<NRecoWebForms:Label runat="server"><xsl:value-of select="@header"/></NRecoWebForms:Label>
						</xsl:when>
						<xsl:when test="l:header">
							<xsl:apply-templates select="l:header/l:*" mode="aspnet-renderer">
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="formUid" select="$formUid"/>
								<xsl:with-param name="mode" select="$mode"/>
							</xsl:apply-templates>										
						</xsl:when>
					</xsl:choose>
				</div>	
			</xsl:if>

			<xsl:if test="l:body">
				<div class="panel-body">
					<xsl:apply-templates select="l:body/l:*" mode="aspnet-renderer">
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="formUid" select="$formUid"/>
						<xsl:with-param name="mode" select="$mode"/>
					</xsl:apply-templates>
				</div>
			</xsl:if>

			<xsl:if test="l:footer">
				<div class="panel-footer">
					<xsl:apply-templates select="l:footer/l:*" mode="aspnet-renderer">
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="formUid" select="$formUid"/>
						<xsl:with-param name="mode" select="$mode"/>
					</xsl:apply-templates>
				</div>
			</xsl:if>

		</div>
		</NRecoWebForms:DataBindHolder>
	</xsl:template>

	<xsl:template match="l:badge" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		<NRecoWebForms:DataBindHolder runat="server">
			<span class="badge {@class}">
				<xsl:apply-templates select="l:*" mode="csharp-expr">
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</span>
		</NRecoWebForms:DataBindHolder>
	</xsl:template>

	<xsl:template match="l:label" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		<NRecoWebForms:DataBindHolder runat="server">
			<span>
				<xsl:attribute name="class">
					label <xsl:choose>
						<xsl:when test="@style">label-<xsl:value-of select="@style"/></xsl:when>
						<xsl:otherwise>label-default</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="l:*" mode="csharp-expr">
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</span>
		</NRecoWebForms:DataBindHolder>
	</xsl:template>

	<xsl:template match="l:button-group" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		<div>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="@layout='vertical'">btn-group-vertical</xsl:when>
					<xsl:otherwise>btn-group</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="l:*" mode="aspnet-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>			
		</div>
	</xsl:template>

	<xsl:template match="l:button-toolbar" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:param name="formUid"/>
		<div class="btn-toolbar" role="toolbar">
			<xsl:apply-templates select="l:*" mode="aspnet-renderer">
				<xsl:with-param name="context" select="$context"/>
				<xsl:with-param name="formUid" select="$formUid"/>
				<xsl:with-param name="mode" select="$mode"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:datepicker]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="DatePickerEditor" src="~/templates/editors/DatePickerEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:datepicker]" mode="register-editor-code">
		IncludeJsFile("~/Scripts/bootstrap-datepicker.js");
		IncludeCssFile("~/css/datepicker3.css");
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:datepicker]" mode="form-view-editor">
		<Plugin:DatePickerEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}">
			<xsl:attribute name="Value">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			<xsl:attribute name="Format">
				<xsl:choose>
					<xsl:when test="@format"><xsl:value-of select="@format"/></xsl:when>
					<xsl:otherwise>{0:d}</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</Plugin:DatePickerEditor>
	</xsl:template>


	<xsl:template match="l:field[l:editor/l:selectbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="SelectBoxEditor" src="~/templates/editors/SelectBoxEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:selectbox]" mode="register-editor-code">
		IncludeJsFile("~/Scripts/select2.min.js");
		IncludeCssFile("~/css/select2/select2.css");
		IncludeCssFile("~/css/select2/select2-bootstrap.css");
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:selectbox]" mode="form-view-editor">
		<Plugin:SelectBoxEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}"
			TextFieldName="{l:editor/l:selectbox/l:data/@text}"
			ValueFieldName="{l:editor/l:selectbox/l:data/@value}">
			<xsl:attribute name="Value">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			<xsl:attribute name="DataProvider"><xsl:value-of select="l:editor/l:selectbox/l:data/@lookup"/></xsl:attribute>
			<xsl:attribute name="Multivalue">
				<xsl:choose>
					<xsl:when test="l:editor/l:selectbox/@multiple='true' or l:editor/l:selectbox/@multiple='1'">True</xsl:when>
					<xsl:otherwise>False</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</Plugin:SelectBoxEditor>
	</xsl:template>
	
</xsl:stylesheet>
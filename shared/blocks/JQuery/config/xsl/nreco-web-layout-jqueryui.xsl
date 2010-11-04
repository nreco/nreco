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
				xmlns:Plugin="urn:remove"
				xmlns:NReco="urn:remove"
				xmlns:asp="urn:remove"
				exclude-result-prefixes="msxsl">

	<xsl:output method='xml' indent='yes' />

	<xsl:template match="l:field[l:editor/l:datepicker]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="DatePickerEditor" src="~/templates/editors/DatePickerEditor.ascx" %@@gt;
	</xsl:template>	

	<xsl:template match="l:field[l:editor/l:timepicker]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="TimePickerEditor" src="~/templates/editors/TimePickerEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:datepicker]" mode="form-view-editor">
		<Plugin:DatePickerEditor runat="server" 
			id="{@name}"
			ObjectValue='@@lt;%# Bind("{@name}") %@@gt;'>
			<xsl:if test="l:editor/l:datepicker/@year-range">
				<xsl:attribute name="YearRange"><xsl:value-of select="l:editor/l:datepicker/@year-range"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:datepicker/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:datepicker/@width"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:datepicker/@year='1' or l:editor/l:datepicker/@year='true'">
				<xsl:attribute name="YearSelection">True</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:datepicker/@clear='true' or l:editor/l:datepicker/@clear='1'">
				<xsl:attribute name="ClearButton">True</xsl:attribute>
			</xsl:if>
		</Plugin:DatePickerEditor>
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:timepicker]" mode="form-view-editor">
		<xsl:variable name="datatype" select="l:editor/l:timepicker/@datatype"/>
		<Plugin:TimePickerEditor runat="server" 
			id="{@name}">
			<xsl:choose>
				<xsl:when test="$datatype='int'">
					<xsl:attribute name="SecondsValue">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
				</xsl:when>
				<xsl:when test="$datatype='time'">
					<xsl:attribute name="TimeSpanValue">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
				</xsl:when>
				<xsl:when test="$datatype='string'">
					<xsl:attribute name="StringValue">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="l:editor/l:timepicker/@seconds='1' or l:editor/l:timepicker/@seconds='true'">
				<xsl:attribute name="SecondsSelection">True</xsl:attribute>
			</xsl:if> 
			<xsl:if test="l:editor/l:timepicker/@default-value">
				<xsl:attribute name="DefaultValue"><xsl:value-of select="l:editor/l:timepicker/@default-value"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:timepicker/@hour-step">
				<xsl:attribute name="HourStep"><xsl:value-of select="l:editor/l:timepicker/@hour-step"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:timepicker/@minute-step">
				<xsl:attribute name="MinuteStep"><xsl:value-of select="l:editor/l:timepicker/@minute-step"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:timepicker/@second-step">
				<xsl:attribute name="SecondStep"><xsl:value-of select="l:editor/l:timepicker/@second-step"/></xsl:attribute>
			</xsl:if>
		</Plugin:TimePickerEditor>
	</xsl:template>	
	
	<xsl:template match="l:icon-html" mode="csharp-expr">"&lt;span class='ui-icon ui-icon-<xsl:value-of select="@type"/>'&gt;&lt;/span&gt;"</xsl:template>
	
	<xsl:template match="l:tabs" mode="aspnet-renderer">
		<xsl:variable name="uniqueId">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>jqTabs<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div id="{$uniqueId}" style="visibility:hidden">
			<ul>
				<xsl:for-each select="l:tab">
					<xsl:call-template name="apply-visibility">
						<xsl:with-param name="content">
							<li><a href="#{$uniqueId}_{position()}">
								<xsl:choose>
									<xsl:when test="@caption"><NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label></xsl:when>
									<xsl:when test="l:caption">
										<xsl:variable name="code"><xsl:apply-templates select="l:caption/node()" mode="csharp-expr"><xsl:with-param name="context">Container.DataItem</xsl:with-param></xsl:apply-templates></xsl:variable>
										<NReco:DataBindHolder runat="server" EnableViewState="false">
										@@lt;%# <xsl:value-of select="$code"/> %@@gt;
										</NReco:DataBindHolder>
									</xsl:when>
								</xsl:choose>
							</a></li>
						</xsl:with-param>
						<xsl:with-param name="expr" select="l:visible/node()"/>
					</xsl:call-template>
				</xsl:for-each>
			</ul>
			<xsl:for-each select="l:tab">
				<xsl:call-template name="apply-visibility">
					<xsl:with-param name="content">			
						<div id="{$uniqueId}_{position()}">
							<!-- nested div for correct margin -->
							<div class="tabContent">
								<xsl:apply-templates select="l:renderer/node()" mode="aspnet-renderer"/>
							</div>
						</div>
					</xsl:with-param>
					<xsl:with-param name="expr" select="l:visible/node()"/>
				</xsl:call-template>
			</xsl:for-each>
		</div>
		<script type="text/javascript">
			jQuery(function() {
				var tabClientId = '<xsl:value-of select="$uniqueId"/>';
				jQuery("#"+tabClientId).tabs( {
					<xsl:if test="@selected='cookie'">
						cookie : { expires: 30, name : '.<xsl:value-of select="$uniqueId"/>', path : '@@lt;%= Request.Url.AbsolutePath %@@gt;' }
					</xsl:if>
				} ).css('visibility', 'visible');
				var tabParamPrefix = tabClientId+'=';
				if (location.search!=null @@amp;@@amp; location.search.indexOf(tabParamPrefix)@@gt;=0 ) {
					var tabParamPrefixIdx = location.search.indexOf(tabParamPrefix);
					jQuery("#"+tabClientId).tabs('option', 'selected', parseInt( location.search.substring(tabParamPrefixIdx+tabParamPrefix.length) ) );
				}
			});
		</script>
	</xsl:template>
	
	<xsl:template match="l:widget" mode="aspnet-renderer">
		<xsl:variable name="uniqueId" select="generate-id(.)"/>
		<xsl:variable name="extraClass"><xsl:value-of select="name(node())"/>view</xsl:variable>
		<xsl:choose>
			<xsl:when test="@caption or l:caption">
				<div id="widgetHeader{$uniqueId}" class="ui-widget-header ui-corner-top {$extraClass}">
					<div class="nreco-widget-header">
						<xsl:choose>
							<xsl:when test="l:caption">
								<xsl:variable name="code"><xsl:apply-templates select="l:caption/node()" mode="csharp-expr"><xsl:with-param name="context">this.GetContext()</xsl:with-param></xsl:apply-templates></xsl:variable>
								<NReco:DataBindHolder runat="server" EnableViewState="false">
								@@lt;%# <xsl:value-of select="$code"/> %@@gt;
								</NReco:DataBindHolder>							
							</xsl:when>
							<xsl:otherwise>
								<NReco:Label runat="server"><xsl:value-of select="@caption"/></NReco:Label>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
				<div id="widgetContent{$uniqueId}" class="ui-widget-content ui-corner-bottom {$extraClass}">
					<div class="nreco-widget-content">
						<xsl:choose>
							<xsl:when test="l:renderer">
								<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="node()" mode="aspnet-renderer"/>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div id="widgetContent{$uniqueId}" class="ui-corner-all ui-widget-content {$extraClass}">
					<div class="nreco-widget-content">
						<xsl:choose>
							<xsl:when test="l:renderer">
								<xsl:apply-templates select="l:renderer/l:*" mode="aspnet-renderer"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="node()" mode="aspnet-renderer"/>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:jgrowtextarea]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="JGrowTextareaEditor" src="~/templates/editors/JGrowTextareaEditor.ascx" %@@gt;
	</xsl:template>		
	<xsl:template match="l:field[l:editor/l:jgrowtextarea]" mode="form-view-editor">
		<Plugin:JGrowTextareaEditor id="{@name}" runat="server" Text='@@lt;%# Bind("{@name}") %@@gt;'>
			<xsl:if test="l:editor/l:jgrowtextarea/@rows">
				<xsl:attribute name="Rows"><xsl:value-of select="l:editor/l:jgrowtextarea/@rows"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:jgrowtextarea/@cols">
				<xsl:attribute name="Columns"><xsl:value-of select="l:editor/l:jgrowtextarea/@cols"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:jgrowtextarea/@maxheight">
				<xsl:attribute name="MaxHeight"><xsl:value-of select="l:editor/l:jgrowtextarea/@maxheight"/></xsl:attribute>
			</xsl:if>			
		</Plugin:JGrowTextareaEditor>
	</xsl:template>	
	
</xsl:stylesheet>
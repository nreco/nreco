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
				exclude-result-prefixes="msxsl">

	<xsl:output method='xml' indent='yes' />

	<xsl:template match="l:field[l:editor/l:flexbox]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="FlexBoxEditor" src="~/templates/editors/FlexBoxEditor.ascx" %@@gt;
		@@lt;%@ Register TagPrefix="Plugin" tagName="FlexBoxRelationEditor" src="~/templates/editors/FlexBoxRelationEditor.ascx" %@@gt;
	</xsl:template>	
	<xsl:template match="l:field[l:editor/l:flexbox]" mode="register-editor-css">
		<link rel="stylesheet" type="text/css" href="css/jquery.flexbox.css" />
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:flexbox and not(l:editor/l:flexbox/l:relation)]" mode="form-view-editor">
		<xsl:variable name="relex">
			<xsl:choose>
				<xsl:when test="l:editor/l:flexbox/l:lookup/@relex"><xsl:value-of select="l:editor/l:flexbox/l:lookup/@relex"/></xsl:when>
				<xsl:when test="l:editor/l:flexbox/l:lookup/l:relex"><xsl:value-of select="l:editor/l:flexbox/l:lookup/l:relex"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="flexboxDalcName">
			<xsl:choose>
				<xsl:when test="l:editor/l:flexbox/@dalc"><xsl:value-of select="l:editor/l:flexbox/@dalc"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$dalcName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<Plugin:FlexBoxEditor id="{@name}" runat="server" xmlns:Plugin="urn:remove"
			DalcServiceName="{$flexboxDalcName}"
			Relex="{$relex}"
			TextFieldName="{l:editor/l:flexbox/l:lookup/@text}"
			ValueFieldName="{l:editor/l:flexbox/l:lookup/@value}"
			Value='@@lt;%# Bind("{@name}") %@@gt;'>
			<xsl:if test="l:editor/l:flexbox/l:context/l:js">
				<xsl:variable name="exprStr"><xsl:apply-templates select="l:editor/l:flexbox/l:context/l:js/l:*" mode="csharp-expr"/></xsl:variable>
				<xsl:attribute name="DataContextJs">@@lt;%# <xsl:value-of select="translate($exprStr, '&#xA;&#xD;&#x9;', '')"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:flexbox/l:context/l:dictionary">
				<xsl:variable name="exprStr"><xsl:apply-templates select="l:editor/l:flexbox/l:context/l:dictionary" mode="csharp-expr"/></xsl:variable>
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$exprStr"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:flexbox/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:flexbox/@width"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:flexbox/@pagesize">
				<xsl:attribute name="RecordsPerPage"><xsl:value-of select="l:editor/l:flexbox/@pagesize"/></xsl:attribute>
			</xsl:if>
		</Plugin:FlexBoxEditor>
	</xsl:template>	

	<xsl:template match="l:field[l:editor/l:flexbox and l:editor/l:flexbox/l:relation]" mode="form-view-editor">
		<xsl:variable name="relex">
			<xsl:choose>
				<xsl:when test="l:editor/l:flexbox/l:lookup/@relex"><xsl:value-of select="l:editor/l:flexbox/l:lookup/@relex"/></xsl:when>
				<xsl:when test="l:editor/l:flexbox/l:lookup/l:relex"><xsl:value-of select="l:editor/l:flexbox/l:lookup/l:relex"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="flexboxDalcName">
			<xsl:choose>
				<xsl:when test="l:editor/l:flexbox/@dalc"><xsl:value-of select="l:editor/l:flexbox/@dalc"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$dalcName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		<Plugin:FlexBoxRelationEditor runat="server" xmlns:Plugin="urn:remove"
			DalcServiceName="{$flexboxDalcName}"
			DsFactoryServiceName="{$datasetFactoryName}"
			Relex="{$relex}"
			TextFieldName="{l:editor/l:flexbox/l:lookup/@text}"
			ValueFieldName="{l:editor/l:flexbox/l:lookup/@value}"
			RelationSourceName="{l:editor/l:flexbox/l:relation/@sourcename}"
			LFieldName="{l:editor/l:flexbox/l:relation/@left}"
			RFieldName="{l:editor/l:flexbox/l:relation/@right}"			
		>
			<xsl:if test="@name or not(l:editor/l:flexbox/l:relation)">
				<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="l:editor/l:flexbox/l:relation/@id">
					<xsl:attribute name="EntityId">@@lt;%# Eval("<xsl:value-of select="l:editor/l:flexbox/l:relation/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField"><xsl:value-of select="l:editor/l:flexbox/l:relation/@id"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="l:editor/l:flexbox/l:context/l:js">
				<xsl:variable name="exprStr"><xsl:apply-templates select="l:editor/l:flexbox/l:context/l:js/l:*" mode="csharp-expr"/></xsl:variable>
				<xsl:attribute name="DataContextJs">@@lt;%# <xsl:value-of select="translate($exprStr, '&#xA;&#xD;&#x9;', '')"/> %@@gt;</xsl:attribute>
			</xsl:if>	
			<xsl:if test="l:editor/l:flexbox/l:context/l:dictionary">
				<xsl:variable name="exprStr"><xsl:apply-templates select="l:editor/l:flexbox/l:context/l:dictionary" mode="csharp-expr"/></xsl:variable>
				<xsl:attribute name="DataContext">@@lt;%# <xsl:value-of select="$exprStr"/> %@@gt;</xsl:attribute>
			</xsl:if>			
			<xsl:if test="l:editor/l:flexbox/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:flexbox/@width"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:flexbox/l:relation/l:validators/l:max">
				<xsl:attribute name="MaxRows"><xsl:value-of select="l:editor/l:flexbox/l:relation/l:validators/l:max/@count"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:flexbox/l:relation/@editor">
				<xsl:attribute name="RelationEditor">@@lt;%$ service:<xsl:value-of select="l:editor/l:flexbox/l:relation/@editor"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:flexbox/@pagesize">
				<xsl:attribute name="RecordsPerPage"><xsl:value-of select="l:editor/l:flexbox/@pagesize"/></xsl:attribute>
			</xsl:if>
		</Plugin:FlexBoxRelationEditor>
	</xsl:template>	
	
	
</xsl:stylesheet>
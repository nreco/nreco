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

	<xsl:template match="l:field[l:editor/l:mcdropdown]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="McDropDownEditor" src="~/templates/editors/McDropDownEditor.ascx" %@@gt;
		@@lt;%@ Register TagPrefix="Plugin" tagName="McDropDownRelationEditor" src="~/templates/editors/McDropDownRelationEditor.ascx" %@@gt;
	</xsl:template>	
	<xsl:template match="l:field[l:editor/l:mcdropdown]" mode="register-editor-css">
		<link rel="stylesheet" type="text/css" href="css/mcdropdown/jquery.mcdropdown.css" />
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:mcdropdown and not(l:editor/l:flexbox/l:relation)]" mode="form-view-editor">
		<Plugin:McDropDownEditor runat="server" xmlns:Plugin="urn:remove"
			id="{@name}"
			Value='@@lt;%# Bind("{@name}") %@@gt;'
			LookupServiceName="{l:editor/l:mcdropdown/l:lookup/@name}"
			TextFieldName="{l:editor/l:mcdropdown/l:lookup/@text}"
			ValueFieldName="{l:editor/l:mcdropdown/l:lookup/@value}"
			ParentFieldName="{l:editor/l:mcdropdown/l:lookup/@parent}">
			<xsl:if test="l:editor/l:mcdropdown/@allowparentselect">
				<xsl:attribute name="AllowParentSelect">
					<xsl:choose>
						<xsl:when test="l:editor/l:mcdropdown/@allowparentselect='0' or l:editor/l:mcdropdown/@allowparentselect='false'">False</xsl:when>
						<xsl:otherwise>True</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
		</Plugin:McDropDownEditor>
	</xsl:template>	
	
	
	<xsl:template match="l:field[l:editor/l:mcdropdown and l:editor/l:mcdropdown/l:relation]" mode="form-view-editor">
		<xsl:variable name="relEditorDalcName">
			<xsl:choose>
				<xsl:when test="l:editor/l:mcdropdown/@dalc"><xsl:value-of select="l:editor/l:mcdropdown/@dalc"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$dalcName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		<Plugin:McDropDownRelationEditor runat="server" xmlns:Plugin="urn:remove"
			DalcServiceName="{$relEditorDalcName}"
			DsFactoryServiceName="{$datasetFactoryName}"
			TextFieldName="{l:editor/l:mcdropdown/l:lookup/@text}"
			LookupServiceName="{l:editor/l:mcdropdown/l:lookup/@name}"
			ValueFieldName="{l:editor/l:mcdropdown/l:lookup/@value}"
			ParentFieldName="{l:editor/l:mcdropdown/l:lookup/@parent}"
			RelationSourceName="{l:editor/l:mcdropdown/l:relation/@sourcename}"
			LFieldName="{l:editor/l:mcdropdown/l:relation/@left}"
			RFieldName="{l:editor/l:mcdropdown/l:relation/@right}"			
		>
			<xsl:if test="@name or not(l:editor/l:mcdropdown/l:relation)">
				<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="l:editor/l:mcdropdown/l:relation/@id">
					<xsl:attribute name="EntityId">@@lt;%# Eval("<xsl:value-of select="l:editor/l:mcdropdown/l:relation/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField"><xsl:value-of select="l:editor/l:mcdropdown/l:relation/@id"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="l:editor/l:mcdropdown/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:mcdropdown/@width"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:mcdropdown/l:relation/@editor">
				<xsl:attribute name="RelationEditor">@@lt;%$ service:<xsl:value-of select="l:editor/l:flexbox/l:relation/@editor"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:mcdropdown/@allowparentselect">
				<xsl:attribute name="AllowParentSelect">
					<xsl:choose>
						<xsl:when test="l:editor/l:mcdropdown/@allowparentselect='0' or l:editor/l:mcdropdown/@allowparentselect='false'">False</xsl:when>
						<xsl:otherwise>True</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>			
		</Plugin:McDropDownRelationEditor>
	</xsl:template>	
	
	
	
</xsl:stylesheet>
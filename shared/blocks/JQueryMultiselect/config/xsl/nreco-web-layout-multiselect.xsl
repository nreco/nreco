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

	<xsl:template match="l:field[l:editor/l:multiselect]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="MultiselectEditor" src="~/templates/editors/MultiselectEditor.ascx" %@@gt;
	</xsl:template>	
	<xsl:template match="l:field[l:editor/l:multiselect]" mode="register-editor-css">
		<link rel="stylesheet" type="text/css" href="css/ui.multiselect.css" />
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:multiselect]" mode="form-view-editor">
		<xsl:param name="context"/>
		<Plugin:MultiselectEditor runat="server" xmlns:Plugin="urn:remove"
			DalcServiceName="{$dalcName}"
			DsFactoryServiceName="{$datasetFactoryName}"
			LookupServiceName="{l:editor/l:multiselect/l:lookup/@name}"
			TextFieldName="{l:editor/l:multiselect/l:lookup/@text}"
			ValueFieldName="{l:editor/l:multiselect/l:lookup/@value}">
			<xsl:if test="@name or not(l:editor/l:flexbox/l:relation)">
				<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:multiselect/l:relation/@sourcename">
				<xsl:attribute name="RelationSourceName"><xsl:value-of select="l:editor/l:multiselect/l:relation/@sourcename"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:multiselect/l:relation/@left">
				<xsl:attribute name="LFieldName"><xsl:value-of select="l:editor/l:multiselect/l:relation/@left"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:multiselect/l:relation/@left">
				<xsl:attribute name="RFieldName"><xsl:value-of select="l:editor/l:multiselect/l:relation/@right"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:multiselect/l:relation/@editor">
				<xsl:attribute name="RelationEditor">@@lt;%$ service:<xsl:value-of select="l:editor/l:multiselect/l:relation/@editor"/> %@@gt;</xsl:attribute>
			</xsl:if>			
			
			<xsl:if test="l:editor/l:multiselect/l:lookup/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:multiselect/l:lookup/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="LookupDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>			
			<xsl:if test="l:editor/l:multiselect/l:relation/@position">
				<xsl:attribute name="PositionFieldName"><xsl:value-of select="l:editor/l:multiselect/l:relation/@position"/></xsl:attribute>
				<xsl:attribute name="Sortable">true</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="l:editor/l:multiselect/@id">
					<xsl:attribute name="EntityId">@@lt;%# Eval("<xsl:value-of select="l:editor/l:multiselect/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField"><xsl:value-of select="l:editor/l:multiselect/@id"/></xsl:attribute>
				</xsl:when>
				<!--xsl:otherwise>
					<xsl:attribute name="EntityId">@@lt;%# FormView.DataKey.Value %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# FormView.DataKeyNames[0] %@@gt;</xsl:attribute>
				</xsl:otherwise-->
			</xsl:choose>
			
			<xsl:if test="l:editor/l:multiselect/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:multiselect/@width"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:multiselect/@height">
				<xsl:attribute name="Height"><xsl:value-of select="l:editor/l:multiselect/@height"/></xsl:attribute>
			</xsl:if>
		</Plugin:MultiselectEditor>
	</xsl:template>		
	
</xsl:stylesheet>
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
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:wiki="urn:wiki"
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl wiki">

	<xsl:output method='html' />
	
	<xsl:variable name="wikiPageName">DSM_Layout</xsl:variable>
	
	<xsl:template match='/xs:schema'>
		<textarea rows="100" cols="200">= <xsl:apply-templates select="xs:annotation" mode="single-line"/> =
<![CDATA[<wiki:toc max_depth="2" />]]>
		<xsl:apply-templates select="xs:element|xs:group[@name]"/>
		</textarea>
	</xsl:template>

	<xsl:template match="xs:group[@name]">
		<xsl:variable name="groupPrefix">
			<xsl:choose>
				<xsl:when test="xs:annotation"><xsl:apply-templates select="xs:annotation" mode="single-line"/>:</xsl:when>
				<xsl:otherwise><xsl:value-of select="@name"/>:</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates select="xs:choice/xs:element[@name]|xs:sequence/xs:element[@name]">
			<xsl:with-param name="prefix" select="$groupPrefix"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="xs:element[@name]">
		<xsl:param name="prefix"/>
		<xsl:variable name="elemType" select="@type"/>
== <xsl:value-of select="$prefix"/><xsl:value-of select="@name"/> ==
<xsl:apply-templates select="xs:annotation"/>
<xsl:choose>
	<xsl:when test="count(//xs:complexType[@name=$elemType])>0">
		<xsl:apply-templates select="//xs:complexType[@name=$elemType]" mode="doc-attributes"/>
		<xsl:apply-templates select="//xs:complexType[@name=$elemType]" mode="doc-children"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-templates select="xs:complexType" mode="doc-attributes"/>
		<xsl:apply-templates select="xs:complexType" mode="doc-children"/>
	</xsl:otherwise>
</xsl:choose>
<!-- recursive -->
<xsl:apply-templates select="xs:complexType" mode="nested-element">
	<xsl:with-param name="prefix" select="$prefix"/>
</xsl:apply-templates>
----
	</xsl:template>
	
	<xsl:template match="xs:complexType" mode="nested-element">
		<xsl:param name="prefix"/>
		<xsl:for-each select=".//xs:element[@name]">
			<xsl:apply-templates select=".">
				<xsl:with-param name="prefix" select="$prefix"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="xs:annotation">
		<xsl:value-of select="xs:documentation"/>
	</xsl:template>
	<xsl:template match="xs:annotation" mode="single-line">
		<xsl:value-of select="translate( normalize-space(xs:documentation), '&#xA;&#xD;&#x9;', '')"/>
	</xsl:template>

	<xsl:template match="xs:complexType[xs:complexContent]" mode="doc-children">
		<xsl:if test="xs:complexContent/xs:extension">
			<xsl:variable name="extTypeName" select="xs:complexContent/xs:extension/@base"/>
			<xsl:apply-templates select="//xs:complexType[@name=$extTypeName]" mode="doc-children"/>
		</xsl:if>
		<xsl:if test="xs:complexContent/xs:restriction">
			<xsl:variable name="rTypeName" select="xs:complexContent/xs:restriction/@base"/>
			<xsl:apply-templates select="//xs:complexType[@name=$rTypeName]" mode="doc-children"/>
		</xsl:if>
		<xsl:apply-templates select="xs:complexContent/xs:extension/xs:sequence|xs:complexContent/xs:extension/xs:choice" mode="doc-children"/>
	</xsl:template>	
	
	<xsl:template match="xs:complexType" mode="doc-children">
<xsl:if test="xs:sequence|xs:choice">
|| *Child* || *Required* || *Description* ||
<xsl:apply-templates select="xs:sequence|xs:choice" mode="doc-children"/>
</xsl:if>
	</xsl:template>
	
	<xsl:template match="xs:sequence|xs:choice" mode="doc-children">
		<xsl:param name="elemPrefix"/>
<xsl:apply-templates select="xs:element|xs:group" mode="doc-children"><xsl:with-param name="elemPrefix" select="$elemPrefix"/></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="xs:group[@ref]" mode="doc-children">
		<xsl:variable name="grpName" select="@ref"/>
		<xsl:apply-templates select="//xs:group[@name=$grpName]" mode="doc-children"/>
	</xsl:template>

	<xsl:template match="xs:group[@name]" mode="doc-children">
		<xsl:apply-templates select="xs:sequence|xs:choice" mode="doc-children">
			<xsl:with-param name="elemPrefix">
				<xsl:choose>
					<xsl:when test="xs:annotation"><xsl:apply-templates select="xs:annotation" mode="single-line"/>:</xsl:when>
					<xsl:otherwise><xsl:value-of select="@name"/>:</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="xs:group[not(@ref) and not(@name)]" mode="doc-children">
		<xsl:param name="elemPrefix"/>
		<xsl:apply-templates select="xs:sequence|xs:choice" mode="doc-children">
			<xsl:with-param name="elemPrefix" select="$elemPrefix"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="xs:element[@name]" mode="doc-children">
		<xsl:param name="elemPrefix"/>
		<xsl:variable name="required">
			<xsl:choose>
				<xsl:when test="@minOccurs='0' or not(@minOccurs)">No</xsl:when>
				<xsl:otherwise>Yes</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>|| [#<xsl:value-of select="$elemPrefix"/><xsl:value-of select="@name"/><![CDATA[ ]]><xsl:value-of select="@name"/>] ||  <xsl:value-of select="$required"/> ||  <xsl:apply-templates select="xs:annotation" mode="single-line"/> ||
</xsl:template>
	
	<xsl:template match="xs:complexType[xs:complexContent]" mode="doc-attributes">
		<xsl:if test="xs:complexContent/xs:extension">
			<xsl:variable name="extTypeName" select="xs:complexContent/xs:extension/@base"/>
			<xsl:apply-templates select="//xs:complexType[@name=$extTypeName]" mode="doc-attributes"/>
		</xsl:if>
		<xsl:if test="xs:complexContent/xs:restriction">
			<xsl:variable name="rTypeName" select="xs:complexContent/xs:restriction/@base"/>
			<xsl:apply-templates select="//xs:complexType[@name=$rTypeName]" mode="doc-attributes"/>
		</xsl:if>
		<xsl:apply-templates select="xs:complexContent/xs:extension/xs:attribute" mode="doc-attributes"/>
	</xsl:template>
	
	<xsl:template match="xs:complexType" mode="doc-attributes">
<xsl:if test="xs:attribute">
|| *Attribute* || *Type* || Required || *Description* ||
<xsl:apply-templates select="xs:attribute" mode="doc-attributes"/>
</xsl:if>
	</xsl:template>

	<xsl:template match="xs:attribute" mode="doc-attributes">
		<xsl:variable name="required">
			<xsl:choose>
				<xsl:when test="@use='required'">Yes</xsl:when>
				<xsl:otherwise>No</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>|| <xsl:value-of select="@name"/> || <xsl:apply-templates select="." mode="resolve-attr-type"/> || <xsl:value-of select="$required"/> || <xsl:apply-templates select="xs:annotation" mode="single-line"/> ||
</xsl:template>
	
	<xsl:template match="xs:attribute" mode="resolve-attr-type">
<xsl:choose>
	<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
</xsl:choose>	
	</xsl:template>
	
</xsl:stylesheet>
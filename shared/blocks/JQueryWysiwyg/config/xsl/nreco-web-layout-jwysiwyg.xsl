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

	<xsl:template match="l:field[l:editor/l:jwysiwyg]" mode="register-editor-css">
		<link rel="stylesheet" type="text/css" href="css/jwysiwyg/jquery.wysiwyg.css" />
		<link rel="stylesheet" type="text/css" href="css/jwysiwyg/farbtastic.css" />
		<xsl:apply-templates select="l:editor/l:jwysiwyg/l:plugins/node()" mode="register-editor-css"/>
	</xsl:template>	

	<xsl:template match="l:field[l:editor/l:jwysiwyg]" mode="register-editor-control">
		<xsl:param name="instances"/>
		@@lt;%@ Register TagPrefix="Plugin" tagName="JWysiwygEditor" src="~/templates/editors/JWysiwygEditor.ascx" %@@gt;
	
		<xsl:variable name="instancesCopy">
			<xsl:if test="$instances"><xsl:copy-of select="$instances"/></xsl:if>
			<xsl:copy-of select="."/>
		</xsl:variable>		
		<xsl:for-each select="msxsl:node-set($instancesCopy)/l:field/l:editor/l:jwysiwyg/l:plugins/l:*">
			<xsl:variable name="pluginName" select="name()"/>
			<xsl:if test="count(following::l:*[name()=$pluginName])=0">
				<xsl:apply-templates select="." mode="register-jwysiwyg-plugin-control">
					<xsl:with-param name="instances" select="preceding::*[name()=$pluginName]"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:jwysiwyg]" mode="form-view-editor">
		<xsl:param name="mode"/>
		<xsl:variable name="ctrlId">
			<xsl:choose>
				<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>editor<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
		<xsl:variable name="uniqueId"><xsl:value-of select="@name"/>_<xsl:value-of select="$mode"/>_<xsl:value-of select="generate-id(.)"/></xsl:variable>
		
		<Plugin:JWysiwygEditor id="{$ctrlId}" runat="server" xmlns:Plugin="urn:remove">
			<xsl:if test="not(l:editor/l:jwysiwyg/@bind) or l:editor/l:jwysiwyg/@bind='true' or l:editor/l:jwysiwyg/@bind='1'">
				<xsl:attribute name="Text">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
			</xsl:if>		
			<xsl:if test="l:editor/l:jwysiwyg/@rows">
				<xsl:attribute name="Rows"><xsl:value-of select="l:editor/l:jwysiwyg/@rows"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:jwysiwyg/@cols">
				<xsl:attribute name="Columns"><xsl:value-of select="l:editor/l:jwysiwyg/@cols"/></xsl:attribute>
			</xsl:if>	

			<xsl:if test="l:editor/l:jwysiwyg/l:plugins/l:*[@toolbar='createLink']">
				<xsl:attribute name="CustomCreateLinkJsFunction">jwysiwygOpen<xsl:value-of select="$uniqueId"/><xsl:value-of select="generate-id(l:editor/l:jwysiwyg/l:plugins/l:*[@toolbar='createLink'])"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:jwysiwyg/l:plugins/l:*[@toolbar='insertImage']">
				<xsl:attribute name="CustomInsertImageJsFunction">jwysiwygOpen<xsl:value-of select="$uniqueId"/><xsl:value-of select="generate-id(l:editor/l:jwysiwyg/l:plugins/l:*[@toolbar='insertImage'])"/></xsl:attribute>
			</xsl:if>
			
		</Plugin:JWysiwygEditor>
		
		<xsl:for-each select="l:editor/l:jwysiwyg/l:plugins/node()">
			<xsl:apply-templates select="." mode="editor-jwysiwyg-plugin">
				<xsl:with-param name="openJsFunction">jwysiwygOpen<xsl:value-of select="$uniqueId"/><xsl:value-of select="generate-id(.)"/></xsl:with-param>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>		
	
	
	<xsl:template match="l:usercontrol" mode="register-jwysiwyg-plugin-control">
		<xsl:param name="instances"/>
		<xsl:apply-templates select="." mode="register-renderer-control">
			<xsl:with-param name="instances" select="$instances"/>
			<xsl:with-param name="prefix">JWysiwygPlugin</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>	
	
	<xsl:template match="l:usercontrol" mode="editor-jwysiwyg-plugin">
		<xsl:param name="openJsFunction"/>
		<xsl:element name="JWysiwygPlugin:{@name}" xmlns:JWysiwygPlugin="urn:remove" >
			<xsl:attribute name="runat">server</xsl:attribute>
			<xsl:attribute name="OpenJsFunction"><xsl:value-of select="$openJsFunction"/></xsl:attribute>
			<xsl:for-each select="attribute::*">
				<xsl:if test="not(name()='src' or name()='name')">
					<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
				</xsl:if>
			</xsl:for-each>			
		</xsl:element>
	</xsl:template>
	
	
	
</xsl:stylesheet>
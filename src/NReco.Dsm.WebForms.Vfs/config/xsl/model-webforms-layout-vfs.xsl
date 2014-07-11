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


	<xsl:template match="l:field[l:editor/l:file]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="FileEditor" src="~/templates/editors/FileEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:file]" mode="register-editor-code">
		IncludeJsFile("~/Scripts/jquery.iframe-transport.js");
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:file]" mode="form-view-editor">
		<Plugin:FileEditor runat="server" xmlns:Plugin="urn:remove"	id="{@name}"
			FileSystem="{l:editor/l:file/@filesystem}"
			Folder="{l:editor/l:file/@folder}"
		>
			<xsl:if test="l:editor/l:file/l:image/@max-width">
				<xsl:attribute name="ImageMaxWidth">
					<xsl:value-of select="l:editor/l:file/l:image/@max-width"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:file/l:image/@max-height">
				<xsl:attribute name="ImageMaxHeight">
					<xsl:value-of select="l:editor/l:file/l:image/@max-height"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:file/l:image/@format">
				<xsl:attribute name="ImageFormat">
					<xsl:value-of select="l:editor/l:file/l:image/@format"/>
				</xsl:attribute>
			</xsl:if>

			<xsl:attribute name="Text">
				@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;
			</xsl:attribute>

			<xsl:if test="l:editor/l:file/@overwrite='true' or l:editor/l:file/@overwrite='1'">
				<xsl:attribute name="Overwrite">True</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:file/@class">
				<xsl:attribute name="CssClass"><xsl:value-of select="l:editor/l:file/@class"/></xsl:attribute>
			</xsl:if>

		</Plugin:FileEditor>
	</xsl:template>

	<xsl:template match="l:filelink" mode="register-renderer-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="FileLink" src="~/templates/renderers/FileLink.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:filelink" mode="aspnet-renderer">
		<xsl:param name="context"/>
		<xsl:param name="mode"/>
		<xsl:variable name="path">
			<xsl:apply-templates select="l:path/l:*" mode="csharp-expr">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<NRecoWebForms:DataBindHolder runat="server">
			<Plugin:FileLink runat="server" Path="@@lt;%# {$path} %@@gt;" FileSystem="{@filesystem}" xmlns:Plugin="urn:remove"/>
		</NRecoWebForms:DataBindHolder>
	</xsl:template>

	</xsl:stylesheet>
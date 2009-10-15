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

	<xsl:template match="l:field[l:editor/l:markitup]" mode="register-editor-css">
		<link rel="stylesheet" type="text/css" href="js/markitup/skins/simple/style.css" />
		<link rel="stylesheet" type="text/css" href="js/markitup/sets/default/style.css" />
	</xsl:template>
	
	<xsl:template match="l:field[l:editor/l:markitup]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="JQueryMarkItUpEditor" src="~/templates/editors/JQueryMarkItUpEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:markitup]" mode="form-view-editor">
		<Plugin:JQueryMarkItUpEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" Text='@@lt;%# Bind("{@name}") %@@gt;'>
			<xsl:if test="l:editor/l:markitup/@rows">
				<xsl:attribute name="Rows"><xsl:value-of select="l:editor/l:markitup/@rows"/></xsl:attribute>
			</xsl:if>			
		</Plugin:JQueryMarkItUpEditor>
	</xsl:template>
	
</xsl:stylesheet>
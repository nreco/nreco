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
	</xsl:template>	
	<xsl:template match="l:field[l:editor/l:mcdropdown]" mode="register-editor-css">
		<link rel="stylesheet" type="text/css" href="css/mcdropdown/jquery.mcdropdown.css" />
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:mcdropdown]" mode="form-view-editor">
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
	
</xsl:stylesheet>
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
	</xsl:template>	
	<xsl:template match="l:field[l:editor/l:flexbox]" mode="register-editor-css">
		<link rel="stylesheet" type="text/css" href="css/jquery.flexbox.css" />
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:flexbox]" mode="form-view-editor">
		<Plugin:FlexBoxEditor id="{@name}" runat="server" xmlns:Plugin="urn:remove"
			DalcServiceName="{$dalcName}"
			Relex="{l:editor/l:flexbox/l:lookup/@relex}"
			TextFieldName="{l:editor/l:flexbox/l:lookup/@text}"
			ValueFieldName="{l:editor/l:flexbox/l:lookup/@value}"
			Value='@@lt;%# Bind("{@name}") %@@gt;'>
		</Plugin:FlexBoxEditor>
	</xsl:template>		
	
</xsl:stylesheet>
<!--
NReco library (http://nreco.googlecode.com/)
Copyright 2014 Vitaliy Fedorchenko
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


	<xsl:template match="l:field[l:editor/l:summernote]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="SummernoteEditor" src="~/templates/editors/SummernoteEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:summernote]" mode="register-editor-code">
		IncludeJsFile("~/Scripts/summernote.min.js");
		IncludeCssFile("~/css/summernote.css");
		IncludeCssFile(Request.Url.Scheme+"://netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css");
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:summernote]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<xsl:param name="formUid"/>
		<Plugin:SummernoteEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}" ValidationGroup="{$formUid}">
			<xsl:attribute name="Text">@@lt;%# Bind("<xsl:value-of select="@name"/>") %@@gt;</xsl:attribute>
		</Plugin:SummernoteEditor>
	</xsl:template>

</xsl:stylesheet>
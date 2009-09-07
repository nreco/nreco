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

	<xsl:template match="l:jstree" mode="register-renderer-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="JSTree" src="~/templates/renderers/JsTree.ascx" %@@gt;
	</xsl:template>
	
	<xsl:template match="l:jstree" mode="aspnet-renderer">
		<Plugin:JSTree runat="server" xmlns:Plugin="urn:remove" DataProviderName="{@provider}" TextFieldName='title' ValueFieldName='id'/> 
	</xsl:template>
	
	
</xsl:stylesheet>
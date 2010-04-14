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

	<xsl:import href="nreco-web-layout.xsl"/>
	
	<xsl:output method='xml' indent='yes' />
	
	<xsl:variable name="viewDefaults" select="/components/default/view"/>

	<xsl:template match='/components'>
		<files>
			<xsl:apply-templates select="l:views/*" mode="file"/>
		</files>
	</xsl:template>
	
	<xsl:template match="l:view" mode="file">
		<xsl:variable name="fileName">
			<xsl:choose>
				<xsl:when test="$viewDefaults/@filepath"><xsl:value-of select="$viewDefaults/@filepath"/>/<xsl:value-of select="@name"/>.ascx</xsl:when>
				<xsl:otherwise>templates/generated/<xsl:value-of select="@name"/>.ascx</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<file name="{$fileName}">
			<content>
				<xsl:apply-templates select="."/>
			</content>
		</file>		
	</xsl:template>
	
</xsl:stylesheet>
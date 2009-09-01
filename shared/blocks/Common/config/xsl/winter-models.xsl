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
								xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
								xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
								exclude-result-prefixes="msxsl">
	<xsl:import href="nreco.xsl"/>
	<xsl:import href="nreco-web.xsl"/>
	<xsl:import href="nreco-semweb.xsl"/>
	<xsl:import href="nicnet.xsl"/>
	<xsl:import href="nicnet-dalc.xsl"/>
	<xsl:import href="nreco-entity-dalc.xsl"/>
	
	<xsl:import href="web-routing.xsl"/>

	<xsl:output method='xml' indent='yes' />

	<xsl:variable name='default-instance-provider'>serviceProviderContext</xsl:variable>
	<xsl:variable name='default-expression-resolver'>defaultExprResolver</xsl:variable>
	
	<xsl:template match='/'>
		<components>
			<xsl:apply-templates select='/components/node()|/root/components/node()'/>
		</components>
	</xsl:template>
	
	<!-- do not render not matched elements -->
	<xsl:template match="text()"></xsl:template>
	
</xsl:stylesheet>
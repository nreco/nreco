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
	
	<xsl:variable name="googleChartsApiBaseUrl">http://chart.apis.google.com/chart?</xsl:variable>
	
	<xsl:template match="l:googlechart" mode="aspnet-renderer">
		<xsl:param name="mode"/>
		<xsl:param name="context"/>
		<xsl:apply-templates select="l:*" mode="googlechart">
			<xsl:with-param name="mode" select="$mode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:bar|l:pie|l:line" mode="googlechart">
		<xsl:param name="mode"/>
		<xsl:param name="context"></xsl:param>
		<xsl:param name="width">
			<xsl:choose>
				<xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
				<xsl:otherwise>300</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="height">
			<xsl:choose>
				<xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
				<xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
				<xsl:otherwise>300</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="chartType">
			<xsl:choose>
				<xsl:when test="name()='line'">lc</xsl:when>
				<xsl:when test="name()='pie' and count(l:dataset)>1">pc</xsl:when>
				<xsl:when test="name()='pie' and (@type='normal' or not(@type))">p</xsl:when>
				<xsl:when test="name()='pie' and @type='3d'">p3</xsl:when>
				<xsl:when test="name()='bar' and (@type='stacked') and (@orientation='horizontal' or not(@orientation))">bhs</xsl:when>
				<xsl:when test="name()='bar' and (@type='grouped' or not(@type)) and (@orientation='horizontal' or not(@orientation))">bhg</xsl:when>
				<xsl:when test="name()='bar' and (@type='stacked') and (@orientation='vertical')">bvs</xsl:when>
				<xsl:when test="name()='bar' and (@type='grouped' or not(@type)) and (@orientation='vertical')">bvg</xsl:when>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="prvName" select="l:data/@provider"/>
		<xsl:param name="title" select="@title"/>
		<xsl:variable name="uniqueId"><xsl:value-of select="@name"/>_<xsl:value-of select="$mode"/>_<xsl:value-of select="generate-id(.)"/></xsl:variable>
		<xsl:variable name="contextResolved">
			<xsl:choose>
				<xsl:when test="not($context='')"><xsl:value-of select="$context"/></xsl:when>
				<xsl:otherwise>null</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<script language="c#" runat="server">
		protected string googleChart_<xsl:value-of select="$uniqueId"/>(object context) {
			return GoogleChartHelper.PrepareDataUrl("<xsl:value-of select="$prvName"/>", 
				context, 
				new string[] {
					<xsl:for-each select="l:dataset">
						<xsl:if test="position()>1">,</xsl:if>
						"<xsl:value-of select="."/>"
					</xsl:for-each>
				},
				<xsl:choose>
					<xsl:when test="name()='pie'">"chl="</xsl:when>
					<xsl:when test="name()='bar' and (@orientation='horizontal' or not(@orientation))">"chxt=y@@chxl=0:|"</xsl:when>
					<xsl:otherwise>"chxt=x@@chxl=0:|"</xsl:otherwise>
				</xsl:choose>,
				"<xsl:value-of select="l:label"/>",
				"<xsl:value-of select="l:label/@lookup"/>"
			);		
		}
		</script>
		<xsl:variable name="chartParams">
			<xsl:value-of select="$googleChartsApiBaseUrl"/>
			<xsl:if test="not($title='')">chtt=<xsl:value-of select="$title"/>|@@</xsl:if>
			chs=<xsl:value-of select="$width"/>x<xsl:value-of select="$height"/>@@
			cht=<xsl:value-of select="$chartType"/>@@
			<xsl:if test="l:dataset/@color">
				chco=<xsl:for-each select="l:dataset">
					<xsl:if test="position()>1">,</xsl:if>
					<xsl:value-of select="@color"/>
				</xsl:for-each>@@
			</xsl:if>
			<xsl:if test="l:dataset/@legend">
				chdl=<xsl:for-each select="l:dataset">
					<xsl:if test="position()>1">,</xsl:if>
					<xsl:value-of select="@legend"/>
				</xsl:for-each>@@
			</xsl:if>
			@@lt;%# googleChart_<xsl:value-of select="$uniqueId"/>(<xsl:value-of select="$contextResolved"/>) %@@gt;
		</xsl:variable>
		<img class="googlechart" width="{$width}" height="{$height}" alt="{$title}" src="{translate($chartParams, '&#xA;&#xD;&#x9;', '')}"/>
	</xsl:template>
	
</xsl:stylesheet>
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

	<xsl:template match="l:mschart" mode="aspnet-renderer">
		<xsl:param name="mode"/>
		<xsl:apply-templates select="l:*" mode="mschart">
			<xsl:with-param name="mode" select="$mode"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="l:bar|l:pie|l:line" mode="mschart">
		<xsl:param name="mode"/>
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
				<xsl:when test="name()='line'">Line</xsl:when>
				<xsl:when test="name()='pie' and count(l:dataset)>1">Pie</xsl:when>
				<xsl:when test="name()='pie' and (@type='normal' or not(@type))">Pie</xsl:when>
				<xsl:when test="name()='pie' and @type='3d'">Pie</xsl:when>
				<xsl:when test="name()='bar' and (@type='stacked') and (@orientation='horizontal' or not(@orientation))">StackedBar</xsl:when>
				<xsl:when test="name()='bar' and (@type='grouped' or not(@type)) and (@orientation='horizontal' or not(@orientation))">Bar</xsl:when>
				<xsl:when test="name()='bar' and (@type='stacked') and (@orientation='vertical')">StackedColumn</xsl:when>
				<xsl:when test="name()='bar' and (@type='grouped' or not(@type)) and (@orientation='vertical')">Column</xsl:when>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="prvName" select="l:data/@provider"/>
		<xsl:variable name="uniqueId"><xsl:value-of select="@name"/>_<xsl:value-of select="$mode"/>_<xsl:value-of select="generate-id(.)"/></xsl:variable>
		<script language="c#" runat="server">
		protected void mschart_<xsl:value-of select="$uniqueId"/>_onLoad(object sender, EventArgs e) {
			MsChartHelper.BindData(
				(System.Web.UI.DataVisualization.Charting.Chart)sender,
				"<xsl:value-of select="$prvName"/>", null, 
				new string[] {
					<xsl:for-each select="l:dataset">
						<xsl:if test="position()>1">,</xsl:if>
						"<xsl:value-of select="."/>"
					</xsl:for-each>
				},
				"<xsl:value-of select="l:label"/>",
				"<xsl:value-of select="l:label/@lookup"/>"	
			);
		}
		</script>
		<asp:Chart id="{$uniqueId}" runat="server" Width="{@width}" Height="{@height}" OnLoad="mschart_{$uniqueId}_onLoad">
			<series>
				<xsl:for-each select="l:dataset">
					<asp:Series ChartType="{$chartType}">
						<xsl:if test="not(@legend='')">
							<xsl:attribute name="Name"><xsl:value-of select="@legend"/></xsl:attribute>
							<xsl:attribute name="IsVisibleInLegend">true</xsl:attribute>
						</xsl:if>
					</asp:Series>
				</xsl:for-each>
			</series>
			<xsl:if test="l:dataset/@legend">
				<legends>
				  <xsl:for-each select="l:dataset/@legend">
					<asp:Legend Enabled="True"></asp:Legend>
				  </xsl:for-each>
				</legends>
			</xsl:if>
			<chartareas>
				<asp:ChartArea Name="ChartArea1">
					<xsl:if test="contains(@type,'3d')">
						<Area3DStyle Enable3D="True" />
					</xsl:if>
				</asp:ChartArea>
			</chartareas>
		</asp:Chart>

	</xsl:template>
	
	
	<!--xsl:template match="l:chart" mode="aspnet-renderer">
		
		<xsl:variable name="mainDsId">
			<xsl:choose>
				<xsl:when test="@datasource"><xsl:value-of select="@datasource"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="datasources/*[position()=1]/@id"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
    <asp:Chart ID="{@name}" runat="server" Width="{@width}" Height="{@height}" DataSourceID="{$mainDsId}">
      <series>
        <xsl:for-each select="l:series/l:*">
			<asp:Series XValueType="{@value-type}" Name="{@name}" XValueMember="{@x-value}" YValueMembers="{@y-value}"
					ChartType="{@diagram-type}" IsVisibleInLegend="{@isShowLegend}">
          </asp:Series>
        </xsl:for-each>
      </series>
      <xsl:if test="l:legends">
        <legends>
          <xsl:for-each select="l:legends/l:*">
            <asp:Legend Enabled="{@enable}" IsTextAutoFit="{@isTextAutoFit}" Name="{@name}" BackColor="Transparent" Font="Trebuchet MS, 8.25pt, style=Bold"></asp:Legend>
          </xsl:for-each>
        </legends>
      </xsl:if>
      <chartareas>
          <asp:ChartArea Name="ChartArea1">
              <AxisX Title="{l:chartArea/l:axisX/@name}" IsLabelAutoFit="True">
                <xsl:if test="l:label">
                  <LabelStyle Angle="{@angle}" Interval="{@interval}" />
                </xsl:if>
              </AxisX>
            
              <AxisY Title="{l:chartArea/l:axisY/@name}" IsLabelAutoFit="True">
                <xsl:if test="l:label">
                  <LabelStyle Angle="{@angle}" Interval="{@interval}" />
                </xsl:if>
              </AxisY>
            
            <xsl:if test="l:chartArea[(@is3DStyle = 'true' or @is3DStyle = 'yes')]">
              <Area3DStyle Enable3D="True" />
            </xsl:if>
          </asp:ChartArea>
        
      </chartareas>
    </asp:Chart>
	</xsl:template-->
	
</xsl:stylesheet>
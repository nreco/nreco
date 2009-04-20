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
	
	<xsl:template match="l:chart" mode="aspnet-renderer">
		
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
          <asp:ChartArea BackColor="NavajoWhite" BackGradientStyle="LeftRight"
						Name="{@name}" ShadowOffset="5">

						
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
	</xsl:template>
	
</xsl:stylesheet>
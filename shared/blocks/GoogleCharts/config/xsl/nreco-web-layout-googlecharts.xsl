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
		<xsl:param name="title" select="@title"/>
		<xsl:param name="chartType">
			<xsl:choose>
				<xsl:when test="@type='pie'">p</xsl:when>
				<xsl:when test="@type='pie3d'">p3</xsl:when>
				<xsl:when test="@type='horizontalStackedBar'">bhs</xsl:when>
				<xsl:when test="@type='horizontalGroupedBar'">bhg</xsl:when>
				<xsl:when test="@type='verticalStackedBar'">bvs</xsl:when>
				<xsl:when test="@type='verticalGroupedBar'">bvg</xsl:when>
			</xsl:choose>
		</xsl:param>
		<img class="googlechart" width="{$width}" height="{$height}" alt="{$title}">
			<xsl:attribute name="src">
				<xsl:value-of select="$googleChartsApiBaseUrl"/>chs=<xsl:value-of select="$width"/>x<xsl:value-of select="$height"/>@@cht=<xsl:value-of select="$chartType"/>@@chd=t:1,2,3|2,3,4
			</xsl:attribute>
		</img>
	</xsl:template>
	
</xsl:stylesheet>
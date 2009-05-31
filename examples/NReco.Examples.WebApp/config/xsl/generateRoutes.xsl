<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:r="urn:schemas-nreco:web:routing:v1"
				xmlns:l="urn:schemas-nreco:nreco:web:layout:v1"
				exclude-result-prefixes="msxsl">

	<!-- example of how one model can be extended with definitions from another -->
	<xsl:template match="/components/l:views">
		<routes>
			<xsl:apply-templates select="l:*" mode="generate-view-route"/>
		</routes>
	</xsl:template>

	<xsl:template match="l:view[l:updatepanel/l:form or l:form]" mode="generate-view-route">
		<r:route name="New{@name}" handler="sitePageRouteHandler">
			<xsl:attribute name="pattern"><xsl:value-of select="@name"/>.aspx/new</xsl:attribute>
			<r:token key="main">~/templates/generated/<xsl:value-of select="@name"/>.ascx</r:token>
			<r:token key="id">-1</r:token>
		</r:route>
		<r:route name="{@name}" handler="sitePageRouteHandler">
			<xsl:attribute name="pattern"><xsl:value-of select="@name"/>.aspx/{id}</xsl:attribute>
			<r:token key="main">~/templates/generated/<xsl:value-of select="@name"/>.ascx</r:token>
			<r:value key="id"/>
		</r:route>
	</xsl:template>

	<xsl:template match="l:view[l:updatepanel/l:list or l:list]" mode="generate-view-route">
		<r:route name="{@name}" handler="sitePageRouteHandler">
			<xsl:attribute name="pattern"><xsl:value-of select="@name"/>.aspx</xsl:attribute>
			<r:token key="main">~/templates/generated/<xsl:value-of select="@name"/>.ascx</r:token>
		</r:route>
	</xsl:template>
	
	<xsl:template match="l:view" mode="generate-view-route">
		<r:route name="{@name}" handler="sitePageRouteHandler">
			<xsl:attribute name="pattern"><xsl:value-of select="@name"/>.aspx</xsl:attribute>
			<r:token key="main">~/templates/generated/<xsl:value-of select="@name"/>.ascx</r:token>
		</r:route>
	</xsl:template>
	

	<xsl:template match="node()" mode="generate-view-route">
	</xsl:template>

</xsl:stylesheet>
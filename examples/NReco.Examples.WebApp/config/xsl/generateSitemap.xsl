<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:r="urn:schemas-nreco:web:routing:v1"
				xmlns:l="urn:schemas-nreco:nreco:web:layout:v1"
				exclude-result-prefixes="msxsl">

	<!-- example of how one model can be extended with definitions from another -->
	<xsl:template match="/components/l:views">
		<sitemap>
			<siteMapNode title="Generated" roles="*">
				<xsl:apply-templates select="l:*" mode="generate-view-sitemap"/>
			</siteMapNode>
		</sitemap>
	</xsl:template>

	<xsl:template match="l:view[l:updatepanel/l:form or l:form]" mode="generate-view-sitemap">
		<siteMapNode title="New {@caption}" roles="*" url="~/{@name}.aspx/new"/>
	</xsl:template>

	<xsl:template match="l:view[l:updatepanel/l:list or l:list]" mode="generate-view-sitemap">
		<siteMapNode title="{@caption} List" roles="*" url="~/{@name}.aspx"/>
	</xsl:template>

	<xsl:template match="l:view" mode="generate-view-sitemap">
		<siteMapNode title="{@caption}" roles="*" url="~/{@name}.aspx"/>
	</xsl:template>

	<xsl:template match="node()" mode="generate-view-sitemap">
	</xsl:template>

</xsl:stylesheet>
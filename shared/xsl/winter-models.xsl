<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
	<xsl:import href="nreco.xsl"/>
	<xsl:import href="nicnet.xsl"/>
	<xsl:import href="nicnet-dalc.xsl"/>

	<xsl:output method='xml' indent='yes' />

	<xsl:template match='/'>
		<components>
			<xsl:apply-templates select='/components/*|/root/components/*'/>
		</components>
	</xsl:template>
</xsl:stylesheet>
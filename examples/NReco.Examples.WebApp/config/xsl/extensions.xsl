<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:wr="urn:schemas-nreco:nreco:web:v1"
				xmlns:r="urn:schemas-nreco:nreco:core:v1"
				exclude-result-prefixes="msxsl">

<!-- example of how model can be extended with new definitions -->
<xsl:template match="r:set-row">
	<xsl:variable name="model">
		<r:invoke-operation method="set_Item">
			<r:target>
				<r:linq>var["row"]</r:linq>
			</r:target>
			<r:args>
				<r:const value="{@field-name}"/>
				<xsl:copy-of select="node()"/>
			</r:args>
		</r:invoke-operation>
	</xsl:variable>
	<xsl:apply-templates select="msxsl:node-set($model)/node()"/>
</xsl:template>
	
</xsl:stylesheet>
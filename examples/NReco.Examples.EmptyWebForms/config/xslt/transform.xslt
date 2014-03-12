<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
		xmlns:ioc='urn:schemas-nicnet:ioc:v2'
>
    <xsl:output method="xml" indent="yes"/>

		<xsl:template match="/">
			<ioc:components>
				<xsl:apply-templates select="*"/>
			</ioc:components>
	</xsl:template>
	
    <xsl:template match="const">
			<ioc:component name='{@name}' type='NI.Ioc.ReplacingFactory'>
				<ioc:constructor-arg>
					<ioc:value><xsl:value-of select='.'/></ioc:value>
				</ioc:constructor-arg>
		</ioc:component>
    </xsl:template>
</xsl:stylesheet>

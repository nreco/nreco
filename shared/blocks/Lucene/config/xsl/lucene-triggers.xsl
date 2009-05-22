<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:c="urn:schemas-nreco:nreco:lucene:v1"
				xmlns:r="urn:schemas-nreco:nreco:core:v1"
				xmlns:d="urn:schemas-nreco:nicnet:dalc:v1"
				exclude-result-prefixes="msxsl c">
				
	<xsl:template match="/components/c:lucene-index-presets">
    <triggers>
				<xsl:apply-templates select="c:*" mode="generate-index-triggers"/>
		</triggers>
	</xsl:template>

	<xsl:template match="c:preset" mode="generate-index-triggers">
      <d:datarow event="inserted">
        <xsl:attribute name="sourcename">
          <xsl:value-of select="@sourcename"/>
        </xsl:attribute>
        <r:ref>
          <xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_Creating_IndexOperation</xsl:attribute>
        </r:ref>
      </d:datarow>
      <d:datarow event="updating">
        <xsl:attribute name="sourcename">
          <xsl:value-of select="@sourcename"/>
        </xsl:attribute>
        <r:ref>
          <xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_Updating_IndexOperation</xsl:attribute>
        </r:ref>
      </d:datarow>
      <d:datarow event="deleting">
        <xsl:attribute name="sourcename">
          <xsl:value-of select="@sourcename"/>
        </xsl:attribute>
        <r:ref>
          <xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_Deleting_IndexOperation</xsl:attribute>
        </r:ref>
      </d:datarow>
	</xsl:template>
	
	<xsl:template match="node()" mode="generate-index-triggers">
	</xsl:template>

</xsl:stylesheet>
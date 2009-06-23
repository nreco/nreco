<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:c="urn:schemas-nreco:nreco:lucene:v1"
				xmlns:r="urn:schemas-nreco:nreco:core:v1"
				xmlns:d="urn:schemas-nreco:nicnet:dalc:v1"
				exclude-result-prefixes="msxsl c">

	<xsl:template match="c:lucene-index-presets">
    <xsl:call-template name="component-definition">
      <xsl:with-param name="name">luceneConfiguration</xsl:with-param>
      <xsl:with-param name="type">NReco.Lucene.LuceneConfiguration,NReco.Lucene</xsl:with-param>
      <xsl:with-param name="injections">
        <property name="IndexPath">
          <value><xsl:choose>
              <xsl:when test="@path">
                <xsl:value-of select="@path"/>
              </xsl:when>
              <xsl:when test="path">
                <xsl:copy-of select="path"/>
              </xsl:when>
            </xsl:choose></value>
        </property>
      </xsl:with-param>
    </xsl:call-template>  
    
		  <xsl:apply-templates select="c:*" mode="generate-columns-lookups"/>
	
			<xsl:apply-templates select="c:*" mode="generate-index-triggers-operations"/>
		
			<xsl:apply-templates select="c:*" mode="generate-lucene-operations"/>
	</xsl:template>

	<xsl:template match="c:preset" mode="generate-columns-lookups">
    <xsl:variable name="columnsLookup">
      <r:name-value>
        <xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_IndexColumnsLookup</xsl:attribute>
        <xsl:for-each select='c:*'>
          <r:entry>
            <xsl:attribute name="key">
              <xsl:value-of select="@name"/>
            </xsl:attribute>
            <xsl:apply-templates select="c:*" mode="generate-columns-parameters"/>
          </r:entry>
        </xsl:for-each>
      </r:name-value>
    </xsl:variable>
    <xsl:apply-templates select="msxsl:node-set($columnsLookup)/r:*" />
  </xsl:template>
	
	<xsl:template match="c:index-parameters" mode="generate-columns-parameters">
		<r:name-value>
			<xsl:for-each select='c:*'>
			  <r:entry>
				<xsl:attribute name="key">
				  <xsl:value-of select="@name"/>
				</xsl:attribute>
				<xsl:value-of select="@value"/>
			  </r:entry>
			</xsl:for-each>
		</r:name-value>
	</xsl:template>
  
	<xsl:template match="c:preset" mode="generate-lucene-operations">
		<xsl:variable name="contentProvider">
		<r:provider>
			<xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_ContentProvider</xsl:attribute>
			<r:dalc result="recordlist">
				<xsl:attribute name="from">
					<xsl:choose>
						<xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
						<xsl:otherwise>db</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<r:query>
					<xsl:value-of select="@datasource"/>
					(
					  1="1"
					)
					[
					<xsl:for-each select='c:*'>
						<xsl:value-of select="@name"/><xsl:if test="position()!=last() and position()!=0">,</xsl:if>
					</xsl:for-each>
					]
				</r:query>
			</r:dalc>
		</r:provider>
		</xsl:variable>
		<xsl:apply-templates select="msxsl:node-set($contentProvider)/node()" />
	</xsl:template>

	<xsl:template match="c:preset" mode="generate-index-triggers-operations">
    <xsl:call-template name="component-definition">
        <xsl:with-param name="name">lucene_<xsl:value-of select="@sourcename"/>_Creating_IndexOperation</xsl:with-param>
      <xsl:with-param name="type">NReco.Lucene.LuceneIndexOperation,NReco.Lucene</xsl:with-param>
       <xsl:with-param name="injections">
         <property name="ColumnsInfoProvider">
           <ref><xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_IndexColumnsLookup</xsl:attribute></ref>
         </property>
         <property name="CurrentOperationType">
           <value>create</value>
         </property>
         <property name="IndexDir"><value><xsl:value-of select="@sourcename"/>\</value></property>
		     <property name="IndexType"><value>auto</value></property>
         <property name="IndexConfiguration">
           <ref name="luceneConfiguration"/>
         </property>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="component-definition">
      <xsl:with-param name="name">lucene_<xsl:value-of select="@sourcename"/>_Updating_IndexOperation</xsl:with-param>
      <xsl:with-param name="type">NReco.Lucene.LuceneIndexOperation,NReco.Lucene</xsl:with-param>
      <xsl:with-param name="injections">
        <property name="ColumnsInfoProvider">
          <ref><xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_IndexColumnsLookup</xsl:attribute></ref>
        </property>
        <property name="CurrentOperationType">
          <value>update</value>
        </property>
        <property name="IndexDir">
          <value><xsl:value-of select="@sourcename"/>\</value>
        </property>
		    <property name="IndexType"><value>auto</value></property>
        <property name="IndexConfiguration">
          <ref name="luceneConfiguration"/>
        </property>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="component-definition">
      <xsl:with-param name="name">lucene_<xsl:value-of select="@sourcename"/>_Deleting_IndexOperation</xsl:with-param>
      <xsl:with-param name="type">NReco.Lucene.LuceneIndexOperation,NReco.Lucene</xsl:with-param>
      <xsl:with-param name="injections">
        <property name="ColumnsInfoProvider">
          <ref><xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_IndexColumnsLookup</xsl:attribute></ref>
        </property>
        <property name="CurrentOperationType">
          <value>delete</value>
        </property>
        <property name="IndexDir"><value><xsl:value-of select="@sourcename"/>\</value>
        </property>
        <property name="IndexConfiguration">
          <ref name="luceneConfiguration"/>
        </property>
		    <property name="IndexType"><value>auto</value></property>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="component-definition">
      <xsl:with-param name="name">lucene_<xsl:value-of select="@sourcename"/>_Full_IndexOperation</xsl:with-param>
      <xsl:with-param name="type">NReco.Lucene.LuceneIndexOperation,NReco.Lucene</xsl:with-param>
      <xsl:with-param name="injections">
        <property name="IndexingContentProvider">
          <ref><xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_ContentProvider</xsl:attribute></ref>
        </property>
        <property name="ColumnsInfoProvider">
          <ref><xsl:attribute name="name">lucene_<xsl:value-of select="@sourcename"/>_IndexColumnsLookup</xsl:attribute></ref>
        </property>
        <property name="IndexDir">
          <value><xsl:value-of select="@sourcename"/>\</value>
        </property>
        <property name="IndexConfiguration">
          <ref name="luceneConfiguration"/>
        </property>
        <property name="IndexType">
          <value>full</value>
        </property>
      </xsl:with-param>
    </xsl:call-template>
	</xsl:template>
  
</xsl:stylesheet>
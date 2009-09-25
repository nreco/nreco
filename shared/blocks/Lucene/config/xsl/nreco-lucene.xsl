<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:l="urn:schemas-nreco:nreco:lucene:v1"
				xmlns:r="urn:schemas-nreco:nreco:core:v1"
				xmlns:d="urn:schemas-nreco:nicnet:dalc:v1"
				exclude-result-prefixes="msxsl l">

	<xsl:template match="l:index">
		<xsl:variable name="indexName" select="@name"/>
		<xsl:variable name="indexDir">
			<xsl:choose>
				<xsl:when test="@location"><value><xsl:value-of select="@location"/></value></xsl:when>
				<xsl:when test="l:location/text()"><value><xsl:value-of select="l:location"/></value></xsl:when>
				<xsl:when test="l:location/node()"><xsl:apply-templates select="l:location/node()"/></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<!-- index factory -->
		<xsl:call-template name="component-definition">
		  <xsl:with-param name="name"><xsl:value-of select="$indexName"/>LuceneFactory</xsl:with-param>
		  <xsl:with-param name="type">NReco.Lucene.LuceneFactory,NReco.Lucene</xsl:with-param>
		  <xsl:with-param name="injections">
			<property name="IndexDir"><xsl:copy-of select="msxsl:node-set($indexDir)/node()"/></property>
			<xsl:if test="l:analyzer">
				<property name="Analyzer">
					<xsl:apply-templates select="l:analyzer/l:*" mode="lucene-analyzer"/>
				</property>
			</xsl:if>
		  </xsl:with-param>
		</xsl:call-template> 

		<!-- index factory -->
		<xsl:call-template name="component-definition">
		  <xsl:with-param name="name"><xsl:value-of select="$indexName"/>SearchManager</xsl:with-param>
		  <xsl:with-param name="type">NReco.Lucene.SearchManager,NReco.Lucene</xsl:with-param>
		  <xsl:with-param name="injections">
			<property name="Factory"><ref name="{$indexName}LuceneFactory"/></property>
			<property name="DefaultSearchFields">
				<xsl:variable name="allFields"><xsl:copy-of select="l:document/l:field"/></xsl:variable>
				<list>
					<xsl:for-each select="msxsl:node-set($allFields)/l:field">
						<xsl:variable name="fldName" select="@name"/>
						<xsl:if test="not(preceding::field[@name=$fldName])">
							<entry><value><xsl:value-of select="$fldName"/></value></entry>
						</xsl:if>
					</xsl:for-each>
				</list>
			</property>
		  </xsl:with-param>
		</xsl:call-template> 	
		
		<!-- transaction manager -->
		<xsl:call-template name="component-definition">
		  <xsl:with-param name="name"><xsl:value-of select="$indexName"/>LuceneTransactionManager</xsl:with-param>
		  <xsl:with-param name="type">NReco.Lucene.TransactionManager,NReco.Lucene</xsl:with-param>
		  <xsl:with-param name="injections">
			<property name="Factories"><list><entry><ref name="{$indexName}LuceneFactory"/></entry></list></property>
		  </xsl:with-param>
		</xsl:call-template>
		
		<!-- document composers -->
		<xsl:apply-templates select="l:document" mode="lucene-document-composer">
			<xsl:with-param name="indexName" select="$indexName"/>
		</xsl:apply-templates>
		
		<!-- indexers -->
		<xsl:apply-templates select="l:indexers/l:*" mode="lucene-indexer">
			<xsl:with-param name="indexName" select="$indexName"/>
		</xsl:apply-templates>
		
		<xsl:apply-templates select="l:indexers/l:*" mode="lucene-mass-indexer">
			<xsl:with-param name="indexName" select="$indexName"/>
		</xsl:apply-templates>		
		
		<!-- reindex operation -->
		<xsl:variable name="fullReindexDsl">
			<r:operation name="{$indexName}LuceneReindexOperation">
				<r:chain>
					<!-- 1. remove old index (if exists) -->
					<r:execute>
						<r:target>
							<r:invoke method="Clear" target="{$indexName}LuceneFactory"/>
						</r:target>
					</r:execute>
					<!-- 2. run all re-indexers -->
					<xsl:for-each select="l:indexers/l:*">
						<r:execute>
							<xsl:attribute name="target"><xsl:apply-templates select="." mode="lucene-mass-indexer-name"><xsl:with-param name="indexName" select="$indexName"/></xsl:apply-templates></xsl:attribute>
						</r:execute>
					</xsl:for-each>
				</r:chain>
			</r:operation>
		</xsl:variable>
		<xsl:apply-templates select="msxsl:node-set($fullReindexDsl)/node()"/>
		
	</xsl:template>
	
	<xsl:template match="l:snowball" mode="lucene-analyzer">
		<component type="Lucene.Net.Analysis.Snowball.SnowballAnalyzer,Snowball.Net" singleton="false">
			<constructor-arg index='0'>
				<value><xsl:value-of select="@language"/></value>
			</constructor-arg>
			<xsl:if test="l:stopword">
				<constructor-arg index='1'>
					<list>
						<xsl:for-each select="l:stopword">
							<entry><value><xsl:value-of select="."/></value></entry>
						</xsl:for-each>
					</list>
					<value><xsl:value-of select="@language"/></value>
				</constructor-arg>
			</xsl:if>
		</component>
	</xsl:template>
			
	<xsl:template match="l:datarow" mode="lucene-mass-indexer-name"><xsl:param name="indexName"/><xsl:value-of select="$indexName"/>_<xsl:value-of select="@sourcename"/>_MassIndexer</xsl:template>

	<xsl:template match="l:datarow" mode="lucene-mass-indexer">
		<xsl:param name="indexName"/>
		
		<xsl:call-template name="component-definition">
		  <xsl:with-param name="name"><xsl:value-of select="$indexName"/>_<xsl:value-of select="@sourcename"/>_MassIndexer</xsl:with-param>
		  <xsl:with-param name="type">NReco.Lucene.DalcMassIndexer,NReco.Lucene</xsl:with-param>
		  <xsl:with-param name="injections">
			<property name="Dalc"><ref name="{@dalc}"/></property>
			<property name="Indexer"><ref name="{$indexName}_{@sourcename}_Indexer"/></property>
			<property name="Transaction"><ref name="{$indexName}LuceneTransactionManager"/></property>
			<property name="SourceName"><value><xsl:value-of select="@sourcename"/></value></property>
		  </xsl:with-param>
		</xsl:call-template>
	</xsl:template>
			
	<xsl:template match="l:datarow" mode="lucene-indexer">
		<xsl:param name="indexName"/>
		
		<xsl:call-template name="component-definition">
		  <xsl:with-param name="name"><xsl:value-of select="$indexName"/>_<xsl:value-of select="@sourcename"/>_Indexer</xsl:with-param>
		  <xsl:with-param name="type">NReco.Lucene.DataRowIndexer,NReco.Lucene</xsl:with-param>
		  <xsl:with-param name="injections">
			<property name="IndexWriterProvider"><ref name="{$indexName}LuceneFactory"/></property>
			<property name="DocumentProviders">
				<list>
					<xsl:for-each select="l:update">
						<entry>
							<xsl:choose>
								<xsl:when test="l:context">
									<component type="NReco.Composition.ProviderCall" singleton="false">
										<property name="Provider"><ref name="{$indexName}_{@document}_DocumentComposer"/></property>
										<property name="ContextFilter">
											<xsl:choose>
												<xsl:when test="l:context/@provider"><ref name="l:context/@provider"/></xsl:when>
												<xsl:when test="l:context/node()">
													<xsl:apply-templates select="l:context/node()"/>
												</xsl:when>
												<xsl:otherwise><xsl:message terminate="yes">DataRowIndexer document context provider must be defined.</xsl:message></xsl:otherwise>
											</xsl:choose>
										</property>
									</component>
									<!-- TBD - extra context -->
								</xsl:when>
								<xsl:otherwise>
									<ref name="{$indexName}_{@document}_DocumentComposer"/>
								</xsl:otherwise>
							</xsl:choose>
						</entry>
					</xsl:for-each>
				</list>
			</property>
		  </xsl:with-param>
		</xsl:call-template>		
		
	</xsl:template>

	<xsl:template match="l:document" mode="lucene-document-composer">
		<xsl:param name="indexName"/>
		<xsl:call-template name="component-definition">
		  <xsl:with-param name="name"><xsl:value-of select="$indexName"/>_<xsl:value-of select="@name"/>_DocumentComposer</xsl:with-param>
		  <xsl:with-param name="type">NReco.Lucene.DocumentComposer,NReco.Lucene</xsl:with-param>
		  <xsl:with-param name="injections">
			<property name="UidProvider">
				<xsl:call-template name="ognl-provider">
					<xsl:with-param name="name"></xsl:with-param>
					<xsl:with-param name="code"><xsl:value-of select="l:uid"/></xsl:with-param>
				</xsl:call-template>
			</property>
			<property name="Fields">
				<list>
					<xsl:for-each select="l:field">
						<entry>
							<xsl:apply-templates select="." mode="lucene-document-field"/>
						</entry>
					</xsl:for-each>
				</list>
			</property>
		  </xsl:with-param>
		</xsl:call-template>  
	</xsl:template>
    
	<xsl:template match="l:field" mode="lucene-document-field">
		<xsl:call-template name="component-definition">
		  <xsl:with-param name="name"></xsl:with-param>
		  <xsl:with-param name="type">NReco.Lucene.DocumentComposer+FieldDescriptor,NReco.Lucene</xsl:with-param>
		  <xsl:with-param name="injections">
			<property name="Name"><value><xsl:value-of select="@name"/></value></property>
			<property name="Store">
				<value>
					<xsl:choose>
						<xsl:when test="@store='0' or @store='false'">false</xsl:when>
						<xsl:otherwise>true</xsl:otherwise>
					</xsl:choose>
				</value>
			</property>
			<property name="Compress">
				<value>
					<xsl:choose>
						<xsl:when test="@compress='1' or @store='true'">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</value>
			</property>			
			<property name="Index">
				<value>
					<xsl:choose>
						<xsl:when test="@index='0' or @index='false'">false</xsl:when>
						<xsl:otherwise>true</xsl:otherwise>
					</xsl:choose>
				</value>
			</property>
			<property name="Analyze">
				<value>
					<xsl:choose>
						<xsl:when test="@analyze='0' or @analyze='false'">false</xsl:when>
						<xsl:otherwise>true</xsl:otherwise>
					</xsl:choose>
				</value>
			</property>
			<property name="Normalize">
				<value>
					<xsl:choose>
						<xsl:when test="@normalize='0' or @normalize='false'">false</xsl:when>
						<xsl:otherwise>true</xsl:otherwise>
					</xsl:choose>
				</value>
			</property>
			<property name="Provider">
				<xsl:call-template name="ognl-provider">
					<xsl:with-param name="name"></xsl:with-param>
					<xsl:with-param name="code"><xsl:value-of select="."/></xsl:with-param>
				</xsl:call-template>
			</property>
			<xsl:if test="@boost">
				<property name="Boost"><value><xsl:value-of select="@boost"/></value></property>
			</xsl:if>
		  </xsl:with-param>
		</xsl:call-template>		
	</xsl:template>
	
  
	<xsl:template match="d:lucene-dalc-triggers" mode="db-dalc-trigger">
		<xsl:param name="eventsMediatorName"/>
		<xsl:param name="namePrefix"/>
		<xsl:variable name="dalcModel">
			<xsl:for-each select="l:index">
				<xsl:apply-templates select="l:indexers/l:datarow" mode="generate-lucene-dalc-triggers">
					<xsl:with-param name="indexName" select="@name"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:variable>
		<xsl:apply-templates select="msxsl:node-set($dalcModel)/node()" mode="db-dalc-trigger">
			<xsl:with-param name="eventsMediatorName" select="$eventsMediatorName"/>
			<xsl:with-param name="namePrefix" select="$namePrefix"/>
		</xsl:apply-templates>
	</xsl:template>
  
	<xsl:template match="l:datarow" mode="generate-lucene-dalc-triggers">
		<xsl:param name="indexName"/>
			<d:datarow event="inserted" sourcename="{@sourcename}">
				<r:operation>
					<r:chain>
						<r:execute>
							<r:target>
								<r:invoke method="Add" target="{$indexName}_{@sourcename}_Indexer">
									<r:args>
										<r:ognl>#row</r:ognl>
									</r:args>
								</r:invoke>
							</r:target>
						</r:execute>
					</r:chain>
				</r:operation>	  
			</d:datarow>
			
			<d:datarow event="updated" sourcename="{@sourcename}">
				<r:operation>
					<r:chain>
						<r:execute>
							<r:target>
								<r:invoke method="Update" target="{$indexName}_{@sourcename}_Indexer">
									<r:args>
										<r:ognl>#row</r:ognl>
									</r:args>
								</r:invoke>
							</r:target>
						</r:execute>
					</r:chain>
				</r:operation>	  
			</d:datarow>
			
			<d:datarow event="deleted" sourcename="{@sourcename}">
				<r:operation>
					<r:chain>
						<r:execute>
							<r:target>
								<r:invoke method="Delete" target="{$indexName}_{@sourcename}_Indexer">
									<r:args>
										<r:ognl>#row</r:ognl>
									</r:args>
								</r:invoke>
							</r:target>
						</r:execute>
					</r:chain>
				</r:operation>	  
			</d:datarow>			
		  
	</xsl:template>
  
  
  
</xsl:stylesheet>
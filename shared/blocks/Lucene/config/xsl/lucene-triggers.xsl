<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:l="urn:schemas-nreco:nreco:lucene:v1"
				xmlns:r="urn:schemas-nreco:nreco:core:v1"
				xmlns:d="urn:schemas-nreco:nicnet:dalc:v1"
				exclude-result-prefixes="msxsl l">
				
	<xsl:template match="/components/l:index">
		<triggers>
			<xsl:apply-templates select="l:indexers/l:datarow" mode="generate-index-triggers">
				<xsl:with-param name="indexName" select="@name"/>
			</xsl:apply-templates>
		</triggers>
	</xsl:template>

	<xsl:template match="l:datarow" mode="generate-index-triggers">
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
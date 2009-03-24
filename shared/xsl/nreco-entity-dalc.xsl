<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:wr="urn:schemas-nreco:nreco:web:v1"
				xmlns:nr="urn:schemas-nreco:nreco:core:v1"
				xmlns:e="urn:schemas-nreco:nreco:entity:v1"
				exclude-result-prefixes="msxsl">

<xsl:template match="e:entity-create-sql">
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Winter.ReplacingFactory</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="TargetObject">
				<value>
					<xsl:apply-templates select="e:entity" mode="generate-mssql-create-sql"/>
				</value>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
				
<xsl:template match='e:entity' mode="generate-mssql-create-sql">
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Entity name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
IF OBJECT_ID('<xsl:value-of select="$name"/>','U') IS NULL
	BEGIN
		CREATE TABLE <xsl:value-of select="$name"/> (
			<xsl:for-each select="e:field">
				<xsl:if test="position()!=1">,</xsl:if>
				<xsl:variable name="fldSql">
					<xsl:apply-templates select="." mode="generate-mssql-create-sql"/>
				</xsl:variable>
				<xsl:value-of select="normalize-space($fldSql)"/>
			</xsl:for-each>
			<xsl:variable name="pkNames">
				<xsl:for-each select="e:field[@pk='true']">
					<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="count(e:field)>0">,
			CONSTRAINT [<xsl:value-of select="$name"/>_PK] PRIMARY KEY ( <xsl:value-of select="normalize-space($pkNames)"/> )
			</xsl:if>
		)
	END	

</xsl:template>

<xsl:template match="e:field" mode="generate-mssql-create-sql">
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Field name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="maxLength">
		<xsl:choose>
			<xsl:when test="@maxlength"><xsl:value-of select="@maxlength"/></xsl:when>
			<xsl:otherwise>50</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="defaultValue">
		<xsl:choose>
			<xsl:when test="@default='true' and (@type='bool' or @type='boolean')">1</xsl:when>
			<xsl:when test="@default='false' and (@type='bool' or @type='boolean')">0</xsl:when>
			<xsl:when test="@default"><xsl:value-of select="@default"/></xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:value-of select="$name"/><xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="@type='string'">nvarchar(<xsl:value-of select="$maxLength"/>)</xsl:when>
		<xsl:when test="@type='text'">ntext</xsl:when>
		<xsl:when test="@type='datetime'">DATETIME</xsl:when>
		<xsl:when test="@type='bool' or @type='boolean'">bit</xsl:when>
		<xsl:when test="@type='int' or @type='integer' or @type='autoincrement'">int</xsl:when>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="@nullable='true' or @nullable='1'">NULL</xsl:when>
		<xsl:otherwise>NOT NULL</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:if test="@type='autoincrement'">IDENTITY(1,1)</xsl:if>
	<xsl:text> </xsl:text>
	<xsl:if test="@default">DEFAULT '<xsl:value-of select="$defaultValue"/>'</xsl:if>
	<xsl:text> </xsl:text>
</xsl:template>

</xsl:stylesheet>
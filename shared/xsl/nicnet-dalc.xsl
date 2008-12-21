<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:template match='db-dalc'>
	<xsl:param name="dalcName">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">DB DALC name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="permissionsEnabled">
		<xsl:choose>
			<xsl:when test="permissions">True</xsl:when>
			<xsl:otherwise>False</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<!-- calc vars -->
	<xsl:variable name="dbDalcName">
		<xsl:choose>
			<xsl:when test="$permissionsEnabled='True'">original<xsl:value-of select="$dalcName"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$dalcName"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="dataviewsEnabled">
		<xsl:choose>
			<xsl:when test="count(dataviews/*)>0">True</xsl:when>
			<xsl:otherwise>False</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:apply-templates select="driver/*" mode="db-dalc-driver">
		<xsl:with-param name="dalcName" select="$dalcName"/>
	</xsl:apply-templates>
	
	<!-- define DB dalc -->
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$dbDalcName'/>
		<xsl:with-param name='type'>NI.Data.Dalc.DbDalc,NI.Data.Dalc</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="AdapterWrapperFactory"><ref name="{$dalcName}-DalcFactory"/></property>
			<property name="Connection"><ref name="{$dalcName}-DalcConnection"/></property>
			<property name="CommandGenerator"><ref name="{$dalcName}-DalcCommandGenerator"/></property>
			<property name="DbDalcEventsMediator"><ref name="{$dalcName}-DalcEventsMediator"/></property>
		</xsl:with-param>
	</xsl:call-template>
	
	<!-- permissions wrapper -->
	<xsl:if test="$permissionsEnabled='True'">
		<xsl:call-template name='component-definition'>
			<xsl:with-param name='name' select='$dalcName'/>
			<xsl:with-param name='type'>NI.Data.Dalc.Permissions.DbDalcProxy</xsl:with-param>
			<xsl:with-param name='injections'>
				<property name="UnderlyingDbDalc"><ref name="{$dbDalcName}"/></property>
				<property name="DalcConditionComposer"><ref name="{$dalcName}-DalcPermissionConditionComposer"/></property>
				<property name="PermissionChecker"><ref name="{$dalcName}-DalcPermissionChecker"/></property>
			</xsl:with-param>
		</xsl:call-template>
		<!-- checker -->
		<xsl:call-template name='component-definition'>
			<xsl:with-param name='name'><xsl:value-of select="$dalcName"/>-DalcPermissionChecker</xsl:with-param>
			<xsl:with-param name='type'>NI.Data.Dalc.Permissions.DalcPermissionChecker</xsl:with-param>
			<xsl:with-param name='injections'>
				<property name="OriginalDalc"><ref name="{$dbDalcName}"/></property>
				<property name="DenyAclEntries">
					<list>
						<!--TBD-->
					</list>
				</property>				
			</xsl:with-param>
		</xsl:call-template>
		<!-- composer -->
		<xsl:call-template name='component-definition'>
			<xsl:with-param name='name'><xsl:value-of select="$dalcName"/>-DalcPermissionConditionComposer</xsl:with-param>
			<xsl:with-param name='type'>NI.Data.Dalc.Permissions.DalcConditionComposer</xsl:with-param>
			<xsl:with-param name='injections'>
				<property name="ConditionDescriptors">
					<list>
						<!--{{aclDalcConditionComposer-ConditionDescriptors}}-->
					</list>
				</property>				
			</xsl:with-param>
		</xsl:call-template>		
	</xsl:if>
	
	<component name="{$dalcName}-DalcEventsMediator" type="NI.Data.Dalc.DbDalcEventsMediator,NI.Data.Dalc" singleton="true"/>
	
	<xsl:if test="not(dataviews/@resolver)">
		<xsl:variable name="defaultDataViewResolver">
			<template-expr-resolver name="{$dalcName}-DalcDataViewDefaultExprResolver">
				<variable prefix="var"/>
			</template-expr-resolver>
		</xsl:variable>
		<xsl:apply-templates select="msxsl:node-set($defaultDataViewResolver)/*"/>
	</xsl:if>
	
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'><xsl:value-of select="$dalcName"/>-DalcCommandGenerator</xsl:with-param>
		<xsl:with-param name='type'>
			<xsl:choose>
				<xsl:when test="$permissionsEnabled='True'">NI.Data.Dalc.Permissions.DbDataViewCommandGenerator</xsl:when>
				<xsl:when test="$dataviewsEnabled='True'">NI.Data.Dalc.DbDataViewCommandGenerator</xsl:when>
				<xsl:otherwise>NI.Data.Dalc.DbCommandGenerator</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="CommandWrapperFactory"><ref name="{$dalcName}-DalcFactory"/></property>
			<xsl:if test="$dataviewsEnabled='True'">
				<property name="DataViews">
					<list>
						<xsl:variable name="exprResolverName">
							<xsl:choose>
								<xsl:when test="dataviews/@resolver"><xsl:value-of select="dataviews/@resolver"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$dalcName"/>-DalcDataViewDefaultExprResolver</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:for-each select="dataviews/*">
							<entry>
								<xsl:apply-templates select="." mode="db-dalc-dataview">
									<xsl:with-param name="defaultExprResolverName" select="$exprResolverName"/>
								</xsl:apply-templates>
							</entry>
						</xsl:for-each>
					</list>
				</property>
			</xsl:if>
			<xsl:if test="$permissionsEnabled='True'">
				<property name="DalcConditionComposer"><ref name="{$dalcName}-DalcConditionComposer"/></property>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>	
	
</xsl:template>

<xsl:template match="view" mode="db-dalc-dataview">
	<xsl:param name="viewAlias">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:when test="name"><xsl:value-of select="name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">DB Data View name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="viewOriginInfo">
		<xsl:choose>
			<xsl:when test="@origin"><xsl:value-of select="@origin"/></xsl:when>
			<xsl:when test="count(origin/sourcename)>0">
				<xsl:for-each select="origin/sourcename"><xsl:if test="position()>1">,</xsl:if><xsl:apply-templates select="." mode="db-dalc-dataview-origin-entry"/></xsl:for-each>
			</xsl:when>
			<xsl:when test="origin"><xsl:value-of select="origin"/></xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="fieldsCount">
		<xsl:choose>
			<xsl:when test="fields/count"><xsl:value-of select="fields/count"/></xsl:when>
			<xsl:otherwise>count(*)</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="fields">
		<xsl:choose>
			<xsl:when test="fields/select"><xsl:value-of select="fields/select"/></xsl:when>
			<xsl:otherwise>*</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="sql">
		<xsl:choose>
			<xsl:when test="@sql"><xsl:value-of select="@sql"/></xsl:when>
			<xsl:when test="sql"><xsl:value-of select="sql"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">SQL Text is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="defaultExprResolverName"/>
	<xsl:variable name="exprResolver">
		<xsl:choose>
			<xsl:when test="@resolver"><ref name="{@resolver}"/></xsl:when>
			<xsl:otherwise><ref name="{$defaultExprResolverName}"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'/>
		<xsl:with-param name='type'>NI.Data.Dalc.DbDataView</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="SourceNameAlias"><value><xsl:value-of select="$viewAlias"/></value></property>
			<property name="SourceNameOrigin"><value><xsl:value-of select="$viewOriginInfo"/></value></property>
			<property name="SqlCountFields"><value><xsl:value-of select="$fieldsCount"/></value></property>
			<property name="SqlFields"><value><xsl:value-of select="$fields"/></value></property>
			<property name="SqlCommandTextTemplate">
				<value><xsl:value-of select="$sql"/></value>
			</property>
			<property name="ExprResolver"><xsl:copy-of select="msxsl:node-set($exprResolver)/*"/></property>
			<xsl:if test="fields/mapping">
				<property name="FieldsMapping">
					<map>
						<xsl:for-each select="fields/mapping/field">
							<entry key="{@name}"><value><xsl:value-of select="."/></value></entry>
						</xsl:for-each>
					</map>
				</property>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="sourcename" mode="db-dalc-dataview-origin-entry">
<xsl:value-of select="."/><xsl:if test="@alias"><![CDATA[ ]]><xsl:value-of select="@alias"/></xsl:if>
</xsl:template>

<xsl:template match="mssql" mode="db-dalc-driver">
	<xsl:param name="dalcName"/>
	<xsl:param name="connectionString">
		<xsl:choose>
			<xsl:when test="connection/@string"><xsl:value-of select="connection/@string"/></xsl:when>
			<xsl:when test="connection/string"><xsl:value-of select="connection/string"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">MSSQL connection string (mssql/connection/string) is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<component name="{$dalcName}-DalcFactory" type="NI.Data.Dalc.SqlClient.SqlFactory,NI.Data.Dalc" singleton="true" lazy-init="true"/>
	<component name="{$dalcName}-DalcConnection" type="System.Data.SqlClient.SqlConnection,System.Data" singleton="true" lazy-init="true">
		<property name="ConnectionString"><value><xsl:value-of select="$connectionString"/></value></property>
	</component>
</xsl:template>

</xsl:stylesheet>
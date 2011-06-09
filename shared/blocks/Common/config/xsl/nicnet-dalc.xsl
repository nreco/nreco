<!--
NReco library (http://nreco.googlecode.com/)
Copyright 2008,2009 Vitaliy Fedorchenko
Distributed under the LGPL licence
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->	
<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:nnd="urn:schemas-nreco:nicnet:dalc:v1"
				xmlns:nc="urn:schemas-nreco:nicnet:common:v1"
				xmlns:nr="urn:schemas-nreco:nreco:core:v1"
				exclude-result-prefixes="nnd nr msxsl">
	<!--xmlns="http://www.nicnet.org/WinterConfiguration/v1.0"-->
<xsl:output method='xml' indent='yes' />


	<!-- DB Data Access Layer Components set -->
<xsl:template match='nnd:db-dalc'>
	<xsl:param name="dalcName">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">DB DALC name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="permissionsEnabled">
		<xsl:choose>
			<xsl:when test="nnd:permissions">True</xsl:when>
			<xsl:otherwise>False</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<!-- calc vars -->
	<xsl:variable name="dbDalcName">
		<xsl:choose>
			<xsl:when test="$permissionsEnabled='True'">
				<xsl:choose>
					<xsl:when test="@original-name"><xsl:value-of select="@original-name"/></xsl:when>
					<xsl:otherwise>original<xsl:value-of select="$dalcName"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$dalcName"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="managerName">
		<xsl:choose>
			<xsl:when test="@manager-name"><xsl:value-of select="@manager-name"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$dalcName"/>Manager</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="dataviewsEnabled">
		<xsl:choose>
			<xsl:when test="count(nnd:dataviews/*)>0">True</xsl:when>
			<xsl:otherwise>False</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:apply-templates select="nnd:driver/*" mode="db-dalc-driver">
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

	<!-- define DALC manager -->
	<xsl:if test="@datasetfactory">
		<xsl:call-template name='component-definition'>
			<xsl:with-param name='name' select="$managerName"/>
			<xsl:with-param name='type'>NI.Data.Dalc.DalcManager</xsl:with-param>
			<xsl:with-param name='injections'>
				<property name="Dalc"><ref name="{$dalcName}"/></property>
				<property name="DataSetProvider"><ref name="{@datasetfactory}"/></property>
			</xsl:with-param>
		</xsl:call-template>	
	</xsl:if>
	
	<!-- default resolver -->
	<xsl:if test="not(nnd:dataviews/@resolver) or not(nnd:permissions/@resolver)">
		<xsl:variable name="defaultExprResolver">
			<nc:template-expr-resolver name="{$dalcName}-DalcDefaultExprResolver">
				<nc:variable prefix="var"/>
				<nc:databind prefix="databind"/>
				<nc:component prefix="component"/>
				<nc:ognl prefix="ognl"/>
				<nc:isinrole prefix="is-in-role"/>
			</nc:template-expr-resolver>
		</xsl:variable>
		<xsl:apply-templates select="msxsl:node-set($defaultExprResolver)/*"/>
	</xsl:if>
	<!-- parser -->
	<xsl:if test="not(nnd:permissions/@parser)">
		<xsl:call-template name='component-definition'>
			<xsl:with-param name='name'><xsl:value-of select="$dalcName"/>-DalcDefaultRelexParser</xsl:with-param>
			<xsl:with-param name='type'>NI.Data.RelationalExpressions.RelExQueryParser</xsl:with-param>
			<xsl:with-param name='injections'>
				<property name="AllowDumpConstants"><value>false</value></property>
			</xsl:with-param>
		</xsl:call-template>		
	</xsl:if>
	
	
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
				<property name="DalcConditionComposer"><ref name="{$dalcName}-DalcPermissionConditionComposer"/></property>
				<property name="DenyAclEntries">
					<list>
						<xsl:for-each select="nnd:permissions/nnd:acl/nnd:deny">
							<entry>
								<xsl:apply-templates select="." mode="db-dalc-permission-acl-entry-descriptor">
									<xsl:with-param name="conditionExprResolverName">
										<xsl:choose>
											<xsl:when test="@resolver"><xsl:value-of select="@resolver"/></xsl:when>
											<xsl:otherwise><xsl:value-of select="$dalcName"/>-DalcDefaultExprResolver</xsl:otherwise>
										</xsl:choose>									
									</xsl:with-param>
								</xsl:apply-templates>
							</entry>
						</xsl:for-each>
						<!--TBD-->
					</list>
				</property>				
			</xsl:with-param>
		</xsl:call-template>
		<!-- composer -->
		<xsl:call-template name='component-definition'>
			<xsl:with-param name='name'><xsl:value-of select="$dalcName"/>-DalcPermissionConditionComposer</xsl:with-param>
			<xsl:with-param name='type'>NI.Data.Dalc.Permissions.CompositeDalcConditionComposer</xsl:with-param>
			<xsl:with-param name='injections'>
				<property name="ConditionComposers">
					<list>
						<entry>
							<component type="NI.Data.Dalc.Permissions.DalcConditionComposer" singleton="false">
								<property name="ConditionDescriptors">
									<list>
										<xsl:for-each select="nnd:permissions/nnd:query">
											<entry>
												<xsl:apply-templates select="." mode="db-dalc-permission-query-descriptor">
													<xsl:with-param name="defaultExprResolverName">
														<xsl:choose>
															<xsl:when test="nnd:permissions/@resolver"><xsl:value-of select="nnd:permissions/@resolver"/></xsl:when>
															<xsl:otherwise><xsl:value-of select="$dalcName"/>-DalcDefaultExprResolver</xsl:otherwise>
														</xsl:choose>									
													</xsl:with-param>
													<xsl:with-param name="defaultRelexParserName">
														<xsl:choose>
															<xsl:when test="nnd:permissions/@parser"><xsl:value-of select="nnd:permissions/@parser"/></xsl:when>
															<xsl:otherwise><xsl:value-of select="$dalcName"/>-DalcDefaultRelexParser</xsl:otherwise>
														</xsl:choose>										
													</xsl:with-param>
												</xsl:apply-templates>
											</entry>
										</xsl:for-each>
									</list>
								</property>
							</component>
						</entry>
						<xsl:for-each select="nnd:permissions/nnd:custom">
							<entry>
								<xsl:apply-templates select="node()"/>
							</entry>
						</xsl:for-each>
					</list>
				</property>
			</xsl:with-param>
		</xsl:call-template>		
	</xsl:if>
	
	<component name="{$dalcName}-DalcEventsMediator" type="NI.Data.Dalc.DbDalcEventsMediator,NI.Data.Dalc" singleton="true"/>
	
	<xsl:if test="@trace='1' or @trace='true' or nnd:trace">
		<component name="{$dalcName}-DalcTraceLogger" type="NI.Data.Dalc.DbDalcTraceLogger,NI.Data.Dalc" singleton="true">
			<property name="DbDalcEventsMediator"><ref name="{$dalcName}-DalcEventsMediator"/></property>
			<xsl:if test="nnd:trace">
				<property name="Enabled"><xsl:apply-templates select="nnd:trace/node()"/></property>
			</xsl:if>
			<property name="LogFilter">
				<xsl:variable name="tpl">
					<nr:provider>
						<nr:chain context="msg">
							<nr:provide result="logger">
								<nr:target>
									<nr:invoke method="GetLogger">
										<nr:target><nr:type>NReco.Logging.LogManager,NReco</nr:type></nr:target>
										<nr:args>
											<nr:const><nr:type>NI.Data.Dalc.DbDalc,NI.Data.Dalc</nr:type></nr:const>
										</nr:args>
									</nr:invoke>
								</nr:target>
							</nr:provide>
							<nr:execute>
								<nr:target>
									<nr:invoke method="Write">
										<nr:target><nr:ognl>#logger</nr:ognl></nr:target>
										<nr:args>
											<nr:const>Debug</nr:const>
											<nr:ognl>#msg</nr:ognl>
										</nr:args>
									</nr:invoke>
								</nr:target>
							</nr:execute>
						</nr:chain>
					</nr:provider>
				</xsl:variable>
				<xsl:apply-templates select="msxsl:node-set($tpl)/node()"/>
			</property>
		</component>
	</xsl:if>
	
	<!-- transaction controller related to this DALC -->
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'><xsl:value-of select="$dalcName"/>-DalcTransaction</xsl:with-param>
		<xsl:with-param name='type'>NI.Data.Dalc.DbDalcTransaction</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="Dalc"><ref name="{$dalcName}"/></property>
		</xsl:with-param>
	</xsl:call-template>
	
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
								<xsl:when test="nnd:dataviews/@resolver"><xsl:value-of select="nnd:dataviews/@resolver"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$dalcName"/>-DalcDefaultExprResolver</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:for-each select="nnd:dataviews/*">
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
				<property name="DalcConditionComposer"><ref name="{$dalcName}-DalcPermissionConditionComposer"/></property>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>

	<xsl:for-each select="nnd:triggers/nnd:*">
		<xsl:apply-templates select="." mode="db-dalc-trigger">
			<xsl:with-param name="eventsMediatorName">
				<xsl:value-of select="$dalcName"/>-DalcEventsMediator
			</xsl:with-param>
			<!-- ensure that trigger names are really unique -->
			<xsl:with-param name="namePrefix"><xsl:value-of select="$dalcName"/>-<xsl:value-of select="generate-id(.)"/>-</xsl:with-param>
		</xsl:apply-templates>
	</xsl:for-each>
	
</xsl:template>

<xsl:template match="nnd:deny" mode="db-dalc-permission-acl-entry-descriptor">
	<xsl:param name="conditionExprResolverName"/>
	<component type="NI.Data.Dalc.Permissions.DalcPermissionAclEntry,NI.Data.Dalc.Permissions" singleton="false">
		<property name="MatchOperation"><value><xsl:value-of select="@operation"/></value></property>
		<property name="SourceNameContextKey"><value>__sourcename</value></property>
		<property name="SubjectContextKey"><value>__username</value></property>
		<property name="MatchSourceName">
			<xsl:choose>
				<xsl:when test="@sourcename"><value>^<xsl:value-of select="@sourcename"/>$</value></xsl:when>
				<xsl:otherwise><value>.*</value></xsl:otherwise>
			</xsl:choose>
		</property>
		<property name="BooleanProvider">
			<component type="NI.Common.Expressions.ExpressionObjectProvider,NI.Common" singleton="false">
				<property name="ExprResolver"><ref name="{$conditionExprResolverName}"/></property>
				<property name="Expression"><value><xsl:value-of select="."/></value></property>
			</component>
		</property>
	</component>
</xsl:template>

<xsl:template match="nnd:custom" mode="db-dalc-dataview">
	<xsl:copy-of select="*"/>
</xsl:template>

<xsl:template match="nnd:view" mode="db-dalc-dataview">
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
			<xsl:when test="count(nnd:origin/nnd:sourcename)>0">
				<xsl:for-each select="nnd:origin/nnd:sourcename"><xsl:if test="position()>1">,</xsl:if><xsl:apply-templates select="." mode="db-dalc-dataview-origin-entry"/></xsl:for-each>
			</xsl:when>
			<xsl:when test="nnd:origin"><xsl:value-of select="nnd:origin"/></xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="fieldsCount">
		<xsl:choose>
			<xsl:when test="nnd:fields/nnd:count"><xsl:value-of select="nnd:fields/nnd:count"/></xsl:when>
			<xsl:otherwise>count(*)</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="fields">
		<xsl:choose>
			<xsl:when test="nnd:fields/nnd:select"><xsl:value-of select="nnd:fields/nnd:select"/></xsl:when>
			<xsl:otherwise>*</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="sql">
		<xsl:choose>
			<xsl:when test="@sql"><xsl:value-of select="@sql"/></xsl:when>
			<xsl:when test="nnd:sql"><xsl:value-of select="nnd:sql"/></xsl:when>
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
			<xsl:if test="nnd:fields/nnd:mapping">
				<property name="FieldsMapping">
					<map>
						<xsl:for-each select="nnd:fields/nnd:mapping/nnd:field">
							<entry key="{@name}"><value><xsl:value-of select="."/></value></entry>
						</xsl:for-each>
					</map>
				</property>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="nnd:sourcename" mode="db-dalc-dataview-origin-entry">
<xsl:value-of select="."/><xsl:if test="@alias"><![CDATA[ ]]><xsl:value-of select="@alias"/></xsl:if>
</xsl:template>

<xsl:template name="db-dalc-get-connection-string">
	<xsl:choose>
		<xsl:when test="nnd:connection/@string">
			<value><xsl:value-of select="nnd:connection/@string"/></value>
		</xsl:when>
		<xsl:when test="nnd:connection/nnd:string/@name">
			<component type="NI.Winter.PropertyInvokingFactory" singleton="false">
				<property name="TargetProperty"><value>ConnectionString</value></property>
				<property name="TargetObject">
					<component type="NI.Winter.MethodInvokingFactory" singleton="false">
						<property name="TargetMethod"><value>get_Item</value></property>
						<property name="TargetMethodArgTypes">
							<list>
								<entry><type>System.String,mscorlib</type></entry>
							</list>
						</property>
						<property name="TargetMethodArgs">
							<list>
								<entry>
									<value><xsl:value-of select="nnd:connection/nnd:string/@name"/></value>
								</entry>
							</list>
						</property>
						<property name="TargetObject">
							<component type="NI.Winter.StaticPropertyInvokingFactory" singleton="false">
								<property name="TargetType"><type>System.Configuration.ConfigurationManager,System.Configuration</type></property>
								<property name="TargetProperty"><value>ConnectionStrings</value></property>
							</component>
						</property>
					</component>
				</property>
			</component>
		</xsl:when>
		<xsl:when test="nnd:connection/nnd:string">
			<value><xsl:value-of select="nnd:connection/nnd:string"/></value>
		</xsl:when>
		<xsl:when test="nnd:connection/node() and not(nnd:connection/text())">
			<xsl:apply-templates select="nnd:connection/node()"/>
		</xsl:when>			
		<xsl:otherwise>
			<xsl:message terminate = "yes">MSSQL connection string (mssql/connection/string) is required</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="nnd:mssql" mode="db-dalc-driver">
	<xsl:param name="dalcName"/>
	<xsl:param name="connectionString">
		<xsl:call-template name="db-dalc-get-connection-string"/>
	</xsl:param>
	<xsl:variable name="top-optimization">
		<xsl:choose>
			<xsl:when test="@top-optimization"><xsl:value-of select="@top-optimization"/></xsl:when>
			<xsl:when test="top-optimization"><xsl:value-of select="top-optimization"/></xsl:when>
		</xsl:choose>
	</xsl:variable>	
	
	<component name="{$dalcName}-DalcFactory" type="NI.Data.Dalc.SqlClient.SqlFactory,NI.Data.Dalc" singleton="true" lazy-init="true">
		<xsl:if test="normalize-space($top-optimization)">
			<property name="TopOptimizationEnabled">
				<value><xsl:value-of select="$top-optimization"/></value>
			</property>
		</xsl:if>
		<xsl:if test="@name-brackets">
			<property name="NameBracketsEnabled">
				<value>
					<xsl:choose>
						<xsl:when test="@name-brackets='true' or @name-brackets='1'">True</xsl:when>
						<xsl:otherwise>False</xsl:otherwise>
					</xsl:choose>
				</value>
			</property>		
		</xsl:if>
		<xsl:if test="@command-timeout">
			<property name="CommandTimeout"><value><xsl:value-of select="@command-timeout"/></value></property>  
		</xsl:if>
	</component>
	<component name="{$dalcName}-DalcConnection" type="System.Data.SqlClient.SqlConnection,System.Data" singleton="true" lazy-init="true">
		<property name="ConnectionString">
			<xsl:copy-of select="msxsl:node-set($connectionString)/*"/>
		</property>
	</component>
</xsl:template>

<xsl:template match="nnd:mysql" mode="db-dalc-driver">
	<xsl:param name="dalcName"/>
	<xsl:param name="connectionString">
		<xsl:call-template name="db-dalc-get-connection-string"/>
	</xsl:param>
	<component name="{$dalcName}-DalcFactory" type="NI.Data.Dalc.MySql.MySqlFactory,NI.Data.Dalc.MySql" singleton="true" lazy-init="true"/>
	<component name="{$dalcName}-DalcConnection" type="MySql.Data.MySqlClient.MySqlConnection,MySql.Data" singleton="true" lazy-init="true">
		<property name="ConnectionString">
			<xsl:copy-of select="msxsl:node-set($connectionString)/*"/>
		</property>
	</component>
</xsl:template>

<xsl:template match="nnd:query" mode="db-dalc-permission-query-descriptor">
	<xsl:param name="sourcename">
		<xsl:choose>
			<xsl:when test="@sourcename"><xsl:value-of select="@sourcename"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">DB Dalc permission query sourcename is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="operation">
		<xsl:choose>
			<xsl:when test="@operation"><xsl:value-of select="@operation"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">DB Dalc permission query operation is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="defaultExprResolverName"/>
	<xsl:param name="defaultRelexParserName"/>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'/>
		<xsl:with-param name='type'>NI.Data.Dalc.Permissions.DalcConditionDescriptor</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="Operation"><value><xsl:value-of select="$operation"/></value></property>
			<property name="SourceName"><value><xsl:value-of select="$sourcename"/></value></property>
			<property name="ConditionProvider">
				<xsl:choose>
					<xsl:when test="count(nnd:*)>0">
						<!-- custom relex query node provider -->
						<xsl:apply-templates select="*"/>
					</xsl:when>
					<xsl:otherwise>
						<component type="NI.Data.RelationalExpressions.RelExQueryNodeProvider,NI.Data.RelationalExpressions" singleton="false">
							<property name="ExprResolver"><ref name="{$defaultExprResolverName}"/></property>
							<property name="RelExQueryParser"><ref name="{$defaultRelexParserName}"/></property>
							<property name="RelExCondition"><value><xsl:value-of select="."/></value></property>
						</component>
					</xsl:otherwise>
				</xsl:choose>
			</property>
		</xsl:with-param>	
	</xsl:call-template>
</xsl:template>

<xsl:template match="nnd:datarow" mode="db-dalc-trigger">
	<xsl:param name="eventsMediatorName"/>
	<xsl:param name="namePrefix"/>
	<xsl:call-template name="db-dalc-datarow-trigger">
		<xsl:with-param name="eventsMediatorName" select="$eventsMediatorName"/>
		<xsl:with-param name="namePrefix" select="$namePrefix"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="db-dalc-datarow-trigger" match="nnd:db-dalc-datarow-trigger">
	<xsl:param name="namePrefix"/>
	<xsl:param name="eventsMediatorName">
		<xsl:choose>
			<xsl:when test="@mediator"><xsl:value-of select="@mediator"/></xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="eventName">
		<xsl:choose>
			<xsl:when test="@event"><xsl:value-of select="@event"/></xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="triggerName">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$namePrefix"/>dbDalcTrigger-<xsl:value-of select="generate-id(.)"/>-<xsl:value-of select="$eventsMediatorName"/></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="sourcename">
		<xsl:choose>
			<xsl:when test="@sourcename"><xsl:value-of select="@sourcename"/></xsl:when>
		</xsl:choose>
	</xsl:param>
	
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$triggerName'/>
		<xsl:with-param name='type'>NI.Data.Dalc.DbDalcRowTrigger</xsl:with-param>
		<xsl:with-param name='injections'>
			<xsl:if test="not($sourcename='')">
				<property name='MatchSourceName'>
					<value><xsl:value-of select='$sourcename'/></value>
				</property>
			</xsl:if>
			<xsl:if test="not($eventName='')">
				<property name='MatchEvent'>
					<value><xsl:value-of select='$eventName'/></value>
				</property>
			</xsl:if>
			<property name="Operation">
				<xsl:apply-templates select="node()"/>
			</property>
		</xsl:with-param>
	</xsl:call-template>
	<!-- event binders -->
	<xsl:call-template name="event-binder">
		<xsl:with-param name="sender" select="$eventsMediatorName"/>
		<xsl:with-param name="receiver" select="$triggerName"/>
		<xsl:with-param name="event">RowUpdating</xsl:with-param>
		<xsl:with-param name="method">RowUpdatingHandler</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="event-binder">
		<xsl:with-param name="sender" select="$eventsMediatorName"/>
		<xsl:with-param name="receiver" select="$triggerName"/>
		<xsl:with-param name="event">RowUpdated</xsl:with-param>
		<xsl:with-param name="method">RowUpdatedHandler</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="nr:relex" mode="nreco-provider" name="relex-query-provider">
	<xsl:param name="name"/>
	<xsl:param name="expression" select="text()"/> 
	<xsl:param name="sort" select="@sort"/>
	<xsl:param name="resolver">
		<xsl:choose>
			<xsl:when test="@resolver"><xsl:value-of select="@resolver"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$default-expression-resolver"/></xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>NI.Data.RelationalExpressions.RelExQueryProvider</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="ExprResolver"><ref name="{$resolver}"/></property>
			<property name="RelEx"><value><xsl:value-of select="$expression"/></value></property>
			<xsl:if test="not($sort='') and $sort">
				<property name="SortProvider">
					<component type='NReco.Composition.ConstProvider' singleton='false'>
						<constructor-arg index='0'>
							<xsl:choose>
								<xsl:when test="contains($sort,',')">
									<list>
										<xsl:call-template name="relex-query-sort-generate-list">
											<xsl:with-param name="input" select="$sort"/>
										</xsl:call-template>
									</list>
								</xsl:when>
								<xsl:otherwise>
									<value><xsl:value-of select="$sort"/></value>
								</xsl:otherwise>
							</xsl:choose>
						</constructor-arg>
					</component>
				</property>
			</xsl:if>
			<xsl:if test="nr:extended-properties/node()">
				<property name="ExtendedPropertiesProvider">
					<xsl:apply-templates select="nr:extended-properties/node()" mode="nreco-provider"/>
				</property>
			</xsl:if>			
			<property name="RelExQueryParser">
				<component type="NI.Data.RelationalExpressions.RelExQueryParser,NI.Data.RelationalExpressions" singleton="false">
					<property name="AllowDumpConstants"><value>false</value></property>
				</component>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="nr:relex-condition" mode="nreco-provider" name="relex-query-condition-provider">
	<xsl:param name="name"/>
	<xsl:param name="expression" select="."/> 
	<xsl:param name="resolver">
		<xsl:choose>
			<xsl:when test="@resolver"><xsl:value-of select="@resolver"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$default-expression-resolver"/></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>NI.Data.RelationalExpressions.RelExQueryNodeProvider</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="ExprResolver"><ref name="{$resolver}"/></property>
			<property name="RelExCondition"><value><xsl:value-of select="$expression"/></value></property>
			<property name="RelExQueryParser">
				<component type="NI.Data.RelationalExpressions.RelExQueryParser,NI.Data.RelationalExpressions" singleton="false">
					<property name="AllowDumpConstants"><value>false</value></property>
				</component>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="relex-query-sort-generate-list">
	<xsl:param name="input"/>
	<xsl:variable name="sortFld" select="substring-before($input, ',')"/>
	<xsl:variable name="tail" select="substring-after($input, ',')"/>
	<entry><value><xsl:value-of select="$sortFld"/></value></entry>
	<xsl:if test="contains($tail,',')">
		<xsl:call-template name="relex-query-sort-generate-list">
			<xsl:with-param name="input" select="substring-after($input, ',')"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:if test="not(contains($tail,','))">
		<entry><value><xsl:value-of select="$tail"/></value></entry>
	</xsl:if>
</xsl:template>	
	

<xsl:template match="nr:dalc" mode="nreco-provider">
	<xsl:param name="name"/>
	<xsl:param name="result">
		<xsl:choose>
			<xsl:when test="@result"><xsl:value-of select="@result"/></xsl:when>
			<xsl:otherwise>object</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="dalc">
		<xsl:choose>
			<xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
			<xsl:otherwise>
				<xsl:message terminate = "yes">Reference to DALC is required</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="query">
		<xsl:choose>
			<xsl:when test="@query">
				<nr:relex><xsl:value-of select="@query"/></nr:relex>
			</xsl:when>
			<xsl:when test="count(nr:query/*)>0"><xsl:copy-of select="nr:query/node()"/></xsl:when>
			<xsl:when test="nr:query">
				<xsl:for-each select="nr:query">
					<nr:relex>
						<xsl:if test="@sort">
							<xsl:attribute name="sort"><xsl:value-of select="@sort"/></xsl:attribute>
						</xsl:if>
						<xsl:value-of select="."/>
					</nr:relex>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate = "yes">Query is required</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>
			<xsl:choose>
				<xsl:when test="$result='object'">NI.Data.Dalc.DalcObjectProvider,NI.Data.Dalc</xsl:when>
				<xsl:when test="$result='record'">NI.Data.Dalc.DalcRecordDictionaryProvider,NI.Data.Dalc</xsl:when>
				<xsl:when test="$result='list'">NI.Data.Dalc.DalcObjectListProvider,NI.Data.Dalc</xsl:when>
				<xsl:when test="$result='recordlist'">NI.Data.Dalc.DalcDictionaryListProvider,NI.Data.Dalc</xsl:when>
				<xsl:when test="$result='dataset'">NI.Data.Dalc.DalcDataSetProvider,NI.Data.Dalc</xsl:when>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name='injections'>
			<xsl:choose>
				<xsl:when test="$result='dataset'">
					<property name="QueryProviders">
						<list>
							<xsl:for-each select="msxsl:node-set($query)/node()">
								<entry>
									<xsl:apply-templates select="." mode="nreco-provider"/>
								</entry>
							</xsl:for-each>
						</list>
					</property>
				</xsl:when>
				<xsl:otherwise>
					<property name="QueryProvider">
						<xsl:if test="count(msxsl:node-set($query)/*)>0">
							<xsl:apply-templates select="msxsl:node-set($query)/node()[position()=1]" mode="nreco-provider"/>
						</xsl:if>
					</property>					
				</xsl:otherwise>
			</xsl:choose>

			<property name="Dalc"><ref name="{$dalc}"/></property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

	
</xsl:stylesheet>
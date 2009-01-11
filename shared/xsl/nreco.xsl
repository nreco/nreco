<xsl:stylesheet version='1.0' 
								xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
								xmlns:msxsl="urn:schemas-microsoft-com:xslt"
								xmlns:nr="urn:schemas-nreco:nreco:core:v1"
								exclude-result-prefixes="msxsl nr">
<xsl:output method='xml' indent='yes' />

<xsl:template match='ref'><ref name='{@name}'/></xsl:template>
	
<xsl:template name='component-definition'>
	<xsl:param name='name' select='@name'/>
	<xsl:param name='type' select='@type'/>
	<xsl:param name='injections'/>
	<component type="{$type}">
		<xsl:choose>
			<xsl:when test="not(normalize-space($name)='')">
				<xsl:attribute name="name"><xsl:value-of select="normalize-space($name)"/></xsl:attribute>
				<xsl:attribute name="singleton">true</xsl:attribute>
				<xsl:attribute name="lazy-init">true</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="singleton">false</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$injections">
			<xsl:copy-of select="msxsl:node-set($injections)/*"/>
		</xsl:if>
	</component>
</xsl:template>

<xsl:template match='nr:chain'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Operations.Chain,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Operations'>
				<list>
					<xsl:for-each select='nr:*'>
						<entry>
							<xsl:apply-templates select='.' mode='chain-operation'/>
						</entry>
					</xsl:for-each>
				</list>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match='nr:execute' mode='chain-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'/><!-- always unnamed! -->
		<xsl:with-param name='type'>NReco.Operations.ChainOperationCall,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Operation'>
				<xsl:choose>
					<xsl:when test='@target'><ref name='{@target}'/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select='nr:target/nr:*' mode='nreco-operation'/>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<xsl:if test='count(nr:context/nr:*)>0'>
				<property name='ContextFilter'>
					<xsl:apply-templates select='nr:context/nr:*' mode='nreco-provider'/>
				</property>
			</xsl:if>
			<xsl:if test='count(nr:condition/nr:*)>0 or @if'>
				<property name='RunCondition'>
					<xsl:choose>
						<xsl:when test='@if'>
							<xsl:call-template name='ognl-provider'>
								<xsl:with-param name='code' select='@if'/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select='nr:condition/nr:*' mode='nreco-provider'/>
						</xsl:otherwise>
					</xsl:choose>
				</property>
			</xsl:if>			
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>
	
<xsl:template match='nr:provide' mode='chain-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'/><!-- always unnamed! -->
		<xsl:with-param name='type'>NReco.Operations.ChainProviderCall,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Provider'>
				<xsl:choose>
					<xsl:when test='@target'><ref name='{@target}'/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select='nr:target/nr:*' mode='nreco-provider'/>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<xsl:if test='count(nr:context/nr:*)>0'>
				<property name='ContextFilter'>
					<xsl:apply-templates select='nr:context/nr:*' mode='nreco-provider'/>
				</property>
			</xsl:if>
			<xsl:if test='count(nr:result/nr:*)>0'>
				<property name='ResultFilter'>
					<xsl:apply-templates select='nr:result/nr:*' mode='nreco-provider'/>
				</property>
			</xsl:if>
			<xsl:if test='count(nr:condition/nr:*)>0 or @if'>
				<property name='RunCondition'>
					<xsl:choose>
						<xsl:when test='@if'>
							<xsl:call-template name='ognl-provider'>
								<xsl:with-param name='code' select='@if'/>
								<xsl:with-param name='name'></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise><xsl:apply-templates select='nr:condition/nr:*' mode='nreco-provider'/></xsl:otherwise>
					</xsl:choose>
				</property>
			</xsl:if>			
			<xsl:if test='@result'>
				<property name='ResultKey'>
					<value><xsl:value-of select='@result'/></value>
				</property>
			</xsl:if>			
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:*' mode='nreco-provider'>
	<xsl:apply-templates select='.'/>
</xsl:template>

<xsl:template match='nr:*' mode='nreco-operation'>
	<xsl:apply-templates select='.'/>
</xsl:template>	
	
<xsl:template match='nr:const' mode='nreco-provider'>
	<xsl:call-template name='const-provider'/>	
</xsl:template>
	
<xsl:template name='const-provider' match='nr:const-provider'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Providers.ConstProvider,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Value'>
				<xsl:choose>
					<xsl:when test='@value'><value><xsl:value-of select='@value'/></value></xsl:when>
					<xsl:when test='count(*)>0'>
						<xsl:apply-templates select='*'/>
					</xsl:when>
					<xsl:otherwise>
						<value><xsl:value-of select='.'/></value>
					</xsl:otherwise>
				</xsl:choose>
			</property>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:ognl' mode='nreco-provider'>
	<xsl:call-template name='ognl-provider'/>
</xsl:template>	
	
<xsl:template match='nr:ognl-provider' name='ognl-provider'>
	<xsl:param name='code' select='.'/>
	<xsl:param name='name' select='@name'/>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>
			<xsl:choose>
				<xsl:when test="not(normalize-space($code)='')">NReco.OGNL.EvalOgnlCode</xsl:when>
				<xsl:otherwise>NReco.OGNL.OgnlExprProvider</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name='injections'>
			<xsl:if test="not(normalize-space($code)='')">
				<property name='Code'>
					<value><xsl:value-of select='$code'/></value>
				</property>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:csharp' mode='nreco-provider'>
	<xsl:call-template name='csharp-operation'/>
</xsl:template>

<xsl:template match='nr:csharp' mode='nreco-operation'>
	<xsl:call-template name='csharp-operation'/>
</xsl:template>	
	
<xsl:template match='nr:csharp-operation' name='csharp-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Operations.EvalCsCode,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<xsl:if test='nr:assembly'>
				<property name='ExtraAssemblies'>
					<list>
					<xsl:for-each select='nr:assembly'>
						<entry>
							<value><xsl:choose>
								<xsl:when test='@name'><xsl:value-of select='@name'/></xsl:when>
								<xsl:otherwise><xsl:value-of select='.'/></xsl:otherwise>
							</xsl:choose></value>
						</entry>
					</xsl:for-each>
					</list>
				</property>
			</xsl:if>
			<xsl:if test='nr:namespace'>
				<property name='ExtraNamespaces'>
					<list>
					<xsl:for-each select='nr:namespace'>
						<entry>
							<value><xsl:choose>
								<xsl:when test='@name'><xsl:value-of select='@name'/></xsl:when>
								<xsl:otherwise><xsl:value-of select='.'/></xsl:otherwise>
							</xsl:choose></value>
						</entry>
					</xsl:for-each>
					</list>
				</property>
			</xsl:if>
			<property name='Variables'>
				<list>
					<xsl:for-each select='nr:var|nr:variable'>
						<entry>
							<xsl:apply-templates select='.' mode='csharp-operation'/>
						</entry>
					</xsl:for-each>
				</list>
			</property>
			<property name='Code'><value><xsl:value-of select='text()'/></value></property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match='nr:var|nr:variable' mode='csharp-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'/><!-- always unnamed! -->
		<xsl:with-param name='type'>NReco.Operations.EvalCsCode+VariableDescriptor,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<constructor-arg index='0'><value><xsl:value-of select='@name'/></value></constructor-arg>
			<constructor-arg index='1'>
				<type>
					<xsl:choose>
						<xsl:when test="@type='int' or @type='integer'">System.Int32,mscorlib</xsl:when>
						<xsl:when test="@type='string'">System.String,mscorlib</xsl:when>
						<xsl:when test="@type='datetime'">System.DateTime,mscorlib</xsl:when>
						<xsl:when test="@type='provider'">NI.Common.Providers.IObjectProvider,NI.Common</xsl:when>
						<xsl:when test="@type='operation'">NI.Common.Operations.IOperation,NI.Common</xsl:when>
						<xsl:otherwise><xsl:value-of select='@type'/></xsl:otherwise>
					</xsl:choose>
				</type>
			</constructor-arg>
			<constructor-arg index='2'>
				<xsl:choose>
					<xsl:when test='@provider'><ref name='{@provider}'/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select='*'/>
					</xsl:otherwise>
				</xsl:choose>
			</constructor-arg>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template name='ref-const-provider'>
	<xsl:param name='refName'/>
	<component type='NReco.Providers.ConstProvider,NReco' singleton='false'>
		<constructor-arg index='0'><ref name='{$refName}'/></constructor-arg>
	</component>	
</xsl:template>

<xsl:template match='nr:invoke' mode='nreco-operation'>
	<xsl:call-template name='invoke-operation'/>
</xsl:template>		
	
<xsl:template match='nr:invoke-operation' name='invoke-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Operations.DynamicInvokeMethod,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='TargetProvider'>
				<xsl:choose>
					<xsl:when test='@target'>
						<xsl:call-template name='ref-const-provider'>
							<xsl:with-param name='refName' select='@target'/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test='nr:target/*'>
						<xsl:apply-templates select='nr:target/nr:*'/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate = "yes">target is not defined</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<property name='MethodNameProvider'>
				<xsl:choose>
					<xsl:when test='@method'>
						<component type='NReco.Providers.ConstProvider`2[[System.Object,mscorlib],[System.String,mscorlib]],NReco' singleton='false'>
							<constructor-arg index='0'>
								<value><xsl:value-of select='@method'/></value>
							</constructor-arg>
						</component>
					</xsl:when>
					<xsl:when test='nr:method/*'>
						<xsl:apply-templates select='nr:method/*' mode='nreco-provider'/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate = "yes">method is not defined</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<property name='ArgumentProviders'>
				<list>
					<xsl:for-each select='nr:args/*'>
						<entry>
							<xsl:apply-templates select='.' mode='nreco-provider'/>
						</entry>
					</xsl:for-each>
				</list>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match='nr:lazy' mode='nreco-operation'>
	<xsl:call-template name='lazy-operation'/>
</xsl:template>		
	
<xsl:template match='nr:lazy-operation' name='lazy-operation'>
	<xsl:param name="opName">
		<xsl:choose>
			<xsl:when test="@operation"><xsl:value-of select="@operation"/></xsl:when>
			<xsl:otherwise>
				<xsl:message terminate = "yes">operation is not defined</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Operations.LazyOperation,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="OperationName">
				<value><xsl:value-of select="$opName"/></value>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>	

</xsl:stylesheet>
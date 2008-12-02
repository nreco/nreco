<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
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
		<xsl:copy-of select="msxsl:node-set($injections)/*"/>
	</component>
</xsl:template>

<xsl:template match='chain'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Operations.Chain,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Operations'>
				<list>
					<xsl:for-each select='*'>
						<entry>
							<xsl:apply-templates select='.' mode='chain-operation'/>
						</entry>
					</xsl:for-each>
				</list>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match='operation-call|op-call' mode='chain-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'/><!-- always unnamed! -->
		<xsl:with-param name='type'>NReco.Operations.ChainOperationCall,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Operation'>
				<xsl:choose>
					<xsl:when test='@target'><ref name='{@target}'/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select='target/*'/>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<xsl:if test='count(context/*)>0'>
				<property name='ContextProvider'>
					<xsl:apply-templates select='context/*'/>
				</property>
			</xsl:if>
			<xsl:if test='count(condition/*)>0 or @if'>
				<property name='RunCondition'>
					<xsl:choose>
						<xsl:when test='@if'>
							<xsl:call-template name='ognl-provider'>
								<xsl:with-param name='code' select='@if'/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select='condition/*'/>
						</xsl:otherwise>
					</xsl:choose>
				</property>
			</xsl:if>			
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>
	
<xsl:template match='provider-call|prv-call' mode='chain-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name'/><!-- always unnamed! -->
		<xsl:with-param name='type'>NReco.Operations.ChainProviderCall,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Provider'>
				<xsl:choose>
					<xsl:when test='@target'><ref name='{@target}'/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select='target/*'/>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<xsl:if test='count(context/*)>0'>
				<property name='ContextProvider'>
					<xsl:apply-templates select='context/*'/>
				</property>
			</xsl:if>
			<xsl:if test='count(result/*)>0'>
				<property name='ResultProvider'>
					<xsl:apply-templates select='result/*'/>
				</property>
			</xsl:if>
			<xsl:if test='count(condition/*)>0 or @if'>
				<property name='RunCondition'>
					<xsl:choose>
						<xsl:when test='@if'>
							<xsl:call-template name='ognl-provider'>
								<xsl:with-param name='code' select='@if'/>
								<xsl:with-param name='name'></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise><xsl:apply-templates select='condition/*'/></xsl:otherwise>
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

<xsl:template match='const-provider|const-prv'>
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

<xsl:template match='ognl-provider|ognl-prv|ognl' name='ognl-provider'>
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
	
<xsl:template match='csharp|csharp-op|csharp-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Operations.EvalCsCode,NReco</xsl:with-param>
		<xsl:with-param name='injections'>
			<xsl:if test='assembly'>
				<property name='ExtraAssemblies'>
					<list>
					<xsl:for-each select='assembly'>
						<entry>
							<value><xsl:choose>
								<xsl:when test='@name'><value><xsl:value-of select='@name'/></value></xsl:when>
								<xsl:otherwise><xsl:value-of select='.'/></xsl:otherwise>
							</xsl:choose></value>
						</entry>
					</xsl:for-each>
					</list>
				</property>
			</xsl:if>
			<xsl:if test='namespace'>
				<property name='ExtraNamespaces'>
					<list>
					<xsl:for-each select='namespace'>
						<entry>
							<value><xsl:choose>
								<xsl:when test='@name'><value><xsl:value-of select='@name'/></value></xsl:when>
								<xsl:otherwise><xsl:value-of select='.'/></xsl:otherwise>
							</xsl:choose></value>
						</entry>
					</xsl:for-each>
					</list>
				</property>
			</xsl:if>
			<property name='Variables'>
				<list>
					<xsl:for-each select='var|variable'>
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

<xsl:template match='var|variable' mode='csharp-operation'>
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

<xsl:template match='invoke|invoke-op|invoke-operation'>
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
					<xsl:when test='target/*'>
						<xsl:apply-templates select='target/*'/>
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
					<xsl:when test='method/*'>
						<xsl:apply-templates select='method/*'/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate = "yes">method is not defined</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<property name='ArgumentProviders'>
				<list>
					<xsl:for-each select='args/*'>
						<entry>
							<xsl:apply-templates select='.'/>
						</entry>
					</xsl:for-each>
				</list>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match='lazy-op|lazy-operation'>
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
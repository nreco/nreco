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
				xmlns:nr="urn:schemas-nreco:nreco:core:v1"
				exclude-result-prefixes="msxsl nr">
<xsl:output method='xml' indent='yes' />

	
<xsl:template match='nr:ref'><ref name='{@name}'/></xsl:template>
	
<xsl:template name='component-definition'>
	<xsl:param name='name' select='@name'/>
	<xsl:param name='type' select='@type'/>
	<xsl:param name='initMethod' select='@init-method'/>
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
		<xsl:if test="not(normalize-space($initMethod)='')">
			<xsl:attribute name="init-method"><xsl:value-of select="$initMethod"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$injections">
			<xsl:copy-of select="msxsl:node-set($injections)/*"/>
		</xsl:if>
	</component>
</xsl:template>

<xsl:template name="event-binder">
	<xsl:param name="sender"/>
	<xsl:param name="event"/>
	<xsl:param name="receiver"/>
	<xsl:param name="method"/>
	<component name="eventBinder-{$sender}-{$event}-{$receiver}-{$method}" type="NI.Winter.EventBinder" singleton="true" lazy-init="false" init-method="Init">
		<property name="SenderObject"><ref name="{normalize-space($sender)}"/></property>
		<property name="SenderEvent"><value><xsl:value-of select="$event"/></value></property>
		<property name="ReceiverObject"><ref name="{normalize-space($receiver)}"/></property>
		<property name="ReceiverMethod"><value><xsl:value-of select="$method"/></value></property>
	</component>
</xsl:template>
	
<xsl:template match="nreco-condition-provider">
	<xsl:call-template name="ognl-provider">
		<xsl:with-param name="code" select="code"/>
	</xsl:call-template>
</xsl:template>

<xsl:template match='nr:chain' name='chain-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.Chain</xsl:with-param>
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
		<xsl:with-param name='type'>NReco.Composition.ChainOperationCall</xsl:with-param>
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
					<xsl:apply-templates select='nr:context/node()' mode='nreco-provider'/>
				</property>
			</xsl:if>
			<xsl:if test='count(nr:condition/nr:*)>0 or @if'>
				<property name='RunCondition'>
					<xsl:choose>
						<xsl:when test='@if or if'>
							<xsl:variable name="condPrv">
								<nreco-condition-provider>
									<code>
										<xsl:choose>
											<xsl:when test="@if"><xsl:value-of select="@if"/></xsl:when>
											<xsl:when test="if"><xsl:value-of select="if"/></xsl:when>
										</xsl:choose>
									</code>
								</nreco-condition-provider>
							</xsl:variable>
							<xsl:apply-templates select="msxsl:node-set($condPrv)/*"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select='nr:condition/node()' mode='nreco-provider'/>
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
		<xsl:with-param name='type'>NReco.Composition.ChainProviderCall</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Provider'>
				<xsl:choose>
					<xsl:when test='@target'><ref name='{@target}'/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select='nr:target/node()' mode='nreco-provider'/>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<xsl:if test='count(nr:context/nr:*)>0'>
				<property name='ContextFilter'>
					<xsl:apply-templates select='nr:context/node()' mode='nreco-provider'/>
				</property>
			</xsl:if>
			<xsl:if test='count(nr:result/nr:*)>0'>
				<property name='ResultFilter'>
					<xsl:apply-templates select='nr:result/node()' mode='nreco-provider'/>
				</property>
			</xsl:if>
			<xsl:if test='count(nr:condition/nr:*)>0 or @if'>
				<property name='RunCondition'>
					<xsl:choose>
						<xsl:when test='@if or if'>
							<xsl:variable name="condPrv">
								<nreco-condition-provider>
									<code>
										<xsl:choose>
											<xsl:when test="@if"><xsl:value-of select="@if"/></xsl:when>
											<xsl:when test="if"><xsl:value-of select="if"/></xsl:when>
										</xsl:choose>
									</code>
								</nreco-condition-provider>
							</xsl:variable>
							<xsl:apply-templates select="msxsl:node-set($condPrv)/*"/>
						</xsl:when>
						<xsl:otherwise><xsl:apply-templates select='nr:condition/node()' mode='nreco-provider'/></xsl:otherwise>
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

<xsl:template match='node()' mode='nreco-provider'>
	<xsl:apply-templates select='.'/>
</xsl:template>

<xsl:template match='node()' mode='nreco-operation'>
	<xsl:apply-templates select='.'/>
</xsl:template>	

<xsl:template name='name-value' match='nr:name-value'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>System.Collections.Generic.Dictionary`2[[System.String,mscorlib],[System.Object,mscorlib]],mscorlib</xsl:with-param>
		<xsl:with-param name='injections'>
			<constructor-arg index="0">
				<map>
					<xsl:for-each select="nr:entry">
						<entry key="{@key}">
							<xsl:choose>
								<xsl:when test="count(nr:*)>0"><xsl:apply-templates select="nr:*"/></xsl:when>
								<xsl:otherwise><value><xsl:value-of select="."/></value></xsl:otherwise>
							</xsl:choose>
						</entry>
					</xsl:for-each>
				</map>
			</constructor-arg>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:const' mode='nreco-provider'>
	<xsl:call-template name='const-provider'/>	
</xsl:template>
	
<xsl:template name='const-provider' match='nr:const-provider'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.ConstProvider</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='Value'>
				<xsl:choose>
					<xsl:when test='@value'><value><xsl:value-of select='@value'/></value></xsl:when>
					<xsl:when test='*'>
						<xsl:apply-templates select='node()'/>
					</xsl:when>
					<xsl:otherwise>
						<value><xsl:value-of select='.'/></value>
					</xsl:otherwise>
				</xsl:choose>
			</property>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:dictionary' mode='nreco-provider'>
	<xsl:call-template name='dictionary-provider'/>	
</xsl:template>

<xsl:template name='dictionary-provider' match='nr:dictionary-provider'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.NameValueProvider</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="PairProviders">
				<map>
					<xsl:for-each select="nr:entry">
						<entry key="{@key}">
							<xsl:apply-templates select="node()" mode="nreco-provider"/>
						</entry>
					</xsl:for-each>
				</map>
			</property>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:listdictionary' mode='nreco-provider'>
	<xsl:call-template name='listdictionary-provider'/>	
</xsl:template>

<xsl:template name='listdictionary-provider' match='nr:listdictionary-provider'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.ListDictionaryProvider</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="KeyProvider">
				<xsl:apply-templates select="nr:key/node()" mode="nreco-provider"/>
			</property>
			<property name="ValueProvider">
				<xsl:apply-templates select="nr:value/node()" mode="nreco-provider"/>
			</property>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:chain' mode='nreco-provider'>
	<xsl:call-template name='chain-provider'/>	
</xsl:template>
	
<xsl:template match='nr:chain-provider' name='chain-provider'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.ChainProvider</xsl:with-param>
		<xsl:with-param name='injections'>
			<xsl:if test="@context">
				<property name="ContextFilter">
					<component type="NReco.Composition.SingleNameValueProvider" singleton="false">
						<property name="Key"><value><xsl:value-of select="@context"/></value></property>
					</component>
				</property>
			</xsl:if>
			<property name='Operations'>
				<list>
					<xsl:for-each select='nr:*'>
						<entry>
							<xsl:apply-templates select='.' mode='chain-operation'/>
						</entry>
					</xsl:for-each>
				</list>
			</property>
			<xsl:if test='@result'>
				<property name='ResultKey'><value><xsl:value-of select='@result'/></value></property>
			</xsl:if>
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
		<xsl:with-param name='type'>NReco.Composition.EvalCsCode</xsl:with-param>
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
		<xsl:with-param name='type'>NReco.Composition.EvalCsCode+VariableDescriptor,NReco.Composition</xsl:with-param>
		<xsl:with-param name='injections'>
			<constructor-arg index='0'><value><xsl:value-of select='@name'/></value></constructor-arg>
			<constructor-arg index='1'>
				<type>
					<xsl:choose>
						<xsl:when test="@type='int' or @type='integer'">System.Int32,mscorlib</xsl:when>
						<xsl:when test="@type='string'">System.String,mscorlib</xsl:when>
						<xsl:when test="@type='bool'">System.Boolean,mscorlib</xsl:when>
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
						<xsl:apply-templates select='nr:*' mode='nreco-provider'/>
					</xsl:otherwise>
				</xsl:choose>
			</constructor-arg>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template name='ref-const-provider'>
	<xsl:param name='refName'/>
	<component type='NReco.Composition.ConstProvider' singleton='false'>
		<constructor-arg index='0'><ref name='{$refName}'/></constructor-arg>
	</component>
</xsl:template>

<xsl:template match='nr:transaction' mode='nreco-operation'>
	<xsl:call-template name='transaction-operation'/>
</xsl:template>

<xsl:template match='nr:invoke' mode='nreco-provider'>
	<xsl:call-template name='invoke-operation'/>
</xsl:template>

<xsl:template match='nr:invoke' mode='nreco-operation'>
	<xsl:call-template name='invoke-operation'/>
</xsl:template>		
	
<xsl:template match='nr:invoke-operation' name='invoke-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.DynamicInvokeMethod</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='TargetProvider'>
				<xsl:choose>
					<xsl:when test='@target'>
						<xsl:call-template name='ref-const-provider'>
							<xsl:with-param name='refName' select='@target'/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test='nr:target/nr:*'>
						<xsl:apply-templates select='nr:target/nr:*' mode='nreco-provider'/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate = "yes">target is not defined</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<property name='MethodNameProvider'>
				<xsl:choose>
					<xsl:when test='@method'>
						<component type='NReco.Composition.ConstProvider`2[[System.Object,mscorlib],[System.String,mscorlib]],NReco.Composition' singleton='false'>
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
					<xsl:for-each select='nr:args/nr:*'>
						<entry>
							<xsl:apply-templates select='.' mode='nreco-provider'/>
						</entry>
					</xsl:for-each>
				</list>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match='nr:transaction-operation' name='transaction-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.Transaction</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="Begin">
				<xsl:apply-templates select="nr:begin/nr:*" mode="nreco-operation"/>
			</property>
			<property name="Commit">
				<xsl:apply-templates select="nr:commit/nr:*" mode="nreco-operation"/>
			</property>
			<property name="Abort">
				<xsl:apply-templates select="nr:abort/nr:*" mode="nreco-operation"/>
			</property>
			<property name="UnderlyingOperation">
				<xsl:choose>
					<xsl:when test="@operation"><ref name="{@operation}"/></xsl:when>
					<xsl:when test="nr:operation/nr:*">
						<xsl:apply-templates select="nr:operation/nr:*" mode="nreco-operation"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate = "yes">underlying operation is not defined</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
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
	<xsl:param name="instancePrvName">
		<xsl:choose>
			<xsl:when test="@instance-provider">
				<xsl:value-of select="@instance-provider"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$default-instance-provider"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.LazyOperation</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="OperationName">
				<value><xsl:value-of select="$opName"/></value>
			</property>
			<property name="InstanceProvider">
				
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>	

<xsl:template match='nr:linq' mode='nreco-provider'>
	<xsl:call-template name='linq-provider'/>
</xsl:template>	
	
<xsl:template match='nr:linq-provider' name='linq-provider'>
	<xsl:param name='code' select='.'/>
	<xsl:param name='name' select='@name'/>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>
			<xsl:choose>
				<xsl:when test="not(normalize-space($code)='')">NReco.LinqDynamic.EvalDynamicCode</xsl:when>
				<xsl:otherwise>NReco.LinqDynamic.DynamicExprProvider</xsl:otherwise>
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

<xsl:template match='nr:context' mode='nreco-provider'>
	<xsl:call-template name='context-provider'/>
</xsl:template>	

<xsl:template match='nr:context-provider' name='context-provider'>
	<xsl:param name='name' select='@name'/>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>NReco.Composition.ContextProvider</xsl:with-param>
		<xsl:with-param name='injections'></xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:provider-call' mode='nreco-provider'>
	<xsl:call-template name='provider-call'/>
</xsl:template>	

<xsl:template match='nr:provider-call' name='provider-call'>
	<xsl:param name='name' select='@name'/>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>NReco.Composition.ProviderCall</xsl:with-param>
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
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:throw' mode='nreco-operation'>
	<xsl:call-template name='throw-operation'/>
</xsl:template>

<xsl:template match='nr:throw-operation' name='throw-operation'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='@name'/>
		<xsl:with-param name='type'>NReco.Composition.ThrowException</xsl:with-param>
		<xsl:with-param name='injections'>
			<xsl:if test="@message or message">
				<property name='MessageProvider'>
					<xsl:choose>
						<xsl:when test='@message'>
							<component type='NReco.Composition.ConstProvider' singleton='false'>
								<constructor-arg index='0'><value><xsl:value-of select="@message"/></value></constructor-arg>
							</component>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select='node()' mode='nreco-provider'/>
						</xsl:otherwise>
					</xsl:choose>
				</property>
			</xsl:if>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

<xsl:template match='nr:each' mode='nreco-operation'>
	<xsl:call-template name='each-operation'/>
</xsl:template>

<xsl:template match='nr:each-operation' name='each-operation'>
	<xsl:param name='name' select='@name'/>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>NReco.Composition.Each</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name='ItemsProvider'>
				<xsl:choose>
					<xsl:when test='@from'><ref name='{@from}'/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select='nr:from/nr:*' mode='nreco-provider'/>
					</xsl:otherwise>
				</xsl:choose>
			</property>
			<property name='ItemOperation'>
				<xsl:choose>
					<xsl:when test='@do'><ref name='{@do}'/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select='nr:do/nr:*' mode='nreco-operation'/>
					</xsl:otherwise>
				</xsl:choose>
			</property>
		</xsl:with-param>
	</xsl:call-template>	
</xsl:template>

</xsl:stylesheet>
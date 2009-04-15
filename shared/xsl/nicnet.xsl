<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:nr="urn:schemas-nreco:nreco:core:v1"
				xmlns:nc="urn:schemas-nreco:nicnet:common:v1"
				exclude-result-prefixes="msxsl">

<xsl:template match='nc:template-expr-resolver'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Common.Expressions.TemplateExprParserResolver,NI.Common</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="ExprDescriptors">
				<list>
					<xsl:for-each select="nc:*">
						<xsl:if test="not(@prefix)">
							<xsl:message terminate = "yes">Template parser needs @prefix attribute</xsl:message>
						</xsl:if>
						<entry>
							<component type="NI.Common.Expressions.ExpressionDescriptor,NI.Common" singleton="false">
								<property name="Marker"><value><xsl:value-of select="@prefix"/></value></property>
								<property name="ExprResolver">
									<xsl:apply-templates select="." mode="template-expr-resolver"/>
								</property>
							</component>
						</entry>
						
					</xsl:for-each>
				</list>
			</property>
		</xsl:with-param>
	</xsl:call-template>		
</xsl:template>

<xsl:template match="nc:var-expr-resolver" name="var-expr-resolver">
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Common.Expressions.VariableExprFastResolver,NI.Common</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="nc:databind-expr-resolver" name="databind-expr-resolver">
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Common.Expressions.DataBindExprResolver,NI.Common</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="nc:isinrole-expr-resolver" name="isinrole-expr-resolver">
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Common.Expressions.IsInRoleExprResolver,NI.Common</xsl:with-param>
	</xsl:call-template>
</xsl:template>


<xsl:template match="nc:component-expr-resolver" name="component-expr-resolver">
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Common.Expressions.ComponentExprResolver,NI.Common</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="NamedServiceProvider">
				<component type="NI.Winter.ServiceProviderContext" singleton="false"/>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="nc:variable" mode="template-expr-resolver">
	<xsl:call-template name="var-expr-resolver"/>
</xsl:template>

<xsl:template match="nc:databind" mode="template-expr-resolver">
	<xsl:call-template name="databind-expr-resolver"/>
</xsl:template>

<xsl:template match="nc:isinrole" mode="template-expr-resolver">
	<xsl:call-template name="isinrole-expr-resolver"/>
</xsl:template>

<xsl:template match="nc:component" mode="template-expr-resolver">
	<xsl:call-template name="component-expr-resolver"/>
</xsl:template>

<xsl:template match="nc:ognl" mode="template-expr-resolver">
	<xsl:variable name="ognlPrv"><nr:ognl-provider/></xsl:variable>
	<xsl:apply-templates select="msxsl:node-set($ognlPrv)/nr:*"/>
</xsl:template>


</xsl:stylesheet>
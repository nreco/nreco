<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">

<xsl:template match='template-expr-resolver'>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Common.Expressions.TemplateExprParserResolver,NI.Common</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="ExprDescriptors">
				<list>
					<xsl:for-each select="*">
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

<xsl:template match="var-expr-resolver" name="var-expr-resolver">
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Common.Expressions.VariableExprFastResolver,NI.Common</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="variable" mode="template-expr-resolver">
	<xsl:call-template name="var-expr-resolver"/>
</xsl:template>

</xsl:stylesheet>
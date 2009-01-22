<xsl:stylesheet version='1.0' 
								xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
								xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
								xmlns:r="urn:schemas-nreco:web:routing:v1"
								exclude-result-prefixes="r msxsl">

<!-- System.Web.Routing model -->
<xsl:template match='r:routes'>
	<xsl:param name="listName">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Routes list name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<component name="{$listName}" type="NI.Winter.ReplacingFactory" singleton="true" lazy-init="true">
		<property name="TargetObject">
			<list>
				<xsl:for-each select="r:route">
					<entry>
						<xsl:apply-templates select="."/>
					</entry>
				</xsl:for-each>
			</list>
		</property>
	</component>
	
</xsl:template>

<xsl:template match="r:route">
	<xsl:param name="pattern">
		<xsl:choose>
			<xsl:when test="@pattern"><xsl:value-of select="@pattern"/></xsl:when>
			<xsl:when test="r:pattern"><xsl:value-of select="r:pattern"/></xsl:when>
			<xsl:otherwise>
				<xsl:message terminate = "yes">Routes list name is required</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="handler">
		<xsl:choose>
			<xsl:when test="@handler"><ref name="{@handler}"/></xsl:when>
			<xsl:when test="r:handler/r:*">
				<xsl:apply-templates select="r:handler/r:*" mode="route-handler"/>
			</xsl:when>
			<xsl:when test="r:handler"><ref name="{r:handler}"/></xsl:when>
			<xsl:otherwise>
				<xsl:message terminate = "yes">Routes list name is required</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<component type="System.Web.Routing.Route" singleton="false">
		<constructor-arg index="0">
			<value><xsl:value-of select="$pattern"/></value>
		</constructor-arg>
		<constructor-arg index="1">
			<xsl:copy-of select="msxsl:node-set($handler)/*"/>
		</constructor-arg>
		<property name="DataTokens">
			<component type="System.Web.Routing.RouteValueDictionary" singleton="false">
				<constructor-arg index='0'>
					<map>
						<xsl:for-each select='r:token'>
							<entry key="{@key}"><value><xsl:value-of select="."/></value></entry>
						</xsl:for-each>
					</map>
				</constructor-arg>
			</component>
		</property>
		<property name="Constraints">
			<component type="System.Web.Routing.RouteValueDictionary" singleton="false">
				<constructor-arg index='0'>
					<map>
						<xsl:for-each select='r:value[@regex or r:regex]'>
							<entry key="{@key}">
									<value>
										<xsl:choose>
											<xsl:when test="@regex"><xsl:value-of select="@regex"/></xsl:when>
											<xsl:when test="regex"><xsl:value-of select="regex"/></xsl:when>
										</xsl:choose>
									</value>
							</entry>
						</xsl:for-each>
					</map>
				</constructor-arg>
			</component>			
		</property>
		<property name="Defaults">
			<component type="System.Web.Routing.RouteValueDictionary" singleton="false">
				<constructor-arg index='0'>
					<map>
						<xsl:for-each select='r:value[@default or r:default]'>
							<entry key="{@key}">
								<value>
									<xsl:choose>
										<xsl:when test="@default">
											<xsl:value-of select="@default"/>
										</xsl:when>
										<xsl:when test="default">
											<xsl:value-of select="default"/>
										</xsl:when>
									</xsl:choose>
								</value>
							</entry>
						</xsl:for-each>
					</map>
				</constructor-arg>
			</component>
		</property>
	</component>	
</xsl:template>

<xsl:template match="r:page" mode="route-handler">
	<xsl:call-template name="route-page-handler">
		<xsl:with-param name="name"></xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="r:page-handler" name="route-page-handler">
	<xsl:param name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="path">
		<xsl:choose>
			<xsl:when test="@path"><xsl:value-of select="@path"/></xsl:when>
			<xsl:when test="r:path"><xsl:value-of select="r:path"/></xsl:when>
			<xsl:otherwise>
				<xsl:message terminate = "yes">Virtual path to page is required</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<component type="NReco.Web.Site.WebFormRouteHandler`1[[System.Web.UI.Page,System.Web]]" singleton="false">
		<xsl:if test="not($name='')">
			<xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
		</xsl:if>
		<constructor-arg index="0">
			<value><xsl:value-of select="$path"/></value>
		</constructor-arg>
	</component>
</xsl:template>
	
</xsl:stylesheet>
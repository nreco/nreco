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
			<map>
				<xsl:for-each select="r:route">
					<entry>
						<xsl:attribute name="key">
							<xsl:choose>
								<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:apply-templates select="."/>
					</entry>
				</xsl:for-each>
			</map>
		</property>
	</component>
	
</xsl:template>

<xsl:template match="r:route">
	<xsl:param name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:when test="r:name"><xsl:value-of select="r:name"/></xsl:when>
		</xsl:choose>
	</xsl:param>
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
				<xsl:message terminate = "yes">Route handler is required</xsl:message>
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
						<xsl:if test="not($name='') and not(r:token/@key='routeName')">
							<entry key="routeName"><value><xsl:value-of select="$name"/></value></entry>
						</xsl:if>
						
						<xsl:for-each select='r:token'>
							<entry key="{@key}">
								<xsl:choose>
									<xsl:when test="r:list[@type]">
										<component type="NI.Winter.ArrayFactory,NI.Winter" singleton="false">
											<property name="Elements">
												<list>
													<xsl:for-each select="r:list/r:entry">
														<entry><value><xsl:value-of select="."/></value></entry>
													</xsl:for-each>
												</list>
											</property>
											<property name="ElementType">
												<type>
													<xsl:choose>
														<xsl:when test="r:list/@type = 'string'">System.String,mscorlib</xsl:when>
														<xsl:otherwise><xsl:value-of select="r:list/@type"/></xsl:otherwise>
													</xsl:choose>
												</type>
											</property>
										</component>
									</xsl:when>
									<xsl:otherwise><value><xsl:value-of select="."/></value></xsl:otherwise>
								</xsl:choose>	
							</entry>
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
											<xsl:when test="r:regex"><xsl:value-of select="r:regex"/></xsl:when>
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
										<xsl:when test="r:default">
											<xsl:value-of select="r:default"/>
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

<xsl:template match="r:axd-handler" name="route-axd-handler">
	<xsl:param name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="type">
		<xsl:choose>
			<xsl:when test="@type"><xsl:value-of select="@type"/></xsl:when>
			<xsl:when test="r:type"><xsl:value-of select="r:type"/></xsl:when>
			<xsl:otherwise>
				<xsl:message terminate = "yes">Handler type is required</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<component type="NReco.Web.Site.AxdRouteHandler" singleton="false">
		<xsl:if test="not($name='')">
			<xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
		</xsl:if>
		<property name="HandlerType">
			<component type="NI.Winter.StaticMethodInvokingFactory,NI.Winter" singleton="false">
				<property name="TargetType"><type>System.Web.Compilation.BuildManager,System.Web</type></property>
				<property name="TargetMethod"><value>GetType</value></property>
				<property name="TargetMethodArgTypes">
					<list>
						<entry><type>System.String,mscorlib</type></entry>
						<entry><type>System.Boolean,mscorlib</type></entry>
						<entry><type>System.Boolean,mscorlib</type></entry>
					</list>
				</property>
				<property name="TargetMethodArgs">
					<list>
						<entry><value><xsl:value-of select="$type"/></value></entry>
						<entry><value>true</value></entry>
						<entry><value>false</value></entry>
					</list>
				</property>
			</component>
		</property>
	</component>
</xsl:template>
	
</xsl:stylesheet>
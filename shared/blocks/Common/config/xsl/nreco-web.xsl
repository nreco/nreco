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
				xmlns:r="urn:schemas-nreco:nreco:web:v1"
				xmlns:nr="urn:schemas-nreco:nreco:core:v1"
				exclude-result-prefixes="r msxsl">

<!-- NReco.Web model -->
<xsl:template match='r:dispatcher'>
	<xsl:param name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Dispatcher name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<component name="{$name}" type="NReco.Web.ActionDispatcher" singleton="true" lazy-init="true">
		<property name="Handlers">
			<list>
				<xsl:for-each select="r:handlers/r:*">
					<entry>
						<xsl:apply-templates select="." mode="action-dispatcher-handler"/>
					</entry>
				</xsl:for-each>
			</list>		  
		</property>	
		<property name="Filters">
			<list>
				<xsl:for-each select="r:filters/r:*">
					<entry>
						<xsl:apply-templates select="." mode="action-dispatcher-filter"/>
					</entry>
				</xsl:for-each>
			</list>		  
		</property>	
	</component>
</xsl:template>

<xsl:template match="r:controltree" mode="action-dispatcher-handler">
	<component type="NReco.Web.ActionHandlers.ControlTreeHandler,NReco.Web" singleton="false"/>
</xsl:template>

<xsl:template match="r:datasource" mode="action-dispatcher-handler">
	<component type="NReco.Web.ActionHandlers.DataSourceHandler,NReco.Web" singleton="false"/>
</xsl:template>

<xsl:template match="r:*" mode="action-dispatcher-handler">
	<xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="r:controlorder" mode="action-dispatcher-filter">
	<component type="NReco.Web.ActionFilters.ControlHandlerOrderFilter,NReco.Web" singleton="false"/>
</xsl:template>

<xsl:template match="r:transaction" mode="action-dispatcher-filter">
	<component type="NReco.Web.ActionFilters.TransactionFilter,NReco.Web" singleton="false">
		<xsl:if test="r:match/nr:*">
			<property name="Match">
				<xsl:apply-templates select="r:match/nr:*" mode="nreco-provider"/>
			</property>
		</xsl:if>
		<property name="Transaction">
			<component type="NReco.Composition.Transaction`1[[NReco.Web.ActionContext]],NReco.Composition" singleton="false">
				<property name="Begin">
					<xsl:apply-templates select="r:begin/nr:*" mode="nreco-operation"/>
				</property>
				<property name="Commit">
					<xsl:apply-templates select="r:commit/nr:*" mode="nreco-operation"/>
				</property>
				<property name="Abort">
					<xsl:apply-templates select="r:abort/nr:*" mode="nreco-operation"/>
				</property>
			</component>
		</property>		
	</component>
</xsl:template>
		
<xsl:template match="r:*" mode="action-dispatcher-filter">
	<xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="nr:webroute" mode="nreco-provider">
	<xsl:param name='name'/>
	<xsl:variable name="dsm">
		<nr:provider>
			<xsl:if test="not($name='')"><xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute></xsl:if>
			<nr:invoke method="GetRouteUrl">
				<nr:target><nr:type>NReco.Web.Site.ControlExtensions</nr:type></nr:target>
				<nr:args>
					<nr:const/><!-- control instance - may be null -->
					<nr:const><xsl:value-of select="@name"/></nr:const>
					<xsl:copy-of select="node()"/>
				</nr:args>
			</nr:invoke>
		</nr:provider>
	</xsl:variable>
	<xsl:apply-templates select="msxsl:node-set($dsm)/node()"/>
</xsl:template>

<xsl:template match="nr:userkey" mode="nreco-provider">
	<xsl:param name='name'/>
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select='$name'/>
		<xsl:with-param name='type'>NReco.Web.Site.Security.UserKeyProvider,NReco.Web.Site</xsl:with-param>
		<xsl:with-param name='injections'>
			<xsl:choose>
				<xsl:when test="@anonymous='dbnull'">
					<property name="AnonymousKey">
						<component type="NI.Winter.StaticFieldInvokingFactory,NI.Winter" singleton="false">
							<property name="TargetType">
								<type>System.DBNull,mscorlib</type>
							</property>
							<property name="TargetField">
								<value>Value</value>
							</property>
						</component>						
					</property>
				</xsl:when>
				<xsl:when test="@anonymous='empty'"><property name="AnonymousKey"><value></value></property></xsl:when>
				<xsl:when test="@anonymous='zero'"><property name="AnonymousKey"><value>0</value></property></xsl:when>
			</xsl:choose>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="r:ref">
	<ref name="{@name}"/>
</xsl:template>


</xsl:stylesheet>
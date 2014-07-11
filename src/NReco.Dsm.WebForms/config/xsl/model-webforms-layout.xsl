<!--
NReco library (http://nreco.googlecode.com/)
Copyright 2008-2014 Vitaliy Fedorchenko
Distributed under the LGPL licence
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->	
<xsl:stylesheet version='1.0' 
				xmlns:l="urn:schemas-nreco:webforms:layout:v2"
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:NIData="urn:remove/NIData"
				xmlns:NRecoWebForms="urn:remove/NRecoWebForms"
				xmlns:asp="urn:remove/AspNet"
				xmlns:UserControl="urn:remove/UserControl"
				xmlns:UserControlEditor="urn:remove/UserControlEditor"
				exclude-result-prefixes="msxsl">

	<xsl:import href="model-webforms-layout-common.xsl"/>
	<xsl:output method='xml' indent='yes' />
	
	<xsl:template match='l:model'>
		<files>
			<xsl:for-each select='l:views/l:view'>
				<file name='{@name}.ascx'>
					<xsl:apply-templates select='.'/>
				</file>
			</xsl:for-each>
		</files>
	</xsl:template>
	
	<xsl:template match="l:view">
<!-- form control header -->
<xsl:variable name="sessionContext">
	<xsl:choose>
		<xsl:when test="@sessiondatacontext='1' or @sessiondatacontext='true'">true</xsl:when>
		<xsl:otherwise>false</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
@@lt;%@ Control Language="c#" AutoEventWireup="false" Inherits="NReco.Dsm.WebForms.LayoutUserControl" UseSessionDataContext="<xsl:value-of select="$sessionContext"/>" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %@@gt;
@@lt;%@ Import namespace="NI.Ioc"%@@gt;
@@lt;%@ Import namespace="NI.Data.Web"%@@gt;
@@lt;%@ Import namespace="System.Data"%@@gt;
				<xsl:call-template name="view-register-controls"/>
				
				<script language="c#" runat="server">
				protected override void OnInit(EventArgs e) {
					AppContext.EventBroker.Subscribe@@lt;ActionEventArgs@@gt;(HandleCustomActions);
					<xsl:call-template name="view-register-control-code"/>
					base.OnInit(e);
					<xsl:apply-templates select="l:action[@name='init']/l:*" mode="csharp-code"/>
				}
				protected override void OnLoad(EventArgs e) {
					base.OnLoad(e);
					if (!IsPostBack) {
						<xsl:apply-templates select="l:action[@name='load']/l:*" mode="csharp-code"/>
					}
				}
				protected override void OnPreRender(EventArgs e) {
					base.OnPreRender(e);
					<xsl:apply-templates select="l:action[@name='prerender']/l:*" mode="csharp-code"/>
				}

				protected void HandleCustomActions(object sender, ActionEventArgs e) {
					var senderControl = sender as Control;
					if (senderControl==null) return;
					if (senderControl!=this @@amp;@@amp; ControlUtils.GetParents@@lt;LayoutUserControl@@gt;(senderControl).FirstOrDefault()!=this)
						return;

					object context = e is ActionView.ActionViewEventArgs ? 
						(object) ((ActionView.ActionViewEventArgs)e).Values : 
						(e.Args is CommandEventArgs ? ((CommandEventArgs)e.Args).CommandArgument : null);
					<xsl:for-each select="l:command">
					if (e.ActionName=="<xsl:value-of select="@name"/>") {
						<xsl:apply-templates select="l:*" mode="csharp-code">
							<xsl:with-param name="context">context</xsl:with-param>
						</xsl:apply-templates>
					}
					</xsl:for-each>
				}
				</script>
				<xsl:apply-templates select="l:datasources/l:*" mode="view-datasource"/>
				<xsl:apply-templates select="l:*[not(name()='datasources' or name()='action' or name()='command')]" mode="aspnet-renderer"/>
	</xsl:template>
	
</xsl:stylesheet>
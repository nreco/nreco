<xsl:stylesheet version='1.0' 
				xmlns:e="urn:schemas-nreco:nreco:entity:v1"
				xmlns:l="urn:schemas-nreco:nreco:web:layout:v1"
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:Dalc="urn:remove"
				xmlns:NReco="urn:remove"
				xmlns:asp="urn:remove"
				exclude-result-prefixes="msxsl">

	<xsl:output method='xml' indent='yes' />

	<xsl:template match="l:field[l:editor/l:markitup]" mode="form-view-editor">
		<xsl:param name="mode"/>
		<xsl:variable name="uniqueId"><xsl:value-of select="@name"/>_<xsl:value-of select="$mode"/>_<xsl:value-of select="generate-id(.)"/></xsl:variable>
		<asp:TextBox id="{@name}" runat="server" Text='@@lt;%# Bind("{@name}") %@@gt;' TextMode="multiline" OnLoad="markitupEditor_{$uniqueId}_onLoad">
			<xsl:if test="l:editor/l:markitup/@rows">
				<xsl:attribute name="Rows"><xsl:value-of select="l:editor/l:markitup/@rows"/></xsl:attribute>
			</xsl:if>
		</asp:TextBox>
		<script language="c#" runat="server">
		protected void markitupEditor_<xsl:value-of select="$uniqueId"/>_onLoad(object sender, EventArgs e) {
			var scriptName = "js/markitup/jquery.markitup.pack.js";
			if (!Page.ClientScript.IsClientScriptBlockRegistered(this.GetType(), scriptName)) {
				Page.ClientScript.RegisterClientScriptBlock(this.GetType(), scriptName, "@@lt;s"+"cript language='javascript' src='"+scriptName+"'@@gt;@@lt;/s"+"cript@@gt;");
			}
		}
		</script>
		<link rel="stylesheet" type="text/css" href="js/markitup/skins/simple/style.css" />
		<link rel="stylesheet" type="text/css" href="js/markitup/sets/default/style.css" />
		
		<script language="javascript">
		jQuery('#@@lt;%# Container.FindControl("<xsl:value-of select="@name"/>").ClientID %@@gt;').markItUp(
			<![CDATA[
			{	
				onShiftEnter:  	{keepDefault:false, replaceWith:'<br />\n'},
				onCtrlEnter:  	{keepDefault:false, openWith:'\n<p>', closeWith:'</p>'},
				onTab:    		{keepDefault:false, replaceWith:'    '},
				markupSet:  [ 	
					{name:'Bold', key:'B', openWith:'(!(<strong>|!|<b>)!)', closeWith:'(!(</strong>|!|</b>)!)', className: "markItUpButtonBold" },
					{name:'Italic', key:'I', openWith:'(!(<em>|!|<i>)!)', closeWith:'(!(</em>|!|</i>)!)', className: "markItUpButtonItalic"  },
					{name:'Stroke through', key:'S', openWith:'<del>', closeWith:'</del>', className: "markItUpButtonStroke" },
					{separator:'---------------' },
					{name:'Picture', className: "markItUpButtonInsPicture", key:'P', replaceWith:'<img src="[![Source:!:http://]!]" alt="[![Alternative text]!]" />' },
					{name:'Link', className: "markItUpButtonInsLink", key:'L', openWith:'<a href="[![Link:!:http://]!]"(!( title="[![Title]!]")!)>', closeWith:'</a>', placeHolder:'Your text to link...' },
					{separator:'---------------' },
					{name:'Clean', className: "markItUpButtonClean", replaceWith:function(markitup) { return markitup.selection.replace(/<(.*?)>/g, "") } },		
					{name:'Preview', className:'preview',  call:'preview'}
				]
			}
			]]>
		);
		</script>
	</xsl:template>
	
</xsl:stylesheet>
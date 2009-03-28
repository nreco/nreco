<xsl:stylesheet version='1.0' 
								xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
								xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
								exclude-result-prefixes="msxsl">

	<xsl:output method='xml' indent='yes' />

	<xsl:template match='/layouts'>
		<files>
			<xsl:apply-templates select="*"/>
		</files>
	</xsl:template>
	
	<xsl:template match="form">
		<file name="templates/generated/{@name}.ascx">
			<content>
<xsl:text disable-output-escaping="yes">
&lt;%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.WebControls.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %&gt;
</xsl:text>		111
			</content>
		</file>
	</xsl:template>
	
</xsl:stylesheet>
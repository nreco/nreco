<xsl:stylesheet version='1.0' 
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:Dalc="http://schemas.microsoft.com/"
				xmlns:NReco="http://schemas.microsoft.com/"
				exclude-result-prefixes="msxsl Dalc NReco">

	<xsl:output method='html' indent='yes' />

	<xsl:template match='/model'>
		<files>
			<xsl:apply-templates select="layouts/*"/>
		</files>
	</xsl:template>
	
	<xsl:template match="form">
		<xsl:variable name="dalcName" select="/model/dalc/@name"/>
		<file name="templates/generated/{@name}.ascx">
			<content>
<!-- form control header -->
<xsl:text disable-output-escaping="yes">
<![CDATA[<]]>%@ Control Language="c#" AutoEventWireup="false" Inherits="System.Web.UI.WebControls.UserControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %<![CDATA[>]]>
</xsl:text>
1
<Dalc:DalcDataSource runat="server" id="pagesDataSource" 
	Dalc='&lt;%$ service:{$dalcName} %>' SourceName="pages" 
	DataSetMode="true" AutoIncrementNames="id" DataKeyNames="id"
	OnSelected='DataSelectedHandler'
	OnUpdated="DataUpdatedHandler"
	OnInserted="DataUpdatedHandler"/>
<NReco:ActionDataSource runat="server" id="actionPagesEntitySource" DataSourceID="pagesDataSource"/>


			</content>
		</file>
	</xsl:template>
	
</xsl:stylesheet>
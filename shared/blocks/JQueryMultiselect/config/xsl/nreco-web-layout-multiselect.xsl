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

	<xsl:template match="l:field[l:editor/l:multiselect]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="MultiselectEditor" src="~/templates/editors/MultiselectEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:multiselect]" mode="form-view-editor">
		<Plugin:MultiselectEditor runat="server" xmlns:Plugin="urn:remove"
			DalcServiceName="{$dalcName}"
			LookupServiceName="{l:editor/l:multiselect/@lookup}"
			RelationSourceName="{l:editor/l:multiselect/l:relation/@sourcename}"
			LFieldName="{l:editor/l:multiselect/l:relation/@left}"
			RFieldName="{l:editor/l:multiselect/l:relation/@right}">
			<xsl:choose>
				<xsl:when test="l:editor/l:multiselect/@id">
					<xsl:attribute name="EntityId">@@lt;%# DataBinder.Eval(Container.DataItem, "<xsl:value-of select="l:editor/l:multiselect/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# "<xsl:value-of select="l:editor/l:multiselect/@id"/>" %@@gt;</xsl:attribute>
				</xsl:when>
				<!--xsl:otherwise>
					<xsl:attribute name="EntityId">@@lt;%# FormView.DataKey.Value %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# FormView.DataKeyNames[0] %@@gt;</xsl:attribute>
				</xsl:otherwise-->
			</xsl:choose>
		</Plugin:MultiselectEditor>
	</xsl:template>		
	
</xsl:stylesheet>
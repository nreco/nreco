<xsl:stylesheet version='1.0' 
				xmlns:e="urn:schemas-nreco:nreco:entity:v1"
				xmlns:l="urn:schemas-nreco:nreco:web:layout:v1"
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:Plugin="urn:remove"
				xmlns:NReco="urn:remove"
				xmlns:asp="urn:remove"
				exclude-result-prefixes="msxsl">

	<xsl:output method='xml' indent='yes' />

	<xsl:template match="l:field[l:editor/l:datepicker]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="DatePickerEditor" src="~/templates/editors/DatePickerEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:datepicker]" mode="form-view-editor">
		<Plugin:DatePickerEditor runat="server" 
			id="{@name}"
			ObjectValue='@@lt;%# Bind("{@name}") %@@gt;'/>
	</xsl:template>	
	
</xsl:stylesheet>
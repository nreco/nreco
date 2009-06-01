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
	
	<xsl:template match="l:tabs" mode="aspnet-renderer">
		<xsl:variable name="uniqueId">jqTabs<xsl:value-of select="generate-id(.)"/></xsl:variable>
		<div id="{$uniqueId}" style="display:none">
			<ul>
				<xsl:for-each select="l:tab">
					<li><a href="#{$uniqueId}_{position()}"><xsl:value-of select="@caption"/></a></li>
				</xsl:for-each>
			</ul>
			<xsl:for-each select="l:tab">
				<div id="{$uniqueId}_{position()}">
					<xsl:apply-templates select="node()" mode="aspnet-renderer"/>
				</div>
			</xsl:for-each>
		</div>
		<script type="text/javascript">
			jQuery(function() {
				jQuery("#<xsl:value-of select="$uniqueId"/>").tabs().show();
			});
		</script>
	</xsl:template>
	
	<xsl:template match="l:widget" mode="aspnet-renderer">
		<xsl:variable name="uniqueId" select="generate-id(.)"/>
		<div id="widgetHeader{$uniqueId}" class="ui-widget-header ui-corner-top nreco-widget-header">
			<xsl:value-of select="@caption"/>
		</div>
		<div id="widgetContent{$uniqueId}" class="ui-corner-bottom ui-widget-content nreco-widget-content">
			<xsl:apply-templates select="node()" mode="aspnet-renderer"/>
		</div>
	</xsl:template>
	
	
</xsl:stylesheet>
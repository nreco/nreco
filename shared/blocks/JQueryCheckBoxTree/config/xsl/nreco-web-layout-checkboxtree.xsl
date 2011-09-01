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

	<xsl:template match="l:field[l:editor/l:checkboxtree]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="CheckBoxTreeEditor" src="~/templates/editors/CheckBoxTreeEditor.ascx" %@@gt;
	</xsl:template>	
	
	<xsl:template match="l:field[l:editor/l:checkboxtree]" mode="form-view-editor">
		<xsl:param name="context"/>	
		<Plugin:CheckBoxTreeEditor runat="server" xmlns:Plugin="urn:remove"
			DalcServiceName="{$dalcName}"
			DsFactoryServiceName="{$datasetFactoryName}"
			LookupServiceName="{l:editor/l:checkboxtree/l:lookup/@name}"
			TextFieldName="{l:editor/l:checkboxtree/l:lookup/@text}"
			ValueFieldName="{l:editor/l:checkboxtree/l:lookup/@value}"
			RelationSourceName="{l:editor/l:checkboxtree/l:relation/@sourcename}"
			ParentFieldName="{l:editor/l:checkboxtree/l:lookup/@parent}"
			LFieldName="{l:editor/l:checkboxtree/l:relation/@left}"
			RFieldName="{l:editor/l:checkboxtree/l:relation/@right}">
			<xsl:if test="@name or not(l:editor/l:checkboxtree/l:relation)">
				<xsl:attribute name="id"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="l:editor/l:checkboxtree/@id">
					<xsl:attribute name="EntityId">@@lt;%# Eval("<xsl:value-of select="l:editor/l:checkboxtree/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField"><xsl:value-of select="l:editor/l:checkboxtree/@id"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="l:editor/l:checkboxtree/l:relation/@id">
					<xsl:attribute name="EntityId">@@lt;%# Eval("<xsl:value-of select="l:editor/l:checkboxtree/l:relation/@id"/>") %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField"><xsl:value-of select="l:editor/l:checkboxtree/l:relation/@id"/></xsl:attribute>
				</xsl:when>
				<!--xsl:otherwise>
					<xsl:attribute name="EntityId">@@lt;%# FormView.DataKey.Value %@@gt;</xsl:attribute>
					<xsl:attribute name="EntityIdField">@@lt;%# FormView.DataKeyNames[0] %@@gt;</xsl:attribute>
				</xsl:otherwise-->
			</xsl:choose>
			<xsl:if test="l:editor/l:checkboxtree/l:default/@provider">
				<xsl:attribute name="DefaultValueServiceName"><xsl:value-of select="l:editor/l:checkboxtree/l:default/@provider"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxtree/l:lookup/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:checkboxtree/l:lookup/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="LookupDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxtree/l:default/l:*">
				<xsl:variable name="contextExpr"><xsl:apply-templates select="l:editor/l:checkboxtree/l:default/l:*" mode="csharp-expr"><xsl:with-param name="context" select="$context"/></xsl:apply-templates></xsl:variable>
				<xsl:attribute name="DefaultDataContext">@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="l:editor/l:checkboxtree/l:oncheck/@ancestors">
				<xsl:attribute name="OnCheckAncestors"><xsl:value-of select="l:editor/l:checkboxtree/l:oncheck/@ancestors"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxtree/l:oncheck/@descendants">
				<xsl:attribute name="OnCheckDescendants"><xsl:value-of select="l:editor/l:checkboxtree/l:oncheck/@descendants"/></xsl:attribute>
			</xsl:if>
			
			<xsl:if test="l:editor/l:checkboxtree/l:onuncheck/@ancestors">
				<xsl:attribute name="OnUncheckAncestors"><xsl:value-of select="l:editor/l:checkboxtree/l:onuncheck/@ancestors"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:checkboxtree/l:onuncheck/@descendants">
				<xsl:attribute name="OnUncheckDescendants"><xsl:value-of select="l:editor/l:checkboxtree/l:onuncheck/@descendants"/></xsl:attribute>
			</xsl:if>			

			<xsl:if test="l:editor/l:checkboxtree/@width">
				<xsl:attribute name="Width"><xsl:value-of select="l:editor/l:checkboxtree/@width"/></xsl:attribute>
			</xsl:if>			
			
		</Plugin:CheckBoxTreeEditor>
	</xsl:template>		
	
</xsl:stylesheet>
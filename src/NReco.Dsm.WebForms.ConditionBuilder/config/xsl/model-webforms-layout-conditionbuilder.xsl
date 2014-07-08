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

	<xsl:output method='xml' indent='yes' />


	<xsl:template match="l:field[l:editor/l:conditionbuilder]" mode="register-editor-control">
		@@lt;%@ Register TagPrefix="Plugin" tagName="ConditionBuilderEditor" src="~/templates/editors/ConditionBuilderEditor.ascx" %@@gt;
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:conditionbuilder]" mode="form-view-editor">
		<xsl:param name="context">null</xsl:param>
		<xsl:param name="formUid"/>

		<xsl:variable name="uniqueId">
			<xsl:choose>
				<xsl:when test="@name">
					<xsl:value-of select="@name"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<Plugin:ConditionBuilderEditor xmlns:Plugin="urn:remove" runat="server" id="{@name}"
			OnComposeFieldsData="ConditionBuilderEditor_{$uniqueId}_OnComposeFieldsData"
			ValidationGroup="{$formUid}">
			<xsl:if test="l:editor/l:conditionbuilder/@conditionfield">
				<xsl:attribute name="ConditionsFieldName"><xsl:value-of select="l:editor/l:conditionbuilder/@conditionfield"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="l:editor/l:conditionbuilder/@expressionfield">
				<xsl:attribute name="ExpressionFieldName"><xsl:value-of select="l:editor/l:conditionbuilder/@expressionfield"/></xsl:attribute>
			</xsl:if>	
			<xsl:if test="l:editor/l:conditionbuilder/@relexfield">
				<xsl:attribute name="RelexFieldName"><xsl:value-of select="l:editor/l:conditionbuilder/@relexfield"/></xsl:attribute>
			</xsl:if>				
			
			<xsl:if test="l:editor/l:conditionbuilder/l:context">
				<xsl:variable name="contextExpr">
					<xsl:apply-templates select="l:editor/l:conditionbuilder/l:context/node()" mode="csharp-expr">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:attribute name="DataContext">
					@@lt;%# <xsl:value-of select="$contextExpr"/> %@@gt;
				</xsl:attribute>
			</xsl:if>
		</Plugin:ConditionBuilderEditor>

		<script runat="server" language="c#">
			public System.Collections.Generic.IList@@lt;System.Collections.Generic.IDictionary@@lt;string,object@@gt;@@gt; ConditionBuilderEditor_<xsl:value-of select="$uniqueId"/>_OnComposeFieldsData(object dataContext) {
			var fieldsData = new System.Collections.Generic.List@@lt;System.Collections.Generic.IDictionary@@lt;string,object@@gt;@@gt;();
			System.Collections.Generic.IDictionary@@lt;string,object@@gt; fieldData;
			<xsl:for-each select="l:editor/l:conditionbuilder/l:field">
				fieldData = <xsl:apply-templates select="." mode="conditionbuilder-field-descriptor-code"/>;
				<xsl:if test="l:relexcondition">
					fieldData["relexcondition"] = "<xsl:value-of select="normalize-space(l:relexcondition)"/>";
				</xsl:if>
				fieldsData.Add(fieldData);
			</xsl:for-each>

			return fieldsData;
			}
		</script>
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:numbertextbox]" mode="conditionbuilder-field-descriptor-code">
		NReco.Dsm.WebForms.ConditionBuilder.ConditionBuilderHelper.ComposeNumberTextFieldDescriptor("<xsl:value-of select="@name"/>", AppContext.GetLabel("<xsl:value-of select="@caption"/>"))
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:textbox]" mode="conditionbuilder-field-descriptor-code">
		NReco.Dsm.WebForms.ConditionBuilder.ConditionBuilderHelper.ComposeTextFieldDescriptor("<xsl:value-of select="@name"/>", AppContext.GetLabel("<xsl:value-of select="@caption"/>"))
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:dropdownlist]" mode="conditionbuilder-field-descriptor-code">
		NReco.Dsm.WebForms.ConditionBuilder.ConditionBuilderHelper.ComposeDropDownFieldDescriptor(
		"<xsl:value-of select="@name"/>", AppContext.GetLabel("<xsl:value-of select="@caption"/>"),
		"<xsl:value-of select="l:editor/l:dropdownlist/@lookup"/>", dataContext, "<xsl:value-of select="l:editor/l:dropdownlist/@text"/>", "<xsl:value-of select="l:editor/l:dropdownlist/@value"/>"
		)
	</xsl:template>

	<xsl:template match="l:field[l:editor/l:datepicker]" mode="conditionbuilder-field-descriptor-code">
		NReco.Dsm.WebForms.ConditionBuilder.ConditionBuilderHelper.ComposeDatePickerFieldDescriptor("<xsl:value-of select="@name"/>", AppContext.GetLabel("<xsl:value-of select="@caption"/>") )
	</xsl:template>

</xsl:stylesheet>
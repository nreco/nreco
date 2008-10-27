<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
	<xsl:import href="nreco.xsl"/>

	<xsl:output method='xml' indent='yes' />


	<xsl:template match='/components'>
		<xsl:apply-templates select='*'/>
	</xsl:template>

	<xsl:template match='choose'>
		<xsl:variable name='model'>
			<chain name="{@name}">
				<prv-call result="state">
					<target><const-prv/></target>
				</prv-call>
				<xsl:apply-templates select="if" mode="choose"/>
				<xsl:if test="default">
					<prv-call if="#state==null or #state==''" result="state">
						<target>
							<xsl:apply-templates select="default/*" mode="choose-op"/>
						</target>
					</prv-call>
				</xsl:if>
			</chain>
		</xsl:variable>
		<xsl:apply-templates select='msxsl:node-set($model)/*'/>
	</xsl:template>

	<xsl:template match='if' mode='choose'>
		<prv-call if="#msg.IndexOf('{@msg}')>=0" result="state">
			<target>
				<xsl:apply-templates select="*" mode="choose-op"/>
			</target>
		</prv-call>
	</xsl:template>

	<xsl:template match='answer' mode='choose-op'>
		<csharp>
			Console.WriteLine( "<xsl:value-of select="."/>" );
			result = "wait";
		</csharp>		
	</xsl:template>

	<xsl:template match='exit' mode='choose-op'>
		<const-prv value='exit'/>
	</xsl:template>


</xsl:stylesheet>
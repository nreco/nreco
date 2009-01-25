<xsl:stylesheet version='1.0' 
								xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
								xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
								xmlns:nr="urn:schemas-nreco:nreco:core:v1"
								exclude-result-prefixes="msxsl">
	<xsl:import href="nreco.xsl"/>

	<xsl:output method='xml' indent='yes' />

	<xsl:template match='/components'>
		<xsl:apply-templates select='*'/>
	</xsl:template>

	<xsl:template match='choose'>
		<xsl:variable name='model'>
			<nr:chain name="{@name}">
				<nr:provide result="state">
					<nr:target>
						<nr:const/>
					</nr:target>
				</nr:provide>
				<xsl:apply-templates select="if" mode="choose"/>
				<xsl:if test="default">
					<nr:provide if="#state==null or #state==''" result="state">
						<nr:target>
							<xsl:apply-templates select="default/*" mode="choose-op"/>
						</nr:target>
					</nr:provide>
				</xsl:if>
			</nr:chain>
		</xsl:variable>
		<xsl:apply-templates select='msxsl:node-set($model)/*'/>
	</xsl:template>

	<xsl:template match='if' mode='choose'>
		<nr:provide if="#msg.IndexOf('{@msg}')>=0" result="state">
			<nr:target>
				<xsl:apply-templates select="*" mode="choose-op"/>
			</nr:target>
		</nr:provide>
	</xsl:template>

	<xsl:template match='answer' mode='choose-op'>
		<nr:csharp>
			Console.WriteLine( "<xsl:value-of select="."/>" );
			result = "wait";
		</nr:csharp>		
	</xsl:template>

	<xsl:template match='exit' mode='choose-op'>
		<nr:const value='exit'/>
	</xsl:template>


</xsl:stylesheet>
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
				xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:e="urn:schemas-nreco:data:schema:v2"
				xmlns="urn:schemas-nicnet:ioc:v2"
				exclude-result-prefixes="msxsl">

<xsl:template match='e:model'>
	<components>
		<xsl:apply-templates select='e:*'/>
	</components>
</xsl:template>
				
<xsl:template match="e:schema-create-sql">
	<component name='{@name}' type='NI.Ioc.ReplacingFactory,NI.Ioc'>
		<property name="TargetObject">
			<value>
				<xsl:choose>
					<xsl:when test="e:dialect/e:mysql">
						DROP PROCEDURE IF EXISTS __init_schema;
						CREATE PROCEDURE __init_schema()
						BEGIN
						<xsl:apply-templates select="e:tables/e:table" mode="generate-mysql-create-sql"/>
						END;
						CALL __init_schema;
						<xsl:apply-templates select="e:tables/e:table" mode="generate-mysql-create-trigger-sql"/>
					</xsl:when>
					<xsl:when test="e:dialect/e:mssql">
						<xsl:variable name="compatibilityMode">
							<xsl:choose>
								<xsl:when test="e:dialect/e:mssql/@compatibility='sql2000'">SQL2000</xsl:when>
								<xsl:when test="e:dialect/e:mssql/@compatibility='sql2005'">SQL2005</xsl:when>
								<xsl:otherwise>SQL2008</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:apply-templates select="e:tables/e:table" mode="generate-mssql-create-sql">
							<xsl:with-param name="compatibilityMode"><xsl:value-of select="$compatibilityMode"/></xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
				</xsl:choose>
			</value>
		</property>
	</component>
</xsl:template>

<xsl:template match="e:dataset-factory">
	<component name="{@name}" type="NI.Data.DataSetFactory,NI.Data" singleton="true" lazy-init="true">
			<property name="Schemas">
				<list>
					<xsl:for-each select="e:tables/e:table">
						<entry>
							<component type="NI.Data.DataSetFactory+SchemaDescriptor,NI.Data" singleton="false">
								<property name="TableNames"><list><entry><value><xsl:value-of select="@name"/></value></entry></list></property>
								<property name="XmlSchema">
									<xml>
										<xsl:apply-templates select="." mode="generate-dataset-xmlschema"/>
									</xml>
								</property>
							</component>
						</entry>
					</xsl:for-each>
				</list>
			</property>
	</component>
</xsl:template>

<xsl:template match="e:table-sourcenames">
	<component name="{@name}" type="NI.Winter.ReplacingFactory" singleton="false" lazy-init="true">
		<property name="TargetObject">
			<list>
				<xsl:for-each select="e:table">
					<entry><value><xsl:value-of select="@name"/></value></entry>
					<xsl:if test="@versions='1' or @versions='true'">
						<entry><value><xsl:value-of select="@name"/>_versions</value></entry>
					</xsl:if>
					<xsl:if test="@log='1' or @log='true'">
						<entry><value><xsl:value-of select="@name"/>_log</value></entry>
					</xsl:if>
				</xsl:for-each>
			</list>
		</property>
	</component>
</xsl:template>
		
<xsl:template name="mssqlPrepareValue">
	<xsl:param name="string"/>
	<xsl:param name="field"/>
	<xsl:variable name="apos">&#x27;</xsl:variable>
	<xsl:if test="contains($string, $apos)"><xsl:value-of
		select="substring-before($string, $apos)" />''<xsl:call-template name="mssqlPrepareValue"><xsl:with-param name="string"><xsl:value-of select="substring-after($string, $apos)" /></xsl:with-param><xsl:with-param name="field" select="$field"/></xsl:call-template></xsl:if>
	<xsl:if test="not(contains($string, $apos))">
		<xsl:choose>
			<xsl:when test="$string='true' and ($field/@type='bool' or $field/@type='boolean')">1</xsl:when>
			<xsl:when test="$string='false' and ($field/@type='bool' or $field/@type='boolean')">0</xsl:when>
			<xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>		
		
<xsl:template match='e:table' mode="generate-mysql-create-sql">
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">table/@name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="fields" select="e:column"/>
	<xsl:variable name="verName"><xsl:value-of select="$name"/>_versions</xsl:variable>
	<xsl:variable name="logName"><xsl:value-of select="$name"/>_log</xsl:variable>
	IF NOT EXISTS(select * from information_schema.tables where table_schema=DATABASE() and table_name='<xsl:value-of select="$name"/>')
		THEN 
			CREATE TABLE <xsl:value-of select="$name"/> (
				<xsl:for-each select="e:column">
					<xsl:if test="position()!=1">,</xsl:if>
					<xsl:variable name="fldSql">
						<xsl:apply-templates select="." mode="generate-mysql-create-sql"/>
					</xsl:variable>
					<xsl:value-of select="normalize-space($fldSql)"/>
				</xsl:for-each>
				<xsl:variable name="pkNames">
					<xsl:for-each select="e:column[@pk='true']">
						<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="count(e:column)>0">,
				PRIMARY KEY ( <xsl:value-of select="normalize-space($pkNames)"/> )
				</xsl:if>
			) ENGINE=InnoDB;
			<!-- for mySQL lets use msSQL generate insert routine b/c insert command works for both -->
			<xsl:for-each select="e:data/e:entry[@add='setup']">
				<xsl:apply-templates select="." mode="generate-mysql-insert-sql">
					<xsl:with-param name="name" select="$name"/>
					<xsl:with-param name="fields" select="$fields"/>
				</xsl:apply-templates>;
			</xsl:for-each>
		END	IF;
	<!-- indexes -->
	<xsl:for-each select="e:data/e:index">
		<xsl:variable name="indexName">index_<xsl:value-of select="$name"/><xsl:for-each select="e:column">_<xsl:value-of select="@name"/></xsl:for-each></xsl:variable>
		IF NOT EXISTS(select * from information_schema.statistics where table_schema=DATABASE() and table_name='<xsl:value-of select="$name"/>' and index_name='<xsl:value-of select="$indexName"/>')
		THEN 		
			CREATE INDEX <xsl:value-of select="$indexName"/> ON <xsl:value-of select="$name"/>(
				<xsl:for-each select="e:column">
					<xsl:variable name="fldName" select="@name"/>
					<xsl:variable name="realField" select="$fields[@name=$fldName]"/>
					<xsl:if test="position()>1">,</xsl:if><xsl:value-of select="@name"/><xsl:if test="$realField/@maxlength>100">(100)</xsl:if>
				</xsl:for-each>
			);
		END IF;
	</xsl:for-each>		
		
	<xsl:if test="@versions='true' or @versions='1'">
		IF NOT EXISTS(select * from information_schema.tables where table_schema=DATABASE() and table_name='<xsl:value-of select="$verName"/>')
			THEN
				CREATE TABLE <xsl:value-of select="$verName"/> (
					version_id varchar(50) NOT NULL DEFAULT '',
					version_timestamp DATETIME NULL
					<xsl:for-each select="e:column">
						<xsl:if test="@name='version_id'">
							<xsl:message terminate = "yes">Entity with enabled versions cannot contain field with name 'version_id'</xsl:message>
						</xsl:if>
						<xsl:if test="@name='version_timestamp'">
							<xsl:message terminate = "yes">Entity with enabled versions cannot contain field with name 'version_timestamp'</xsl:message>
						</xsl:if>
						,
						<xsl:variable name="fldSql">
							<xsl:apply-templates select="." mode="generate-mysql-create-sql">
								<xsl:with-param name="allowAutoIncrement">0</xsl:with-param>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="normalize-space($fldSql)"/>
					</xsl:for-each>
					<xsl:variable name="verPkNames">
						<xsl:for-each select="e:column[@pk='true']">
							<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="count(e:column)>0">,
					PRIMARY KEY ( version_id, <xsl:value-of select="normalize-space($verPkNames)"/> )
					</xsl:if>
				);
			END IF;
	</xsl:if>		
	
	<xsl:if test="@log='true' or @log='1'">
		IF NOT EXISTS(select * from information_schema.tables where table_schema=DATABASE() and table_name='<xsl:value-of select="$logName"/>')
			THEN
				CREATE TABLE <xsl:value-of select="$logName"/> (
					id int NOT NULL AUTO_INCREMENT,
					timestamp DATETIME NULL,
					username varchar(500) NULL,
					action varchar(50) NULL
					<xsl:for-each select="e:column[@pk='true']">
						,
						<xsl:variable name="fldSql">
							<xsl:apply-templates select="." mode="generate-mysql-create-sql">
								<xsl:with-param name="allowAutoIncrement">0</xsl:with-param>
								<xsl:with-param name="name">record_<xsl:value-of select="@name"/></xsl:with-param>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="normalize-space($fldSql)"/>
					</xsl:for-each>
					,
					PRIMARY KEY ( id )
				);
			END IF;
	</xsl:if>
	
	<!-- add fields if table already exists -->
	<xsl:if test="count(e:column[not(@pk) or @pk='false' or @pk='0'])>0">
		<xsl:for-each select="e:column[not(@pk) or @pk='false' or @pk='0']">
			<xsl:variable name="fldSql">
				<xsl:apply-templates select="." mode="generate-mysql-create-sql"/>
			</xsl:variable>
			IF NOT EXISTS(select * from information_schema.columns where table_schema=DATABASE() and table_name='<xsl:value-of select="$name"/>' and column_name='<xsl:value-of select="@name"/>')
				THEN
					ALTER TABLE <xsl:value-of select="$name"/> ADD <xsl:value-of select="normalize-space($fldSql)"/>;
				END IF;
		</xsl:for-each>
		<!-- versions table -->
		<xsl:if test="@versions='true' or @versions='1'">
			<xsl:for-each select="e:column[not(@pk) or @pk='false' or @pk='0']">
				<xsl:variable name="fldSql">
					<xsl:apply-templates select="." mode="generate-mysql-create-sql">
						<xsl:with-param name="allowAutoIncrement">0</xsl:with-param>
					</xsl:apply-templates>
				</xsl:variable>
			IF NOT EXISTS(select * from information_schema.columns where table_schema=DATABASE() and table_name='<xsl:value-of select="$verName"/>' and column_name='<xsl:value-of select="@name"/>')
					THEN
						ALTER TABLE <xsl:value-of select="$verName"/> ADD <xsl:value-of select="normalize-space($fldSql)"/>;
					END IF;
			</xsl:for-each>
		</xsl:if>
	</xsl:if>	
	
	<!-- entity predefined data -->
	<xsl:variable name="pkFields" select="e:column[@pk='true']"/>
	<xsl:for-each select="e:data/e:entry[@add='not-exists' or not(@add)]">
		<xsl:variable name="entry" select="."/>
		<xsl:variable name="dataIdCondition">
			<xsl:for-each select="$pkFields">
				<xsl:variable name="pkFieldName" select="@name"/>
				<xsl:if test="position()!=1"> AND </xsl:if> <xsl:value-of select="$pkFieldName"/> = '<xsl:value-of select="$entry/e:column[@name=$pkFieldName]"/>'
			</xsl:for-each>
		</xsl:variable>
		IF NOT EXISTS(SELECT * FROM <xsl:value-of select="$name"/> WHERE <xsl:value-of select="$dataIdCondition"/>) THEN
			<xsl:apply-templates select="." mode="generate-mssql-insert-sql">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="fields" select="$fields"/>
			</xsl:apply-templates>;
		END IF;
	</xsl:for-each>	
	
</xsl:template>

<xsl:template match='e:table' mode="generate-mysql-create-trigger-sql">
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Entity name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="verName"><xsl:value-of select="$name"/>_versions</xsl:variable>
	<xsl:if test="@versions='true' or @versions='1'">
		<xsl:variable name="insertTriggerName">
			<xsl:choose>
				<xsl:when test="string-length($name)>35">__VerInsert_<xsl:value-of select="substring($name,0,52)"/></xsl:when>
				<xsl:otherwise>__TrackVersionsInsertTrigger_<xsl:value-of select="$name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="updateTriggerName">
			<xsl:choose>
				<xsl:when test="string-length($name)>35">__VerUpdate_<xsl:value-of select="substring($name,0,52)"/></xsl:when>
				<xsl:otherwise>__TrackVersionsUpdateTrigger_<xsl:value-of select="$name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- re-create versions trigger -->
		DROP TRIGGER IF EXISTS <xsl:value-of select="$insertTriggerName"/>;
		DROP TRIGGER IF EXISTS <xsl:value-of select="$updateTriggerName"/>;
		<xsl:variable name="allColumnsList">
			<xsl:for-each select="e:column"><xsl:value-of select="@name"/>,</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="allNEWColumnsList">
			<xsl:for-each select="e:column">NEW.<xsl:value-of select="@name"/>,</xsl:for-each>
		</xsl:variable>
		CREATE TRIGGER <xsl:value-of select="$insertTriggerName"/> AFTER INSERT ON <xsl:value-of select="$name"/> FOR EACH ROW
			BEGIN
				insert into <xsl:value-of select="$verName"/> (<xsl:value-of select="normalize-space($allColumnsList)"/> version_id, version_timestamp) VALUES (<xsl:value-of select="normalize-space($allNEWColumnsList)"/> UUID(),NOW());
			END;
		CREATE TRIGGER <xsl:value-of select="$updateTriggerName"/> AFTER UPDATE ON <xsl:value-of select="$name"/> FOR EACH ROW
			BEGIN
				insert into <xsl:value-of select="$verName"/> (<xsl:value-of select="normalize-space($allColumnsList)"/> version_id, version_timestamp) VALUES (<xsl:value-of select="normalize-space($allNEWColumnsList)"/> UUID(),NOW());
			END;
	</xsl:if>
</xsl:template>
	
	
<xsl:template match="e:column" mode="generate-mysql-create-sql">
	<xsl:param name="allowAutoIncrement">1</xsl:param>
	<xsl:param name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Field name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="maxLength">
		<xsl:choose>
			<xsl:when test="@maxlength"><xsl:value-of select="@maxlength"/></xsl:when>
			<xsl:otherwise>50</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="defaultValue">
		<xsl:choose>
			<xsl:when test="@default"><xsl:value-of select="@default"/></xsl:when>
			<xsl:when test="e:default"><xsl:value-of select="e:default"/></xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:value-of select="$name"/><xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="@type='string'">varchar(<xsl:value-of select="$maxLength"/>) CHARACTER SET utf8</xsl:when>
		<xsl:when test="@type='text'">TEXT CHARACTER SET utf8</xsl:when>
		<xsl:when test="@type='date'">DATE</xsl:when>
		<xsl:when test="@type='datetime'">DATETIME</xsl:when>
		<xsl:when test="@type='bool' or @type='boolean'">TINYINT(1)</xsl:when>
		<xsl:when test="@type='int' or @type='integer' or @type='autoincrement'">int</xsl:when>
		<xsl:when test="@type='long' or @type='longautoincrement'">bigint</xsl:when>
		<xsl:when test="@type='decimal'">decimal(18,6)</xsl:when>
		<xsl:when test="@type='float'">float</xsl:when>
		<xsl:when test="@type='double'">double</xsl:when>
		<xsl:when test="@type='binary'">BLOB</xsl:when>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="@nullable='true' or @nullable='1'">NULL</xsl:when>
		<xsl:otherwise>NOT NULL</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:if test="(@type='autoincrement' or @type='longautoincrement') and $allowAutoIncrement='1'">AUTO_INCREMENT</xsl:if>
	<xsl:text> </xsl:text>
	<xsl:if test="@default and not(@type='text')">DEFAULT '<xsl:call-template name="mssqlPrepareValue"><xsl:with-param name="string" select="$defaultValue"/><xsl:with-param name="field" select="."/></xsl:call-template>'</xsl:if>
	<xsl:text> </xsl:text>
</xsl:template>

		
<xsl:template match='e:table' mode="generate-mssql-create-sql">
	<xsl:param name="compatibilityMode">SQL2005</xsl:param>
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Entity name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="verName"><xsl:value-of select="$name"/>_versions</xsl:variable>
	<xsl:variable name="logName"><xsl:value-of select="$name"/>_log</xsl:variable>
	<xsl:variable name="fields" select="e:column"/>
	
	<!-- add fields if table already exists -->
	<xsl:if test="count(e:column[not(@pk) or @pk='false' or @pk='0'])>0">
	IF OBJECT_ID('<xsl:value-of select="$name"/>','U') IS NOT NULL
		BEGIN
			<xsl:for-each select="e:column[not(@pk) or @pk='false' or @pk='0']">
				<xsl:variable name="fldSql">
					<xsl:apply-templates select="." mode="generate-mssql-create-sql">
						<xsl:with-param name="compatibilityMode" select="$compatibilityMode"/>
					</xsl:apply-templates>
				</xsl:variable>
				IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '<xsl:value-of select="$name"/>' AND COLUMN_NAME = '<xsl:value-of select="@name"/>')
					BEGIN
						ALTER TABLE <xsl:value-of select="$name"/> ADD <xsl:value-of select="normalize-space($fldSql)"/>
					END
			</xsl:for-each>
		END
		
		<!-- versions table -->
		<xsl:if test="@versions='true' or @versions='1'">
			IF OBJECT_ID('<xsl:value-of select="$verName"/>','U') IS NOT NULL
				BEGIN
					<xsl:for-each select="e:column[not(@pk) or @pk='false' or @pk='0']">
						<xsl:variable name="fldSql">
							<xsl:apply-templates select="." mode="generate-mssql-create-sql">
								<xsl:with-param name="allowAutoIncrement">0</xsl:with-param>
								<xsl:with-param name="compatibilityMode" select="$compatibilityMode"/>
							</xsl:apply-templates>
						</xsl:variable>
						IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '<xsl:value-of select="$verName"/>' AND COLUMN_NAME = '<xsl:value-of select="@name"/>')
							BEGIN
								ALTER TABLE <xsl:value-of select="$verName"/> ADD <xsl:value-of select="normalize-space($fldSql)"/>
							END
					</xsl:for-each>
					<!-- migration: add version_timestamp -->
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '<xsl:value-of select="$verName"/>' AND COLUMN_NAME = 'version_timestamp')
						BEGIN
							ALTER TABLE <xsl:value-of select="$verName"/> ADD version_timestamp DATETIME NULL
						END
				END
		</xsl:if>
	</xsl:if>	
		
	<!-- create new tables -->
	IF OBJECT_ID('<xsl:value-of select="$name"/>','U') IS NULL
		BEGIN
			CREATE TABLE <xsl:value-of select="$name"/> (
				<xsl:for-each select="e:column">
					<xsl:if test="position()!=1">,</xsl:if>
					<xsl:variable name="fldSql">
						<xsl:apply-templates select="." mode="generate-mssql-create-sql">
							<xsl:with-param name="compatibilityMode" select="$compatibilityMode"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="normalize-space($fldSql)"/>
				</xsl:for-each>
				<xsl:variable name="pkNames">
					<xsl:for-each select="e:column[@pk='true']">
						<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="count(e:column)>0">,
				CONSTRAINT [<xsl:value-of select="$name"/>_PK] PRIMARY KEY ( <xsl:value-of select="normalize-space($pkNames)"/> )
				</xsl:if>
			)
			<xsl:if test="e:column[contains(@type,'autoincrement')]">
			SET IDENTITY_INSERT <xsl:value-of select="$name"/> ON;
			</xsl:if>
			<xsl:apply-templates select="e:data/e:entry[@add='setup']" mode="generate-mssql-insert-sql">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="fields" select="$fields"/>
			</xsl:apply-templates>
			<xsl:if test="e:column[contains(@type,'autoincrement')]">
			SET IDENTITY_INSERT <xsl:value-of select="$name"/> OFF;
			</xsl:if>		
		END	
	<!-- versions triggers -->
	<xsl:if test="@versions='true' or @versions='1'">
		IF OBJECT_ID('<xsl:value-of select="$verName"/>','U') IS NULL
			BEGIN
				CREATE TABLE <xsl:value-of select="$verName"/> (
					version_id varchar(50) NOT NULL DEFAULT '',
					version_timestamp datetime NULL
					<xsl:for-each select="e:column">
						<xsl:if test="@name='version_id'">
							<xsl:message terminate = "yes">Entity with enabled versions cannot contain field with name 'version_id'</xsl:message>
						</xsl:if>
						<xsl:if test="@name='version_timestamp'">
							<xsl:message terminate = "yes">Entity with enabled versions cannot contain field with name 'version_timestamp'</xsl:message>
						</xsl:if>
						,
						<xsl:variable name="fldSql">
							<xsl:apply-templates select="." mode="generate-mssql-create-sql">
								<xsl:with-param name="allowAutoIncrement">0</xsl:with-param>
								<xsl:with-param name="compatibilityMode" select="$compatibilityMode"/>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="normalize-space($fldSql)"/>
					</xsl:for-each>
					<xsl:variable name="verPkNames">
						<xsl:for-each select="e:column[@pk='true']">
							<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="count(e:column)>0">,
					CONSTRAINT [<xsl:value-of select="$verName"/>_PK] PRIMARY KEY ( version_id, <xsl:value-of select="normalize-space($verPkNames)"/> )
					</xsl:if>
				)
			END			
		
		IF OBJECT_ID('<xsl:value-of select="$name"/>_TrackVersionsTrigger') IS NOT NULL	
			DROP TRIGGER [<xsl:value-of select="$name"/>_TrackVersionsTrigger]
		IF OBJECT_ID('<xsl:value-of select="$name"/>_TrackVersionsTrigger') IS NULL
				<xsl:variable name="allColumnsList">
					<xsl:for-each select="e:column"><xsl:value-of select="$name"/>.<xsl:value-of select="@name"/>,</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="insertedIdCondition">
					<xsl:for-each select="e:column[@pk='true']">
						<xsl:if test="position()!=1"> AND </xsl:if> <xsl:value-of select="$name"/>.<xsl:value-of select="@name"/> = inserted.<xsl:value-of select="@name"/>
					</xsl:for-each>				
				</xsl:variable>
				EXEC('
					CREATE TRIGGER [<xsl:value-of select="$name"/>_TrackVersionsTrigger] ON [<xsl:value-of select="$name"/>] AFTER INSERT,UPDATE AS 
					BEGIN
						SET NOCOUNT ON;
						insert into <xsl:value-of select="$verName"/> (<xsl:value-of select="normalize-space($allColumnsList)"/> version_id, version_timestamp) select <xsl:value-of select="normalize-space($allColumnsList)"/> NEWID() as version_id, GETDATE() as version_timestamp from <xsl:value-of select="$name"/> inner join inserted on (<xsl:value-of select="normalize-space($insertedIdCondition)"/>);
					END
				')
	</xsl:if>
	
	<xsl:if test="@log='true' or @log='1'">
		IF OBJECT_ID('<xsl:value-of select="$logName"/>','U') IS NULL
			BEGIN
				CREATE TABLE <xsl:value-of select="$logName"/> (
					id int NOT NULL IDENTITY(1,1),
					timestamp datetime NULL,
					username varchar(500) NULL,
					action varchar(50) NULL
					<xsl:for-each select="e:column[@pk='true']">
						,
						<xsl:variable name="fldSql">
							<xsl:apply-templates select="." mode="generate-mssql-create-sql">
								<xsl:with-param name="allowAutoIncrement">0</xsl:with-param>
								<xsl:with-param name="compatibilityMode" select="$compatibilityMode"/>
								<xsl:with-param name="name">record_<xsl:value-of select="@name"/></xsl:with-param>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="normalize-space($fldSql)"/>
					</xsl:for-each>
					,
					CONSTRAINT [<xsl:value-of select="$logName"/>_PK] PRIMARY KEY ( id )
				)
			END			
	</xsl:if>
	
	<!-- indexes -->
	<xsl:for-each select="e:data/e:index">
		<xsl:variable name="indexName">index_<xsl:value-of select="$name"/><xsl:for-each select="e:column">_<xsl:value-of select="@name"/></xsl:for-each></xsl:variable>
		<xsl:variable name="checkIndexExistSql">
			<xsl:choose>
				<xsl:when test="$compatibilityMode='SQL2000'">EXISTS(SELECT * FROM sysindexes WHERE id = OBJECT_ID('<xsl:value-of select="$name"/>') AND name = '<xsl:value-of select="$indexName"/>')</xsl:when>
				<xsl:otherwise>EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('<xsl:value-of select="$name"/>') AND name = '<xsl:value-of select="$indexName"/>')</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		IF NOT <xsl:value-of select="$checkIndexExistSql"/>
			BEGIN
				CREATE NONCLUSTERED INDEX <xsl:value-of select="$indexName"/> ON <xsl:value-of select="$name"/>(
					<xsl:for-each select="e:column"><xsl:if test="position()>1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>
				)
			END
	</xsl:for-each>	
	
	<!-- entity predefined data -->
	<xsl:variable name="pkFields" select="e:column[@pk='true']"/>
	<xsl:for-each select="e:data/e:entry[@add='not-exists' or not(@add)]">
		<xsl:variable name="entry" select="."/>
		<xsl:variable name="dataIdCondition">
			<xsl:for-each select="$pkFields">
				<xsl:variable name="pkFieldName" select="@name"/>
				<xsl:if test="position()!=1"> AND </xsl:if> <xsl:value-of select="$pkFieldName"/> = '<xsl:value-of select="$entry/e:column[@name=$pkFieldName]"/>'
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="$pkFields[contains(@type,'autoincrement')]">
		SET IDENTITY_INSERT <xsl:value-of select="$name"/> ON;
		</xsl:if>
		IF (SELECT count(*) FROM <xsl:value-of select="$name"/> WHERE <xsl:value-of select="$dataIdCondition"/>)=0
			<xsl:apply-templates select="." mode="generate-mssql-insert-sql">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="fields" select="$fields"/>
			</xsl:apply-templates>
		<xsl:if test="$pkFields[contains(@type,'autoincrement')]">
		SET IDENTITY_INSERT <xsl:value-of select="$name"/> OFF;
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="e:entry" mode="generate-mssql-insert-sql">
	<xsl:param name="name"/>
	<xsl:param name="fields"/>
	<xsl:variable name="insertFields">
		<xsl:for-each select="e:column"><xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>
	</xsl:variable>
	<xsl:variable name="insertValues">
		<xsl:for-each select="e:column"><xsl:variable name="fldName" select="@name"/><xsl:if test="position()!=1">,</xsl:if>N'<xsl:call-template name="mssqlPrepareValue"><xsl:with-param name="string" select="."/><xsl:with-param name="field" select="$fields[@name=$fldName]"/></xsl:call-template>'</xsl:for-each>
	</xsl:variable>
	INSERT INTO <xsl:value-of select="$name"/> (<xsl:value-of select="$insertFields"/>) VALUES (<xsl:value-of select="$insertValues"/>)
</xsl:template>

<xsl:template match="e:entry" mode="generate-mysql-insert-sql">
	<xsl:param name="name"/>
	<xsl:param name="fields"/>
	<xsl:variable name="insertFields">
		<xsl:for-each select="e:column"><xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>
	</xsl:variable>
	<xsl:variable name="insertValues">
		<xsl:for-each select="e:column"><xsl:variable name="fldName" select="@name"/><xsl:if test="position()!=1">,</xsl:if>'<xsl:call-template name="mssqlPrepareValue"><xsl:with-param name="string" select="."/><xsl:with-param name="field" select="$fields[@name=$fldName]"/></xsl:call-template>'</xsl:for-each>
	</xsl:variable>
	INSERT INTO <xsl:value-of select="$name"/> (<xsl:value-of select="$insertFields"/>) VALUES (<xsl:value-of select="$insertValues"/>)
</xsl:template>

<xsl:template match="e:column" mode="generate-mssql-create-sql">
	<xsl:param name="allowAutoIncrement">1</xsl:param>
	<xsl:param name="compatibilityMode">SQL2008</xsl:param>
	<xsl:param name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Field name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="maxLength">
		<xsl:choose>
			<xsl:when test="@maxlength"><xsl:value-of select="@maxlength"/></xsl:when>
			<xsl:otherwise>50</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="defaultValue">
		<xsl:choose>
			<xsl:when test="@default"><xsl:value-of select="@default"/></xsl:when>
			<xsl:when test="e:default"><xsl:value-of select="e:default"/></xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:value-of select="$name"/><xsl:text> </xsl:text>
	<xsl:variable name="sqlTextType">
		<xsl:choose>
			<xsl:when test="$compatibilityMode='SQL2005' or $compatibilityMode='SQL2008'">nvarchar(max)</xsl:when>
			<xsl:otherwise>ntext</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="sqlBinaryType">
		<xsl:choose>
			<xsl:when test="$compatibilityMode='SQL2005' or $compatibilityMode='SQL2008'">varbinary(max)</xsl:when>
			<xsl:otherwise>image</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>	
	<xsl:choose>
		<xsl:when test="@type='string'">nvarchar(<xsl:value-of select="$maxLength"/>)</xsl:when>
		<xsl:when test="@type='text'"><xsl:value-of select="$sqlTextType"/></xsl:when>
		<xsl:when test="@type='date' and $compatibilityMode='SQL2008'">DATE</xsl:when>
		<xsl:when test="@type='datetime' or (@type='date' and not($compatibilityMode='SQL2008'))">DATETIME</xsl:when>
		<xsl:when test="@type='bool' or @type='boolean'">bit</xsl:when>
		<xsl:when test="@type='int' or @type='integer' or @type='autoincrement'">int</xsl:when>
		<xsl:when test="@type='long' or @type='longautoincrement'">bigint</xsl:when>
		<xsl:when test="@type='decimal'">decimal(18,6)</xsl:when>
		<xsl:when test="@type='float'">float</xsl:when>
		<xsl:when test="@type='double'">float</xsl:when>
		<xsl:when test="@type='binary'"><xsl:value-of select="$sqlBinaryType"/></xsl:when>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:choose>
		<xsl:when test="@nullable='true' or @nullable='1'">NULL</xsl:when>
		<xsl:otherwise>NOT NULL</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
	<xsl:if test="contains(@type,'autoincrement') and $allowAutoIncrement='1'">IDENTITY(1,1)</xsl:if>
	<xsl:text> </xsl:text>
	<xsl:if test="@default">DEFAULT '<xsl:call-template name="mssqlPrepareValue"><xsl:with-param name="string" select="$defaultValue"/><xsl:with-param name="field" select="."/></xsl:call-template>'</xsl:if>
	<xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="e:table" mode="generate-dataset-xmlschema">
	<xsl:variable name="schemaName" select="@name"/>
	<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xs:element name="DataSet" msdata:IsDataSet="true">
			<xs:complexType>
				<xs:choice maxOccurs="unbounded">
					<xs:element name="{$schemaName}">
						<xs:complexType>
							<xs:sequence>
								<xsl:apply-templates select="e:column" mode="generate-dataset-xmlschema-field"/>
							</xs:sequence>
						</xs:complexType>
					</xs:element>
				</xs:choice>
			</xs:complexType>
			<xs:unique name="PKConstraint" msdata:PrimaryKey="true">
				<xs:selector xpath=".//{$schemaName}" />
				<xsl:apply-templates select="e:column[@pk='true' or @pk='1']" mode="generate-dataset-xmlschema-pk"/>
			</xs:unique>
		</xs:element>
	</xs:schema>
</xsl:template>

<xsl:template match="e:column" mode="generate-dataset-xmlschema-pk">
	<xs:field xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath="{@name}" />
</xsl:template>

<xsl:template match="e:column" mode="generate-dataset-xmlschema-field">
	<xs:element xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
		<xsl:if test="@nullable='true' or @nullable='1'">
			<xsl:attribute name="minOccurs">0</xsl:attribute>
		</xsl:if>
		<xsl:if test="@default">
			<xsl:attribute name="default"><xsl:value-of select="@default"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="@type='autoincrement' or @type='longautoincrement'">
			<xsl:attribute name="msdata:AutoIncrement">true</xsl:attribute>
			<xsl:attribute name="msdata:AutoIncrementSeed">0</xsl:attribute>
			<xsl:attribute name="msdata:AutoIncrementStep">-1</xsl:attribute><!-- this is workaround that prevents a conflict with DB-generated autoincrement during mass-update -->
		</xsl:if>

		<xsl:if test="not( (@type='string' or @type='text') and @maxlength)">
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="@type='string'">xs:string</xsl:when>
					<xsl:when test="@type='text'">xs:string</xsl:when>
					<xsl:when test="@type='datetime' or @type='date'">xs:dateTime</xsl:when>
					<xsl:when test="@type='bool' or @type='boolean'">xs:boolean</xsl:when>
					<xsl:when test="@type='int' or @type='integer' or @type='autoincrement'">xs:integer</xsl:when>
					<xsl:when test="@type='long' or @type='longautoincrement'">xs:long</xsl:when>
					<xsl:when test="@type='decimal'">xs:decimal</xsl:when>
					<xsl:when test="@type='float'">xs:float</xsl:when>
					<xsl:when test="@type='double'">xs:double</xsl:when>
				</xsl:choose>			
			</xsl:attribute>
		</xsl:if>
		
		<xsl:if test="(@type='string' or @type='text') and @maxlength">
			<xs:simpleType>
				<xs:restriction base="xs:string">
					<xs:maxLength value="{@maxlength}" />
				</xs:restriction>
			</xs:simpleType>			
		</xsl:if>
		
	</xs:element>
</xsl:template>



</xsl:stylesheet>

<!--
NReco library (http://nreco.googlecode.com/)
Copyright 2008,2009 Vitaliy Fedorchenko
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
				xmlns:wr="urn:schemas-nreco:nreco:web:v1"
				xmlns:r="urn:schemas-nreco:nreco:core:v1"
				xmlns:e="urn:schemas-nreco:nreco:entity:v1"
				xmlns:d="urn:schemas-nreco:nicnet:dalc:v1"
				exclude-result-prefixes="msxsl">

	<xsl:variable name="currentUserKeyProvider" select="/components/default/services/userkeyprovider/@name"/>
				
				
<xsl:template match="e:entity-create-sql">
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Winter.ReplacingFactory</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="TargetObject">
				<value>
					<xsl:choose>
						<xsl:when test="e:dialect/e:mysql">
							DROP PROCEDURE IF EXISTS __init_schema;
							CREATE PROCEDURE __init_schema()
							BEGIN
							<xsl:apply-templates select="e:entity" mode="generate-mysql-create-sql"/>
							END;
							CALL __init_schema;
							<xsl:apply-templates select="e:entity" mode="generate-mysql-create-trigger-sql"/>
						</xsl:when>
						<xsl:when test="e:dialect/e:mssql">
							<xsl:variable name="compatibilityMode">
								<xsl:choose>
									<xsl:when test="e:dialect/e:mssql/@compatibility='sql2000'">SQL2000</xsl:when>
									<xsl:when test="e:dialect/e:mssql/@compatibility='sql2008'">SQL2008</xsl:when>
									<xsl:otherwise>SQL2005</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:apply-templates select="e:entity" mode="generate-mssql-create-sql">
								<xsl:with-param name="compatibilityMode"><xsl:value-of select="$compatibilityMode"/></xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<!-- by default - lets assume MS SQL -->
							<xsl:apply-templates select="e:entity" mode="generate-mssql-create-sql"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</property>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="e:dataset-factory">
	<xsl:call-template name='component-definition'>
		<xsl:with-param name='name' select="@name"/>
		<xsl:with-param name='type'>NI.Data.Dalc.DataSetFactory</xsl:with-param>
		<xsl:with-param name='injections'>
			<property name="Schemas">
				<list>
					<xsl:for-each select="e:entity">
						<entry>
							<component type="NI.Data.Dalc.DataSetFactory+SchemaDescriptor" singleton="false">
								<property name="SourceNames"><list><entry><value><xsl:value-of select="@name"/></value></entry></list></property>
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
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="e:entity-sourcenames">
	<component name="{@name}" type="NI.Winter.ReplacingFactory" singleton="false" lazy-init="true">
		<property name="TargetObject">
			<list>
				<xsl:for-each select="e:entity">
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
		
<xsl:template match='e:entity' mode="generate-mysql-create-sql">
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Entity name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="fields" select="e:field"/>
	<xsl:variable name="verName"><xsl:value-of select="$name"/>_versions</xsl:variable>
	<xsl:variable name="logName"><xsl:value-of select="$name"/>_log</xsl:variable>
	IF NOT EXISTS(select * from information_schema.tables where table_schema=DATABASE() and table_name='<xsl:value-of select="$name"/>')
		THEN 
			CREATE TABLE <xsl:value-of select="$name"/> (
				<xsl:for-each select="e:field">
					<xsl:if test="position()!=1">,</xsl:if>
					<xsl:variable name="fldSql">
						<xsl:apply-templates select="." mode="generate-mysql-create-sql"/>
					</xsl:variable>
					<xsl:value-of select="normalize-space($fldSql)"/>
				</xsl:for-each>
				<xsl:variable name="pkNames">
					<xsl:for-each select="e:field[@pk='true']">
						<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="count(e:field)>0">,
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
		<xsl:variable name="indexName">index_<xsl:value-of select="$name"/><xsl:for-each select="e:field">_<xsl:value-of select="@name"/></xsl:for-each></xsl:variable>
		IF NOT EXISTS(select * from information_schema.statistics where table_schema=DATABASE() and table_name='<xsl:value-of select="$name"/>' and index_name='<xsl:value-of select="$indexName"/>')
		THEN 		
			CREATE INDEX <xsl:value-of select="$indexName"/> ON <xsl:value-of select="$name"/>(
				<xsl:for-each select="e:field">
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
					<xsl:for-each select="e:field">
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
						<xsl:for-each select="e:field[@pk='true']">
							<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="count(e:field)>0">,
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
					<xsl:for-each select="e:field[@pk='true']">
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
	<xsl:if test="count(e:field[not(@pk) or @pk='false' or @pk='0'])>0">
		<xsl:for-each select="e:field[not(@pk) or @pk='false' or @pk='0']">
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
			<xsl:for-each select="e:field[not(@pk) or @pk='false' or @pk='0']">
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
	<xsl:variable name="pkFields" select="e:field[@pk='true']"/>
	<xsl:for-each select="e:data/e:entry[@add='not-exists' or not(@add)]">
		<xsl:variable name="entry" select="."/>
		<xsl:variable name="dataIdCondition">
			<xsl:for-each select="$pkFields">
				<xsl:variable name="pkFieldName" select="@name"/>
				<xsl:if test="position()!=1"> AND </xsl:if> <xsl:value-of select="$pkFieldName"/> = '<xsl:value-of select="$entry/e:field[@name=$pkFieldName]"/>'
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

<xsl:template match='e:entity' mode="generate-mysql-create-trigger-sql">
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Entity name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="verName"><xsl:value-of select="$name"/>_versions</xsl:variable>
	<xsl:if test="@versions='true' or @versions='1'">
		<!-- re-create versions trigger -->
		DROP TRIGGER IF EXISTS __TrackVersionsInsertTrigger_<xsl:value-of select="$name"/>;
		DROP TRIGGER IF EXISTS __TrackVersionsUpdateTrigger_<xsl:value-of select="$name"/>;
		<xsl:variable name="allColumnsList">
			<xsl:for-each select="e:field"><xsl:value-of select="@name"/>,</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="allNEWColumnsList">
			<xsl:for-each select="e:field">NEW.<xsl:value-of select="@name"/>,</xsl:for-each>
		</xsl:variable>
		CREATE TRIGGER __TrackVersionsInsertTrigger_<xsl:value-of select="$name"/> AFTER INSERT ON <xsl:value-of select="$name"/> FOR EACH ROW
			BEGIN
				insert into <xsl:value-of select="$verName"/> (<xsl:value-of select="normalize-space($allColumnsList)"/> version_id, version_timestamp) VALUES (<xsl:value-of select="normalize-space($allNEWColumnsList)"/> UUID(),NOW());
			END;
		CREATE TRIGGER __TrackVersionsUpdateTrigger_<xsl:value-of select="$name"/> AFTER UPDATE ON <xsl:value-of select="$name"/> FOR EACH ROW
			BEGIN
				insert into <xsl:value-of select="$verName"/> (<xsl:value-of select="normalize-space($allColumnsList)"/> version_id, version_timestamp) VALUES (<xsl:value-of select="normalize-space($allNEWColumnsList)"/> UUID(),NOW());
			END;
	</xsl:if>
</xsl:template>
	
	
<xsl:template match="e:field" mode="generate-mysql-create-sql">
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

		
<xsl:template match='e:entity' mode="generate-mssql-create-sql">
	<xsl:param name="compatibilityMode">SQL2005</xsl:param>
	<xsl:variable name="name">
		<xsl:choose>
			<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
			<xsl:otherwise><xsl:message terminate = "yes">Entity name is required</xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="verName"><xsl:value-of select="$name"/>_versions</xsl:variable>
	<xsl:variable name="logName"><xsl:value-of select="$name"/>_log</xsl:variable>
	<xsl:variable name="fields" select="e:field"/>
	
	<!-- add fields if table already exists -->
	<xsl:if test="count(e:field[not(@pk) or @pk='false' or @pk='0'])>0">
	IF OBJECT_ID('<xsl:value-of select="$name"/>','U') IS NOT NULL
		BEGIN
			<xsl:for-each select="e:field[not(@pk) or @pk='false' or @pk='0']">
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
					<xsl:for-each select="e:field[not(@pk) or @pk='false' or @pk='0']">
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
				<xsl:for-each select="e:field">
					<xsl:if test="position()!=1">,</xsl:if>
					<xsl:variable name="fldSql">
						<xsl:apply-templates select="." mode="generate-mssql-create-sql">
							<xsl:with-param name="compatibilityMode" select="$compatibilityMode"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="normalize-space($fldSql)"/>
				</xsl:for-each>
				<xsl:variable name="pkNames">
					<xsl:for-each select="e:field[@pk='true']">
						<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="count(e:field)>0">,
				CONSTRAINT [<xsl:value-of select="$name"/>_PK] PRIMARY KEY ( <xsl:value-of select="normalize-space($pkNames)"/> )
				</xsl:if>
			)
			<xsl:if test="e:field[contains(@type,'autoincrement')]">
			SET IDENTITY_INSERT <xsl:value-of select="$name"/> ON;
			</xsl:if>
			<xsl:apply-templates select="e:data/e:entry[@add='setup']" mode="generate-mssql-insert-sql">
				<xsl:with-param name="name" select="$name"/>
				<xsl:with-param name="fields" select="$fields"/>
			</xsl:apply-templates>
			<xsl:if test="e:field[contains(@type,'autoincrement')]">
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
					<xsl:for-each select="e:field">
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
						<xsl:for-each select="e:field[@pk='true']">
							<xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="count(e:field)>0">,
					CONSTRAINT [<xsl:value-of select="$verName"/>_PK] PRIMARY KEY ( version_id, <xsl:value-of select="normalize-space($verPkNames)"/> )
					</xsl:if>
				)
			END			
		
		IF OBJECT_ID('<xsl:value-of select="$name"/>_TrackVersionsTrigger') IS NOT NULL	
			DROP TRIGGER [<xsl:value-of select="$name"/>_TrackVersionsTrigger]
		IF OBJECT_ID('<xsl:value-of select="$name"/>_TrackVersionsTrigger') IS NULL
				<xsl:variable name="allColumnsList">
					<xsl:for-each select="e:field"><xsl:value-of select="$name"/>.<xsl:value-of select="@name"/>,</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="insertedIdCondition">
					<xsl:for-each select="e:field[@pk='true']">
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
					<xsl:for-each select="e:field[@pk='true']">
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
		<xsl:variable name="indexName">index_<xsl:value-of select="$name"/><xsl:for-each select="e:field">_<xsl:value-of select="@name"/></xsl:for-each></xsl:variable>
		<xsl:variable name="checkIndexExistSql">
			<xsl:choose>
				<xsl:when test="$compatibilityMode='SQL2000'">EXISTS(SELECT * FROM sysindexes WHERE id = OBJECT_ID('<xsl:value-of select="$name"/>') AND name = '<xsl:value-of select="$indexName"/>')</xsl:when>
				<xsl:otherwise>EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('<xsl:value-of select="$name"/>') AND name = '<xsl:value-of select="$indexName"/>')</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		IF NOT <xsl:value-of select="$checkIndexExistSql"/>
			BEGIN
				CREATE NONCLUSTERED INDEX <xsl:value-of select="$indexName"/> ON <xsl:value-of select="$name"/>(
					<xsl:for-each select="e:field"><xsl:if test="position()>1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>
				)
			END
	</xsl:for-each>	
	
	<!-- entity predefined data -->
	<xsl:variable name="pkFields" select="e:field[@pk='true']"/>
	<xsl:for-each select="e:data/e:entry[@add='not-exists' or not(@add)]">
		<xsl:variable name="entry" select="."/>
		<xsl:variable name="dataIdCondition">
			<xsl:for-each select="$pkFields">
				<xsl:variable name="pkFieldName" select="@name"/>
				<xsl:if test="position()!=1"> AND </xsl:if> <xsl:value-of select="$pkFieldName"/> = '<xsl:value-of select="$entry/e:field[@name=$pkFieldName]"/>'
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
		<xsl:for-each select="e:field"><xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>
	</xsl:variable>
	<xsl:variable name="insertValues">
		<xsl:for-each select="e:field"><xsl:variable name="fldName" select="@name"/><xsl:if test="position()!=1">,</xsl:if>N'<xsl:call-template name="mssqlPrepareValue"><xsl:with-param name="string" select="."/><xsl:with-param name="field" select="$fields[@name=$fldName]"/></xsl:call-template>'</xsl:for-each>
	</xsl:variable>
	INSERT INTO <xsl:value-of select="$name"/> (<xsl:value-of select="$insertFields"/>) VALUES (<xsl:value-of select="$insertValues"/>)
</xsl:template>

<xsl:template match="e:entry" mode="generate-mysql-insert-sql">
	<xsl:param name="name"/>
	<xsl:param name="fields"/>
	<xsl:variable name="insertFields">
		<xsl:for-each select="e:field"><xsl:if test="position()!=1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>
	</xsl:variable>
	<xsl:variable name="insertValues">
		<xsl:for-each select="e:field"><xsl:variable name="fldName" select="@name"/><xsl:if test="position()!=1">,</xsl:if>'<xsl:call-template name="mssqlPrepareValue"><xsl:with-param name="string" select="."/><xsl:with-param name="field" select="$fields[@name=$fldName]"/></xsl:call-template>'</xsl:for-each>
	</xsl:variable>
	INSERT INTO <xsl:value-of select="$name"/> (<xsl:value-of select="$insertFields"/>) VALUES (<xsl:value-of select="$insertValues"/>)
</xsl:template>

<xsl:template match="e:field" mode="generate-mssql-create-sql">
	<xsl:param name="allowAutoIncrement">1</xsl:param>
	<xsl:param name="compatibilityMode">SQL2005</xsl:param>
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

<xsl:template match="e:entity" mode="generate-dataset-xmlschema">
	<xsl:variable name="schemaName" select="@name"/>
	<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
		<xs:element name="DataSet" msdata:IsDataSet="true">
			<xs:complexType>
				<xs:choice maxOccurs="unbounded">
					<xs:element name="{$schemaName}">
						<xs:complexType>
							<xs:sequence>
								<xsl:apply-templates select="e:field" mode="generate-dataset-xmlschema-field"/>
							</xs:sequence>
						</xs:complexType>
					</xs:element>
				</xs:choice>
			</xs:complexType>
			<xs:unique name="PKConstraint" msdata:PrimaryKey="true">
				<xs:selector xpath=".//{$schemaName}" />
				<xsl:apply-templates select="e:field[@pk='true' or @pk='1']" mode="generate-dataset-xmlschema-pk"/>
			</xs:unique>
		</xs:element>
	</xs:schema>
</xsl:template>

<xsl:template match="e:field" mode="generate-dataset-xmlschema-pk">
	<xs:field xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath="{@name}" />
</xsl:template>

<xsl:template match="e:field" mode="generate-dataset-xmlschema-field">
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


<xsl:template match="d:entity-dalc-triggers" mode="db-dalc-trigger">
	<xsl:param name="eventsMediatorName"/>
	<xsl:param name="namePrefix"/>
	<xsl:variable name="dalcModel">
		<xsl:apply-templates select="e:entity" mode="entity-dalc-triggers"/>
	</xsl:variable>
	<xsl:apply-templates select="msxsl:node-set($dalcModel)/node()" mode="db-dalc-trigger">
		<xsl:with-param name="eventsMediatorName" select="$eventsMediatorName"/>
		<xsl:with-param name="namePrefix" select="$namePrefix"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="e:entity-dalc-triggers">
	<xsl:apply-templates select="e:entity" mode="entity-dalc-triggers"/>
</xsl:template>

<xsl:template match="e:entity" mode="entity-dalc-triggers">
	<xsl:variable name="sourcename" select="@name"/>
	<!-- lets collect _all_ actions for this entity -->
	<xsl:variable name="actions">
		<xsl:copy-of select=".//e:action[not(@name='saving' or @name='saved')]"/>
		<!-- deal with composite 'saving' -->
		<xsl:if test="not(.//e:action[@name='creating']) and .//e:action[@name='saving']">
			<e:action name="creating"/>
		</xsl:if>
		<xsl:if test="not(.//e:action[@name='updating']) and .//e:action[@name='saving']">
			<e:action name="updating"/>
		</xsl:if>
		<!-- deal with composite 'saved' -->
		<xsl:if test="not(.//e:action[@name='created']) and .//e:action[@name='saved']">
			<e:action name="created"/>
		</xsl:if>
		<xsl:if test="not(.//e:action[@name='updated']) and .//e:action[@name='saved']">
			<e:action name="updated"/>
		</xsl:if>
		<!-- extra trigger on deleting for log tracking -->
		<xsl:if test="@log='1' or @log='true'">
			<e:action name="deleted"/>
			<e:action name="inserted"/>
			<e:action name="updated"/>
		</xsl:if>
		
	</xsl:variable>
	<xsl:variable name="thisEntity" select="."/>

	<xsl:for-each select="msxsl:node-set($actions)/node()">
		<xsl:variable name="actionName" select="@name"/>
		<xsl:variable name="dalcEventName">
			<xsl:choose>
				<xsl:when test="$actionName='creating'">inserting</xsl:when>
				<xsl:when test="$actionName='created'">inserted</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$actionName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- select distinct actions -->
		<xsl:if test="not(preceding-sibling::action[@name=$actionName])">
			<d:datarow event="{$dalcEventName}" sourcename="{$sourcename}">
				<r:operation>
					<r:chain>
						<!-- field triggers -->
						<xsl:for-each select="$thisEntity/e:field">
							<xsl:apply-templates select="e:action[@name=$actionName]/e:*" mode="entity-action-dalc-trigger-execute">
								<xsl:with-param name="field" select="."/>
							</xsl:apply-templates>
							<!-- deal with composite actions -->
							<xsl:if test="$actionName='creating' or $actionName='updating'">
								<xsl:apply-templates select="e:action[@name='saving']/e:*" mode="entity-action-dalc-trigger-execute">
									<xsl:with-param name="field" select="."/>
								</xsl:apply-templates>							
							</xsl:if>
							<xsl:if test="$actionName='created' or $actionName='updated'">
								<xsl:apply-templates select="e:action[@name='saved']/e:*" mode="entity-action-dalc-trigger-execute">
									<xsl:with-param name="field" select="."/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						
						<!-- write log entry -->
						<xsl:if test="($thisEntity/@log='1' or $thisEntity/@log='true') and ($actionName='inserted' or $actionName='updated' or $actionName='deleted')">
							<r:execute>
								<r:target>
									<r:invoke method="Insert">
										<r:target><r:ognl>#sender</r:ognl></r:target>
										<r:args>
											<r:ognl>#{
												'action':'<xsl:value-of select="$actionName"/>', 
												'timestamp' : @DateTime@Now, 
												'username' : @System.Threading.Thread@CurrentPrincipal.Identity.Name
												<xsl:for-each select="$thisEntity/e:field[@pk='true' or @pk='1']">
													, 'record_<xsl:value-of select="@name"/>' : @DataRow@Get(#row,'<xsl:value-of select="@name"/>')
												</xsl:for-each>
											}</r:ognl>
											<r:const value="{$sourcename}_log"/>
										</r:args>
									</r:invoke>
								</r:target>
							</r:execute>
						</xsl:if>
						
					</r:chain>
				</r:operation>
			</d:datarow>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="e:set-datetimenow" mode="entity-action-dalc-trigger-execute">
	<xsl:param name="field"/>
	<r:execute>
		<r:target>
			<r:invoke method="set_Item">
				<r:target>
					<r:ognl>#row</r:ognl>
				</r:target>
				<r:args>
					<r:const value="{$field/@name}"/>
					<r:ognl>@DateTime@Now</r:ognl>
				</r:args>
			</r:invoke>
		</r:target>
	</r:execute>
</xsl:template>

<xsl:template match="e:set-username" mode="entity-action-dalc-trigger-execute">
	<xsl:param name="field"/>
	<r:execute>
		<r:target>
			<r:invoke method="set_Item">
				<r:target>
					<r:ognl>#row</r:ognl>
				</r:target>
				<r:args>
					<r:const value="{$field/@name}"/>
					<r:ognl>@System.Threading.Thread@CurrentPrincipal.Identity.Name</r:ognl>
				</r:args>
			</r:invoke>
		</r:target>
	</r:execute>
</xsl:template>				

<xsl:template match="e:set-userkey" mode="entity-action-dalc-trigger-execute">
	<xsl:param name="field"/>
	<r:execute>
		<xsl:if test="@if='default'">
			<xsl:attribute name="if">
				#rowVal = #row["<xsl:value-of select="$field/@name"/>"],
				<xsl:if test="$field/@default">#rowVal == "<xsl:value-of select="$field/@default"/>" || </xsl:if> #rowVal == null || @DBNull@Value.Equals(#rowVal) == @String@Empty
			</xsl:attribute>
		</xsl:if>	
		<r:target>
			<r:invoke method="set_Item">
				<r:target>
					<r:ognl>#row</r:ognl>
				</r:target>
				<r:args>
					<r:const value="{$field/@name}"/>
					<xsl:choose>
						<xsl:when test="$currentUserKeyProvider and $currentUserKeyProvider!=''">
							<r:proxy>
								<r:target>
									<r:ref name="{$currentUserKeyProvider}"/>
								</r:target>
								<r:result>
									<r:proxy>
										<r:target><r:ognl>#arg==null ? @DBNull@Value : #arg</r:ognl></r:target>
										<r:context>
											<r:custom>
												<component type="NReco.Composition.SingleNameValueProvider" singleton="false">
													<property name="Key"><value>arg</value></property>
												</component>
											</r:custom>
										</r:context>
									</r:proxy>
									
								</r:result>
							</r:proxy>
						</xsl:when>
						<xsl:otherwise>
							<r:userkey anonymous="dbnull"/>
						</xsl:otherwise>
					</xsl:choose>
				</r:args>
			</r:invoke>
		</r:target>
	</r:execute>
</xsl:template>	

<xsl:template match="e:set-guid" mode="entity-action-dalc-trigger-execute">
	<xsl:param name="field"/>
	<r:execute>
		<xsl:if test="@if='default'">
			<xsl:attribute name="if">
				#rowIdVal = #row["<xsl:value-of select="$field/@name"/>"],
				<xsl:if test="$field/@default">#rowIdVal == "<xsl:value-of select="$field/@default"/>" || </xsl:if> #rowIdVal == null || @Convert@ToString(#rowIdVal) == @String@Empty ? true : false		
			</xsl:attribute>
		</xsl:if>
		<r:target>
			<r:invoke method="set_Item">
				<r:target>
					<r:ognl>#row</r:ognl>
				</r:target>
				<r:args>
					<r:const value="{$field/@name}"/>
					<r:ognl>@System.Guid@NewGuid().ToString()</r:ognl>
				</r:args>
			</r:invoke>
		</r:target>
	</r:execute>
</xsl:template>

<xsl:template match="e:set-provider" mode="entity-action-dalc-trigger-execute">
	<xsl:param name="field"/>
	<r:execute>
		<r:target>
			<r:invoke method="set_Item">
				<r:target>
					<r:ognl>#row</r:ognl>
				</r:target>
				<r:args>
					<r:const value="{$field/@name}"/>
					<r:ref name="{@name}"/>
				</r:args>
			</r:invoke>
		</r:target>
	</r:execute>
</xsl:template>	


</xsl:stylesheet>

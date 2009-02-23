IF OBJECT_ID('accounts','U') IS NULL
	BEGIN
		CREATE TABLE accounts (
			id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
			username varchar(50) NOT NULL DEFAULT '',
			password varchar(50) NOT NULL DEFAULT '',
			email varchar(250) NOT NULL DEFAULT '',
			comment varchar(250) NOT NULL DEFAULT '',
			password_question varchar(250) NULL,
			password_answer varchar(250) NULL,
			is_approved bit NOT NULL DEFAULT '1',
			creation_date DATETIME NULL,
			last_login_date DATETIME NULL,
			last_activity_date DATETIME NULL,
			last_pwd_change_date DATETIME NULL
		)
	END
	
IF OBJECT_ID('pages','U') IS NULL
	BEGIN
		CREATE TABLE pages (
			id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
			title nvarchar(250) NOT NULL DEFAULT '',
			[content] ntext NOT NULL DEFAULT '',
			content_type varchar(50) NOT NULL DEFAULT 'wiki',
			is_public bit NOT NULL default '1'
		)
	END	
	
IF OBJECT_ID('account_roles','U') IS NULL
	BEGIN
		CREATE TABLE account_roles (
			username nvarchar(50) NOT NULL,
			rolename nvarchar(50) NOT NULL,
			
			CONSTRAINT [account_roles_PK] PRIMARY KEY  ( username, rolename )			
		)
	END		

IF OBJECT_ID('page_visibility','U') IS NULL
	BEGIN
		CREATE TABLE page_visibility (
			page_id int NOT NULL,
			account_id int NOT NULL,
			
			CONSTRAINT [page_visibility_PK] PRIMARY KEY  ( page_id, account_id )			
		)
	END	

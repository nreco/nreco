IF OBJECT_ID('accounts','U') IS NOT NULL
	BEGIN
		CREATE TABLE accounts (
			id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
			login varchar(50) NOT NULL DEFAULT '',
			password varchar(50) NOT NULL DEFAULT ''
		)
	END
	
IF OBJECT_ID('pages','U') IS NOT NULL
	BEGIN
		CREATE TABLE accounts (
			id int NOT NULL IDENTITY(1,1) PRIMARY KEY,
			title nvarchar(250) NOT NULL DEFAULT '',
			[content] ntext NOT NULL DEFAULT '',
			content_type varchar(50) NOT NULL DEFAULT 'wiki'
		)
	END	
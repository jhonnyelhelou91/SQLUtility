# SQL Utility Scripts

SQL Server utility scripts to manage administrative, performance and troubleshooting operations on your SQL Server. 

## Getting Started

The scripts were tested on SQL Server 2012 and above.

### Prerequisites

* Install SSMS - SQL Server Management Studio from PowerShell `choco install sql-server-management-studio` or download from [Microsoft](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017 "Microsoft")
* Create schema utility `CREATE SCHEMA Utility;`

- - - -

### Cleanup Generator

An SQL view that helps you generate drop queries for the existing objects.
<details>
   <summary>Get cleanup queries for specific table</summary>
   <p>
	Select * from [Utility].[GenerateDrop] where [Table] = 'Blogs'
   </p>
</details>
<details>
   <summary>Get cleanup queries for specific type</summary>
   <p>
	Select * from [Utility].[GenerateDrop] where [Type] = 'F' or [TypeDescription] = 'FOREIGN_KEY_CONSTRAINT'
   </p>
</details>
<details>
   <summary>Get cleanup queries for specific schema</summary>
   <p>
	Select * from [Utility].[GenerateDrop] where [Schema] <> 'dbo'
   </p>
</details>

### Select/Delete Dependent Data

When cascade option is restrict, delete operations of used entities fail. This inline table valued function helps you generate manual scripts to select/delete scripts for the related rows.
<details>
   <summary>Select/Delete dependent data for single id</summary>
   <p>
	`SELECT * FROM [Utility].[GenerateDeleteDependent]('Users', '= 1')`
	`SELECT * FROM [Utility].[GenerateSelectDependent]('Users', '= 1')`
   </p>
</details>
<details>
   <summary>Select/Delete dependent data for multiple conditions</summary>
   <p>
	`SELECT * FROM [Utility].[GenerateDeleteDependent]('dbo.Users', 'IN (1, 2)')`
	`SELECT * FROM [Utility].[GenerateSelectDependent]('dbo.Users', 'IN (1, 2)')`
   </p>
</details>

### Rename Linked Server
Inline table valued function that generates alter queries to rename linked servers for views and stored procedures
<details>
   <summary>Rename Linked Server</summary>
   <p>
	`SELECT * FROM [Utility].[GenerateRenameLinkedServer]('oldserver', 'newserver')`
   </p>
</details>

### Update Keyword
Stored procedure that generates update queries to replace keyword(s). Null is not considered a keyword.
<details>
   <summary>Replace keyword in all tables</summary>
   <p>
	`EXEC [Utility].[sp_updatekeyword]('Value1', ',', 'NewValue')`
   </p>
</details>
<details>
   <summary>Replace multiple keywords in all tables</summary>
   <p>
	`EXEC [Utility].[sp_updatekeyword]('Value1,Value2', ',', 'NewValue')`
   </p>
</details>

### View Table Size
Stored procedure that generates information about tables, rows and reserved sizes.
<details>
   <summary>View Table Size</summary>
   <p>
	`EXEC [Utility].[sp_tablesize]`
   </p>
</details>

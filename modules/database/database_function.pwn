// functions

DatabaseInit()
{
	DBConn = mysql_connect_file(); 
	
	if (DBConn == MYSQL_INVALID_HANDLE || mysql_errno(DBConn) != 0)
	{
		print("MySQL: Erro de conexao, servidor desligado.");
		return SendRconCommand("exit"); 
	}
	else
	{
		print("MySQL: Conexao com o servidor ligada..");
		VerifyTables();
	}
	return 1;
}

DatabaseExit()
{
	if(mysql_errno(DBConn) == 0)
	{
		mysql_close(DBConn);
		print("MySQL: Conexao com o banco de dados fechada.");
	}
	return 1;
}

VerifyTables()
{
	mysql_query(DBConn, 
	"CREATE TABLE IF NOT EXISTS `player`(\
		`id` INT AUTO_INCREMENT,\
		`name` VARCHAR(24) NOT NULL,\
		`pass` VARCHAR(64) NOT NULL,\
		PRIMARY KEY(`id`));", false);

	print("MySQL: Tabela \"player\" foi verificada.");
	return 1;
}
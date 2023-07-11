// includes

#include    <open.mp>
#include    <a_mysql>
#include 	<bcrypt>
#include 	<util>

// defines

#define 	MAX_PLAYER_PASS 	(64)

// database

#define 	MYSQL_HOSTNAME 		"127.0.0.1"
#define 	MYSQL_USERNAME 		"beto"
#define 	MYSQL_PASSWORD 		"123"
#define 	MYSQL_DATABASE 		"san_andreas_roleplay"

// enum's

enum // dialogs
{
	DIALOG_UNUSED,
	DIALOG_LOGIN
}

// variables

new MySQL:DBConn;

// structures

enum E_PLAYER_DATA
{
	pID,

	pName[MAX_PLAYER_NAME],
	pPass[MAX_PLAYER_PASS],

	bool:pLogged
}

new PlayerInfo[MAX_PLAYER_PASS][E_PLAYER_DATA];

main()
{}

// callbacks

public OnGameModeInit()
{
    DBConn = mysql_connect(MYSQL_HOSTNAME, MYSQL_USERNAME, MYSQL_PASSWORD, MYSQL_DATABASE); 
	
	if (DBConn == MYSQL_INVALID_HANDLE || mysql_errno(DBConn) != 0)
	{
		print("MySQL: Erro de conexao, servidor desligado.");
		return SendRconCommand("exit"); 
	}
	else
	{
		print("MySQL: Conexao com o servidor iniciada.");

		mysql_query(DBConn, 
		"CREATE TABLE IF NOT EXISTS `player`(\
			`id` INT AUTO_INCREMENT,\
			`name` VARCHAR(24) UNIQUE NOT NULL,\
			`pass` VARCHAR(64) NOT NULL,\
			PRIMARY KEY(`id`));",
		false);

		print("MySQL: Tabela \"player\" verificada com sucesso.");
	}
    return 1;
}

public OnGameModeExit()
{
    if(mysql_errno(DBConn) == 0)
	{
		mysql_close(DBConn);
		print("MySQL: Conexao com o banco de dados fechada.");
	}
    return 1;
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	Unspawn(playerid);

	new Cache:result, query[64];

	mysql_format(DBConn, query, sizeof query, "SELECT * FROM `player` WHERE `name` = '%e';", PlayerInfo[playerid][pName]);
	result = mysql_query(DBConn, query, true);

	if(cache_num_rows() > 0)
	{
		cache_get_value_name_int(0, "id", PlayerInfo[playerid][pID]);
		cache_get_value_name(0, "pass", PlayerInfo[playerid][pPass], MAX_PLAYER_PASS);

		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Bem vindo(a) ao servidor %s!\n\nDigite sua senha para entrar:", "Entrar", "Sair", PlayerInfo[playerid][pName]);
	}
	else
	{
		KickInTime(playerid, 1000);
		ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "NÃ£o registrado", "Bem vindo(a) ao servidor %s!\n\nVocê não é registrado em nosso servidor,\nfaça seu processo seletivo", "Sair", "", PlayerInfo[playerid][pName]);
	}

	cache_unset_active();
	cache_delete(result);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(PlayerInfo[playerid][pLogged] == true)
	{
		new query[256];

		mysql_format(DBConn, query, sizeof query, "UPDATE `player` SET `name` = '%e', `pass` = '%e' WHERE `id` = %d;", PlayerInfo[playerid][pName], PlayerInfo[playerid][pPass], PlayerInfo[playerid][pID]);
		mysql_query(DBConn, query, false);
	}
	ResetPlayerInfo(playerid);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_LOGIN:
		{
			if(response)
			{
				bcrypt_check(inputtext, PlayerInfo[playerid][pPass], "OnPlayerTryLogin", "d", playerid);
			}
			else
			{
				Kick(playerid);
			}
		}
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{

	return 0;
}

public OnPlayerSpawn(playerid)
{
	if(PlayerInfo[playerid][pLogged] == false)
	{
		Kick(playerid);
	}
	return 1;
}

forward OnPlayerTryLogin(playerid);
public OnPlayerTryLogin(playerid)
{
	if(bcrypt_is_equal() == true)
	{
		SendInfoMessage(playerid, "Você foi logado.");
		PlayerInfo[playerid][pLogged] = true;
		Spawn(playerid);
	}
	else
	{
		SendErrorMessage(playerid, "Senha incorreta.");
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Bem vindo(a) ao servidor %s!\n\nDigite sua senha para entrar:", "Entrar", "Sair", PlayerInfo[playerid][pName]);
	}
	return 1;
}

ResetPlayerInfo(playerid)
{
	new reset[E_PLAYER_DATA];
	PlayerInfo[playerid] = reset;
	return 1;
}
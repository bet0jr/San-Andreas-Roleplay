// callbacks

#include    <YSI_Coding\y_hooks>

hook OnGameModeInit()
{
	DatabaseInit();
	return 1;
}

hook OnGameModeExit()
{
	DatabaseExit();
	return 1;
}
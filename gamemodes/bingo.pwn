// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#include <a_samp>

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Blank Filterscript by your name here");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

// Professional Bingo System SA-MP Gamemode
#include <a_samp>

// ================================
// BINGO SYSTEM CONSTANTS
// ================================
#define BINGO_ROWS 5
#define BINGO_COLS 7
#define BINGO_TOTAL_CELLS 35

// ================================
// BINGO ENUMS AND DATA
// ================================
enum bingoEnum {
    prizeSide, // 0 - horizontal prizes, 1 - vertical prizes
    prizeName[50]
}

new bingoRewardInfo[][bingoEnum] = {
    { 0, "Game Currency 300000" },
    { 0, "Jaguar XKR-S" },
    { 0, "Neon Sword #1" },
    { 0, "Skin (2415)" },
    { 0, "Nissan GTR" },
    { 1, "Samurai Gas Mask" },
    { 1, "Game Currency 150000" },
    { 1, "Skin (2363)" },
    { 1, "Ferrari 365 GTB/4" },
    { 1, "Green Dragon" },
    { 1, "10 EXP" },
    { 1, "BMW Alpina B7 Widebody" }
};

// ================================
// PLAYER BINGO DATA - INDIVIDUAL SYSTEM
// ================================
new bool:playerBingoField[MAX_PLAYERS][BINGO_TOTAL_CELLS]; // Each player has own field
new playerBingoOpened[MAX_PLAYERS]; // Number of opened cells per player
new bool:playerWonPrizes[MAX_PLAYERS][12]; // Track which prizes each player has won (12 total prizes)
new playerTotalPrizes[MAX_PLAYERS]; // Count of total prizes won per player

// ================================
// MAIN FUNCTIONS
// ================================
main()
{
	print("\n----------------------------------");
	print(" Professional Bingo System");
	print(" SA-MP Server Started Successfully");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	// Set the gamemode text that appears in the server browser
	SetGameModeText("Bingo System v1.0");
	
	// Add a player class (skin ID 0 = CJ skin)
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	
	// Print to server console
	print("Bingo system initialized!");
	print("Bingo field: 5x7 (35 cells)");
	print("Available commands: /bingo, /bingofield, /bingoprizes, /help");
	
	return 1;
}

public OnGameModeExit()
{
	print("Bingo system shutting down...");
	return 1;
}

public OnPlayerConnect(playerid)
{
	// Get player's name
	new playerName[MAX_PLAYER_NAME];~
	GetPlayerName(playerid, playerName, sizeof(playerName));
	
	// Send welcome message to the player
	SendClientMessage(playerid, 0xFF0000FF, "====================================");
	SendClientMessage(playerid, 0x00FF00FF, "Welcome to Professional Bingo Server!");
	SendClientMessage(playerid, 0xFFFF00FF, "Type /bingo to open a random cell!");
	SendClientMessage(playerid, 0xFFFF00FF, "Each player has their own bingo field!");
	SendClientMessage(playerid, 0xFFFF00FF, "Type /help for all commands!");
	SendClientMessage(playerid, 0xFF0000FF, "====================================");
	
	// Print to server console
	printf("Player %s connected to bingo server", playerName);
	
	// Send message to all players
	new welcomeMsg[128];
	format(welcomeMsg, sizeof(welcomeMsg), "%s joined the server!", playerName);
	SendClientMessageToAll(0x00FFFFFF, welcomeMsg);
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	// Get player's name and reason
	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));
	
	new reasonText[32];
	switch(reason)
	{
		case 0: reasonText = "Timeout/Crash";
		case 1: reasonText = "Quit";
		case 2: reasonText = "Kicked/Banned";
	}
	
	// Print to server console
	printf("Player %s disconnected (%s)", playerName, reasonText);
	
	// Send message to all players
	new leaveMsg[128];
	format(leaveMsg, sizeof(leaveMsg), "%s left the server (%s)", playerName, reasonText);
	SendClientMessageToAll(0x00FFFFFF, leaveMsg);
	
	return 1;
}

public OnPlayerSpawn(playerid)
{
	// Send spawn message
	SendClientMessage(playerid, 0x00FF00FF, "You have spawned!");
	SendClientMessage(playerid, 0xFFFF00FF, "Use /bingo to open a random bingo cell!");
	SendClientMessage(playerid, 0xFFFF00FF, "Use /bingofield to view your field!");
	SendClientMessage(playerid, 0xFFFF00FF, "Use /bingoprizes to see your won prizes!");
	
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	// Custom chat format with player name
	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));
	
	new chatMsg[144];
	format(chatMsg, sizeof(chatMsg), "%s: %s", playerName, text);
	SendClientMessageToAll(0xFFFFFFFF, chatMsg);
	
	return 0; // Return 0 to prevent default chat
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	// /bingo command - open random cell
	if (strcmp("/bingo", cmdtext, true) == 0)
	{
		new playerName[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playerName, sizeof(playerName));
		
		// Check if there are still closed cells
		if(playerBingoOpened[playerid] >= BINGO_TOTAL_CELLS)
		{
			SendClientMessage(playerid, 0xFF0000FF, "All cells are already opened! Your bingo game is complete.");
			return 1;
		}
		
		// Open random cell
		new cellId = OpenRandomBingoCell(playerid);
		if(cellId == -1)
		{
			SendClientMessage(playerid, 0xFF0000FF, "Error opening cell!");
			return 1;
		}
		
		// Display information about opened cell
		new msg[128];
		format(msg, sizeof(msg), "%s opened cell #%d (%d/35)", playerName, cellId, playerBingoOpened[playerid]);
		SendClientMessageToAll(0x00FFFF00, msg);
		
		printf("BINGO: Player %s opened cell %d (%d/35 total)", playerName, cellId, playerBingoOpened[playerid]);
		
		// Check for bingo
		CheckPlayerBingo(playerid);
		
		return 1;
	}
	
	// /bingofield command - show player's field
	if (strcmp("/bingofield", cmdtext, true) == 0)
	{
		ShowPlayerBingoField(playerid);
		return 1;
	}
	
	// /bingoprizes command - show player's won prizes
	if (strcmp("/bingoprizes", cmdtext, true) == 0)
	{
		ShowPlayerPrizes(playerid);
		return 1;
	}
	
	// /help command
	if (strcmp("/help", cmdtext, true) == 0)
	{
		SendClientMessage(playerid, 0xFFFF00FF, "=== Bingo System Commands ===");
		SendClientMessage(playerid, 0xFFFFFFFF, "/bingo - Open a random bingo cell");
		SendClientMessage(playerid, 0xFFFFFFFF, "/bingofield - Show your bingo field");
		SendClientMessage(playerid, 0xFFFFFFFF, "/bingoprizes - Show your won prizes");
		SendClientMessage(playerid, 0xFFFFFFFF, "/help - Show this help message");
		SendClientMessage(playerid, 0xFFFF00FF, "=============================");
		return 1;
	}
	
	return 0;
}

public OnPlayerRequestClass(playerid, classid)
{
	// Set player position and camera for class selection
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	
	SendClientMessage(playerid, 0x00FF00FF, "Welcome! Press ENTER to spawn and play bingo!");
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	// Test bingo command via RCON
	if(strcmp(cmd, "testbingo", true) == 0)
	{
		print("RCON: Testing bingo system...");
		print("RCON: Simulating player bingo actions");
		print("RCON: Individual bingo system active - each player gets own 5x7 field");
		print("RCON: Players use /bingo command when connected to open random cells");
		print("RCON: Players use /bingofield to view their field");
		return 1;
	}
	
	// Show bingo prizes via RCON
	if(strcmp(cmd, "bingoprizes", true) == 0)
	{
		print("RCON: Bingo Prizes Available:");
		print("RCON: Horizontal Prizes (Rows):");
		for(new i = 0; i < BINGO_ROWS; i++)
		{
			printf("RCON:   Row %d: %s", i, bingoRewardInfo[i][prizeName]);
		}
		print("RCON: Vertical Prizes (Columns):");
		for(new i = BINGO_ROWS; i < sizeof(bingoRewardInfo); i++)
		{
			printf("RCON:   Column %d: %s", i - BINGO_ROWS, bingoRewardInfo[i][prizeName]);
		}
		return 1;
	}
	
	// Show bingo system status
	if(strcmp(cmd, "bingostatus", true) == 0)
	{
		print("RCON: === BINGO SYSTEM STATUS ===");
		printf("RCON: System Type: Individual (each player separate)");
		printf("RCON: Field Size: %dx%d (%d cells)", BINGO_ROWS, BINGO_COLS, BINGO_TOTAL_CELLS);
		printf("RCON: Total Prizes: %d", sizeof(bingoRewardInfo));
		print("RCON: Status: ACTIVE and ready for players");
		print("RCON: Commands: /bingo, /bingofield, /help");
		return 1;
	}
	
	// Announce bingo to connected players
	if(strcmp(cmd, "bingosay", true) == 0)
	{
		SendClientMessageToAll(0xFF00FFFF, "🎯 BINGO GAME ANNOUNCEMENT!");
		SendClientMessageToAll(0xFFFF00FF, "Type /bingo to open random cells in your field!");
		SendClientMessageToAll(0xFFFF00FF, "Each player has their own 5x7 bingo field!");
		SendClientMessageToAll(0xFFFF00FF, "Complete a row or column to win prizes!");
		print("RCON: Bingo announcement sent to all connected players");
		return 1;
	}
	
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

// ================================
// BINGO SYSTEM FUNCTIONS
// ================================

// Open random cell
stock OpenRandomBingoCell(playerid)
{
	new closedCells[BINGO_TOTAL_CELLS];
	new closedCount = 0;
	
	// Find all closed cells
	for(new i = 0; i < BINGO_TOTAL_CELLS; i++)
	{
		if(!playerBingoField[playerid][i])
		{
			closedCells[closedCount] = i;
			closedCount++;
		}
	}
	
	// If no closed cells
	if(closedCount == 0) return -1;
	
	// Choose random closed cell
	new randomIndex = random(closedCount);
	new cellId = closedCells[randomIndex];
	
	// Open cell
	playerBingoField[playerid][cellId] = true;
	playerBingoOpened[playerid]++;
	
	return cellId;
}

// Check for bingo
stock CheckPlayerBingo(playerid)
{
	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));
	
	new newPrizesWon = 0;
	new newPrizeMessages[5][128]; // Store up to 5 new prize messages
	
	// Check horizontal lines (rows)
	for(new row = 0; row < BINGO_ROWS; row++)
	{
		new completed = true;
		for(new col = 0; col < BINGO_COLS; col++)
		{
			new cellId = row * BINGO_COLS + col;
			if(!playerBingoField[playerid][cellId])
			{
				completed = false;
				break;
			}
		}
		
		if(completed && !playerWonPrizes[playerid][row])
		{
			// New horizontal bingo (row prize)
			playerWonPrizes[playerid][row] = true;
			playerTotalPrizes[playerid]++;
			
			format(newPrizeMessages[newPrizesWon], 128, "*** BINGO! %s won ROW %d: %s", 
				   playerName, row, bingoRewardInfo[row][prizeName]);
			newPrizesWon++;
			
			printf("BINGO HORIZONTAL: Player %s won row %d - %s", playerName, row, bingoRewardInfo[row][prizeName]);
		}
	}
	
	// Check vertical lines (columns)
	for(new col = 0; col < BINGO_COLS; col++)
	{
		new completed = true;
		for(new row = 0; row < BINGO_ROWS; row++)
		{
			new cellId = row * BINGO_COLS + col;
			if(!playerBingoField[playerid][cellId])
			{
				completed = false;
				break;
			}
		}
		
		if(completed)
		{
			new prizeIndex = BINGO_ROWS + col; // Index in prize array for vertical lines
			if(!playerWonPrizes[playerid][prizeIndex])
			{
				// New vertical bingo (column prize)
				playerWonPrizes[playerid][prizeIndex] = true;
				playerTotalPrizes[playerid]++;
				
				format(newPrizeMessages[newPrizesWon], 128, "*** BINGO! %s won COLUMN %d: %s", 
					   playerName, col, bingoRewardInfo[prizeIndex][prizeName]);
				newPrizesWon++;
				
				printf("BINGO VERTICAL: Player %s won column %d - %s", playerName, col, bingoRewardInfo[prizeIndex][prizeName]);
			}
		}
	}
	
	// Announce all new prizes won
	if(newPrizesWon > 0)
	{
		for(new i = 0; i < newPrizesWon; i++)
		{
			SendClientMessageToAll(0xFF00FF00, newPrizeMessages[i]);
		}
		
		// Show total prizes summary
		if(newPrizesWon > 1)
		{
			new summaryMsg[128];
			format(summaryMsg, sizeof(summaryMsg), "*** %s won %d prizes at once! Total prizes: %d/12", 
				   playerName, newPrizesWon, playerTotalPrizes[playerid]);
			SendClientMessageToAll(0xFFFF00FF, summaryMsg);
		}
		else
		{
			new summaryMsg[128];
			format(summaryMsg, sizeof(summaryMsg), "*** %s now has %d prizes total!", 
				   playerName, playerTotalPrizes[playerid]);
			SendClientMessageToAll(0x00FFFFFF, summaryMsg);
		}
	}
}

// Show player's field
stock ShowPlayerBingoField(playerid)
{
	new msg[256];
	
	SendClientMessage(playerid, 0xFFFF00FF, "=== Your Bingo Field (5x7) ===");
	
	for(new row = 0; row < BINGO_ROWS; row++)
	{
		new rowStr[128] = "";
		for(new col = 0; col < BINGO_COLS; col++)
		{
			new cellId = row * BINGO_COLS + col;
			new cellStr[8];
			
			if(playerBingoField[playerid][cellId])
			{
				format(cellStr, sizeof(cellStr), "[X]");
			}
			else
			{
				format(cellStr, sizeof(cellStr), "[%d]", cellId);
			}
			
			strcat(rowStr, cellStr);
			if(col < BINGO_COLS - 1) strcat(rowStr, " ");
		}
		SendClientMessage(playerid, 0xFFFFFFFF, rowStr);
	}
	
	format(msg, sizeof(msg), "Opened cells: %d/%d | Prizes won: %d/12", 
		   playerBingoOpened[playerid], BINGO_TOTAL_CELLS, playerTotalPrizes[playerid]);
	SendClientMessage(playerid, 0x00FF00FF, msg);
}

// Show player's won prizes
stock ShowPlayerPrizes(playerid)
{
	new playerName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playerName, sizeof(playerName));
	
	SendClientMessage(playerid, 0xFFFF00FF, "=== Your Won Prizes ===");
	
	if(playerTotalPrizes[playerid] == 0)
	{
		SendClientMessage(playerid, 0xFF0000FF, "You haven't won any prizes yet!");
		SendClientMessage(playerid, 0xFFFFFFFF, "Complete rows or columns to win prizes!");
		return;
	}
	
	new prizesShown = 0;
	
	// Show horizontal prizes (rows)
	SendClientMessage(playerid, 0x00FFFF00, "Row Prizes:");
	for(new row = 0; row < BINGO_ROWS; row++)
	{
		if(playerWonPrizes[playerid][row])
		{
			new prizeMsg[128];
			format(prizeMsg, sizeof(prizeMsg), "  Row %d: %s", row, bingoRewardInfo[row][prizeName]);
			SendClientMessage(playerid, 0xFFFFFFFF, prizeMsg);
			prizesShown++;
		}
	}
	
	// Show vertical prizes (columns)
	SendClientMessage(playerid, 0x00FFFF00, "Column Prizes:");
	for(new col = 0; col < BINGO_COLS; col++)
	{
		new prizeIndex = BINGO_ROWS + col;
		if(playerWonPrizes[playerid][prizeIndex])
		{
			new prizeMsg[128];
			format(prizeMsg, sizeof(prizeMsg), "  Column %d: %s", col, bingoRewardInfo[prizeIndex][prizeName]);
			SendClientMessage(playerid, 0xFFFFFFFF, prizeMsg);
			prizesShown++;
		}
	}
	
	// Summary
	new summaryMsg[128];
	format(summaryMsg, sizeof(summaryMsg), "Total: %d prizes won out of 12 possible!", playerTotalPrizes[playerid]);
	SendClientMessage(playerid, 0x00FF00FF, summaryMsg);
	
	// Progress message
	if(playerTotalPrizes[playerid] < 12)
	{
		new remaining = 12 - playerTotalPrizes[playerid];
		format(summaryMsg, sizeof(summaryMsg), "%d more prizes available! Keep playing!", remaining);
		SendClientMessage(playerid, 0xFFFF00FF, summaryMsg);
	}
	else
	{
		SendClientMessage(playerid, 0xFF00FFFF, "*** CONGRATULATIONS! You won ALL prizes! ***");
	}
}

#endif
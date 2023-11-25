#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Custom Server Commands"

#define MAX_STRING	50
#define MAX_BUFFER	100
#define MAX_DIR		200
#define MAX_MOTDS 	100

new gMOTDCommand[MAX_MOTDS][MAX_STRING];
new gMOTDSource[MAX_MOTDS][MAX_STRING];
new gMOTDTitle[MAX_MOTDS][MAX_STRING];
new gNumMOTD;

new gDIR[MAX_DIR]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	new configsdir[MAX_DIR];
	get_configsdir(configsdir, MAX_DIR-1);
	format(gDIR, MAX_DIR-1, "%s/Custom Commands", configsdir);
	
	set_task(1.0, "Load");
}

public Load()
{
	new file[MAX_DIR];
	format(file, MAX_DIR-1, "%s/motds.ini", gDIR);
	
	new fp;
	if (!(fp = fopen(file, "r")))
		log_amx("Failed to open file ^"%s^" - clients will not be able to use the custom commands");
	else
	{
		new buffer[MAX_BUFFER];
		new command[MAX_STRING];
		new source[MAX_STRING];
		new title[MAX_STRING];
		new internalCommand[MAX_STRING];
		
		while (!feof(fp))
		{
			if (gNumMOTD >= MAX_MOTDS)
				break;
			
			buffer[0]		= '^0';
			command[0]		= '^0';
			source[0]		= '^0';
			title[0]		= '^0';
			internalCommand[0] 	= '^0';
			
			fgets(fp, buffer, MAX_BUFFER-1);
			
			if (!strlen(buffer) || buffer[0] == ';' || buffer[0] == '^n')
				continue;
			else
			{
				parse(buffer, command, MAX_STRING-1, source, MAX_STRING-1, title, MAX_STRING-1);
								
				if (!strlen(command) || !strlen(source))
					continue;
				
				copy(gMOTDCommand[gNumMOTD], MAX_STRING-1, command);
				
				if (containi(source, "http://") != -1)
					format(gMOTDSource[gNumMOTD], MAX_STRING-1, "%s", source);
				else
					format(gMOTDSource[gNumMOTD], MAX_STRING-1, "%s/%s", gDIR, source);
					
				copy(gMOTDTitle[gNumMOTD], MAX_STRING-1, strlen(title) ? title : command);
				
				format(internalCommand, MAX_STRING-1, "say %s", command);
				register_clcmd(internalCommand, "CMD_HookMOTD");
		
				++gNumMOTD;
			}
		}
	}
}

public CMD_HookMOTD(id)
{
	new arg[MAX_STRING];
	read_argv(1, arg, MAX_STRING-1);
	
	new i;
	for (i = 0; i < gNumMOTD; i++)
	{
		if (equal(arg, gMOTDCommand[i]))
		{
			show_motd(id, gMOTDSource[i], gMOTDTitle[i]); 
			break;
		}
	}
	
	return PLUGIN_HANDLED;
}
				
			
				
			
		

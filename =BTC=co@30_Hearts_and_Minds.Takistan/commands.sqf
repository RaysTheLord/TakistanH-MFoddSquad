pvpfw_chatIntercept_allCommands = [
	[
		"help",
		{
			_commands = "";
			{
				_commands = _commands + (pvpfw_chatIntercept_commandMarker + (_x select 0)) + ", ";
			}forEach pvpfw_chatIntercept_allCommands;
			systemChat format["Available Commands: %1",_commands];
		}
	],
	[
		"jump",
		{player setVelocity [0,0,3]}
	],
	[
		"echo",
		{
			_argument = _this select 0;
			systemChat format["Echo: %1",_argument];
		}
	]
];
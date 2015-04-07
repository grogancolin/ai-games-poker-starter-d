module starterBot;

import std.conv : to;
import std.algorithm;
import std.stdio;
import std.string;
import std.range : array;

import poker;
/**
  * Compile wiht dmd starterBot.d -version=SampleMain
  * to include this main function.
  */
version(SampleMain){
        void main(){
                writefln("Sample main function for running Poker AI StarterBot");
                auto p = new PokerBot();
                p.run();
        }
}
/**
 * All communications types allowed to us from the server
 * */
enum Communication : string{
	Settings = "Settings",
	Match = "Match",
	Action = "Action",
	Player1 = "player1",
	Player2 = "player2"
}

/** Main class for the PokerBot.
 * All io with the server goes through this."
 * */
public class PokerBot{
public:
	this(){
          }

	public void run(){
		string line = stdin.readln;
		scope(failure) { 
			stderr.writefln("ERROR: Last line from server \"%s\"", line);
		}

		while(line.length != 0){
			immutable splitted = line.strip.chomp.split(" ");
			assert(splitted.length == 3, "Error communicating with server");
			final switch(splitted[0]){
				case Communication.Settings : gameSettings.handleSettings(splitted[1..$]); break;
				case Communication.Match : match.handleMatch(splitted[1..$]); break;
				case Communication.Action : handleAction(this, splitted[1..$]); break;
				case Communication.Player1 : player1.handlePlayerUpdate(splitted[1..$]); break;
				case Communication.Player2 : player2.handlePlayerUpdate(splitted[1..$]); break;
				
			}
			stderr.writefln("%s", gameSettings);
			stderr.writefln("%s", match);
			pastCommunications ~= line;
			line = stdin.readln;

		}
	}

	Settings gameSettings;
	Match match;
	Player player1 = Player("player1");
	Player player2 = Player("player2");

	/** Contains all past communication with the server. For ease of playback */
	string[] pastCommunications;
}

enum Cards{_2s,_2h,_2d,_2c,_3s,_3h,_3d,_3c,_4s,_4h,_4d,_4c,_5s,_5h,_5d,_5c,_6s,_6h,_6d,_6c,_7s,_7h,_7d,_7c,_8s,_8h,_8d,_8c,_9s,_9h,_9d,_9c,_Ts,_Th,_Td,_Tc,_Js,_Jh,_Jd,_Jc,_Qs,_Qh,_Qd,_Qc,_Ks,_Kh,_Kd,_Kc,_As,_Ah,_Ad,_Ac}

public struct Settings{
	ulong timeBank;
	ulong timePerMove;
	ulong handsPerLevel;
	ulong startingStack;
	string botName;
}

public struct Match{
	ulong round=1;
	ulong smallBlind;
	ulong bigBlind;
	byte onButton;
	Cards[] cards;
	ulong maxWinPot;
	ulong amountToCall;
	
	void updateCards(immutable string cards){
		this.cards ~= cards.parseCardString;
	}
}

struct Player{
	string name; //"player1" | "player2"
	ulong stack;
	Cards[2] hand;

    /**
      * Will always go all in
       */
	string decideNextAction(ulong timeToDecide){
		return "call " ~ stack.to!string;
	}

}


void handleSettings(ref Settings settings, immutable string[] ar){
	switch(ar[0]){
		case "time_bank" : settings.timeBank = ar[1].to!ulong; break;
		case "time_per_move" : settings.timePerMove = ar[1].to!ulong; break;
		case "hands_per_level" : settings.handsPerLevel = ar[1].to!ulong; break;
		case "starting_stack" : settings.startingStack = ar[1].to!ulong; break;
		case "your_bot" : settings.botName = ar[1].dup; break;
		default: assert(0, "Error handling Settings communication");
	}
}

void handleMatch(ref Match match, immutable string[] ar){
	switch(ar[0]){
		case "round" : match.round = ar[1].to!ulong; break;
		case "small_blind" : match.smallBlind = ar[1].to!ulong; break;
		case "big_blind" : match.bigBlind = ar[1].to!ulong; break;
		case "on_button" : match.onButton = ar[1] == "player1" ? 1 : 2; break;
		case "table" : match.updateCards(ar[1]); break;
		case "max_win_pot" : match.maxWinPot = ar[1].to!ulong; break;
		case "amountToCall" : match.amountToCall = ar[1].to!ulong; break;
		default: assert(0, "Error handling match communication");
	}
}

void handlePlayerUpdate(Player player, immutable string[] ar){
	switch(ar[0]){
		case "stack" : player.stack = ar[1].to!uint; break;
		case "hand" : player.hand = ar[1].parseCardString; break;
		case "post" : break;
		case "fold" : break;
		case "check" : break;
		case "call" : break;
		case "raise" : break;
		case "wind" : stderr.writefln("YAY!"); break;
		default: assert(0, "Error handling player update");
	}
}

void handleAction(PokerBot bot, immutable string[] ar){
	string command;
	switch(ar[0]){
		case "player1" : command = bot.player1.decideNextAction(ar[1].to!ulong); break;
		case "player2" : command = bot.player2.decideNextAction(ar[1].to!ulong); break;
		default: assert(0, "Error handling update");
	}
	writefln("%s", command);
}

/** Utils **/

/**
 * Parses a string of the form [1h,2h,3h] into a Cards[]
 * */
Cards[] parseCardString(immutable string cards){
	return cards[1..$-1].split(",")
		.map!(a => "_"~a)
			.map!(a => a.to!Cards)
			.array;
}

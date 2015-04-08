module customBot;

import std.stdio;

import starterBot;
import poker;
import utils;
void main()
{
	//foreach(hand; ValidPokerHands.Pairs){
	//	writefln("%s", hand);
	//}
	Card _2s = Card(Suit.Spade, Rank.Two);
	Card _3s = Card(Suit.Spade, Rank.Three);
	Card _4h = Card(Suit.Heart, Rank.Four);
	Card _5h = Card(Suit.Heart, Rank.Five);
	Card _6d = Card(Suit.Diamond, Rank.Six);
	Hand myHand = Hand([_2s, _3s, _4h, _5h, _6d]);
	foreach(hand; ValidPokerHands.Straights){
		if(myHand.compare(hand))
		writefln("%s", hand);
	}
}


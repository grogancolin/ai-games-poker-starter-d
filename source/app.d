module customBot;

import std.stdio;
import std.algorithm;
import std.range;
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
	Hand myHand = Hand([_2s, _3s, _4h, _5h, _6d].retro.array);
//	foreach(hand; genStraights){
//		//if(myHand.compare(hand))
//		//writefln("%s", hand);
//	}
	writefln("Num High Cards %s", ValidPokerHands.HighCards.length);
	writefln("Num Pairs %s", ValidPokerHands.Pairs.length);
	writefln("Num Two pairs %s", ValidPokerHands.TwoPairs.length);
	writefln("Num Three of a kinds %s", ValidPokerHands.ThreeOfAKinds.length);
	writefln("Num Straights %s", ValidPokerHands.Straights.length);
	foreach(hand; ValidPokerHands.StraightFlushes){
		writefln("%s", hand);
		if(myHand.compare(hand))
			writefln("My hand %s\nHand %s", myHand, hand);
	}

	writefln("Num combs %s", AllCombinationsOfCards.length);
}


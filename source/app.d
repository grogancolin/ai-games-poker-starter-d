module customBot;

import std.stdio;

import starterBot;
import poker;

void main()
{
	foreach(int i, Hand hand; ValidPokerHands.HighCard)
		writefln("%s - %s", i, hand);

	Card[] myHand = [Deck[0], Deck[1], Deck[2], Deck[3]];
	writefln("%s", Combinations(myHand));

}

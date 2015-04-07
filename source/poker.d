module poker;
/+
 + Module handles everything to do with texas holdem poker.
 + +/

import std.conv;
debug import std.stdio;

public enum Suit{
	Club,
	Diamond,
	Heart,
	Spade
}
public enum Rank{
	Ace,
	King,
	Queen,
	Jack,
	Ten,
	Nine,
	Eight,
	Seven,
	Six,
	Five,
	Four,
	Three,
	Two
}

/*
 * Represents a single card
 * */
public struct Card{
	Suit suit;
	Rank rank;

	string toString(){
		return this.cardName;
	}
}

/*
 * Represents a poker hand
 * */
public struct Hand{
	Card[] cards;

	/**
	 * Calculates the value of this hand.
	 * 
	 * */
	public @property value(){

	}
}

/**
 * A compile time calculated table of valid poker hands
 * */
public enum ValidPokerHands : Hand[]{
	HighCard = genHighCards
}

Hand[] genHighCards(){
	Hand[] hands;
	foreach(card; Deck)
		hands ~= Hand([card]);
	return hands;
}

Hand[] genPairs(){
	Hand[] hands;

	return hands;
}

enum Deck = genFullDeck;

/+ Utils +/

public const allSuits = [__traits(allMembers, Suit)];
public const allRanks = [__traits(allMembers, Rank)];

private Card[] genFullDeck(){
	Card[] cards;
	foreach(rank; 0..allRanks.length)
	foreach(suit; 0..allSuits.length)
		cards ~= Card(cast(Suit)suit, cast(Rank)rank);
	return cards;
}

/**
 * Used for printing.
 * */
public string cardName(Card c){
	char[2] n;
	with(Rank)
	final switch(c.rank){
		case Ace: n[0]='A'; break;
		case King: n[0]='K'; break;
		case Queen: n[0]='Q'; break;
		case Jack: n[0]='J'; break;
		case Ten: n[0]='T'; break;
		case Nine: n[0]='9'; break;
		case Eight: n[0]='8'; break;
		case Seven: n[0]='7'; break;
		case Six: n[0]='6'; break;
		case Five: n[0]='5'; break;
		case Four: n[0]='4'; break;
		case Three: n[0]='3'; break;
		case Two: n[0]='2'; break;
	}
	
	with(Suit)
	final switch(c.suit){
		case Club: n[1]='c'; break;
		case Diamond: n[1]='d'; break;
		case Heart: n[1]='h'; break;
		case Spade: n[1]='s'; break;
	}
	
	return n.to!string;
}


public T[] Combinations(T)(T[] elements){
	import std.algorithm;
	import std.range;
	import std.array;
	debug writefln("Combinations - %s", elements);
	auto res = elements.map!((a){
			auto index = elements.countUntil(a);
			return elements.filter!(b => elements.countUntil(b) != index)
				.array
				.Combinations
				.map!(y => [a, y])
				.array;
		});
	T[] ar;
	foreach(ele; res)
		writefln("%s", ele);
	return ar;
}


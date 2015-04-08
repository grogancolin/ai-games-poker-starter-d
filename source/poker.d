module poker;
/+
 + Module handles everything to do with texas holdem poker.
 + +/

import std.conv;
import utils;
import std.range;
import std.algorithm;
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

	/**
	  * Compares this hand with another
	  */
	public bool compare(Hand other){
		bool val = true;
		foreach(card; this.cards){
			if(!other.cards.canFind(card))
				val = false;
		}

		return val;
	}
}

/**
 * A compile time calculated table of valid poker hands
 * */
public enum ValidPokerHands : Hand[]{
	HighCards = genHighCards,
	Pairs = genPairs,
	TwoPairs = genTwoPairs,
	ThreeOfAKinds = genThreeOfAKinds,
	Straights = genStraights,
	FourOfAKinds = genFourOfAKinds
}

Hand[] genHighCards(){
	Hand[] hands;
	foreach(card; Deck)
		hands ~= Hand([card]);
	return hands;
}

Hand[] genPairs(){
	Hand[] hands;
	foreach(i; iota(0, 51, 4).array){
		auto bunch = Deck[i..i+4].combinations(2);
		foreach(hand; bunch)
			hands ~= Hand(hand);
	}
	return hands;
}

Hand[] genTwoPairs(){
	Hand[] hands;
	Hand[] singlePairs = genPairs();

	foreach(res; ValidPokerHands.Pairs.combinations(2)){
		if(res[0].cards[0].rank == res[1].cards[0].rank)
			continue;
		else
			hands ~= Hand(res[0].cards ~ res[1].cards);

	}
	return hands;
}

Hand[] genThreeOfAKinds(){
	Hand[] hands;
	foreach(i; iota(0, 51, 4).array){
		auto bunch = Deck[i..i+4].combinations(3);
		foreach(hand; bunch)
			hands ~= Hand(hand);
	}
	return hands;
}


Hand[] genStraights(){
	Rank[] ranks = mixin("["~ allRanks.map!(a => "Rank."~a).join(",") ~ "]");
	Suit[] suits = mixin("["~ allSuits.map!(a => "Suit."~a).join(",") ~ "]");
	// straights are special, as Aces count for 1 and 13, so,
	// add another Ace rank onto the end of ranks
	ranks ~= Rank.Ace;
	Rank[][] straightRanks;
	for(int i=0; i < ranks.length-5; i++ ){
		straightRanks ~= ranks[i..i+5];
	}
	// get all possible combinations of suits

	auto suitsComb_4 = suits.combinations(4);
	pragma(msg, typeof(suitsComb_4.front));
	Suit[][] suitCombs;
	foreach(suit; suits)
	foreach(comb; suitsComb_4){
		suitCombs ~= comb ~ suit;
	}


	Hand[] hands;
	foreach(suitComb; suitCombs){
		foreach(straightRank; straightRanks){
			Hand h;
			foreach(rank; straightRank){
				foreach(suit; suitComb){
					h.cards ~= Card(suit, rank);
				}
			}
			hands ~= h;
		}
	}
	return hands;
}

Hand[] genFourOfAKinds(){
	Hand[] hands;
	foreach(i; iota(0, 51, 4).array){
		hands ~= Hand(Deck[i..i+4]);
	}
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

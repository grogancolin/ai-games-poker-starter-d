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
	Spade,
	DONT_CARE
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
	Two,
	DONT_CARE
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

	bool compare(Card other){
		if( ( this.rank == other.rank || this.rank == Rank.DONT_CARE || other.rank == Rank.DONT_CARE ) 
			&& 
			(this.suit == other.suit || this.suit == Suit.DONT_CARE || other.suit == Suit.DONT_CARE)
		  ) // then
			return true;
		else
			return false;
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
	  * Both hands must be in DESCENDING ORDER
	  */
	public bool compare(Hand other){
		for(int i=0; i<min(this.cards.length, other.cards.length); i++){
			if(!this.cards[i].compare(other.cards[i]))
				return false;
		}
		return true;
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
	Flushes = genFlushes,
	FullHouses = genFullHouses,
	FourOfAKinds = genFourOfAKinds,
	StraightFlushes = genStraightFlushes,
	RoyalFlushes = genRoyalFlushes
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
	// straights are special, as Aces count for 1 and 13, so,
	// add another Ace rank onto the end of ranks
	ranks ~= Rank.Ace;
	Rank[][] straightRanks;
	for(int i=0; i < ranks.length-4; i++ ){
		straightRanks ~= ranks[i..i+5];
	}
	// get all possible combinations of suits
	Hand[] hands;
	foreach(r; straightRanks)
		hands ~= Hand(r.map!(a => Card(Suit.DONT_CARE, a)).array);
	return hands;
}

/+
Hand[] genFlushes(){
	Suit[] suits = mixin("["~ allSuits.map!(a => "Suit."~a).join(",") ~ "]");

	Hand[] hands;
	foreach(suit; suits){
		// create a hand with five cards, all of which have suits = suit
		Hand h;
		iota(0,5,1).each!(a => h.cards ~= Card(suit, Rank.DONT_CARE));
	}
	return hands;
}
+/
Hand[] genFlushes(){
	Suit[] suits = mixin("["~ allSuits.map!(a => "Suit."~a).join(",") ~ "]");
	
	Hand[] hands;
	Hand[] genericFlushes;
	foreach(suit; suits){
		// create a hand with five cards, all of which have suits = suit
		Card[5] cards;
		cards.each!(a => a=Card(suit, Rank.DONT_CARE));
		genericFlushes ~= Hand(cards);
	}

	Hand h;
	foreach(combination; AllCombinationsOfCards){
		Suit s = combination[0].suit;
		if(combination.any!(a => a.suit != s))
			continue;
		h = Hand(combination);
		foreach(flush; genericFlushes)
			if(h.compare(flush))
				hands ~= h;
	}
	return hands;
}
Hand[] genFullHouses(){
	// get all pairs
	Hand[] pairs = ValidPokerHands.Pairs;
	Hand[] threes = ValidPokerHands.ThreeOfAKinds;

	Hand[] hands;
	foreach(pair; pairs){
		foreach(three; threes){
			if(pair.cards[0].rank != three.cards[0].rank)
				hands ~= Hand(pair.cards ~ three.cards);
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

Hand[] genStraightFlushes(){
	Suit[] suits = mixin("["~ allSuits.map!(a => "Suit."~a).join(",") ~ "]");

	Rank[] ranks = mixin("["~ allRanks.map!(a => "Rank."~a).join(",") ~ "]");
	// straights are special, as Aces count for 1 and 13, so,
	// add another Ace rank onto the end of ranks
	ranks ~= Rank.Ace;
	Rank[][] straightRanks;
	for(int i=0; i < ranks.length-4; i++ ){
		straightRanks ~= ranks[i..i+5];
	}
	Hand[] hands;
	foreach(suit; suits){
		foreach(straight; straightRanks){
			hands ~= Hand(straight.map!(a => Card(suit, a)).array);
		}
	}
	return hands;
}

Hand[] genRoyalFlushes(){
	Hand[] hands;
	Suit[] suits = mixin("["~ allSuits.map!(a => "Suit."~a).join(",") ~ "]");
	foreach(suit; suits){
		Card A = Card(suit, Rank.Ace);
		Card K = Card(suit, Rank.King);
		Card Q = Card(suit, Rank.Queen);
		Card J = Card(suit, Rank.Jack);
		Card T = Card(suit, Rank.Ten);
		hands ~= Hand([A,K,Q,J,T]);
	}
	return hands;
}

enum Deck = genFullDeck;
enum AllCombinationsOfCards = Deck.combinations(5);
/+ Utils +/

public const allSuits = [__traits(allMembers, Suit)].filter!(a => a!="DONT_CARE").array;
public const allRanks = [__traits(allMembers, Rank)].filter!(a => a!="DONT_CARE").array;

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
		case DONT_CARE : n[0]='x'; break;
	}

	with(Suit)
	final switch(c.suit){
		case Club: n[1]='c'; break;
		case Diamond: n[1]='d'; break;
		case Heart: n[1]='h'; break;
		case Spade: n[1]='s'; break;
		case DONT_CARE: n[1]='X'; break;
	}

	return n.to!string;
}

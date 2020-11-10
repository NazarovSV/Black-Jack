# frozen_string_literal: true

require_relative 'Cards/Suits/hearts'
require_relative 'Cards/Suits/clubs'
require_relative 'Cards/Suits/diamonds'
require_relative 'Cards/Suits/spades'
require_relative 'Cards/two'
require_relative 'Cards/three'
require_relative 'Cards/four'
require_relative 'Cards/five'
require_relative 'Cards/six'
require_relative 'Cards/seven'
require_relative 'Cards/eight'
require_relative 'Cards/nine'
require_relative 'Cards/ten'
require_relative 'Cards/jack'
require_relative 'Cards/queen'
require_relative 'Cards/king'
require_relative 'Cards/ace'

class Deck
  def initialize(count_of_deck = 1)
    @cards = []
    build_deck(count_of_deck)
  end

  def shuffle
    @cards = @cards.shuffle
  end

  def get_card
    @cards.shift
  end

  private

  attr_accessor :cards

  def build_deck(count_of_deck)
    suits = [Hearts.new, Diamonds.new, Clubs.new, Spades.new]

    count_of_deck.times do
      suits.each do |suit|
        @cards.push Two.new suit
        @cards.push Three.new suit
        @cards.push Four.new suit
        @cards.push Five.new suit
        @cards.push Six.new suit
        @cards.push Seven.new suit
        @cards.push Eight.new suit
        @cards.push Nine.new suit
        @cards.push Ten.new suit
        @cards.push Jack.new suit
        @cards.push Queen.new suit
        @cards.push King.new suit
        @cards.push Ace.new suit
      end
    end
  end
end

# frozen_string_literal: true

class AIDealer
  def initialize(cards, deck)
    @cards = cards
    @deck = deck
  end

  def make_a_move
    @cards.push @deck.get_card if count_total < 17
  end

  private

  attr_accessor :cards, :deck

  def count_total
    total = 0
    cards.each do |card|
      total += if card.is_a? Ace
                 total + 11 > 21 ? card.value[0] : card.value[-1]
               else
                 card.value
               end
    end
    total
  end
end

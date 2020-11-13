# frozen_string_literal: true

class AIDealer
  def initialize(name, cards, deck)
    @name = name
    @cards = cards
    @deck = deck
  end

  def take_card?
    if count_total < 17
      @cards.push @deck.take_card
      true
    else
      false
    end
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

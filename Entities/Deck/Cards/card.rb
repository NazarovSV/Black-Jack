# frozen_string_literal: true

class Card
  attr_reader :name, :suit, :value

  def initialize(name, value, suit)
    @name = name
    @suit = suit
    @value = value
  end
end

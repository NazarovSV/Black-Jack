# frozen_string_literal: true

require_relative 'suit'

class Spades < Suit
  def initialize
    super 'пики', '^'
  end
end

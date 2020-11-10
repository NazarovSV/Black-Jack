# frozen_string_literal: true

require_relative 'card'

class Ace < Card
  def initialize(suit)
    super 'Туз',[1, 11], suit
  end
end

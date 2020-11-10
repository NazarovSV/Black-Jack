# frozen_string_literal: true

require_relative 'card'

class Jack < Card
  def initialize(suit)
    super 'Валет', 10, suit
  end
end

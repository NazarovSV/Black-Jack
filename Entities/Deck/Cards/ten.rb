# frozen_string_literal: true

require_relative 'card'

class Ten < Card
  def initialize(suit)
    super 'Десятка', 10, suit
  end
end

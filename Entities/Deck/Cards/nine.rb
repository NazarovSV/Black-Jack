# frozen_string_literal: true

require_relative 'card'

class Nine < Card
  def initialize(suit)
    super 'Девятка',9, suit
  end
end

# frozen_string_literal: true

require_relative 'card'

class King < Card
  def initialize(suit)
    super 'Король',10, suit
  end
end

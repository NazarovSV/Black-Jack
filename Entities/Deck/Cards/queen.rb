# frozen_string_literal: true

require_relative 'card'

class Queen < Card
  def initialize(suit)
    super 'Королева',10, suit
  end
end

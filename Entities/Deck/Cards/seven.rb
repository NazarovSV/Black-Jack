# frozen_string_literal: true

require_relative 'card'

class Seven < Card
  def initialize(suit)
    super 'Семерка', 7, suit
  end
end

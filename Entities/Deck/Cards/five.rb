# frozen_string_literal: true

require_relative 'card'

class Five < Card
  def initialize(suit)
    super 'Пятерка', 5, suit
  end
end

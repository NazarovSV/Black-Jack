# frozen_string_literal: true

require_relative 'card'

class Eight < Card
  def initialize(suit)
    super 'Восьмерка', 8, suit
  end
end

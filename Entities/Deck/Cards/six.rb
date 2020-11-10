# frozen_string_literal: true

require_relative 'card'

class Six < Card
  def initialize(suit)
    super 'Шестерка',6, suit
  end
end

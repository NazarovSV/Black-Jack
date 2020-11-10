# frozen_string_literal: true

require_relative 'card'

class Three < Card
  def initialize(suit)
    super 'Тройка',3, suit
  end
end

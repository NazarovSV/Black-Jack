# frozen_string_literal: true

require_relative 'card'

class Two < Card
  def initialize(suit)
    super 'Двойка',2, suit
  end
end

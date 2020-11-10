# frozen_string_literal: true

require_relative 'card'

class Four < Card
  def initialize(suit)
    super 'Четверка',4, suit
  end
end

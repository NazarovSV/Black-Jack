# frozen_string_literal: true

class User
  attr_reader :name, :account, :cards

  def initialize(name, account)
    @name = name
    @account = account
    @cards = []
  end

  def clear_cards
    @cards = []
  end
end

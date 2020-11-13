# frozen_string_literal: true

require_relative '../Entities/Bank/account'

class Bank
  attr_reader :total, :accounts

  def initialize(accounts)
    @total = 0
    @accounts = accounts
  end

  def place_bet(bet)
    @accounts.each do |player_account, _|
      player_account.account.withdraw_money bet
      @total += bet
    end
  end

  def deposit_money(winner)
    if winner.nil?
      accounts.each { |account| account.put_money(@total / accounts.count) }
    else
      accounts[winner].put_money @total
    end
    @total = 0
  end

  def accounts_info
    accounts_info = {}
    accounts.each { |user_account, account| accounts_info[user_account.name] = account.total }
    accounts_info
  end
end

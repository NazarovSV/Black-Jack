# frozen_string_literal: true

require_relative '../Utils/validation'
require_relative '../Entities/User/user'
require_relative '../Entities/Bank/account'
require_relative '../Entities/Deck/deck'
require_relative '../Entities/Deck/Cards/ace'

class Game
  include Validation

  def start
    greeting
    self.user_name = gets.chomp
    validate!
    create_players
    create_deck

    2.times { user.cards.push @deck.get_card }
    2.times { dealer.cards.push @deck.get_card }

    puts "Карты дилера: * *\n"
    puts "Карты пользователя #{user.name}:"
    user.cards.each { |card| puts "#{card.name} #{card.suit.image}" }
    total = 0
    user.cards.each do |card|
      total += if card.is_a? Ace
                 total + 11 > 21 ? card.value[0] : card.value[-1]
               else
                 card.value
               end
    end
    puts "Итого: #{total}"
  end

  private

  attr_accessor :deck, :user, :dealer

  def create_deck
    puts 'Сколько колод участвует в игре?'
    puts 'Введите число:'
    deck_count = gets.chomp.to_i
    raise 'должно участвовать одна или больше колод' if deck_count.nil? || !deck_count.positive?

    @deck = Deck.new deck_count
    @deck.shuffle
  rescue StandardError => e
    puts e.message
    retry
  end

  def create_players
    @user = User.new(@user_name, Account.new(100))
    @dealer = User.new('Dealer', Account.new(100))
  end

  def greeting
    puts 'Добрый день! Введите, пожалуйста ваше имя'
  end

  validate :user_name, :presence
end

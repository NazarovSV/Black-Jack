# frozen_string_literal: true

require_relative '../Utils/validation'
require_relative '../Entities/User/user'
require_relative '../Entities/Bank/account'
require_relative '../Entities/Deck/deck'
require_relative '../Entities/Deck/Cards/ace'

class Game
  include Validation

  def initialize
    @bank = 0
    @game_variants = {
      'Пропустить' => nil,
      'Добавить карту' => nil,
      'Открыть карты' => method(:open_cards)
    }
  end

  def start
    greeting
    initialize_game_settings
    launch_game
  end

  private

  def open_cards
    print_user_game_info @dealer
    print_user_game_info @user
    summarize
  end

  def print_users_banks_state
    [@user, @dealer].each { |user| puts "На текущий момент у пользователя #{user.name} денег #{user.account.total}\n\n" }
  end

  def summarize
    user_total = count_total @user
    dealer_total = count_total @dealer

    deposit_money(dealer_total, user_total)
    @bank = 0
    print_users_banks_state
  end

  def deposit_money(dealer_total, user_total)
    if user_total > dealer_total
      @user.account.put_money @bank
    elsif user_total < dealer_total
      @dealer.account.put_money @bank
    else
      @user.account.put_money(@bank / 2)
      @dealer.account.put_money(@bank / 2)
    end
  end

  def next_step
    print_variants

    choice = gets.chomp.to_i
    raise 'ошибка выбора варианта' unless choice.positive? && choice <= @game_variants.length

    key = @game_variants.keys[choice - 1]
    @game_variants[key].call
  rescue StandardError => e
    puts e.message
    retry
  end

  def print_variants
    @game_variants.each_with_index do |(variant_name, _), index|
      puts "#{index + 1} - #{variant_name}"
    end
  end

  def launch_game
    [@user, @dealer].each do |user|
      2.times { user.cards.push @deck.get_card }
      @bank += user.account.withdraw_money 10
    end

    puts "Карты дилера: #{['*'].cycle(dealer.cards.count).to_a.join(' ')}\n\n"
    print_user_game_info @user

    next_step
  end

  def print_user_game_info(user)
    puts "Карты пользователя #{user.name}:"
    user.cards.each { |card| puts "#{card.name} #{card.suit.image}" }
    total = count_total(user)
    puts "Итого: #{total}\n\n"
  end

  def count_total(user)
    total = 0
    user.cards.each do |card|
      total += if card.is_a? Ace
                 total + 11 > 21 ? card.value[0] : card.value[-1]
               else
                 card.value
               end
    end
    total
  end

  def initialize_game_settings
    self.user_name = gets.chomp
    validate!
    create_players
    create_deck
  end

  attr_accessor :deck, :user, :dealer, :bank, :game_variants

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

# frozen_string_literal: true

require_relative '../Utils/validation'
require_relative '../Entities/User/user'
require_relative '../Entities/Bank/account'
require_relative '../Entities/Deck/deck'
require_relative '../Entities/Deck/Cards/ace'
require_relative 'ai_dealer'

class Game
  include Validation

  def initialize
    @bank = 0
    @game_variants = {
      'Пропустить' => method(:skip),
      'Добавить карту' => method(:add_card_for_user),
      'Открыть карты' => method(:open_cards)
    }
    @previous_user_refused = false
  end

  def launch
    greeting
    initialize_game_settings
    start
  end

  private

  def start
    loop do
      if deck.card_count < 6
        puts 'Карт в колоде меньше 6, перезапустите игру!'
        break
      end
      reset_state
      deal_cards
      place_bets
      print_cards

      if twenty_one? @user
        summarize
      else
        players_make_moves
      end

      break if exit?
    end
  end

  def players_make_moves
    loop do
      break if @winner_found

      if player_has_three_cards?(@user)
        summarize
        break
      else
        user_move
        break if @winner_found

        if twenty_one?(@user) || more_than_twenty_one?(@user) || player_has_three_cards?(@dealer)
          summarize
          break
        end

        dealer_move
      end
    end
  end

  def player_has_three_cards?(user)
    user.cards.count == 3
  end

  def reset_state
    @winner_found = false
    @dealer.cards.clear
    @user.cards.clear
  end

  def skip
    summarize if @previous_user_refused
  end

  def add_card_for_user
    card = @deck.take_card
    @user.cards.push card
    puts "Добавлена карта #{card.name} #{card.suit.image}\n"
  end

  def open_cards
    print_user_game_info @dealer
    print_user_game_info @user
    summarize
  end

  def print_users_banks_state
    [@user, @dealer].each { |user| puts "На текущий момент у пользователя #{user.name} денег #{user.account.total}\n" }
  end

  def summarize
    puts 'Итого:'
    print_user_game_info @dealer
    print_user_game_info @user

    print_winner(winner_player)
    deposit_money(winner_player)
    @bank = 0
    print_users_banks_state
    @winner_found = true
  end

  def print_winner(winner)
    if winner.nil?
      puts 'Ничья. Деньги возвращены на счета!\n'
    else
      puts "Победил #{winner.name}!\n"
    end
  end

  def winner_player
    player = nil
    if twenty_one_or_lower?(@user) && (greater_than(@user, @dealer) || more_than_twenty_one?(@dealer))
      player = @user
    elsif twenty_one_or_lower?(@dealer) && (greater_than(@dealer, @user) || more_than_twenty_one?(@user))
      player = @dealer
    end
    player
  end

  def greater_than(first_player, second_player)
    count_total(first_player) > count_total(second_player)
  end

  def deposit_money(winner)
    if winner.nil?
      @user.account.put_money(@bank / 2)
      @dealer.account.put_money(@bank / 2)
    else
      winner.account.put_money @bank
    end
  end

  def user_move
    print_variants

    choice = gets.chomp.to_i
    raise 'ошибка выбора варианта' unless choice.positive? && choice <= @game_variants.length

    key = @game_variants.keys[choice - 1]
    @game_variants[key]&.call
  rescue StandardError => e
    puts e.message
    retry
  end

  def dealer_move
    dealer ||= AIDealer.new @dealer.name, @dealer.cards, @deck
    refused = dealer.make_a_move
    if @previous_user_refused
      summarize
    else
      @previous_user_refused = refused
    end
  end

  def print_variants
    @game_variants.each_with_index do |(variant_name, _), index|
      puts "#{index + 1} - #{variant_name}"
    end
  end

  def exit?
    puts 'Продолжаем игру?(y/n)'
    answer = gets.chomp
    raise 'Введите правильный вариант ответа' unless %w[y n].include? answer

    answer == 'n'
  rescue StandardError => e
    puts e.message
    retry
  end

  def print_cards
    puts "Карты дилера: #{hidden_dealer_cards}\n\n"
    print_user_game_info @user
  end

  def deal_cards
    [@user, @dealer].each do |user|
      2.times { user.cards.push @deck.take_card }
    end
  end

  def place_bets
    [@user, @dealer].each do |user|
      @bank += user.account.withdraw_money 10
    end
  end

  def twenty_one?(user)
    count_total(user) == 21
  end

  def more_than_twenty_one?(user)
    count_total(user) > 21
  end

  def twenty_one_or_lower?(user)
    count_total(user) <= 21
  end

  def hidden_dealer_cards
    ['*'].cycle(dealer.cards.count).to_a.join(' ')
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

  attr_accessor :deck, :user, :dealer, :bank, :game_variants, :previous_user_refused, :winner_found

  validate :user_name, :presence

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
end

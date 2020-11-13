# frozen_string_literal: true

require_relative '../Utils/validation'
require_relative '../Entities/User/user'
require_relative '../Entities/Bank/account'
require_relative '../Entities/Deck/deck'
require_relative '../Entities/Deck/Cards/ace'
require_relative 'ai_dealer'
require_relative 'bank'

class Game
  include Validation

  def initialize(ui)
    @ui = ui
    @previous_user_refused = false
  end

  def launch
    @ui.greeting
    initialize_game_settings @ui.player_name
    start
  end

  private

  attr_accessor :ui, :deck, :user, :dealer, :bank, :winner_found

  def start
    loop do
      if deck.card_count < 6
        @ui.warning 'Карт в колоде меньше 6, перезапустите игру!'
        break
      end
      reset_state
      deal_cards
      place_bets

      show_players_cards hide_dealer_cards: true

      if twenty_one? @user
        summarize
      else
        players_make_moves
      end

      break unless continue?
    end
  end

  def players_make_moves
    loop do
      if player_has_three_cards?(@user)
        summarize
        break
      else
        user_move
        break if @winner_found

        if twenty_one?(@user) || more_than_twenty_one?(@user) || player_has_three_cards?(@dealer) || players_refused?
          summarize
          break
        end
        @dealer_refused = !dealer_take_card?
      end
    end
  end

  def players_refused?
    @dealer_refused && @player_refused
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
    @player_refused = true
  end

  def add_card_for_user
    card = @deck.take_card
    @user.cards.push card
    @ui.show_progress "Добавлена карта #{card.name} #{card.suit.image}\n"
  end

  def summarize
    @winner_found = true
    winner = winner_player
    show_totals(winner)
    reward_the_winner(winner)
    show_account_info
  end

  def reward_the_winner(winner)
    @bank.deposit_money(winner)
  end

  def show_totals(winner)
    players_info = prepare_players_info
    winner_name = nil
    winner_name = winner.name unless winner.nil?
    totals = { players: players_info,
               winner: winner_name }

    @ui.show_totals totals
  end

  def show_account_info
    @ui.show_account_info @bank.accounts_info
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

  def user_move
    @game_variants ||= {
      'Пропустить' => method(:skip),
      'Добавить карту' => method(:add_card_for_user),
      'Открыть карты' => method(:summarize)
    }
    id = choose_option
    raise 'ошибка выбора варианта' unless id >= 0 && id < @game_variants.count

    key = @game_variants.keys[id]
    @game_variants[key].call
  rescue StandardError => e
    @ui.warning e.message
    @ui.warning e.backtrace
    retry
  end

  def dealer_take_card?
    dealer ||= AIDealer.new @dealer.name, @dealer.cards, @deck
    take = dealer.take_card?
    @ui.show_progress "#{@dealer.name} берет карту"
    take
  end

  def choose_option
    options = {}
    @game_variants.each_with_index { |(key, _), index| options[index + 1] = key }
    @ui.choose_option(options) - 1
  end

  def continue?
    @ui.continue?
  end

  def show_players_cards(hide_dealer_cards: false)
    info = prepare_players_info(hide_dealer_cards: hide_dealer_cards)
    @ui.show_players_cards info
  end

  def prepare_players_info(hide_dealer_cards: false)
    info = {}
    info[@dealer.name] = player_card_info @dealer, hide_cards: hide_dealer_cards
    info[@user.name] = player_card_info @user
    info
  end

  def player_card_info(user, hide_cards: false)
    cards = []
    @dealer.cards.each do |card|
      cards.push(hide_cards ? '*' : "#{card.name} #{card.suit.image}")
    end
    total = hide_cards ? '*' : count_total(user)
    { cards: cards,
      total: total }
  end

  def deal_cards
    [@user, @dealer].each do |user|
      2.times { user.cards.push @deck.take_card }
    end
  end

  def place_bets
    @bank.place_bet 10
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

  def initialize_game_settings(user_name)
    create_players user_name
    @bank = Bank.new({ @user => @user.account, @dealer => @dealer.account })
    create_deck
  end

  def create_deck
    count = @ui.deck_counts
    raise 'должно участвовать одна или больше колод' if count.nil? || !count.positive?

    @deck = Deck.new count
    @deck.shuffle
  rescue StandardError => e
    @ui.warning e.message
    retry
  end

  def create_players(user_name)
    @user = User.new(user_name, Account.new(100))
    @dealer = User.new('Dealer', Account.new(100))
  end
end

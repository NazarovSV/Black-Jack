# frozen_string_literal: true

require_relative '../Utils/validation'

class ConsoleUI
  include Validation

  validate :user_name, :type, String
  validate :user_name, :presence

  def greeting
    puts 'Добрый день!'
  end

  def player_name
    puts 'Введите, пожалуйста, ваше имя:'
    self.user_name = gets.chomp
    validate!
    user_name
  rescue StandardError => e
    puts e.message
    retry
  end

  def warning(text)
    puts text
  end

  def show_progress(text)
    puts text
  end

  def deck_counts
    puts 'Сколько колод участвует в игре?'
    puts 'Введите число:'
    gets.chomp.to_i
  end

  def show_totals(info)
    puts "\n===Итоги:==="
    show_players_cards info[:players]
    show_winner info[:winner]
  end

  def show_winner(winner)
    if winner.nil?
      puts 'Ничья. Деньги возвращены на счета!\n'
    else
      puts "Победил #{winner}!\n"
    end
  end

  def show_players_cards(players)
    players.each do |player, card_info|
      puts "\nИгрок #{player}:"
      card_info[:cards].each { |card| puts "\t#{card}" }
      puts "Итого: #{card_info[:total]}"
    end
  end

  def choose_option(options)
    puts "\nПожалуйста, выберете вариант:"
    options.each { |id, option| puts "#{id}: #{option}" }
    gets.chomp.to_i
  end

  def show_account_info(accounts)
    accounts.each { |owner, total| puts "На текущий момент у пользователя #{owner} денег #{total}\n" }
  end

  def continue?
    puts "\nПродолжаем игру?(y/n)"
    answer = gets.chomp
    raise 'Введите правильный вариант ответа' unless %w[y n].include? answer

    answer == 'y'
  rescue StandardError => e
    puts e.message
    retry
  end
end

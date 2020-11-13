# frozen_string_literal: true

require_relative 'Service/game'
require_relative 'UI/console_ui'

Game.new(ConsoleUI.new).launch

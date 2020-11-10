# frozen_string_literal: true

require_relative 'suit'

class Suit
  attr_reader :image, :name

  def initialize(name, image)
    @name = name
    @image = image
  end
end

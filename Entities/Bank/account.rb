# frozen_string_literal: true

require_relative '../../Utils/validation'

class Account
  include Validation

  attr_reader :total

  def initialize(total)
    self.incoming_total = total
    validate!
    validate_positive! @incoming_total
    @total = total
  end

  def withdraw_money(sum)
    self.incoming_sum = sum
    validate!
    validate_positive! @total - @incoming_sum
    @total -= @incoming_sum
  end

  def put_money(sum)
    self.incoming_sum = sum
    validate!
    @total += @incoming_sum
  end

  validate :incoming_total, :type, Integer
  validate :incoming_sum, :type, Integer

  private

  def validate_positive!(new_total)
    raise 'Сумма в банке должна быть больше нуля!' if new_total.negative?
  end
end

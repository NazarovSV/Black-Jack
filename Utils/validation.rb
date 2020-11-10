module Validation
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods

    attr_accessor :checks

    def validate(attribute, validation_type, param)

      validation ||= {
          presence: method(:validate_presence),
          type: method(:validate_type)
      }

      define_get_attribute(attribute)
      define_set_attribute(attribute, param, validation, validation_type)

    end

    private

    def define_set_attribute(attribute, param, validation, validation_type)
      define_method("#{attribute}=") do |value|
        instance_variable_set("@#{attribute}", value)

        hash = {method: validation[validation_type],
                attribute: value,
                param: param}

        if instance_variable_get("@checks")
          instance_variable_get("@checks").push(hash)
        else
          instance_variable_set("@checks", [hash])
        end

      end
    end

    def define_get_attribute(attribute)
      define_method(attribute) do
        instance_variable_get("@#{attribute}")
      end
    end

    def init_validation
      {
                presence: method(:validate_presence),
                format: method(:validate_format),
                type: method(:validate_type)
            }
    end

    attr_reader :validation

    def validate_presence(value, param)
      raise 'Параметр nil или пустая строка' unless value.to_s.length.positive?
    end

    def validate_type(value, type)
      raise "Параметр не соответствует типу #{type}, указан тип - #{value.class}" unless value.is_a? type
    end

  end

  module InstanceMethods

    def validate!

      checks = self.class.checks
      checks ||= []
      checks.each do |check|
        method = check[:method]
        attribute = check[:attribute]
        param = check[:param]
        method.call attribute, param
      rescue => e
        checks.delete check
        raise e
      end
    end
  end

end
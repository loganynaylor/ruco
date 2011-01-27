module Ruco
  class Form
    delegate :move, :delete, :value, :to => :text_field

    def initialize(label, options, &submit)
      @options = options
      @label = label.strip + ' '
      @submit = submit
      reset
    end

    def view
      @label + @text_field.view
    end

    def insert(text)
      @text_field.insert(text.gsub("\n",''))
      @submit.call(@text_field.value) if text.include?("\n")
    end

    def cursor
      Position.new 0, @label.size + @text_field.cursor.column
    end

    def reset
      @text_field = TextField.new(:columns => @options[:columns] - @label.size)
    end

    private

    attr_reader :text_field
  end
end
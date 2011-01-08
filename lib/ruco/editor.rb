module Ruco
  class Editor
    SCROLLING_OFFSET = 20

    attr_reader :cursor_line, :cursor_column

    def initialize(file, options)
      @file = file
      @options = options
      @content = File.read(@file)
      @line = 0
      @column = 0
      @cursor_line = 0
      @cursor_column = 0
      @scrolled_lines = 0
      @scrolled_columns = 0
      @options[:line_scrolling_offset] ||= @options[:lines] / 2
      @options[:column_scrolling_offset] ||= @options[:columns] / 2
    end

    def view
      Array.new(@options[:lines]).map_with_index do |_,i|
        (lines[i + @scrolled_lines] || "").slice(@scrolled_columns, @options[:columns])
      end * "\n" + "\n"
    end

    def move(line, column)
      @line =    [[@line   + line,    0].max, lines.size].min
      @column =  [[@column + column, 0].max, (lines[@line]||'').size].min

      adjust_view
    end

    def insert(text)
      insertion_point = lines[0...@line].join("\n").size + @column
      insertion_point += 1 if @line > 0 # account for missing newline
      @content.insert(insertion_point, text)
      inserted_lines = text.naive_split("\n")

      if inserted_lines.size > 1
        # column position does not add up when hitting return
        @column = inserted_lines.last.size
        move(inserted_lines.size - 1, 0)
      else
        move(inserted_lines.size - 1, inserted_lines.last.size)
      end
    end

    private

    def lines
      @content.naive_split("\n")
    end

    def adjust_view
      reposition_cursor
      scroll_column_into_view
      scroll_line_into_view
      reposition_cursor
    end

    def scroll_column_into_view
      offset = [@options[:column_scrolling_offset], @options[:columns]].min

      if @cursor_column >= @options[:columns]
        @scrolled_columns = @column - @options[:columns] + offset
      end

      if @cursor_column < 0
        @scrolled_columns = @column - offset
      end

      @scrolled_columns = [[@scrolled_columns, 0].max, @column].min
    end

    def scroll_line_into_view
      offset = [@options[:line_scrolling_offset], @options[:lines]].min

      if @cursor_line >= @options[:lines]
        @scrolled_lines = @line - @options[:lines] + offset
      end

      if @cursor_line < 0
        @scrolled_lines = @line - offset
      end

      @scrolled_lines = [[@scrolled_lines, 0].max, @line].min
    end

    def reposition_cursor
      @cursor_column = @column - @scrolled_columns
      @cursor_line = @line - @scrolled_lines
    end
  end
end
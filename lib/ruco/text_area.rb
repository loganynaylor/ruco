module Ruco
  class TextArea
    attr_reader :lines, :selection

    def initialize(content, options)
      @lines = content.naive_split("\n")
      @options = options
      @line = 0
      @column = 0
      @window = Window.new(@options[:lines], @options[:columns])
      @window.position = position
    end

    def view
      @window.position = position
      @window.crop(lines) * "\n" + "\n"
    end

    def cursor
      @window.cursor
    end

    def color_mask
      mask = Array.new(@options[:lines])
#      return mask unless @selection
#
#      mask.map_with_index do |_,line|
#        visible = visible_area(line)
#        next unless @selection.overlap?(visible)
#
#        first = [@selection.first, visible.first].max
#        last = [@selection.last, visible.last].min
#
#        [
#          [first[1]-@scrolled_columns,Curses::A_REVERSE],
#          [last[1]-@scrolled_columns, Curses::A_NORMAL]
#        ]
#      end
    end

    def move(where, *args)
      case where
      when :relative then
        @line += args.first
        @column += args.last
      when :to then
        @line, @column = args
      when :to_bol then move_to_bol(*args)
      when :to_eol then move_to_eol(*args)
      when :to_line then @line = args.first
      when :to_column then @column = args.first
      when :to_index then move(:to, *position_for_index(*args))
      when :page_down then
        shift = @options[:lines] - 1
        @line += shift
      when :page_up then
        shift = @options[:lines] - 1
        @line -= shift
      else
        raise "Unknown move type #{where} with #{args.inspect}"
      end
      @selection = nil unless @selecting
      adjust_view
    end

    def selecting(&block)
      start = if @selection
        (position == @selection.first ? @selection.last : @selection.first)
      else
        position
      end

      @selecting = true
      instance_exec(&block)
      @selecting = false

      sorted = [start, position].sort
      @selection = sorted[0]..sorted[1]
    end

    def text_in_selection
      return '' unless @selection
      start = index_for_position(@selection.first)
      finish = index_for_position(@selection.last)
      content.slice(start, finish-start)
    end

    def reset
      @selection = nil
    end

    def insert(text)
      delete_content_in_selection if @selection

      text.tabs_to_spaces!
      if text == "\n" and @column >= after_last_word
        current_whitespace = current_line.leading_whitespace
        next_whitespace = lines[@line+1].to_s.leading_whitespace
        text = text + [current_whitespace, next_whitespace].max
      end
      insert_into_content text
      move_according_to_insert text
    end

    def delete(count)
      if @selection
        delete_content_in_selection
        return
      end

      if count > 0
        if current_line[@column..-1].size >= count
          current_line.slice!(@column, count)
        else
          with_lines_as_string do |content|
            content.slice!(index_for_position, count)
          end
        end
      else
        backspace(count.abs)
      end
    end

    def index_for_position(position=self.position)
      index = lines[0...position.line].join("\n").size + position.column
      index += 1 if position.line > 0 # account for missing newline
      index
    end

    def content
      (lines * "\n").freeze
    end

    def resize(lines, columns)
      @options[:lines] = lines
      @options[:columns] = columns
    end

    protected

    def position
      Position.new(@line, @column)
    end

    def position_for_index(index)
      jump = content.slice(0, index).to_s.naive_split("\n")
      [jump.size - 1, jump.last.size]
    end

    def with_lines_as_string
      string = @lines * "\n"
      yield string
      @lines = string.naive_split("\n")
    end

    def after_last_word
      current_line.index(/\s*$/)
    end

    def move_to_eol
      after_last_whitespace = current_line.size

      if @column == after_last_whitespace or @column < after_last_word
        move :to_column, after_last_word
      else
        move :to_column, after_last_whitespace
      end
    end

    def move_to_bol
      before_first_word = current_line.index(/[^\s]/) || 0
      column = if @column == 0 or @column > before_first_word
        before_first_word
      else
        0
      end
      move :to_column, column
    end

    def backspace(count)
      if @column >= count
        new_colum = @column - count
        current_line.slice!(new_colum, count)
        move :to_column, new_colum
      else
        start_index = index_for_position - count
        if start_index < 0
          count += start_index
          start_index = 0
        end

        with_lines_as_string do |content|
          content.slice!(start_index, count)
        end

        move :to, *position_for_index(start_index)
      end
    end

    def adjust_view
      @line =    [[@line,   0].max, lines.size - 1].min
      @column =  [[@column, 0].max, current_line.size].min
    end

    def insert_into_content(text)
      if text.include?("\n")
        with_lines_as_string do |content|
          content.insert(index_for_position, text)
        end
      else
        # faster but complicated for newlines
        lines[@line].insert(@column, text)
      end
    end

    def position_inside_content?
      @line < lines.size and @column < lines[@line].to_s.size
    end

    def current_line
      lines[@line] || ''
    end

    def move_according_to_insert(text)
      inserted_lines = text.naive_split("\n")
      if inserted_lines.size > 1
        # column position does not add up when hitting return
        @column = inserted_lines.last.size
        move(:relative, inserted_lines.size - 1, 0)
      else
        move(:relative, inserted_lines.size - 1, inserted_lines.last.size)
      end
    end

    def delete_content_in_selection
      with_lines_as_string do |content|
        start = index_for_position(@selection.first)
        finish = index_for_position(@selection.last)
        content.slice!(start, finish-start)
        move(:to, *@selection.first)
      end
      @selection = nil
    end
  end
end
module Ruco
  # everything that does not belong to a text-area
  # but is needed for Ruco::Editor
  class EditorArea < TextArea
    def initialize(*args)
      super(*args)
      @history = History.new(:state => state, :track => [:content], :entries => 100, :timeout => 2)
    end

    def undo
      @history.undo
      self.state = @history.state
    end

    def redo
      @history.redo
      self.state = @history.state
    end

    def view
      @history.add(state)
      super
    end

    def delete_line
      lines.slice!(line, 1)
      sanitize_position
    end

    def indent
      selected_lines.each do |line|
        lines[line].insert(0, ' ' * Ruco::TAB_SIZE)
      end
      adjust_to_indentation Ruco::TAB_SIZE
    end

    def unindent
      lines_to_unindent = (selection ? selected_lines : [line])
      removed = lines_to_unindent.map do |line|
        remove = [lines[line].leading_whitespace.size, Ruco::TAB_SIZE].min
        lines[line].slice!(0, remove)
        remove
      end

      adjust_to_indentation -removed.first, -removed.last
    end

    private

    def state
      {
        :content => content,
        :position => position,
        :screen_position => screen_position
      }
    end

    def state=(data)
      @selection = nil
      @lines = data[:content].naive_split("\n")
      self.position = data[:position]
      self.screen_position = data[:screen_position]
    end

    # TODO use this instead of instance variables
    def screen_position
      Position.new(@window.top, @window.left)
    end

    def screen_position=(pos)
      @window.set_top(pos[0], @lines.size)
      @window.left = pos[1]
    end

    def adjust_to_indentation(first, last=nil)
      last ||= first
      if selection
        cursor_adjustment = (selection.first == position ? first : last)
        selection.first.column = [selection.first.column + first, 0].max
        selection.last.column = [selection.last.column + last, 0].max
        self.column += cursor_adjustment
      else
        self.column += first
      end
    end

    def selected_lines
      selection.first.line.upto(selection.last.line)
    end
  end
end
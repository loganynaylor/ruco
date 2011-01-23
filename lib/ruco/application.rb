module Ruco
  class Application
    def initialize(file, options)
      @file = file
      @options = options

      setup_actions
      setup_keys
      load_user_config
      create_components
    end

    def view
      status.view + "\n" + editor.view + command.view
    end

    def color_mask
      reverse = [[[0,Curses::A_REVERSE]]]
      reverse + editor.color_mask + reverse
    end

    def cursor
      Cursor.new(@focused.cursor.line + @status_lines, @focused.cursor.column)
    end

    def key(key)
      if bound = @bindings[key]
        result = if bound.is_a?(Symbol)
          @actions[bound].call
        else
          bound.call
        end
        return result
      end

      case key

      # move
      when :down then @focused.move(:relative, 1,0)
      when :right then @focused.move(:relative, 0,1)
      when :up then @focused.move(:relative, -1,0)
      when :left then @focused.move(:relative, 0,-1)
      when :end then @focused.move :to_eol
      when :home then @focused.move :to_bol
      when :page_up then @focused.move :page_up
      when :page_down then @focused.move :page_down

      # select
      when :"Shift+down" then
        @focused.selecting do
          move(:relative, 1, 0)
        end
      when :"Shift+right"
        @focused.selecting do
          move(:relative, 0, 1)
        end
      when :"Shift+up"
        @focused.selecting do
          move(:relative, -1, 0)
        end
      when :"Shift+left" then
        @focused.selecting do
          move(:relative, 0, -1)
        end

      # modify
      when :tab then @focused.insert("\t")
      when :enter then
        @focused.insert("\n")
      when :backspace then @focused.delete(-1)
      when :delete then @focused.delete(1)

      when :escape then # escape from focused
        @focused.reset
        @focused = editor
      else
        @focused.insert(key) if key.is_a?(String)
      end
    end

    def bind(key, action=nil, &block)
      raise "Ctrl+m cannot be bound" if key == :"Ctrl+m" # would shadow enter -> bad
      raise if action and block
      @bindings[key] = action || block
    end

    def action(name, &block)
      @actions[name] = block
    end

    def ask(question, options={}, &block)
      @focused = command
      command.ask(question, options) do |response|
        @focused = editor
        block.call(response)
      end
    end

    def configure(&block)
      instance_exec(&block)
    end

    def resize(lines, columns)
      @options[:lines] = lines
      @options[:columns] = columns
      create_components
      @editor.resize(editor_lines, columns)
    end

    private

    attr_reader :editor, :status, :command

    def setup_actions
      @actions = {}

      action :paste do
        @focused.insert(Clipboard.paste)
      end

      action :copy do
        Clipboard.copy(@focused.text_in_selection)
      end

      action :cut do
        Clipboard.copy(@focused.text_in_selection)
        @focused.delete(0)
      end

      action :save do
        editor.save
      end

      action :quit do
        if editor.modified?
          ask("Loose changes? Enter=Yes Esc=Cancel") do
            :quit
          end
        else
          :quit
        end
      end

      action :go_to_line do
        ask('Go to Line: '){|result| editor.move(:to_line, result.to_i - 1) }
      end

      action :delete_line do
        editor.delete_line
      end

      action :find do
        ask("Find: ", :cache => true){|result| editor.find(result) }
      end
    end

    def setup_keys
      @bindings = {}
      bind :"Ctrl+s", :save
      bind :"Ctrl+w", :quit
      bind :"Ctrl+q", :quit
      bind :"Ctrl+g", :go_to_line
      bind :"Ctrl+f", :find
      bind :"Ctrl+d", :delete_line
      bind :"Ctrl+x", :cut
      bind :"Ctrl+c", :copy
      bind :"Ctrl+v", :paste
    end

    def load_user_config
      Ruco.application = self
      config = File.expand_path("~/.ruco.rb")
      load config if File.exist?(config)
    end

    def create_components
      @status_lines = 1
      @editor ||= Ruco::Editor.new(@file, :lines => editor_lines, :columns => @options[:columns])
      @status = Ruco::StatusBar.new(@editor, :columns => @options[:columns])
      @command = Ruco::CommandBar.new(:columns => @options[:columns])
      command.cursor_line = editor_lines
      @focused = @editor
    end

    def editor_lines
      command_lines = 1
      editor_lines = @options[:lines] - @status_lines - command_lines
    end
  end
end
module Ruco
  class StyleMap
    attr_accessor :lines

    def initialize(lines)
      @lines = Array.new(lines)
    end

    def add(style, line, columns)
      @lines[line] ||= []
      @lines[line] << [style, columns]
    end

    def flatten
      @lines.map do |styles|
        next unless styles

        # start and one after end of every column-range changes styles
        points_of_change = styles.map{|s,c| [c.first, c.last+1] }.flatten

        flat = []

        styles.each do |style, columns|
          points_of_change.each do |point|
            next unless columns.include?(point)
            flat[point] ||= []
            flat[point].unshift style
          end
        end

        max = styles.map{|s,c|c.last}.max
        flat[max+1] = []
        flat
      end
    end

    def +(other)
      lines = self.lines + other.lines
      new = StyleMap.new(0)
      new.lines = lines
      new
    end

    def slice!(*args)
      sliced = lines.slice!(*args)
      new = StyleMap.new(0)
      new.lines = sliced
      new
    end

    def shift
      slice!(0, 1)
    end

    def pop
      slice!(-1, 1)
    end
    
    STYLES = {
      :normal => 0,
      :reverse => Curses::A_REVERSE
    }

    def self.styled(content, styles)
      styles ||= []
      content = content.dup

      build = []
      build << [[]]

      buffered = ''
      styles.each do |style|
        if style
          build[-1] << buffered
          buffered = ''

          # set new style
          build << [style]
        end
        buffered << (content.slice!(0,1) || '')
      end
      build[-1] << buffered + content
      build
    end

    def self.curses_style(styles)
      styles.sum{|style| STYLES[style] or raise("Unknown style #{style}") }
    end
  end
end
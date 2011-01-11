require File.expand_path('spec/spec_helper')

describe Ruco::Editor do
  def write(content)
    File.open(@file,'w'){|f| f.write(content) }
  end

  let(:editor){ Ruco::Editor.new(@file, :lines => 3, :columns => 5, :line_scrolling_offset => 5, :column_scrolling_offset => 5) }

  before do
    @file = 'spec/temp.txt'
  end

  it "reads tab as spaces" do
    write("\t\ta")
    editor.view.should == "    a\n\n\n"
  end

  describe :move do
    before do
      write("    \n    \n    ")
    end

    it "starts at 0,0" do
      editor.cursor.should == [0,0]
    end

    it "can move" do
      editor.move(:relative, 1,2)
      editor.cursor.should == [1,2]
      editor.move(:relative, 1,1)
      editor.cursor.should == [2,3]
    end

    it "can move in empty file" do
      write("\n\n\n")
      editor.move(:relative, 2,0)
      editor.cursor.should == [2,0]
    end

    it "cannot move left/top off screen" do
      editor.move(:relative, -1,-1)
      editor.cursor.should == [0,0]
    end

    it "cannot move right of characters" do
      editor.move(:relative, 2,6)
      editor.cursor.should == [2,4]
    end

    it "stays in last line when moving past lines" do
      write("    ")
      editor.move(:relative, 6,3)
      editor.cursor.should == [0,3]
    end

    describe 'column scrolling' do
      it "can scroll columns" do
        write("123456789\n123")
        editor.move(:relative, 0,4)
        editor.view.should == "12345\n123\n\n"
        editor.cursor.column.should == 4

        editor.move(:relative, 0,1)
        editor.view.should == "6789\n\n\n"
        editor.cursor.column.should == 0
      end

      it "cannot scroll past the screen" do
        write('123456789')
        editor.move(:relative, 0,4)
        6.times{ editor.move(:relative, 0,1) }
        editor.view.should == "6789\n\n\n"
        editor.cursor.column.should == 4
      end

      it "can scroll columns backwards" do
        write('123456789')
        editor.move(:relative, 0,5)
        editor.view.should == "6789\n\n\n"

        editor.move(:relative, 0,-1)
        editor.view.should == "12345\n\n\n"
        editor.cursor.column.should == 4
      end
    end

    describe 'line scrolling' do
      before do
        write("1\n2\n3\n4\n5\n6\n7\n8\n9")
      end

      it "can scroll lines down (at maximum of screen size)" do
        editor.move(:relative, 2,0)
        editor.view.should == "1\n2\n3\n"

        editor.move(:relative, 1,0)
        editor.view.should == "4\n5\n6\n"
        editor.cursor.line.should == 0
      end

      it "can scroll till end of file" do
        editor.move(:relative, 15,0)
        editor.view.should == "9\n\n\n"
        editor.cursor.line.should == 0
      end
    end
  end

  describe :to do
    it "cannot move outside of text (bottom/right)" do
      write("123\n456")
      editor.move(:to, 10,10)
      editor.cursor.should == [1,3]
    end

    it "cannot move outside of text (top/left)" do
      write("123\n456")
      editor.move(:relative, 1,1)
      editor.move(:to, -10,-10)
      editor.cursor.should == [0,0]
    end
  end

  describe :to_eol do
    before do
      write("\n aa \n  ")
    end

    it 'stays at start when line is empty' do
      editor.move :to_eol
      editor.cursor.should == [0,0]
    end

    it 'moves after last word if cursor was before it' do
      editor.move(:relative, 1,1)
      editor.move :to_eol
      editor.cursor.should == [1,3]
    end

    it 'moves after last whitespace if cursor was after last word' do
      editor.move(:relative, 1,3)
      editor.move :to_eol
      editor.cursor.should == [1,4]
    end

    it 'moves after last work if cursor was after last whitespace' do
      editor.move(:relative, 1,4)
      editor.move :to_eol
      editor.cursor.should == [1,3]
    end
  end

  describe :to_bol do
    before do
      write("\n  aa \n  ")
    end

    it 'stays at start when line is empty' do
      editor.move :to_bol
      editor.cursor.should == [0,0]
    end

    it 'moves before first work if at start of line' do
      editor.move(:relative, 1,0)
      editor.move :to_bol
      editor.cursor.should == [1,2]
    end

    it 'moves to start of line if before first word' do
      editor.move(:relative, 1,1)
      editor.move :to_bol
      editor.cursor.should == [1,0]

      editor.move(:relative, 0,2)
      editor.move :to_bol
      editor.cursor.should == [1,0]
    end

    it 'moves before first word if inside line' do
      editor.move(:relative, 1,5)
      editor.move :to_bol
      editor.cursor.should == [1,2]
    end
  end

  describe :find do
    before do
      write("\n ab\n ab")
    end

    it "moves to first occurrence" do
      editor.find('ab')
      editor.cursor.should == [1,1]
    end

    it "moves to next occurrence" do
      editor.move(:relative, 1,1)
      editor.find('ab')
      editor.cursor.should == [2,1]
    end

    it "stays in place when nothing was found" do
      editor.move(:relative, 2,1)
      editor.find('ab')
      editor.cursor.should == [2,1]
    end
  end

  describe :view do
    before do
      write('')
    end

    it "displays an empty screen" do
      editor.view.should == "\n\n\n"
    end

    it "displays short file content" do
      write('xxx')
      editor.view.should == "xxx\n\n\n"
    end

    it "displays long file content" do
      write('1234567')
      editor.view.should == "12345\n\n\n"
    end

    it "displays multiline-file content" do
      write("xxx\nyyy\nzzz\niii")
      editor.view.should == "xxx\nyyy\nzzz\n"
    end
  end

  describe :insert do
    before do
      write('')
    end

    it "can insert new chars" do
      write('123')
      editor.move(:relative, 0,1)
      editor.insert('ab')
      editor.view.should == "1ab23\n\n\n"
      editor.cursor.should == [0,3]
    end

    it "can insert new newlines" do
      editor.insert("ab\nc")
      editor.view.should == "ab\nc\n\n"
      editor.cursor.should == [1,1]
    end

    it "jumps to correct column when inserting newline" do
      write("abc\ndefg")
      editor.move(:relative, 1,2)
      editor.insert("1\n23")
      editor.view.should == "abc\nde1\n23fg\n"
      editor.cursor.should == [2,2]
    end

    it "jumps to correct column when inserting 1 newline" do
      write("abc\ndefg")
      editor.move(:relative, 1,2)
      editor.insert("\n")
      editor.view.should == "abc\nde\nfg\n"
      editor.cursor.should == [2,0]
    end

    it "can add newlines to the end" do
      write('')
      editor.insert("\n")
      editor.insert("\n")
      editor.cursor.should == [2,0]
    end

    it "can add newlines to the moveable end" do
      write('abc')
      editor.move(:relative, 0,3)
      editor.insert("\n")
      editor.insert("\n")
      editor.cursor.should == [2,0]
    end

    it "inserts tab as spaces" do
      editor.insert("\t")
      editor.view.should == "  \n\n\n"
      editor.cursor.should == [0,2]
    end
  end

  describe :save do
    it 'stores the file' do
      write('xxx')
      editor.insert('a')
      editor.save
      File.read(@file).should == 'axxx'
    end

    it 'creates the file' do
      `rm #{@file}`
      editor.insert('a')
      editor.save
      File.read(@file).should == 'a'
    end
  end

  describe :delete do
    it 'removes a char' do
      write('123')
      editor.delete(1)
      editor.view.should == "23\n\n\n"
      editor.cursor.should == [0,0]
    end

    it 'removes a line' do
      write("123\n45")
      editor.move(:relative, 0,3)
      editor.delete(1)
      editor.view.should == "12345\n\n\n"
      editor.cursor.should == [0,3]
    end

    it "cannot backspace over 0,0" do
      write("aa")
      editor.move(:relative, 0,1)
      editor.delete(-3)
      editor.view.should == "a\n\n\n"
      editor.cursor.should == [0,0]
    end

    it 'backspaces a char' do
      write('123')
      editor.move(:relative, 0,3)
      editor.delete(-1)
      editor.view.should == "12\n\n\n"
      editor.cursor.should == [0,2]
    end

    it 'backspaces a newline' do
      write("1\n234")
      editor.move(:relative, 1,0)
      editor.delete(-1)
      editor.view.should == "1234\n\n\n"
      editor.cursor.should == [0,1]
    end
  end

  describe :changes? do
    it "is unchanged by default" do
      editor.modified?.should == false
    end

    it "is changed after insert" do
      editor.insert('x')
      editor.modified?.should == true
    end

    it "is changed after delete" do
      editor.delete(1)
      editor.modified?.should == true
    end

    it "is not changed after move" do
      editor.move(:relative, 1,1)
      editor.modified?.should == false
    end

    it "is unchanged after save" do
      editor.insert('x')
      editor.save
      editor.modified?.should == false
    end
  end
end
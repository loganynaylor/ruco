require File.expand_path('spec/spec_helper')

describe Ruco::CommandBar do
  let(:default_view){ "^W Exit    ^S Save    ^F Find" }
  let(:bar){ Ruco::CommandBar.new(:columns => 30) }

  it "shows shortcuts by default" do
    bar.view.should == default_view
  end

  it "shows less shortcuts when space is low" do
    bar = Ruco::CommandBar.new(:columns => 29)
    bar.view.should == default_view
    bar = Ruco::CommandBar.new(:columns => 28)
    bar.view.should == "^W Exit    ^S Save"
  end

  describe :find do
    it "sets command bar into search mode" do
      bar.find
      bar.view.should == "Find: "
      bar.cursor.column.should == 6
    end

    it "can enter stuff" do
      bar.find
      bar.insert('abc')
      bar.view.should == "Find: abc"
      bar.cursor.column.should == 9
    end

    it "keeps entered stuff" do
      bar.find
      bar.insert('abc')
      bar.insert("\n")
      bar.find
      bar.view.should == "Find: abc"
      bar.cursor.column.should == 9
    end

    it "can reset the search" do
      bar.find
      bar.insert('abc')
      bar.reset

      bar.view.should == default_view
      bar.find
      bar.view.should == "Find: " # term removed
    end

    it "can execute a search" do
      bar.find
      bar.insert('abc')
      result = bar.insert("d\n")
      result.should == Ruco::Command.new(:find, 'abcd')
    end

    it "finds with offset when same search is entered again" do
      bar.find
      bar.insert('abcd')
      bar.insert("\n")
      bar.find
      result = bar.insert("\n")
      result.should == Ruco::Command.new(:find, 'abcd')
    end
  end

  describe :move_to_line do
    it "displays a form" do
      bar.move_to_line
      bar.view.should == "Go to Line: "
    end

    it "gets output" do
      bar.move_to_line
      bar.insert('123')
      result = bar.insert("\n")
      result.should == Ruco::Command.new(:move, :to_line, 123)
    end

    it "gets reset when starting a new go to line" do
      bar.move_to_line
      bar.insert('123')
      bar.move_to_line
      bar.view.should == "Go to Line: "
    end

    it "gets reset when submitting" do
      bar.move_to_line
      bar.insert("123\n")
      bar.view.should == default_view
    end

    it "does not reset search when resetting" do
      bar.find
      bar.insert('abc')
      bar.move_to_line
      bar.reset

      bar.view.should == default_view
      bar.find
      bar.view.should == "Find: abc"
    end
  end
end
require File.expand_path('spec/spec_helper')

describe Ruco::History do
  let(:history){ Ruco::History.new(:state => {:x => 1}) }

  it "knows its state" do
    history.state.should == {:x => 1}
  end

  it "can add a state" do
    history.add :y => 2
    history.state.should == {:y => 2}
  end

  it "can undo a state" do
    history.add :y => 2
    history.undo
    history.state.should == {:x => 1}
  end

  it "can undo-redo-undo a state" do
    history.add :y => 2
    history.undo
    history.redo
    history.state.should == {:y => 2}
  end

  it "cannot redo a modified stack" do
    history.add :y => 2
    history.undo
    history.add :z => 3
    history.redo
    history.state.should == {:z => 3}
    history.redo
    history.state.should == {:z => 3}
  end

  it "cannot undo into nirvana" do
    history.add :y => 2
    history.undo
    history.undo
    history.state.should == {:x => 1}
  end

  it "cannot redo into nirvana" do
    history.add :y => 2
    history.redo
    history.state.should == {:y => 2}
  end
end
require File.expand_path('spec/spec_helper')

describe Ruco::StatusBar do
  let(:file){ 'spec/temp.txt' }
  let(:editor){ Ruco::Editor.new(file, :lines => 5, :columns => 10) }
  let(:bar){ Ruco::StatusBar.new(editor, :columns => 10) }

  it "shows name and version" do
    bar.view.should include("Ruco #{Ruco::VERSION}") 
  end

  it "shows the file" do
    bar.view.should include(file)
  end

  it "indicates modified" do
    bar.view.should_not include('*')
    editor.insert('x')
    bar.view.should include('*')
  end

  it "indicates writable" do
    bar.view.should_not include('!')
  end

  it "indicates writable if file is missing" do
    editor.stub!(:file).and_return '/gradasadadsds'
    bar.view.should_not include('!')
  end

  it "indicates not writable" do
    # this test will always fail on Windows with cygwin because of how cygwin sets up permissions
    unless RUBY_PLATFORM =~ /mingw/
      editor.stub!(:file).and_return '/etc/sudoers'
      bar.view.should include('!')
    end
  end

  it "shows line and column and right side" do
    bar.view.should =~ /1:1$/
  end
end

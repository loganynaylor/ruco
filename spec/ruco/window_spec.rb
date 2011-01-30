require File.expand_path('spec/spec_helper')

describe Ruco::Window do

  describe :crop do
    let(:window){ Ruco::Window.new(2,4) }

    it "does not modify given lines" do
      original = ['1234','1234']
      window.crop(original)
      original.should == ['1234','1234']
    end

    it "removes un-displayable chars" do
      result = window.crop(['12345','12345','12345'])
      result.should == ['1234','1234']
    end

    it "does not add whitespace" do
      result = window.crop(['1','',''])
      result.should == ['1','']
    end

    it "creates lines if necessary" do
      result = window.crop(['1234'])
      result.should == ['1234','']
    end

    it "stays inside frame as long as position is in frame" do
      window.position = Ruco::Position.new(1,3)
      result = window.crop(['12345678','12345678'])
      result.should == ['1234','1234']
    end

    it "can display empty lines" do
      window.crop([]).should == ['','']
    end

    describe 'scrolled' do
      it "goes out of frame if line is out of frame" do
        window = Ruco::Window.new(6,1)
        window.position = Ruco::Position.new(6,0)
        result = window.crop(['1','2','3','4','5','6','7','8','9'])
        result.should == ['4','5','6','7','8','9']
      end

      it "goes out of frame if column is out of frame" do
        window = Ruco::Window.new(1,6)
        window.position = Ruco::Position.new(0,6)
        result = window.crop(['1234567890'])
        result.should == ['456789']
      end
    end
  end

  describe :top do
    let(:window){ Ruco::Window.new(10,10) }

    it "does not change when staying in frame" do
      window.top.should == 0
      window.position = Ruco::Position.new(9,0)
      window.top.should == 0
    end

    it "changes by offset when going vertically out of frame" do
      window.position = Ruco::Position.new(10,0)
      window.top.should == 5
    end

    it "changes to x - offset when going down out of frame" do
      window.position = Ruco::Position.new(20,0)
      window.top.should == 15
    end

    it "changes to x - offset when going down out of frame" do
      window.position = Ruco::Position.new(20,0)
      window.position = Ruco::Position.new(7,0)
      window.top.should == 2
    end
  end

  describe :left do
    let(:window){ Ruco::Window.new(10,10) }

    it "does not change when staying in frame" do
      window.left.should == 0
      window.position = Ruco::Position.new(0,9)
      window.left.should == 0
    end

    it "changes by offset when going vertically out of frame" do
      window.position = Ruco::Position.new(0,9)
      window.position = Ruco::Position.new(0,10)
      window.left.should == 5
    end

    it "changes to x - offset when going right out of frame" do
      window.position = Ruco::Position.new(0,20)
      window.left.should == 15
    end

    it "changes to x - offset when going left out of frame" do
      window.position = Ruco::Position.new(0,20)
      window.position = Ruco::Position.new(0,7)
      window.left.should == 2
    end

    it "does not change when staying in changed frame" do
      window.position = Ruco::Position.new(0,9)
      window.position = Ruco::Position.new(0,10)
      window.left.should == 5
      window.position = Ruco::Position.new(0,14)
      window.left.should == 5
    end
  end
end

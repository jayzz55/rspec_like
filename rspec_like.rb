def describe(&block)
  ExampleGroup.new(block).evaluate!
end

class ExampleGroup
  attr_accessor :block

  def initialize(block)
    @block = block
  end

  def evaluate!
    instance_eval(&block)
  end

  def be(expected)
    {matcher: MatcherBe, expected: expected}
  end
end

class MatcherBe
  attr_accessor :got, :expected

  def initialize(got, expected)
    @got = got
    @expected = expected
  end

  def call
    got.class == expected
  end
end

class Object
  def should(comparator=nil)
    if comparator
      comparator # => {:matcher=>MatcherBe, :expected=>Fixnum}, {:matcher=>MatcherBe, :expected=>TrueClass}
      # DelayedAssertion.new(self).class == comparator
      comparator[:matcher].new(DelayedAssertion.new(self).call, comparator[:expected]).call
    else
      DelayedAssertion.new(self)
    end
  end
end


class DelayedAssertion
  attr_accessor :subject

  def initialize(subject)
    @subject = subject
  end

  def call
    subject
  end

  def ==(other)
    subject == other
  end

  def be(expected)
    false
  end

  def to_s
    subject.to_s
  end
end

describe do
  (1 + 1).should == 2 # => true
  1.should be Fixnum # => true
  (123 == 123).should be TrueClass # => true
end

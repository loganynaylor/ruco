class Range
  # http://stackoverflow.com/questions/699448/ruby-how-do-you-check-whether-a-range-contains-a-subset-of-another-range
  def overlap?(other)
    (first <= other.last) and (other.first <= last)
  end

  # (1..2).last_element == 2
  # (1...3).last_element == 2
  def last_element
    Dispel::Tools.last_element(self)
  end unless defined? last_element

  # (1..2).move(2) == (3..4)
  def move(n)
    if exclude_end?
      (first + n)...(last + n)
    else
      (first + n)..(last + n)
    end
  end
end

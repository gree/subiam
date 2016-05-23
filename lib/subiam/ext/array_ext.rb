class Array
  def keys_to_s_recursive
    new_one = []
    self.each_with_index do |elem, index|
      if elem.respond_to? :keys_to_s_recursive
        new_one[index] = elem.keys_to_s_recursive
        next
      end
      new_one[index] = elem
    end
    new_one
  end
end
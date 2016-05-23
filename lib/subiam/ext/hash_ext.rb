class Hash
  def sort_array!
    keys.each do |key|
      value = self[key]
      self[key] = sort_array0(value)
    end

    self
  end

  def keys_to_s_recursive
    new_one = {}
    self.each do |key, elem|
      if elem.respond_to? :keys_to_s_recursive
        new_one[key.to_s] = elem.keys_to_s_recursive
        next
      end
      new_one[key.to_s] = elem
    end
    new_one
  end

  private

  def sort_array0(value)
    case value
    when Hash
      new_value = {}

      value.each do |k, v|
        new_value[k] = sort_array0(v)
      end

      new_value
    when Array
      value.map {|v| sort_array0(v) }.sort_by(&:to_s)
    else
      value
    end
  end
end

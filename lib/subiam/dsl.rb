class Subiam::DSL
  def self.convert(exported, options = {})
    Subiam::DSL::Converter.convert(exported, options)
  end

  def self.parse(dsl, path, options = {})
    Subiam::DSL::Context.eval(dsl, path, options).result
  end
end

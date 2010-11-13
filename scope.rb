class Scope
  attr_reader :vars
  def initialize(parent = nil)
    @vars = {}
    @parent = parent
  end

  def error(str, line, column)
    puts "[Error] #{@line}:#{@column}: #{str}"
    exit
  end

  def define(name, value, line, column)
    error("Cannot redefine #{name}", line, column) if @vars.include?(name) || (!@parent.nil? && @parent.vars.include?(name))
    @vars[name] = value
  end

  def get(name, line, column)
    if @vars.include?(name)
      @vars[name]
    elsif !@parent.nil? && @parent.vars.include?(name)
      @parent.get(name, line, column)
    else
      error("#{name} is undefined", line, column)
    end
  end
end

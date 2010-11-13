class Scope
  attr_reader :vars, :args
  def initialize(parent = nil)
    @vars = {}
    @args = {}
    @parent = parent
  end

  def error(str, line, column)
    puts "[Error] #{@line}:#{@column}: #{str}"
    exit
  end

  def addArg(name, line, column)
    error("Two arguments with name #{name}", line, column) if @args.include?(name)
    error("Cannot redefine #{name}") if @vars.include?(name)
    @args[name] = :undefined
  end

  def defineArg(name, value, line, column)
    error("Cannot redefine #{name}") if @vars.include?(name) || (@args.include?(name) && @args[name] != :undefined)
    @args[name] = value
  end

  def define(name, value, line, column)
    error("Cannot redefine #{name}", line, column) if @vars.include?(name) || @args.include?(name) #|| (!@parent.nil? && @parent.vars.include?(name))
    @vars[name] = value
  end

  def get(name, line, column)
    if @vars.include?(name)
      @vars[name]
    elsif !@parent.nil? && @parent.vars.include?(name)
      @parent.get(name, line, column)
    else
      error("Undefined variable #{name}", line, column)
    end
  end

  def defined?(name)
    ((@vars.include?(name) && @vars[name] != :undefined) || (@args.include?(name) && @args[name] != :undefined) || (!@parent.nil? && @parent.defined?(name)))
  end

  def accessible?(name)
    puts "@vars: #{@vars.inspect}"
    puts "@args: #{@args.inspect}"
    @vars.include?(name) || @args.include?(name) || (!@parent.nil? && @parent.accessible?(name))
  end
end

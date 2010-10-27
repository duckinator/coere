#!/usr/bin/env ruby

code = <<EOF
    function1: [str1 str2 ->
      string: (join " " (list str1 str2))
      (print string)
    ]

EOF

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

class Parser
  def initialize(code)
    @code = code
    @i = 0
    @line = 1
    @column = 1
    @global_scope = Scope.new
    parse
  end

  def ret(i, items)
    [i, items]
  end

  def cur
    @code[@i]
  end

  def next!
    @i += 1
    if cur == "\n"
      @column = 0
      @line += 1
    else
      @column += 1
    end
  end

  def error(str)
    puts "[Error] #{@line}:#{@column}: #{str}"
    exit
  end

  def parse_string(start)
    puts "In parse_string()"
    pos = @code.index('"', start)
    while @code[pos-1] == "\\"
      pos = @code.index('"', pos)
    end
    ret pos + 1, @code[start..(pos-1)]
  end

  def parse_definition(name, start, scope)
    puts "In parse_definition()"
    scope.define(name, "HAI", @line, @column)
    pos = start
    ret pos, [:define, "?", "?!"]
  end

  def parse_lambda(start, pscope)
    puts "In parse_lambda()"
    scope = Scope.new(pscope)
    pos = start
    ret pos, [:lambda, [], []]
  end

  def parse_list(start, pscope)
    puts "In parse_list()"
    scope = Scope.new(pscope)
    i = start
    items = []
    itemNumber = 0
    endloop = false
    until endloop
      current = @code[i]
      case current
      when ':'
        error "Definition inside of a list."
      when '['
        ret = parse_lambda(i + 1, scope)
        items[itemNumber] = ret
      when ')'
        endloop = true
      end
      i += 1
      break if endloop
    end
    ret i, [:call, "?", []]
  end

  def parse
    puts "In parse()"
    program = []
    name = nil
    scope = @global_scope
    until cur.nil?
      ret = [nil, nil]
      case cur
      when '['
        next!
        ret = parse_lambda(@i, scope)
      when '('
        next!
        ret = parse_list(@i, scope)
      when ':'
        next!
        error "Unexpected ':'" if name.nil?
        ret = parse_definition(name, @i, scope)
      when '"'
        error "Useless string: Not bound to a variable and outside of all lambdas."
      when "\n"
        @column = 0
        @line += 1
      else
        p cur
        name = "#{name}#{cur}"
      end
      if !ret[0].nil?
        @i = ret[0]
      else
        next!
      end
      program << ret[1] unless ret[1].nil?
    end
    program
  end
end

Parser.new(code)
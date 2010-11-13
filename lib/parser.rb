require File.join(File.dirname(__FILE__), 'scope.rb')

class Parser
  attr_reader :ast
  def initialize(code)
    @ast = []
    @code = code
    @i = 0
    @line = 1
    @column = 1
    @global_scope = Scope.new
    parse
  end

  def cur
    @code[@i]
  end

  def whitespace?
    [" ", "\t", "\n"].include?(@code[@i])
  end

  def lastWhitespace?
    [" ", "\t", "\n"].include?(@code[@i-1])
  end

  def skipWhitespace
    next! while whitespace?
  end

  def skipComments
    if cur == ";"
      readUntil("\n")
    end
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

  def assertHasMore(message = nil)
    message = "Unexpected end of file" if message.nil?
    error message if @i >= @code.length 
  end

  def readUntil(c)
    next! until cur == c
  end

  def parse_string
    assertHasMore("Unterminated string literal met end of file.")
    start = @i
    last = @code.index('"', @i)
    next! until @i == last
    while @code[@i-1] == "\\"
      next! until cur == '"'
    end
    next!
    @code[(start-1)..(@i-2)]
  end

  def parse_definition(name, scope)
    assertHasMore("Definition met end of file.")
    item = nil
    endloop = false
    next!
    skipWhitespace
    skipComments
    case cur
    when ':'
      error "Definition inside of a definition."
    when '"'
      item = parse_string
    when '['
      item = parse_lambda(scope)
    when '('
      item = parse_list(scope)
    end
    scope.define(name, item, @line, @column)
    [:define, name, item]
  end

  def parse_lambda(pscope)
    assertHasMore("Unexpected end of file in lambda, expected lambda, list, or definition.")
    scope = Scope.new(pscope)
    args = []
    body = []
    in_args = true
    name = nil
    endloop = false
    next!
    skipWhitespace
    until endloop
      skipComments
      case cur
        when '"'
          if in_args
            error "String in lambda argument."
          else
            body << parse_string
          end
        when '('
          if in_args
            error "List in lambda argument."
          else
            body << parse_list(scope)
          end
        when '['
          if in_args
            error "Lambda in lambd argument."
          else
            body << parse_lambda(scope)
          end
        when ']'
          endloop = true
        else
          if cur == "-" && @code[@i+1] == ">"
            # the -> in lambdas
            args << name unless name.nil?
            in_args = false
            name = nil
            next! # Skip over the > in ->
          elsif whitespace?
            if in_args && !name.nil?
              args << [:variable, name]
            elsif !name.nil?
              body << [:variable, name]
            end
            name = nil
          else
            name = "#{name}#{cur}"
          end
      end
      next! unless endloop
    end
    [:lambda, args, body]
  end

  def parse_list(pscope)
    assertHasMore("Unexpected end of file in list, expected lambda, string, or list.")
    scope = Scope.new(pscope)
    items = []
    name = nil
    endloop = false
    next!
    until endloop
      skipComments
      case cur
      when '"'
        items << parse_string
      when ':'
        error "Definition inside of a list."
      when '['
        items << parse_lambda(scope)
      when '('
        items << parse_list(scope)
      when ')'
        items << [:variable, name] unless name.nil?
        endloop = true
      else
        if whitespace?
          items << [:variable, name] unless name.nil?
          name = nil
        else
          name = "#{name}#{cur}"
        end
      end
      unless endloop
        assertHasMore("Unexpected end of file in list, expected lambda, string, or list.")
        next!
      end
    end
    args = []
    args = items[1..-1] if items.length > 1

    [:call, items[0], args]
  end

  def parse
    program = []
    name = nil
    scope = @global_scope
    skipWhitespace
    skipComments
    until cur.nil?
      skipComments
      case cur
      when '['
        ret = parse_lambda(scope)
      when '('
        ret = parse_list(scope)
      when ':'
        error "Unexpected ':'" if name.nil?
        ret = parse_definition(name, scope)
      when '"'
        error "Useless string: Not bound to a variable and outside of all lambdas."
      else
        name = "#{name}#{cur}"
      end
      next!
      program << ret unless ret.nil?
    end
    @ast = program
    program
  end
end


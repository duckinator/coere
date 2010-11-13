#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'scope.rb')

code = <<EOF
    function1: [str1 str2 ->
      string: (join " " (list str1 str2))
      (print string)
    ]

EOF


class Parser
  def initialize(code)
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
    puts "In parse_string()"
    assertHasMore("Unterminated string literal met end of file.")
    start = @i
    next! until @i == @code.index('"', start)
    while @code[@i-1] == "\\"
      next! until cur == '"'
    end
    next!
    @code[start..(@i-1)]
  end

  def parse_definition(name, scope)
    puts "In parse_definition()"
    assertHasMore("Definition met end of file.")
    items = []
    endloop = false
    next!
    case cur
    when ':'
      error "Definition inside of a definition."
    when '"'
      items << parse_string
    when '['
      items << parse_lambda(scope)
    when '('
      items << parse_list(scope)
    end
    scope.define(name, items, @line, @column)
    [:define, name, items]
  end

  def parse_lambda(pscope)
    puts "In parse_lambda()"
    assertHasMore("Unexpected end of file in lambda, expected lambda, list, or definition.")
    scope = Scope.new(pscope)
    args = []
    body = []
    in_args = true
    name = nil
    endloop = false
    next!
    until endloop
      p in_args
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
            # First half of ->
            args << name
            in_args = false
            name = nil
          elsif @code[@i-1] == "-" && cur == ">"
            # Second half of ->
          elsif whitespace?
            if in_args
              args << [:variable, name]
            else
              body << [:variable, name]
            end
            name = nil
          else
            name = "#{name}#{cur}"
          end
      end
      next! unless endloop
    end
    p args
    p body
    [:lambda, args, body]
  end

  def parse_list(pscope)
    puts "In parse_list()"
    assertHasMore("Unexpected end of file in list, expected lambda, string, or list.")
    scope = Scope.new(pscope)
    items = []
    name = nil
    endloop = false
    next!
    until endloop
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
    puts "In parse()"
    program = []
    name = nil
    scope = @global_scope
    until cur.nil?
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
    p program
    program
  end
end

Parser.new(code)

5.times{puts}

Parser.new("(a b (c d))")

5.times{puts}

Parser.new("a: [b -> b]")

5.times{puts}

Parser.new("a: [b -> (b)]")

5.times{puts}

Parser.new("[a b -> (print a) (print b)]")


#!/usr/bin/env ruby

code = <<EOF

    function1: [str1 str2 ->
      string: (join " " (list str1 str2))
      (print string)
    ]

EOF

class Parser
  def initialize(code)
    @i = 0
    @column = 0
    @line = 0
    @code = code
    @cur = ''
  end

  def parse_list(start)
    next_open_paren = @code.index('(', start)
    next_close_paren = @code.index(')', start)
    next_open_brace = @code.index('[', start)
    next_close_brace = @code.index(']', start)
  end

  def parse_main
    until @code[@i].nil?
      @cur = @code[@i]
      case @cur
      when '('
        
      when "\n"
        @column = 0
        @line += 1
        @i += 1
        puts "Line #{@line}"
      else
        p @cur
        @i += 1
        @column += 1
      end
    end
  end


  alias parse parse_main
end

p = Parser.new(code)
p.parse
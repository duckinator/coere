require File.join(File.dirname(__FILE__), 'scope.rb')

module Coere
  class Parser
    def initialize(file='(eval)', code='')
      parse(file, code)
    end

    def reset
      @ast = []
      @file = ''
      @code = ''
      @i = 0
      @line = 1
      @column = 1
      @global_scope = Scope.new
    end

    def current
      @code[@i]
    end

    def previous
      @code[@i-1]
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
      if current == ";"
        readUntil("\n")
        skipWhitespace
      end
    end

    def next!
      @i += 1
      if current == "\n"
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

    def assertDeclared(name, scope)
      error "Undeclared variable #{name}" unless scope.declared?(name)
    end

    def readUntil(c)
      next! until current == c
    end

    def parse(file, code)
      reset
      @file = file
      @code = code
    end
  end
end

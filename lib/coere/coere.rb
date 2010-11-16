%w{parser scope sysconfig}.each { |x| require File.join(File.dirname(File.expand_path(__FILE__)), "..", "#{x}.rb") }

class CoereParser < Parser
  def initialize(file = '', code = '', col = 1, line = 1, scope = nil, reset = true)
    @language = 'coere'
    super(@language, file, code, col, line, scope, reset)
  end

  def setup
    on ':' do
      next!
      l = @line
      c = @column
      str = readUntil("\n")
      code = Parser.new(@language, @file, str[1..-1], c, l, @scope, false).ast
      @scope.define(name, code, line, column)
      [[:define, @name, code], '']
    end

    on '[' do
    end

    on '(' do
    end

    on '"' do
      next!
      str = readUntil('"')
      next!
      puts "String: #{str.inspect}"

      [str.inspect]
    end

    on ';' do
      readUntil("\n")
    end
  end
end

CoereParser.new(File.join(SysConfig.dir, "tests", "main.#{@language}"))

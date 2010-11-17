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
      parser = CoereParser.new(@file, str[1..-1], c, l, @scope, false)
      @line = parser.line
      @column = parser.column
      @scope.define(@name, code, l, c)
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

      [str]
    end

    on ';' do
      readUntil("\n")
    end
  end
end

p CoereParser.new(File.join(SysConfig.dir, "tests", "main.coere")).ast

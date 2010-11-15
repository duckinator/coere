require File.join(File.dirname(File.expand_path(__FILE__)), 'scope.rb')

$PARSER_HANDLERS = {}

class Parser
  def initialize(language, file='(eval)', code='')
    @language = language
    parse(file, code)
  end

  def loadFiles
    dir = File.join(File.dirname(File.expand_path(__FILE__)), "subparsers", @language)
    if RUBY_PLATFORM =~ /(win|w)32$/
      cmd = "dir"
      flags = "/B"
    else
      cmd = "ls"
      flags = "-1"
    end
    `cd #{dir} && #{cmd} #{flags}`.split.grep(/\.rb$/).each {|x| require File.join(dir, x) }
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

  def self.on(name, &block)
    $PARSER_HANDLERS[@language] ||= {}
    $PARSER_HANDLERS[@language][name] = block
  end
end

parser = Parser.new("coere")
parser.loadFiles
p parser

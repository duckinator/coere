%w{scope sysconfig}.each { |x| require File.join(File.dirname(File.expand_path(__FILE__)), "#{x}.rb") }

class Parser
  attr_accessor :ast, :name, :file, :code, :position, :line, :column, :scope
  def initialize(language, file='', code='', col=1, line=1, scope = nil, reset = true)
    SysConfig.setup unless SysConfig.done
    @language = language
    @column = col
    @line = line
    @reset = reset
    @scope = scope
    @file = file
    @code = code
    @handlers = {}
    reset() # Why must I use parens?
    loadFiles
    parse(file, code) unless code.empty?
  end

  def loadFiles
    dir = File.join(SysConfig.dir, "lib", @language)
    `cd #{dir} && #{SysConfig.ls} #{SysConfig.lsflags}`.split.grep(/\.rb$/).each {|x| require File.join(dir, x) }
  end

  def reset
    @ast = []
    @name = ''
    @position = 0
    @file = '' if @reset
    @code = '' if @reset
    @offset =  0 if @reset
    @line = 1 if @reset
    @column = 1 if @reset
    @scope = Scope.new if @scope.nil?
    setup
  end

  def current
    @code[@position]
  end

  def previous
    @code[@position-1]
  end

  def whitespace?
    [" ", "\t", "\n"].include?(@code[@position])
  end

  def lastWhitespace?
    [" ", "\t", "\n"].include?(@code[@position-1])
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
    @position += 1
    if current == "\n"
      @column = 1
      @line += 1
    else
      @column += 1
    end
  end

  def error(str, showpos=true)
    print "[Error] "
    print "#{@line}:#{@column}: " if showpos
    puts str
    exit
  end

  def assertHasMore(message = nil)
    message = "Unexpected end of file" if message.nil?
    error message if @position >= @code.length 
  end

  def assertDeclared(name, scope)
    error "Undeclared variable #{name}" unless scope.declared?(name)
  end

  def readUntil(c)
    start = @position
    next! until current == c
    @code[start...@position]
  end

  def parse(one, two='')
    #reset
    code = ''
    file = '(no-file)'
    if (one.nil? || one.empty?) && two.empty?
      error "No file or code specified", false
    elsif two.empty?
      if File.exist?(one)
        file = one
      else
        code = one
      end
    else
      file = one
      code = two
    end
    if code.empty?
      if File.exist?(file)
        code = File.open(file).read
      else
        error "File #{file} not found", false
      end
    end
    @file = file if @file.empty?
    @code = code if @code.empty?
    assertHasMore("No code provided")
    while @position < @code.length
      puts "[#{@position}] #{@line}:#{@column}: #{current.inspect}"
      oldPos = @position
      ret = handle
      @ast << ret[0] if ret.is_a?(Array) && ret.length > 0
      @name = ret[1] if ret.is_a?(Array) && ret.length > 1
      next! if oldPos == @position
    end
  end

  def handle
    if @@handlers.include?(current)
      instance_eval &@@handlers[current]
    else
      @name += current
    end
  end

  def on(name, &block)
    @handlers ||= {}
    @handlers[name] = block
  end

  def self.runtests
    SysConfig.setup
    dir = File.join(SysConfig.dir, "tests")
    `#{SysConfig.ls} #{dir}`.split.each do |s|
      subdir = File.join(dir, s)
      parser = Parser.new(s)
      `#{SysConfig.ls} #{subdir}`.split.each do |file|
        puts "Running \"#{file.split('.')[0..-2].join('.')}\" test for #{s}"
        parser.parse(File.join(subdir, file))
      end
    end
  end

  def setup
  end
end


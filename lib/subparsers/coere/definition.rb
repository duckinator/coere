require File.join(File.dirname(File.expand_path(__FILE__)), "..", "..", "scope.rb")

Parser.on('coere', ':') do
  next!
  l = @line
  c = @column
  str = readUntil("\n")
  code = Parser.new(@language, @file, str[1..-1], c, l, @scope, false).ast
  @scope.define(name, code, line, column)
  [[:define, @name, code], '']
end

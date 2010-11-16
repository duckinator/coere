require File.join(File.dirname(File.expand_path(__FILE__)), "..", "..", "scope.rb")

Parser.on('coere', '"') do
  next!
  str = readUntil('"')
  next!
  puts "String: #{str.inspect}"

  [str.inspect]
end

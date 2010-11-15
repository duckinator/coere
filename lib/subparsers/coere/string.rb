require File.join(File.dirname(File.expand_path(__FILE__)), "..", "..", "scope.rb")

Parser.on '"' do
  puts "Ohai, string!"
end

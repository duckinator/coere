#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'parser.rb')

code = <<EOF
    function1: [str1 str2 ->              ; useless comment
      string: (join " " (list str1 str2)) ;; useless documentation comment
      (print string)
    ]
EOF

p Parser.new(code).ast

2.times{puts}

p Parser.new("(a b (c d))").ast

2.times{puts}

p Parser.new("a: [b -> b]").ast

2.times{puts}

p Parser.new("a: [b -> (b)]").ast

2.times{puts}

p Parser.new("[a b -> (print a) (print b)]").ast


#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), '..', 'lib', 'parser.rb')

code = <<EOF
    join: ""   ; make the parser play nice until i add builtins
    list: ""   ; make the parser play nice until i add builtins
    print: ""  ; make the parser play nice until i add builtins
    function1: [str1 str2 ->              ; useless comment
      string: (join " " (list str1 str2)) ;; useless documentation comment
      (print string)
    ]
EOF

p Parser.new(code).ast

2.times{puts}

p Parser.new("a: [b -> b]").ast

2.times{puts}

p Parser.new("a: [b -> (b)]").ast

2.times{puts}

code = <<EOF
print: "" ; make the parser play nice until i add builtins
[a b -> (print a) (print b)]
EOF

p Parser.new(code).ast

2.times{puts}

code = <<EOF
  print: ''
  (print "ohai thar")
EOF

p Parser.new(code).ast

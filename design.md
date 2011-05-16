Comments
========
* ;   -  Non-documentation comment
* ;;   -  Documentation comment


Lambdas
=======
Lambdas are merely a block of code that accepts arguments, if you just need a block, then leave the argument list empty.
Lambdas return the last value.

    [ x y -> foo]


Variable Definition
===================
Variables are immutable, but I can't think of a better term.

    alist: (list "abc" "def")

Function Definition
===================
Functions are named lambdas

    ;; joins /str1/ and /str2/ with a space, and print the resulting string
    function1: [str1 str2 ->
      string: (join " " (list str1 str2))
      (print string)
    ]

    ;; joins all items in /list/ with spaces, and print the resulting string
    function2: [list ->
      string: (join " " list)
      (print string)
    ]

Function Calling
================

    (function1 (list "foo" "bar"))


Throwing It Together
====================

    ; Define a-list
    alist: (list "abc" "def")
    
    ; combine each item in alist with a space, and prints them
    (function2 alist)
    
    ; combine each item in the list with a space, and prints them
    (function2 (list "foo" "bar"))

AST
===

This is just a quick layout for the AST.

## Function calls ##

    (add 1 2)

would become

    [:call, "add", [1, 2]]

## Lambdas ##

    [arg1 arg2 ->  arg1 + arg2]

would become

    [:lambda, ["arg1", "arg2"], [:call, "add", ["arg1", "arg2"]]]

## Variable definitions ##

    variablename: "value"

would become

    [:define, "variablename", "value"]

## Function definitions, aka named lambdas ##

    functionname: [arg1 arg2 -> (+ arg1 arg2)]
      
would become

    [:define, "functionname",
      [:lambda, [[:argument, "arg1"], [:argument, "arg2"]],
         [:call, "add", [[:variable, "arg1"], [:variable, "arg2"]]]]]


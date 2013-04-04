{dispatch_impl} = require 'libprotocol'
{info, warn, error, debug} = dispatch_impl 'ILogger', 'Calc'
{pubsubhub, partial} = require 'libprotein'


module.exports =
    protocols:
        definitions:
            Calc: [
                ['*cons*',          [], {concerns: {before: [pubsubhub]}}]

                ['push!',           ['v']]
                ['pop!',            []]
                ['reset!',          []]

                ['stack-change?',   ['f']]
                ['error?',          ['f']]
            ]
            Helper2: [
                ['join',            ['sep', 'list']]
            ]
        implementations:
            Helper2: (node) ->
                join: (sep, list) -> list.join sep

            Calc: (node, {pub, sub}) ->
                $stack$ = []
                $error$ = false

                OPS =
                    '+': (s) -> if s.length > 1 then s.push (s.pop() + s.pop()) else (sorry s)
                    '-': (s) -> if s.length > 1 then s.push (s.pop() - s.pop()) else (sorry s)
                    '*': (s) -> if s.length > 1 then s.push (s.pop() * s.pop()) else (sorry s)
                    '/': (s) -> if s.length > 1 then s.push (s.pop() / s.pop()) else (sorry s)
                    '?': (s) -> debug s

                is_op = (v) -> v in (Object.keys OPS)

                sorry = ->
                    $stack$ = ['E','R','R','O','R']
                    $error$ = true
                    pub 'fail'

                check = (f, v) -> if $error$ then (pub 'fail') else (f v)

                push = (v) ->
                    if (is_op v) then (OPS[v] $stack$) else ($stack$.push v)
                    sorry() if $stack$.length > 7
                    pub 'on-stack-change', $stack$

                pop = ->
                    $stack$.pop()
                    pub 'on-stack-change', $stack$


                'push!': partial check, push
                'pop!': partial check, pop
                'stack-change?': partial sub, 'on-stack-change'
                'error?': partial sub, 'fail'
                'reset!': ->
                    $stack$ = []
                    $error$ = false
                    pub 'on-stack-change', $stack$


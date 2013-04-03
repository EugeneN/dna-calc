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
                    '+': (s) -> if s.length > 1 then s.push (s.pop() + s.pop()) else (error s)
                    '-': (s) -> if s.length > 1 then s.push (s.pop() - s.pop()) else (error s)
                    '*': (s) -> if s.length > 1 then s.push (s.pop() * s.pop()) else (error s)
                    '/': (s) -> if s.length > 1 then s.push (s.pop() / s.pop()) else (error s)
                    '?': (s) -> debug s

                is_op = (v) -> v in (Object.keys OPS)

                error = -> 
                    $stack$ = ['E','R','R','O','R']
                    $error$ = true
                    pub 'error'

                check = (f, v) ->
                    if $error$
                        debug "Error state"
                        pub 'error'
                    else
                        f v

                push = (v) ->
                    if is_op v then (OPS[v] $stack$) else ($stack$.push v)
                    error() if $stack$.length > 7
                    pub 'on-stack-change', $stack$

                pop = ->
                    $stack$.pop()
                    pub 'on-stack-change', $stack$


                'push!': partial check, push

                'pop!': partial check, pop

                'stack-change?': partial sub, 'on-stack-change'

                'error?': partial sub, 'error'

                'reset!': ->
                    $stack$ = []
                    $error$ = false
                    debug 'reset', $stack$
                    pub 'on-stack-change', $stack$


{dispatch_impl} = require 'libprotocol'
{info, warn, error, debug} = dispatch_impl 'ILogger', 'Calc'
{pubsubhub, partial} = require 'libprotein'

OPS =
    '+' : (a) -> a.reduce(
            (x, y) -> x + y
            0
        )
    '-' : (a) -> a.reduce(
            (x, y) -> y - x
            0
        )

module.exports =
    protocols:
        definitions:
            Calc: [
                ['*cons*',          [], {concerns: {before: [pubsubhub]}}]

                ['push!',            ['v']]
                ['do-calc',         []]
                ['reset!',          []]

                ['on-stack-change', ['f']]
                ['render-stack',    ['s']]
            ]
        implementations:
            Calc: (node, {pub, sub}) ->
                $stack$ = []

                push = (v) ->
                    $stack$.push v
                    pub 'on-stack-change', $stack$

                'push!': push

                'do-calc': ->
                    args = []
                    while v = $stack$.shift()
                        if v in Object.keys OPS
                            result = OPS[v] args
                            push result
                            break
                        else
                            args.push v

                'on-stack-change': partial sub, 'on-stack-change'

                'render-stack': (s) -> s.join ' '

                'reset!': ->
                    $stack$ = []
                    debug 'reset', $stack$
                    pub 'on-stack-change', $stack$


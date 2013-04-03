X =
    partial: (f, partial_args...) ->
        y = (args...) ->
            f (partial_args.concat args)...

        X.metabolize f, y

    complement: (f) -> (args...) -> !(f args...)

    compose2: (f, g) -> (args...) -> f g args...

    compose3: (f, g, h) -> (args...) -> f(g(h(args...)))

    first: (s) -> s[0]

    identity: (x) -> x

    drop_while: (f, s) ->
        for i in s
            return i unless (f i)

    is_function: (v) -> typeof v is 'function'

    is_array: (v) -> Array.isArray v

    is_object: (v) ->
        # FIXME
        if X.is_array v
            false
        else
            v instanceof {}.constructor

    bool: (v) ->
        # FIXME
        if (X.is_array v)
            !!v.length
        else if (X.is_object v)
            !!(Object.keys(v).length)
        else
            !!v

    and_: (args...) ->
        args.reduce(
            (a, b) -> (X.bool a) and (X.bool b)
            true
        )

    or_: (args...) ->
        args.reduce(
            (a, b) -> (X.bool a) or (X.bool b)
            false
        )

    to_hash: (list_of_tuples) ->
        h = {}
        list_of_tuples.map ([k, v]) -> h[k] = v
        h

    metabolize: (f, g) ->
        g.meta = f.meta
        g

    data_to_opts: (sufx, node) ->
        $node = jQuery node
        keys = Object.keys $node.data()

        X.to_hash (keys.filter((key) -> key[0...sufx.length] is sufx)
                       .map((key) -> [key[sufx.length...], ($node.data key)]))

    add2: (a, b) ->
        if (X.is_array a) and (X.is_array b)
            a.concat b
        else if (X.is_object a) and (X.is_object b)
            ret = {}
            ret[k] = v for own k, v of a
            ret[k] = v for own k, v of b
            ret
        else
            a + b

    add: (values...) ->
        values.reduce (a, b) -> X.add2 a, b

    pubsubhub: ->
        do ->
            q = {}

            sub: (name, f) ->
                q[name] or= []
                q[name].push f

            pub: (name, data...) ->
                q[name]?.map (f) -> f data...

            unsub: (name, f) ->
                if q[name]
                    q[name] = q[name].filter (s) -> s isnt f

            unsuball: (name) ->
                q[name] = [] if q[name]

    distinct: (list) ->
        t = {}
        t[i] = i for i in list
        (v for k, v of t)

    repeat: (v, n) -> (v for i in [0...n])



module.exports = X
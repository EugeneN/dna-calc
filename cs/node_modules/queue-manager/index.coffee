{is_array} = require 'libprotein'

Q = {}

put_to_queue = (q, f) ->
    Q[q] = [] unless Q[q]
    fs = if (is_array f) then f else [f]
    fs.map (f) -> Q[q].push f

run_queue = (q) ->
    if Q[q]
        setTimeout(
            ->
                while f = Q[q].shift()
                    f()
            10
        )
    else
        throw "No such queue: #{q}"

module.exports = {put_to_queue, run_queue}

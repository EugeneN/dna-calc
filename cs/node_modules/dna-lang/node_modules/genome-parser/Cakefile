fs = require 'fs'
path = require 'path'
{Parser} = require 'jison'

ENC = 'utf8'
GRAMMAR = './grammar.jison'
MODULE_NAME = 'genome-parser.coffee'

task 'cafebuild', 'build with cafe', (cb) ->
  fs.readFile GRAMMAR, ENC, (err, grammar) ->
    throw err if err

    dna_parser = new Parser grammar

    ret_result =
        {filename: 'index.coffee', source: dna_parser.generate(), type: 'commonjs'}

    a = JSON.stringify ret_result
    process.send a

    setTimeout(
        ->
            process.exit 0

        9500
    )


task 'build', 'build with npm', (cb) ->
  fs.readFile GRAMMAR, ENC, (err, grammar) ->
    throw err if err

    dna_parser = new Parser grammar

    res = dna_parser.generate()
    fs.writeFileSync "index.js", res

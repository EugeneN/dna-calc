%lex
%%

\s+                    /* skip whitespace */
[0-9]+"."[0-9]*        return 'FLOAT'
[0-9]+                 return 'INT'
\"(\\.|[^\\"]*?)\"     return 'STRING'
"NaN"                  return 'NAN'
"null"                 return 'NULL'
":(?=[a-z0-9]+?)"      return 'KEYWORD'
":"                    return 'ESEP'
[A-Za-z_\-<>+*=$#%^&!?][A-Za-z0-9_\-<>+*=$#%^&!?]* return 'IDENTIFIER'
\"                     return 'DBLQUOTE'
\'                     return 'QUOTE'
"("                    return '('
")"                    return ')'
"["                    return '['
"]"                    return ']'
"^"                    return '^'
"@"                    return '@'
"|"                    return '|'
","                    return ','
"/"                    return '/'
";"                    return ';'
":"                    return ':'
<<EOF>>                return 'EOF'
.                      return 'INVALID'

/lex

/* operator associations and precedence */
%left ',' '|' ';' '/'
%right ESEP

%start program

%%

program
    :
    | text EOF
        {{
           //console.log($1);
           return $1;
        }}
    ;

text
    : statement
        %{ $$ = [$1]; %}
    | text ';' statement
        %{
           $$ = ($1).concat($3);
        %}
    ;

statement
    : ';'
    | event_binding_def
        {{ $$ = $1; }}
    ;

event_binding_def
    : events ESEP handlers
        %{ $$ = {events: $1, handlers: $3}; %}
    ;

events
    : event_expression
        %{ $$ = [$1]; %}
    | events ',' event_expression
        %{ $$ = ($1).concat([$3]); %}
    ;

event_expression
    : event
        {{ $$ = $1; }}
    | event values
        {{ $$ = {type: 'partial-event', event: $1, args: $2}; }}
    ;

event
    : IDENTIFIER
        %{ $$ = {ns: undefined, name: $1, scope: undefined, type: 'event'}; %}
    | IDENTIFIER '/' IDENTIFIER
        %{ $$ = {ns: $1, name: $2, scope: undefined, type: 'event'}; %}
    | IDENTIFIER '@' IDENTIFIER
        %{ $$ = {ns: undefined, name: $1, scope: $3, type: 'event'}; %}
    | IDENTIFIER '/' IDENTIFIER '@' IDENTIFIER
        %{ $$ = {ns: $1, name: $3, scope: $5, type: 'event'}; %}
    ;

handlers
    : handler
        %{ $$ = [$1]; %}
    | handlers ',' handler
        %{ $$ = ($1).concat([$3]); %}
    ;

handler
    : block
        {{ $$ = {type: 'handler', seq: [$1]}; }}
    | handler '|' block
        {{ $$ = {type: 'handler', seq: $1.seq.concat([$3])}; }}
    ;

block
    : value
        {{ $$ = $1; }}
    | fn
        {{ $$ = $1; }}
    | fn values
        {{ $$ = { type: "partial", fn: $1, args: $2}; }}
    ;

values
    : value
        {{ $$ = [$1]; }}
    | values value
        {{ $$ = $1.concat([$2]); }}
    ;

value
    : primitive
        {{ $$ = $1; }}
    | complex
        {{ $$ = $1; }}
    | expr
        {{ $$ = $1; }}
    ;

expr
    : '(' handler ')'
        {{ $$ = {type: 'nested', value: $2}; }}
    | QUOTE '(' handler ')'
        {{ $$ = {type: 'quoted-nested', value: $3}; }}
    ;


primitive
    : NAN
        {{ $$ = { type: "NaN", value: NaN }; }}
    | NULL
        {{ $$ = { type: "null", value: null }; }}
    | KEYWORD
        {{ $$ = { type: "keyword", value: $1 }; }}
    | STRING
        {{ $$ = { type: "string", value: ($1).match('\"(\\.|[^\\"]*?)\"')[1] }; }}
    | number
        {{ $$ = $1; }}
    ;

number
    : INT
        {{ $$ = { type: "integer", value: parseInt($1, 10)}; }}
    | FLOAT
        {{ $$ = { type: "float", value: parseFloat($1, 10)}; }}
    ;

complex
    : '[' vector ']'
        {{ $$ = { type: "vector", value: $2}; }}
    ;

vector
    :
        {{ $$ = []; }}
    | vector vec_item
        {{ $$ = $1.concat([$2]); }}
    ;

vec_item
    : primitive
        {{ $$ = $1; }}
    | complex
        {{ $$ = $1; }}
    | expr
        {{ $$ = $1; }}
    ;

fn
    : IDENTIFIER
        {{ $$ = {type: 'fn', ns: undefined, name: $1, scope: undefined}; }}
    | IDENTIFIER '/' IDENTIFIER
        {{ $$ = {type: 'fn', ns: $1, name: $3, scope: undefined}; }}
    | IDENTIFIER '@' IDENTIFIER
        {{ $$ = {type: 'fn', ns: undefined, name: $1, scope: $3}; }}
    | IDENTIFIER '/' IDENTIFIER '@' IDENTIFIER
        {{ $$ = {type: 'fn', ns: $1, name: $3, scope: $5}; }}
    ;

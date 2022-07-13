:- module(parser, [parse/2]).
:- use_module(lexer).
% add pattern matching for arguments

parse(Code, AST) :-
    tokenize(Code, Out),
    % group functions here
    instructions(AST, Out, []).

instruction(N) --> fn_def(N); lam_def(N); lit(N); sym(N); seq(N); pass(N); tracer; as_def(N); loop(N).

instructions([N]) --> instruction(N).
instructions([N|R]) --> instruction(N), instructions(R).

tracer --> [sym_t("$trace",_)], {trace}.

fn_def(fn(Name, Args, Instructions)) --> ['fn'(_), sym_t(Name, _)], arg_list(Args), (block(Instructions); single(Instructions)).
fn_def(fn(Name, [], Instructions)) --> ['fn'(_), sym_t(Name, _)], (block(Instructions); single(Instructions)).

lam_def(lam(Args, Instructions)) --> ['lam'(_)], arg_list(Args), ['::'(_)], instructions(Instructions), ['end'(_)].
lam_def(lam([], Instructions)) --> ['lam'(_)], (block(Instructions); single(Instructions)).
lam_def(lam([], Instructions, [L1, L2])) --> ['('(L1)], instructions(Instructions), [')'(L2)].

as_def(as(Args)) --> ['as'(_)], arg_list(Args), ['->'(_)].

loop(ntimes(N, L)) --> lam_def(L), ['{'(_)], lit(N), ['}'(_)].
loop(for(Instructions)) --> ['loop'(_)], (block(Instructions); single(Instructions)). % use collection on stack
loop(for(Pattern, Collection, Instructions)) --> ['loop'(_)], pattern(Pattern), ['in'(_)], expr_list(Collection), (block(Instructions); single(Instructions)).
loop(for(Collection, Instructions)) --> ['loop'(_)], expr_list(Collection), (block(Instructions); single(Instructions)).
loop(while(Condition, Instructions)) --> ['loop'(_)], expr_list(Condition), (block(Instructions); single(Instructions)).
loop(while(Instructions)) --> ['loop'(_)], (block(Instructions); single(Instructions)). % use lambda on stack

pass(pass(L)) --> ['pass'(L)].

lit(lit(V)) --> [lit_t(V, _)].
sym(sym(N)) --> [sym_t(N, _)].

elem(N)               --> lit(N); sym(N); seq(N); lam_def(N).
elem_group(N)         --> elem(N).
elem_group([N|R])     --> elem(N), elem_group(R).
elems(N)              --> elem_group(N).
elems([N|R])          --> elem_group(N), [','(_)], elems(R).
seq(cons(H, T))       --> ['['(_)], elems(H), [sym_t("<:",_)], elem_group(T), [']'(_)].
seq(snoc(F, L))       --> ['['(_)], elem_group(F), [sym_t(":>",_)], elems(L), [']'(_)].
seq(tape([])) --> ['['(_), ']'(_)].
seq(tape(N))  --> ['['(_)], elems(N), [']'(_)]. % circular doubly linked list

arg_list(P)     --> pattern(P).
arg_list([P|R]) --> pattern(P), arg_list(R).

expr(E) --> lit(E); sym(E); seq(E).
expr_list(E) --> expr(E).
expr_list([E|R]) --> expr(E), expr_list(R).

pat_list(P)         --> pattern(P).
pat_list([P|R])     --> pattern(P), pat_list(R).
pattern(pat_lit(V)) --> [lit_t(V, _)].
pattern(pat_var(N)) --> [sym_t(N, _)].
pattern(pat_cons(H, T)) --> ['['(_)], pat_list(H), [sym_t("<:",_)], pattern(T), [']'(_)].
pattern(pat_snoc(F, L)) --> ['['(_)], pattern(F), [sym_t(":>",_)], pat_list(L), [']'(_)].
pattern(pat_list([])) --> ['['(_), ']'(_)].
pattern(pat_list(L)) --> ['['(_)], pat_list(L), [']'(_)].

block(Instructions) --> ['::'(_)], instructions(Instructions), ['end'(_)].
single(Instruction)    --> ['->'(_)], instruction(Instruction).

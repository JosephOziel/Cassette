:- module(run, [run/1, run_no_main/1, run2/1, run_bare/1, debugc/1]).
:- use_module(eval).
:- use_module('../frontend/parser').
:- use_module(tape).

% run predicates
run(Code) :-
    parse(Code, AST),
    Tape @- !, CTX = ctx{},
    eval_list(AST, CTX, Tape, ECTX, ETape),
    eval(sym("main"), ECTX, ETape, _CTX, _Tape).

run_no_main(Code) :-
    parse(Code, AST),
    Tape @- !, CTX = ctx{},
    eval_list(AST, CTX, Tape, _, NTape), print_term(NTape, []).

run2(Code) :-
    parse(Code, AST),
    run_bare(AST).

run_bare(AST) :-
    Tape @- !, CTX = ctx{},
    eval_list(AST, CTX, Tape, ECTX, ETape),
    print_term(ETape, []), nl, print_term(ECTX, []).

debugc(Code) :-
    parse(Code, AST),
    gtrace,
    run_bare(AST).


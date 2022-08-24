:- module(builtins, [builtin/5]).
:- use_module(tape).
:- use_module(pretty_print).

% the overidable builtins

def_op(bin, "+", [X, Y, R] >> (R is X + Y)).
def_op(unit, "out", [X] >> pretty_print(X)).

builtin(Op, CTX, Tape, CTX, NTape) :-
    def_op(Ty, Op, F),
    (   Ty = bin, bin_op(F, Tape, NTape)
    ;   Ty = unit, unit_op(F, Tape, NTape)).

% utils
bin_pop(Tape, X, Y, NTape) :-
    Tape0 @- Tape^X, NTape @- Tape0^Y.

bin_op(Op, Tape, NTape) :-
    bin_pop(Tape, X, Y, Tape0),
    call(Op, X, Y, R),
    NTape @- Tape0+R.

un_op(Op, Tape, NTape) :-
    Tape0 @- Tape^X,
    call(Op, X, R),
    NTape @- Tape0+R.

unit_op(Op, Tape, NTape) :-
    NTape @- Tape^X,
    call(Op, X).
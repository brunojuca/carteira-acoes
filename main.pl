:- dynamic operacao/7.

:- use_module(library(persistency)).

:- persistent operacao(ticket:any, tipo:any, quantidade:any, preco_unid:any, data:any, taxas:any, valor_total:any).

:- initialization(init).

init :- 
    absolute_file_name('operacoes.db', File, [access(write)]),
    db_attach(File, []).
    at_halt(db_sync(gc(always))).


% operacao(ticket, tipo, quantidade, preco_unid, data, taxas, valor_total)
% operacao("ITSA4", "COMPRA", 10, 8.80, 22/11/2022, 0.1, 0.1).

% compra
compra(T, N, P, D) :-
    X is 0.00025 * N * P + 0.00005 * N * P,
    V is N * P + X,
    assert_operacao(T, "COMPRA", N, P, D, X, V).

% venda
venda(T, N, P, D) :-
    X is 0.00025 * N * P + 0.00005 * N * P,
    V is N * P - X,
    assert_operacao(T, "COMPRA", N, P, D, X, V).

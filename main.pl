:- dynamic operacao/7.

:- use_module(library(persistency)).

:- persistent operacao(date:any, ticket:any, tipo:any, preco_unid:any, quantidade:any, taxas:any, valor_total:any).

:- initialization(init).

init :- 
    absolute_file_name('operacoes.db', File, [access(write)]),
    db_attach(File, []).
    at_halt(db_sync(gc(always))).


% compra
compra(D, M, Y, T, N, P) :-
    X is floor(10^2*(0.00025 * N * P + 0.00005 * N * P))/10^2,
    V is N * P + X,
    assert_operacao(date(D, M, Y), T, "COMPRA", P, N, X, V).

% venda
venda(D, M, Y, T, N, P) :-
    X is floor(10^2*(0.00025 * N * P + 0.00005 * N * P))/10^2,
    V is N * P - X,
    N1 is -N,
    V1 is -V,
    assert_operacao(date(D, M, Y), T, "VENDA", P, N1, X, V1).

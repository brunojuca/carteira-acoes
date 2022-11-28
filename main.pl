% BRUNO DE OLIVEIRA JUCÁ - 201965013A
% RÔMULO CHRISPIM DE MELLO - 201935038

:- dynamic operacao/7.

:- use_module(library(persistency)).

:- persistent operacao(date:any, ticket:any, tipo:any, preco_unid:any, quantidade:any, taxas:any, valor_total:any).

:- initialization(init).

init :- 
    absolute_file_name('operacoes-gen.db', File, [access(write)]),
    db_attach(File, []).
    at_halt(db_sync(gc(always))).


compra(D, M, Y, T, P, N) :-
    X is floor(10^2*(0.00025 * N * P + 0.00005 * N * P))/10^2,
    V is N * P + X, 
    assert_operacao(date(D, M, Y), T, 'COMPRA', P, N, X, V).

venda(D, M, Y, T, P, N) :-
    X is floor(10^2*(0.00025 * N * P + 0.00005 * N * P))/10^2,
    V is N * P - X,
    N1 is -N,
    V1 is -V,
    assert_operacao(date(D, M, Y), T, 'VENDA', P, N1, X, V1).

operacoes :-
    format('\n|~t~a~t~13||~t~a~t~9+|~t~a~t~11+|~t~a~t~17+|~t~a~t~13+|~t~a~t~8+|~t~a~t~14+|~n', 
        ['DATA', 'TICKET', 'OPERAÇÃO', 'PREÇO UNITÁRIO', 'QUANTIDADE', 'TAXAS', 'CUSTO TOTAL']),
    format("|~`-t~85||~n"),
    forall(operacao(date(D, M, Y), T, Z, P, N, X, V), 
        format('| ~`0t~a~4+/~`0t~a~3+/~t~a~t~6+|~t~a~t~9+|~t~a~t~11+|~t~2f~16+ |~t~d~13+ |~t~2f~8+ |~t~2f~14+ |~n', 
            [D, M, Y, T, Z, P, N, X, V])),
    write('\n').

operacoes(T, Z, Y) :-
    format('\n|~t~a~t~13||~t~a~t~9+|~t~a~t~11+|~t~a~t~17+|~t~a~t~13+|~t~a~t~8+|~t~a~t~14+|~n', 
        ['DATA', 'TICKET', 'OPERAÇÃO', 'PREÇO UNITÁRIO', 'QUANTIDADE', 'TAXAS', 'CUSTO TOTAL']),
    format("|~`-t~85||~n"),
    forall(operacao(date(D, M, Y), T, Z, P, N, X, V), 
        format('| ~`0t~a~4+/~`0t~a~3+/~t~a~t~6+|~t~a~t~9+|~t~a~t~11+|~t~2f~16+ |~t~d~13+ |~t~2f~8+ |~t~2f~14+ |~n', 
            [D, M, Y, T, Z, P, N, X, V])),
    write('\n').

sum_carteira((T-'VENDA'-_-N-X-V), (_-_-Pm-Na-_-Va), Result) :-
    Vt is Va + V,
    Nt is Na + N,
    (Nt =:= 0 ->
        Pmn = 0,
        Vtn = 0
        ;
        Pmn = Pm,
        Vtn = Vt),
    Result = (T-'COMPRA'-Pmn-Nt-X-Vtn).

sum_carteira((T-'COMPRA'-P-N-X-V), (_-_-_-Na-_-Va), Result) :-
    Vt is Va + V,
    Nt is Na + N,
    Pmn is (P*N + Va)/Nt,
    Result = (T-'COMPRA'-Pmn-Nt-X-Vt).

calcula_acao(T) :-
    bagof((T-Z-P-N-X-V), D^M^Y^(operacao(date(D, M, Y), T, Z, P, N, X, V)), Os),
    foldl(sum_carteira, Os, (T-_-0-0-0-0), S), !, % corte pois os casos de sum_carteira são excludentes
    (_-_-Pm-Nt-_-Vt) = S,
    (Nt =\= 0 ->
        format('|~t~a~t~8||~t~2f~13+ |~t~d~13+ |~t~2f~18+ |~n', 
        [T, Pm, Nt, Vt])
        ;
        true).

carteira :-
    setof((T), D^M^Y^Z^P^N^X^V^(operacao(date(D, M, Y), T, Z, P, N, X, V)), Ts),
    format('\n|~t~a~t~8||~t~a~t~14+|~t~a~t~13+|~t~a~t~18+|~n', 
    ['ACÃO', 'PREÇO MÉDIO', 'QUANTIDADE', 'VALOR INVESTIDO']),
    format("|~`-t~53||~n"),
    maplist(calcula_acao, Ts),
    write('\n').

sum_lucro_carteira((T-'VENDA'-_-N-X-V-_), (_-_-Pm-Na-_-Va-La), Result) :-
    Vt is Va + V,
    Nt is Na + N,
    Lt is La + (Pm*N-V),
    (Nt =:= 0 ->
        Pmn = 0,
        Vtn = 0
        ;
        Pmn = Pm,
        Vtn = Vt),
    Result = (T-'COMPRA'-Pmn-Nt-X-Vtn-Lt).

sum_lucro_carteira((T-'COMPRA'-P-N-X-V-_), (_-_-_-Na-_-Va-La), Result) :-
    Vt is Va + V,
    Nt is Na + N,
    Pmn is (P*N + Va)/Nt,
    Result = (T-'COMPRA'-Pmn-Nt-X-Vt-La).

calcula_lucro(Y, T, La, Result) :-
    bagof((T-Z-P-N-X-V-0), D^M^Y^(operacao(date(D, M, Y), T, Z, P, N, X, V)), Os),
    foldl(sum_lucro_carteira, Os, (T-_-0-0-0-0-0), S), !, % corte pois os casos de sum_lucro_carteira são excludentes
    (_-_-_-_-_-_-L) = S,
    Result is La + L,
    format('|~t~a~t~8||~t~2f~9+ |~n', 
    [T, L]).


lucro(Y) :-
    setof((T), D^M^Y^P^N^X^V^(operacao(date(D, M, Y), T, 'VENDA', P, N, X, V)), Ts),
    format('\n|~t~a~t~8||~t~a~t~10+|~n', 
    ['ACÃO', 'LUCRO']),
    format("|~`-t~18||~n"),
    foldl(calcula_lucro(Y), Ts, 0, Lt),
    format("|~`-t~18||~n"),
    format('|~t~a~t~8||~t~2f~9+ |~n', 
    ['TOTAL', Lt]),
    write('\n').
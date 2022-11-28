# BRUNO DE OLIVEIRA JUCÁ - 201965013A
# RÔMULO CHRISPIM DE MELLO - 201935038

import random as rd
import datetime as dt

def random_date(data_inicial:dt.datetime, data_final:dt.datetime):
    delta = data_final - data_inicial
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = rd.randrange(int_delta)
    return data_inicial + dt.timedelta(seconds=random_second)

def op_valida(acao, op, n):
    if op == "VENDA":
        if n_acoes[acoes_opt.index(acao)] < n:
            return False
        else:
            n_acoes[acoes_opt.index(acao)] = n_acoes[acoes_opt.index(acao)] - n
    else:
        n_acoes[acoes_opt.index(acao)] = n_acoes[acoes_opt.index(acao)] + n
    return True


rd.seed(0)

ops_n = 50
ops_opt = ["COMPRA", "VENDA"]
acoes_opt = ["MGLU3", "OIBR3", "VIIA3", "IRBR3", "HAPV3", "AMER3", "B3SA3", "CIEL3", "CASH3", "CVCB3", "NTCO3", "VALE3"]
n_acoes = [0 for i in range(len(acoes_opt))]

datas = []
acoes = []
ops = []
precos = []
qtd = []

data_inicial  = dt.datetime(2020, 1, 1)
data_final  = dt.datetime(2022, 11, 27)

for i in range(ops_n):
    datas.append(random_date(data_inicial, data_final))
    precos.append(round((rd.random()*20)+30, 2))

    choice_acao = rd.choice(acoes_opt)
    choice_op = rd.choice(ops_opt)
    n = rd.randint(1, 500)

    while (not op_valida(choice_acao, choice_op, n)):
        choice_acao = rd.choice(acoes_opt)
        choice_op = rd.choice(ops_opt)

    acoes.append(choice_acao)
    ops.append(choice_op)
    qtd.append(n)


datas.sort()

for i in range(ops_n):
    print(str(ops[i]).lower() + "(" +  str(datas[i].day) + ", " + str(datas[i].month) + ", " + str(datas[i].year) + ", '" + str(acoes[i]) + "', " + str(precos[i]) + ", " + str(qtd[i]) + ")." )
#    SSC-0112 - Organização de Computadores Digitais
#    Turma A - 2018/01
#    Prof Paulo Sérgio Lopes de Souza
#
#    Implementação de uma Bitwise Trie em Assembly MIPS
#
#    Alunos:
#        Felipe Scrochio Custódio - 9442688
#        Gabriel Henrique Scalici - 9292970
#        Juliano Fantozzi - 9791218
#        André Luis Storino Junior - 9293668
#
#     Montado e executado utilizando MARS
#
# NOMENCLATURA DAS FUNÇÕES
#   funcionalidade_funcao.
#   Todas as funções foram declaradas com o nome principal seguido
#   de sua utilidade, utilizando Snake Case. Assim, fica mais fácil
#   pesquisar todas as funções de inserção de nó, por exemplo, pois
#   todas começam com insert_node. Isso também nos auxiliou ao utilizar
#   editores com completação automática.
#
# USO DE REGISTRADORES
# +--------------+--------------------------+
# | Registrador  |        Usado para        |
# +--------------+--------------------------+
# | $s0-$s4      | Opções do Menu           |
# | $t0          | Input do Menu            |
# | $s5          | Endereço inicial da Trie |
# | $s6          | Contador (Trie)          |
# | $s7          | Contador (Pilha)         |
# | $a1          | Endereço de 'Chave'      |
# +--------------+--------------------------+
#
# ESTRUTURA DA BITWISE TRIE
# +----------------------+--------------+---------+
# |       Atributo       | Tipo de Dado | Tamanho |
# +----------------------+--------------+---------+
# | Endereço nó esquerda | Ponteiro     | 4 bytes |
# | Endereço nó direita  | Ponteiro     | 4 bytes |
# | Flag de nó terminal  | Char         | 1 byte  |
# +----------------------+--------------+---------+

.data

    .align 2

    # Menu principal

    # Strings de menu
    str_menu: .asciiz "\n\nBITWISE TRIE\n\n    1. Inserção\n    2. Remoção\n    3. Busca\n    4. Visualização\n    5. Sair\n    Escolha uma opção (1 a 5): "

    # Strings das opções do menu
    str_insert: .asciiz "Digite o binário para inserção: "
    str_remove: .asciiz "Digite o binário para remoção: "
    str_search: .asciiz "Digite o binário para busca: "

    str_repeat: .asciiz "Binario já existente na arvore."
    str_sucess: .asciiz "Sucesso!\n"

    str_duplicated: .asciiz "Chave repetida. Inserção não permitida.\n"
    str_invalid: .asciiz "Chave inválida. Insira somente números binários (ou -1 retorna ao menu)\n"
    str_return: .asciiz "Retornando ao menu.\n"

    str_exit: .asciiz "Saindo...\n"

    # Strings da visualização
    str_vis_n: .asciiz "N"
    str_vis_space: .asciiz " "
    str_vis_p1: .asciiz "("

    str_vis_p2: .asciiz ")\n"
    srt_vis_info_t: .asciiz "T"
    str_vis_info_nt: .asciiz "NT"
    str_vis_null: .asciiz "null"

    str_vis_root: .asciiz "raiz"
    str_vis_zero: .asciiz "0"
    str_viz_one: .asciiz "1"
    str_vis_t: .asciiz ", T"
    str_vis_nt: .asciiz ", NT"
    #str_vis_null: .asciiz ", null"
    str_vis_comma: .asciiz ", "
    #str_vis_p2: .asciiz ") "
    str_vis_nl: .asciiz "\n"

    # Input
    chave: .space 16 # 16 dígitos = 16 bytes

    # Raiz da Trie
    root: .space 8 # Cada nó possui dois ponteiros de 4 bytes (esq, dir)

.text

    main:
        # Opções do Menu ficam armazenadas
        # nos registradores $sX
        li $s0, 1 # 1 - Inserção
        li $s1, 2 # 2 - Remoção
        li $s2, 3 # 3 - Busca
        li $s3, 4 # 4 - Visualizar
        li $s4, 5 # 5 - Sair
        # Alocar nó raiz
        li $v0, 9 # alocar memória
        la $a0, 12 # 1 nó = 12 bytes (2 endereços/ponteiros + 1 flag indicando se o noh eh terminal)
        # a flag ocupa 4 bytes ao inves de 1 byte por causa do alinhamento
        syscall

        # Colocando o valor null nos ponteiros do primeiro noh
        # endereco a esquerda = null
        sw $zero, 0($v0)
        # endereco a direita = null
        sw $zero, 4($v0)

        # flag indicando se eh noh terminal = false
        sw $zero, 8($v0)

        # Colocando o valor null nos ponteiros do primeiro noh
        # endereco a esquerda = null
        sw $zero, 0($v0)
        # endereco a direita = null
        sw $zero, 4($v0)

        # Armazenar endereço inicial da Trie (raiz)
        sw $v0, root

    # Funcionalidade do Menu
    menu:

        li $v0, 4 # imprimir string
        la $a0, str_menu
        syscall

        li $v0, 5 # ler inteiro
        syscall
        move $t0, $v0 # guardar input em $t0

        # ir para opção escolhida
        beq $t0, $s0, insert_node # 1
        #beq $t0, $s1, remove_node # 2
        beq $t0, $s2, search_node # 3
        beq $t0, $s3, visualize # 4
        beq $t0, $s4, exit # 5
        j menu # loop (opção inválida)

    # Funcionalidades da Trie


    # +----------+
    # | INSERÇÃO |
    # +----------+
    insert_node:
        li $v0, 4 # imprimir string
        la $a0, str_insert
        syscall

        li $v0, 8 # ler string
        la $a0, chave # armazenar input do usuário em 'chave'
        li $a1, 16 # preparar para ler 16 bytes
        syscall

        jal check_input # verificar se input é válido (volta ao menu se -1)
        bne $v0, 1, insert_node # pede nova chave caso seja inválida

        # verificar se chave já existe
        jal search_node
        bne $v0, 1, insert_node # pede nova chave caso seja repetida

        # acessar 'chave' do usuário
        # $a1 é nosso ponteiro para iterar sobre a chave
        la $a1, chave

        # acessar nó raiz
        # $t1 = sempre nó atual
        la $t1, root

        insert_node_loop:
            # percorrer chave do usuário
            # $t0 = caractere atual da chave
            # $a1 = endereço do caractere atual da chave
            lb $t0, 0($a1) # $ a1 sempre estará atualizado
            beq $t0, $zero, insert_node_left # 0 = inserir à esquerda
            beq $t0, $s0, insert_node_right # 1 = inserir à direita

            # fim da string significa que nó atual é nó terminal de chave
            sw $s0, 8($v0) # marcar flag como '1'

            j insert_node # encerrou, pedir nova string ou retorno ao menu

        insert_node_right:
            # verificar se existe filho à direita
            # $t2 = ponteiro temporário para filhos
            lw $t2, 4($t1)
            bnez $t2, insert_descend_right

            # se &dir == null, criar e inserir novo nó
            insert_node_right_new:
                # vamos alocar e inserir
                li $v0, 9 # alocar memória
                li $a0, 8 # 1 nó = 8 bytes (2 endereços/ponteiros)
                syscall # $v0 contém endereço inicial do novo nó

                # coloca o valor null nos ponteiros do novo nó
                # endereco a esquerda = null
                sw $zero, 0($v0)
                # endereco a direita = null
                sw $zero, 4($v0)
                # flag indicando se eh noh terminal = false
                sw $zero, 8($v0)

                sw $v0, 4($t1) # novo nó é armazenado como filho direito do nó atual
                # descer para novo nó e continuar loop

            # se &dir != null, descer para ele e voltar ao loop
            insert_descend_right:
                # descendo na árvore, t1 = &dir do nó em que estávamos
                lw $t1, 4($t1)
                addi $a1, $a1, 1 # ir para próximo caractere na chave
                j insert_node_loop

        insert_node_left:
            # verificar se existe filho à esquerda
            # $t2 = ponteiro temporário para filhos
            lw $t2, 0($t1)
            bnez $t2, insert_descend_left

            # se &dir == null, criar e inserir novo nó
            insert_node_left_new:
                # vamos alocar e inserir
                li $v0, 9 # alocar memória
                li $a0, 8 # 1 nó = 8 bytes (2 endereços/ponteiros)
                syscall # $v0 contém endereço inicial do novo nó

                # coloca o valor null nos ponteiros do novo nó
                # endereco a esquerda = null
                sw $zero, 0($v0)
                # endereco a esquerda = null
                sw $zero, 4($v0)
                # flag indicando se eh noh terminal = false
                sw $zero, 8($v0)

                sw $v0, 0($t1) # novo nó é armazenado como filho direito do nó atual
                # descer para novo nó e continuar loop

            # se &dir != null, descer para ele e voltar ao loop
            insert_descend_left:
                # descendo na árvore, t1 = &dir do nó em que estávamos
                lw $t1, 0($t1)
                addi $a1, $a1, 1 # ir para próximo caractere na chave
                j insert_node_loop


    # +-------+
    # | BUSCA |
    # +-------+
    search_node:
        # valores setados nos registradores durante o check_input
        #t1 = '0'
        #t2 = '1'
        #t4 = '\n'
        la $a1, chave #a1 = input
        move $a0, $s5 #a0 = root
        lb $t0, 0($a1) #carrega primeiro digito do input

        search_node_loop:
            beq $t0, $t4, search_found #fim da leitura '\n'
            beq $t0, $zero, search_found #fim da leitura '\0'
            beq $t0, $t1, search_zero #caso byte == '0' goto search_zero
            beq $t0, $t2, search_one #caso byte == '1' goto search_one
            j search_node_loop

        search_zero:
            lw $t0, 0($s5) #carrega endereço "0" da arvore
            bnez $t0, search_next_char #caso haja um endereço, continue percorrendo o vetor
            beqz $t0, search_not_found #caso nao haja endereço, retornar "input nao encontrado"

        search_one:
            lw $t0, 4($s5) #carrega endereço "1" da arvore
            bnez $t0, search_next_char #caso haja um endereço, continue percorrendo o vetor
            beqz $t0, search_not_found #caso nao haja endereço, retornar "input nao encontrado

        search_next_char:
            addi $a1, $a1, 1
            lb $t0, 0($a1)
            j search_node_loop

        search_not_found:
            li $v0, -1 # return -1
            jr $ra

        search_found:
            li $v0, 1 # return 1
            jr $ra

    # +---------+
    # | REMOÇÃO |
    # +---------+
    remove_node:
        li $v0, 4 # imprimir string
        la $a0, str_remove
        syscall

        li $v0, 8 # ler string
        la $a0, chave
        li $a1, 16
        syscall

        jal check_input # verifica se o input esta correto
        bne $v0, 1, remove_node

        jal search_node # verifica se a chave a ser deletada existe de fato
        beq $v0, -1, error_str_not_found

        # setup para a recursão
        la $a1, chave # a1 = input
        move $v0, $s5 # v0 = root
        lb $t0, 0($a1) # carrega primeiro digito do input
        jal remove_node_recursion # chama recursão

        remove_node_recursion:
            #t0 = recebe de $a1 o byte da chave de entrada (input do usuario)
            #t1 = '0' ||  #a0 = nó pai de $v0
            #t2 = '1' ||  #a1 = input string
            #t4 = '\n'||  #v0 = retorno
            remove_node_recursion_loop:
                #push da recursão
                sw $v0, 0($sp)
                sw $ra, -4($sp)
                addi $sp, $sp, -8
                #jump para os casos
                beq $t0, $t1, remove_node_zero
                beq $t0, $t2, remove_node_one
                beq $t0, $t4, remove_node_set_flag # caso base, quando $t0 = \n
                beqz $t0, remove_node_set_flag # caso base, quando $t0 = \0

            remove_node_zero:
                move $a0, $v0
                lw $v0, 0($a0) # carrega endereço "0" da arvore (nó a esquerda)
                addi, $a1, $a1, 1  # incrementando o input do usuario
                lb $t0, 0($a1) # carregando o proximo elemento da string
                jal remove_node_recursion_loop
                lw $t3, 0($v0) # preparando a subtração dos endereços
                lw $t5, 4($v0) # preparando a subtração dos endereços
                sub $t3, $t3, $t5 # caso a subtração seja != 0, pelo menos 1 dos dois existe, não pode ser deletado
                lb $t5, 8($v0) # load da flag para verificar se é node terminal ou não
                sub $t3, $t3, $t5 # caso a subtração seja != 0, ou a flag existe ou algum dos endereços existem. Não pode deletar
                beqz $t3, remove_node_pop_remove_zero
                j r_node_found

            remove_node_one:
                move $a0, $v0
                lw $v0, 4($a0) # carrega endereço "1" da arvore (a direita)
                addi, $a1, $a1, 1 # incrementando o input do usuario
                lb $t0, 0($a1) # carregando o proximo elemento da string
                jal remove_node_recursion_loop
                lw $t3, 0($v0) # preparando a subtração dos endereços
                lw $t5, 4($v0) # preparando a subtração dos endereços
                sub $t3, $t3, $t5 # caso a subtração seja != 0, pelo menos 1 dos dois existe, não pode ser deletado
                lb $t5, 8($v0) # load da flag para verificar se é node terminal ou não
                sub $t3, $t3, $t5 # caso a subtração seja != 0, ou a flag existe ou algum dos endereços existem. Não pode deletar
                beqz $t3, remove_node_pop_remove_zero
                j r_node_found

            r_node_found:
                lw $ra, 4($sp) # pop da pilha
                lw $v0, 8($sp)
                addi, $sp, $sp, 8
                jr $ra

            remove_node_pop_remove_zero:
                lw $v0, 8($sp) # carregando endereço na pilha
                sw $zero, 0($v0) # setando o nó filho a esquerda em 0 (remoção)
                j r_node_found

            remove_node_pop_remove_zero:
                lw $v0, 8($sp) # carregando endereço na pilha
                sw $zero, 4($v0) # setando o nó filho a direita em 0 (remoção)
                j r_node_found

            remove_node_set_flag:
                sb $zero, 8($v0) # setando a flag de terminal para 0
                j r_node_found

    # +--------------+
    # | VISUALIZAÇÃO |
    # +--------------+
    # +-------------+------------------------------------------------------------------+
    # | Registrador |                            Utilidade                             |
    # +-------------+------------------------------------------------------------------+
    # | $t0         | endereco do no checado                                           |
    # | $t1         | valores obtidos da memoria a partir de $t0                       |
    # | $t2         | contador do nivel da arvore                                      |
    # | $t3         | armazena o endereco da estrutura alocada que sera obtida da fila |
    # | $t4         | valores obtidos da memoria a partir de $t3                       |
    # | $t5         | primeiro elemento da fila utilizada                              |
    # | $t6,$t7     | utilizados nas funcoes da fila                                   |
    # | $a3         | endereco do noh sentinela para contar o nivel da arvore          |
    # +-------------+------------------------------------------------------------------+

    # Imprime a arvore em largura, com informacoes relevantes de cada noh
    visualize:

        # armazenando endereco da raiz
        # lw $t0, $s5
        lw $t0, root

        # nivel inicial = 0
        li $t2, 0

        # inicializando fila
        add $t5, $zero, $zero

        # adicionando elemento sentinela na fila para contar os niveis da arvore
        add $a0, $t5, $zero
        li $a1, 0 # endereco null sera colocado nesta sentinela
        li $a2, 0
        jal enqueue
        add $a3, $v0, $zero # $a3 recebe o endereco do sentinela

        # imprimindo informacoes da raiz
        # "N0 (raiz, NT, &esq, &dir) \n"
        li $v0, 4 # imprimir string "N"
        la $a0, str_vis_n
        syscall

        li $v0, 1 #imprimir 0 (nivel da raiz)
        add $a0, $t2, $zero
        syscall

        li $v0, 4 # imprimir string " "
        la $a0, str_vis_space
        syscall

        li $v0, 4 # imprimir string "("
        la $a0, str_vis_p1
        syscall

        li $v0, 4 # imprimir string "raiz"
        la $a0, str_vis_root
        syscall

        li $v0, 4 # imprimir string ", NT"
        la $a0, str_vis_nt
        syscall

        # Checa se o endereco do filho a esquerda != null
        vis_check_left:
            lw $t1, 0($t0)
            bnez $t1, vis_print_left
            jal vis_print_null

        # Checa se o endereco do filho a direita != null
        vis_check_right:
            lw $t1, 4($t0)
            bnez $t1, vis_print_right
            jal vis_print_null
            j vis_next_node

        # imprime o endereco do filho a esquerda
        # adiciona o filho a esquerda na fila
        vis_print_left:
            li $v0, 4 # imprimir string ", "
            la $a0, str_vis_comma
            syscall

            li $v0, 1 # imprimir o endereco do filho a esquerda
            add $a0, $t1, $zero
            syscall

            # adicionar filho a esquerda na fila
            add $a0, $t5, $zero
            add $a1, $t1, $zero
            li $a2, 0
            jal enqueue
            add $t5, $v0, $zero #novo endereco da cabeca da fila

            j vis_check_right

        # imprime o endereco do filho a direita
        # adiciona o filho a direita na fila
        vis_print_right:
            li $v0, 4 # imprimir string "
            la $a0, str_vis_comma
            syscall

            li $v0, 1 # imprimir o endereco do filho a direita
            add $a0, $t1, $zero
            syscall

            # adicionar filho a direita na fila
            add $a0, $t5, $zero
            add $a1, $t1, $zero
            li $a2, 1
            jal enqueue
            add $t5, $v0, $zero #novo endereco da cabeca da fila

            j vis_next_node

        vis_print_null:
            li $v0, 4 # imprimir string ", null"
            la $a0, str_vis_null
            syscall
            jr $ra

        # checa se a fila esta vazia, caso contrario imprime o proximo noh
        vis_next_node:
            li $v0, 4 # imprimir string ") "
            la $a0, str_vis_p2
            syscall

            vis_next_dequeue:
                # pega o proximo endereco da fila
                add $a0, $t5, $zero # $a0 recebe a cabeca da fila
                jal dequeue
                add, $t5, $v1, $zero # nova cabeca da fila
                add, $t3, $v0, $zero # elemento removido da fila

                # checando se o elemento removido eh o elemento sentinela
                beq $t3, $a3, vis_next_level
                # $t0 recebe endereco do noh checado (que estava armazenado na estrutura da fila)
                lw $t0, 0($t3)
                # $t4 recebe o digito do noh checado
                lw $t4, 4($t3)
                # desalocando memoria da estrutura alocada pela fila
                li $v0, 9
                li $a0, -12
                syscall
                vis_next_level:
                    # desalocando memoria do sentinela
                    li $v0, 9
                    li $a0, -12
                    syscall

                    li $v0, 4 # imprimir string "\n"
                    la $a0, str_vis_nl
                    syscall

                    # checando se a fila esta vazia
                    add $a0, $t5, $zero
                    jal queue_empty
                    beqz $v0, menu # TERMINA A VISUALIZACAO DA ARVORE

                    # adiciona outro sentinela caso nao tenha acabado a visualizacao
                    add $a0, $t5, $zero
                    li $a1, 0 # endereco null sera colocado nesta sentinela
                    li $a2, 0
                    jal enqueue
                    add $a3, $v0, $zero # $a3 recebe o novo sentinela

                    # incrementa o contador de nivel e imprime informacao do novo nivel
                    addi $t2, $t2, 1
                    li $v0, 4 # imprimir string "N"
                    la $a0, str_vis_n
                    syscall

                    li $v0, 1 #imprimir nivel da arvore
                    add $a0, $t2, $zero
                    syscall

                    li $v0, 4 # imprimir string " "
                    la $a0, str_vis_space
                    syscall

                    j vis_next_dequeue

        vis_print_node_info:
            # imprimindo informacoes do noh
            # "(0 ou 1, NT, &esq, &dir) "

            li $v0, 4 # imprimir string "("
            la $a0, str_vis_p1
            syscall

            # imprimir string "0" ou "1"
            bnez $t4, vis_print_one

            vis_print_zero:
                li $v0, 1
                li $a0, 0
                syscall
                j vis_print_continue

            vis_print_one:
                li $v0, 1
                li $a0, 1
                syscall

        vis_print_continue:
            # imprimir string ", NT" ou ", T"
            lw $t1, 8($t0)
            bnez $t1, vis_print_T

            vis_print_NT:
                li $v0, 4
                la $a0, str_vis_nt
                syscall
                j vis_check_left
            vis_print_T:
                li $v0, 4
                la $a0, str_vis_t
                syscall
                j vis_check_left

    # Funções auxiliares

    # +--------------+
    # |    FILA      |
    # +--------------+
    #
    # ESTRUTURA DE DADOS
    # +---------------------+--------------+---------+
    # |      Atributo       | Tipo de Dado | Tamanho |
    # +---------------------+--------------+---------+
    # | Nó da Árvore        | Ponteiro     | 4 bytes |
    # | Digito obtido       | Inteiro      | 4 bytes |
    # | Elemento antecessor | Ponteiro     | 4 bytes |
    # +---------------------+--------------+---------+
    #
    # $a0 tera o endereco do primeiro elemento da fila
    # a fila estara vazia quando $a0 = null

    # $a0 tem o primeiro elemento da fila
    # $v0 ira retornar o valor 0 caso a fila esteja vazia
    # $v0 ira retornar o endereco da primeira estrutura alocada na fila caso contrario
    queue_empty:
        add $v0, $a0, $zero
        jr $ra

    # $a0 tem o primeiro elemento da fila
    # $a1 tem o endereco do noh a ser armazenado
    # $a2 tem o valor do digito daquele noh
    # $v0 ira retornar o endereco da cabeça da fila
    enqueue:
        # aloca memoria para um novo noh
        add $t6, $a0, $zero # salvando primeiro elemento da fila em $t6

        li $v0, 9 # alocando memoria para um novo elemento na fila
        li $a0, 12
        syscall
        # adicionando informacoes na nova estrutura
        sw $a1, 0($v0)
        sw $a2, 4($v0)
        sw $zero, 8($v0)

        # percorrendo a fila ate o ultimo noh
        # adicionando a referencia para o novo noh alocado
        beqz $t6, enqueue_empty    # fila vazia
        add $a0, $t6, $zero # $a0 recebe o endereco da cabeca da fila

        enqueue_loop:
            lw $t7, 8($a0) # endereco do antecessor deste elemento na fila
            beqz $t7, enqueue_end_loop # caso nao haja antecessor, insira elemento
            lw $a0, 8($a0) # vai para o proximo elemento da fila
            j enqueue_loop
        enqueue_end_loop:
            sw $v0, 8($a0)    # novo elemento inserido na fila
            add $v0, $t6, $zero # $v0 recebe a referencia para a cabeca da fila
        enqueue_empty:
            jr $ra # termina a insercao

    # $a0 tem o primeiro elemento da fila
    # $v0 ira retornar o endereco do elemento removido da fila, null caso a fila esteja vazia
    # $v1 ira retornar o endereco da nova cabeca da fila, null caso a fila esteja vazia
    # lembrar de desalocar 12 bytes da estrutura retornada em $v0, caso desejar
    dequeue:
        beqz $a0, dequeue_empty # fila vazia
        add $v0, $a0, $zero # $v0 recebe o elemento na cabeca da fila
        lw $v1 8($a0) # $v1 tem a referencia do proximo elemento
        jr $ra
        dequeue_empty:
            li $v0, 0
            li $v1, 0
            jr $ra

    # +--------------+
    # | CHECAR INPUT |
    # +--------------+
    check_input:
        # Percorrer string de entrada
        li $t1, 48 # 0 em ASCII
        li $t2, 49 # 1 em ASCII
        li $t3, 45 # - em ASCII
        li $t4, 10 # \n em ASCII
        la $a1, chave # carregar endereço de chave em $a1

        check_input_loop:
            # Carregar valor de endereço em a1 e colocar em $t0
            lb $t0, 0($a1)
            # Verificar se bit atual é 0, 1
            beq $t0, $t1, check_input_continue # checa se é 0
            beq $t0, $t2, check_input_continue # checa se é 1
            beq $t0, $t3, check_input_return1 # checa se é -
            beq $t0, $t4, check_input_pass # verifica se é '\n', se chegou no fim
            beq $t0, $zero, check_input_pass # verifica se eh '\0'
            # não é 0, 1, - ou final de string
            j check_input_error

        # é 0 ou 1, continua
        check_input_continue:
            # Ver se está na posição final da entrada
            lb $t0, 1($a1) # carrega proximo byte da string
            addi $a1, $a1, 1 # Andar para o próximo char
            j check_input_loop # reinicia check_input_loop

        # voltar ao menu (-1)
        # checando se o byte seguido do '-' equivale ao digito '1'
        check_input_return1:
            lb $t0 1($a1)
            beq $t0, $t2, check_input_return2
            j check_input_error

        # checando se a string acabou apos o "-1"
        check_input_return2:
            lb $t0 2($a1)
            # checando se eh '\n'
            beq $t0, $t4, check_input_return3
            # checando se eh '\0'
            beq $t0, $zero, check_input_return3
            j check_input_error

        check_input_return3:
            # Exibir string de retorno
            # Imprimir string
            li $v0, 4
            la $a0, str_return
            syscall
            j menu

        check_input_error:
            # exibir string de chave inválida
            li $v0, 4 # imprimir string
            la $a0, str_invalid
            syscall

            li $v0, -1 # -1 no retorno = erro
            jr $ra # retornar

        check_input_pass:
            #print string retorno
            li $v0, 4
            la $a0, str_return
            syscall

            li $v0, 1 # 1 no retorno = sucesso
            jr $ra

    # +------+
    # | SAIR |
    # +------+
    exit:
        li $v0, 4 # imprimir string
        la $a0, str_exit
        syscall

        li $v0, 10 # finalizar execução
        syscall

#  --- --- ---
# | 1 | 2 | 3 |
#  --- --- ---
# | 4 | 5 | 6 |
#  --- --- ---
# | 7 | 8 | 9 |
#  --- --- ---

#1 en la casilla para X
#-1 en la casilla para O

#.globl main

.data # Section where data is stored in memory (allocated in RAM), similar to
      # variables in higher level languages

	turnoJugador1: .asciiz "\nTurno jugador 1 (X)\n"
	turnoJugador2: .asciiz "\nTurno jugador 2 (O)\n"
	digitarPosicion: .asciiz "\nDigite posici�n:\n"
	finalizacion: .asciiz "\nJuego finalizado\n"
	posicionIncorrecta: .asciiz "\nPosici�n incorrecta. Vuelta a introducirla\n"
	simboloX: .asciiz "  X  "
	simboloO: .asciiz "  O  "
	vacio: .asciiz "     "
	barra: .asciiz "|"
	saltoLinea: .asciiz "\n"
	ganaPartidaJugador1: .asciiz "\nGana el jugador 1\n"
	ganaPartidaJugador2: .asciiz "\nGana el jugador 2\n"
	empate: .asciiz "\nEl juego ha terminado en empate\n"
	bienvenido: .asciiz "\nBienvenido\nDigite el n�mero de una de las siguientes opciones:\n"
	digiteNuevoJuegoJugadores: .asciiz "\n1. Nuevo juego para 2 jugadores\n"
	digiteNuevoJuegoMaquina: .asciiz "2. Nuevo juego para 1 jugador vs m�quina\n"
	digiteSalir: .asciiz "3. Salir\n"
	barrasHorizontales: .asciiz "-------------------"
	referenciaLinea1: .asciiz "|  1  |  2  |  3  |"
	referenciaLinea2: .asciiz "|  4  |  5  |  6  |"
	referenciaLinea3: .asciiz "|  7  |  8  |  9  |"
	espacio: .asciiz "            "
	turnoMaquina: .asciiz "Juega la m�quina\n"
	ganaMaquina: .asciiz "Gana la m�quina. �Ser� que alg�n d�a las m�quinas gobernar�n la Tierra?\n"

.text #c�digo de aqu� en adelante

main:
	jal imprimirMenuInicio #imprimir men� de inicio
	
	li $v0, 5 # system call code for Read Integer
	syscall # reads the value into $v0
	beq $v0, 1, nuevoJuegoJugadores # si el valor digitado es 1 arranca nuevo juego
	beq $v0, 2, nuevoJuegoContraMaquina # si el valor digitado es 1 arranca nuevo juego
	beq $v0, 3, fin # si el valor digitado es 2 se termina la ejecuci�n
	
imprimirMenuInicio:
	la $a0 bienvenido # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	
	la $a0 digiteNuevoJuegoJugadores # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	
	la $a0 digiteNuevoJuegoMaquina # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	
	la $a0 digiteSalir # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	
	jr $ra #return a main
	
nuevoJuegoJugadores:

	li $s5, 0 #color negro en hexa
	jal limpiarJugadasGUI
	nop
	
	li $s5, 0xFFFFFF #color blanco en hexa
	jal imprimirTablaGUI
	nop
	
	li $s1, 1 # para saber si es entre humanos
	jal inicializarTabla
	jal imprimirTabla #imprimir tabla inicial
	
	li $v1,1 #asignar a v1 el valor de 1 para arrancar el ciclo siguiente
	b loopTurnos #lanzar los 9 turnos
	
nuevoJuegoContraMaquina:

	li $s5, 0 #color negro en hexa
	jal limpiarJugadasGUI
	nop
	
	li $s5, 0xFFFFFF #color blanco en hexa
	jal imprimirTablaGUI
	nop

	li $s1, 2 # para saber si es entre humano y m�quina
	jal inicializarTabla
	jal imprimirTabla #imprimir tabla inicial
	
	li $v1,1 #asignar a v1 el valor de 1 para arrancar el ciclo siguiente
	b loopTurnosContraMaquina #lanzar los 9 turnos
	
loopTurnosContraMaquina:    	
    	
    	#turno jugador 1
    	jal lanzarTurnoJugador1
    	jal imprimirTabla	
	jal validarTresEnLinea #validar si alguno gan�
	add $v1,$v1,1 #incrementar v1 en 1 (contador)
	
	bgt $v1,9,empateJugadores #cuando llega a 9 rompe el ciclo (hay empate)
	
	#turno m�quina
    	jal lanzarTurnoMaquina    	
	jal imprimirTabla	
	
	jal validarTresEnLinea #validar si alguno gan�
	add $v1,$v1,1 #incrementar v1 en 1 (contador)
	
	b loopTurnosContraMaquina #volver a ejecutar la funci�n
	
lanzarTurnoMaquina:

	#imprimir turno m�quina
	la $a0 turnoMaquina # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	
	b pedirPosicionMaquina
	
pedirPosicionMaquina:

	li $a2, 2 #asignar a a2 el valor de jugador 2
	li $a3, -1 #asignar a a3 valor de -1 para adicionar un O en la casilla
	
	#####################################################################
	
	beq $v1,2, revisarJugadaCentro #si es la segunda jugada(primera de la m�quina)
	
	#####################################################################
	
	beq $v1,4, revisarJugadaCentroYEsquina #si es la segunda jugada de la m�quina (4ta en total)
	
	beq $v1,6, revisarJugadaRiesgosa
	
	b jugadasAltaPrioridad

jugadasAltaPrioridad:
	################################################
	#jugadas de alta prioridad
	
	#primero ver si se puede ganar
	
	li $t0, 0 # asignar valor de 0 a t1
	# validar | 1 | 2 | 3 |
	add $t0,$t1,$t2 #sumar
	add $t0,$t0,$t3 #sumar
	beq $t0, -2, hacerJugadaMaquinaFila1AltaPrioridad # puede ganar la m�quina
	
	li $t0, 0 # asignar valor de 0 a t1
	# validar | 4 | 5 | 6 |
	add $t0,$t4,$t5 #sumar
	add $t0,$t0,$t6 #sumar
	beq $t0, -2, hacerJugadaMaquinaFila2AltaPrioridad # puede ganar la m�quina
	
	li $t0, 0 # asignar valor de 0 a t1
	# validar | 7 | 8 | 9 |
	add $t0,$t7,$t8 #sumar
	add $t0,$t0,$t9 #sumar
	beq $t0, -2, hacerJugadaMaquinaFila3AltaPrioridad # puede ganar la m�quina
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 1 | 
	# | 4 |
	# | 7 | 
	add $t0,$t1,$t4 #sumar
	add $t0,$t0,$t7 #sumar
	beq $t0, -2, hacerJugadaMaquinaColumna1AltaPrioridad # puede ganar la m�quina
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 2 |
	# | 5 |
	# | 8 |
	add $t0,$t2,$t5 #sumar
	add $t0,$t0,$t8 #sumar
	beq $t0, -2, hacerJugadaMaquinaColumna2AltaPrioridad # puede ganar la m�quina
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 3 |
	# | 6 |
	# | 9 |
	add $t0,$t3,$t6 #sumar
	add $t0,$t0,$t9 #sumar
	beq $t0, -2, hacerJugadaMaquinaColumna3AltaPrioridad # puede ganar la m�quina
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	add $t0,$t1,$t5 #sumar
	add $t0,$t0,$t9 #sumar
	beq $t0, -2, hacerJugadaMaquinaTranversal1AltaPrioridad # puede ganar la m�quina
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   |
	add $t0,$t7,$t5 #sumar
	add $t0,$t0,$t3 #sumar
	beq $t0, -2, hacerJugadaMaquinaTranversal2AltaPrioridad # puede ganar la m�quina
	
	###################
	#evitar que gane el humano

	li $t0, 0 # asignar valor de 0 a t1
	# validar | 1 | 2 | 3 |
	add $t0,$t1,$t2 #sumar
	add $t0,$t0,$t3 #sumar
	beq $t0, 2, hacerJugadaMaquinaFila1AltaPrioridad # va a ganar el humano
	
	li $t0, 0 # asignar valor de 0 a t1
	# validar | 4 | 5 | 6 |
	add $t0,$t4,$t5 #sumar
	add $t0,$t0,$t6 #sumar
	beq $t0, 2, hacerJugadaMaquinaFila2AltaPrioridad # va a ganar el humano
	
	li $t0, 0 # asignar valor de 0 a t1
	# validar | 7 | 8 | 9 |
	add $t0,$t7,$t8 #sumar
	add $t0,$t0,$t9 #sumar
	beq $t0, 2, hacerJugadaMaquinaFila3AltaPrioridad # va a ganar el humano
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 1 | 
	# | 4 |
	# | 7 | 
	add $t0,$t1,$t4 #sumar
	add $t0,$t0,$t7 #sumar
	beq $t0, 2, hacerJugadaMaquinaColumna1AltaPrioridad # va a ganar el humano
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 2 |
	# | 5 |
	# | 8 |
	add $t0,$t2,$t5 #sumar
	add $t0,$t0,$t8 #sumar
	beq $t0, 2, hacerJugadaMaquinaColumna2AltaPrioridad # va a ganar el humano
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 3 |
	# | 6 |
	# | 9 |
	add $t0,$t3,$t6 #sumar
	add $t0,$t0,$t9 #sumar
	beq $t0, 2, hacerJugadaMaquinaColumna3AltaPrioridad # va a ganar el humano
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	add $t0,$t1,$t5 #sumar
	add $t0,$t0,$t9 #sumar
	beq $t0, 2, hacerJugadaMaquinaTranversal1AltaPrioridad # va a ganar el humano
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   |
	add $t0,$t7,$t5 #sumar
	add $t0,$t0,$t3 #sumar
	beq $t0, 2, hacerJugadaMaquinaTranversal2AltaPrioridad # va a ganar el humano
	
	b jugadaMediaPrioridadFila1

######################################################
#jugadas de media prioridad
#si se tiene una marca en una posible l�nea para alguna opci�n entonces marcar la segunda
#s�lo si la l�nea sirve para ganar, es decir, si no hay marca del humano en esa l�nea

jugadaMediaPrioridadFila1:
	#revisar si la 1ra fila est� ocupada
	
	# validar | 1 | 2 | 3 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	
	jal validarPosicion1Ocupada
	jal validarPosicion2Ocupada
	jal validarPosicion3Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 1, hacerJugadaMaquinaFila1MediaPrioridad
	
	b jugadaMediaPrioridadFila2
	
jugadaMediaPrioridadFila2:
	
	# validar | 4 | 5 | 6 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion4Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion6Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila	
	
	beq $s2, 1, hacerJugadaMaquinaFila2MediaPrioridad #si la l�nea s�lo tiene 1 marca
	
	b jugadaMediaPrioridadFila3
	
jugadaMediaPrioridadFila3:
	
	# validar | 7 | 8 | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion7Ocupada
	jal validarPosicion8Ocupada
	jal validarPosicion9Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 1, hacerJugadaMaquinaFila3MediaPrioridad #si la l�nea s�lo tiene 1 marca
	
	b jugadaMediaPrioridadColumna1
	
jugadaMediaPrioridadColumna1:	
	#validar
	# | 1 | 
	# | 4 |
	# | 7 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion1Ocupada
	jal validarPosicion4Ocupada
	jal validarPosicion7Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 1, hacerJugadaMaquinaColumna1MediaPrioridad #si la l�nea s�lo tiene 1 marca
	
	b jugadaMediaPrioridadColumna2

jugadaMediaPrioridadColumna2:
	#validar
	# | 2 |
	# | 5 |
	# | 8 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion2Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion8Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 1, hacerJugadaMaquinaColumna2MediaPrioridad #si la l�nea s�lo tiene 1 marca
	
	b jugadaMediaPrioridadColumna3
	
jugadaMediaPrioridadColumna3:
	
	#validar
	# | 3 |
	# | 6 |
	# | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion3Ocupada
	jal validarPosicion6Ocupada
	jal validarPosicion9Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 1, hacerJugadaMaquinaColumna3MediaPrioridad #si la l�nea s�lo tiene 1 marca
	
	b jugadaMediaPrioridadTransversal1
	
jugadaMediaPrioridadTransversal1:	
	#validar
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion1Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion9Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 1, hacerJugadaMaquinaTranversal1MediaPrioridad #si la l�nea s�lo tiene 1 marca
	
	b jugadaMediaPrioridadTransversal2

jugadaMediaPrioridadTransversal2:
	#validar
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   | 
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion7Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion3Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 1, hacerJugadaMaquinaTranversal2MediaPrioridad #si la l�nea s�lo tiene 1 marca
	
	b irPorLineaEnCeros

irPorLineaEnCeros:

	#####################################################################
	#si alguna l�nea est� en ceros entonces iniciarla
	
	# validar | 1 | 2 | 3 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion1Ocupada
	jal validarPosicion2Ocupada
	jal validarPosicion3Ocupada
	jal generarAleatorioLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 0, hacerJugadaLineaCeroFila1 #no hay marcas en la l�nea
	
	# validar | 4 | 5 | 6 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion4Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion6Ocupada
	jal generarAleatorioLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 0, hacerJugadaLineaCeroFila2
	
	# validar | 7 | 8 | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion7Ocupada
	jal validarPosicion8Ocupada
	jal validarPosicion9Ocupada
	jal generarAleatorioLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 0, hacerJugadaLineaCeroFila3
	
	#validar
	# | 1 | 
	# | 4 |
	# | 7 | 
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion1Ocupada
	jal validarPosicion4Ocupada
	jal validarPosicion7Ocupada
	jal generarAleatorioLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 0, hacerJugadaLineaCeroColumna1
	
	#validar
	# | 2 |
	# | 5 |
	# | 8 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion2Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion8Ocupada
	jal generarAleatorioLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 0, hacerJugadaLineaCeroColumna2
	
	#validar
	# | 3 |
	# | 6 |
	# | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion3Ocupada
	jal validarPosicion6Ocupada
	jal validarPosicion9Ocupada
	jal generarAleatorioLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 0, hacerJugadaLineaCeroColumna3

	#validar
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion1Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion9Ocupada
	jal generarAleatorioLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 0, hacerJugadaLineaCeroTransversal1
	
	#validar
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion7Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion3Ocupada
	jal generarAleatorioLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $s2, 0, hacerJugadaLineaCeroTransversal2
	
	#####################################################################
	
	#bge $v1,3, hacerUnaJugada #si # de jugada es >= 3
	
	b jugadasBajaPrioridad
	
jugadasBajaPrioridad:
	# validar | 1 | 2 | 3 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	
	jal validarPosicion1Ocupada
	jal validarPosicion2Ocupada
	jal validarPosicion3Ocupada
		
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	blt $s2, 3, hacerJugadaMaquinaFila1BajaPrioridad #si la l�nea s�lo tiene 1 marca
	
	# validar | 4 | 5 | 6 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion4Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion6Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	blt $s2, 3, hacerJugadaMaquinaFila2BajaPrioridad #si la l�nea s�lo tiene 1 marca
	
	# validar | 7 | 8 | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2	
	
	jal validarPosicion7Ocupada	
	jal validarPosicion8Ocupada
	jal validarPosicion9Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	blt $s2, 3, hacerJugadaMaquinaFila3BajaPrioridad #si la l�nea s�lo tiene 1 marca
	
	#validar
	# | 1 | 
	# | 4 |
	# | 7 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion1Ocupada
	jal validarPosicion4Ocupada
	jal validarPosicion7Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	blt $s2, 3, hacerJugadaMaquinaColumna1BajaPrioridad #si la l�nea s�lo tiene 1 marca 
	
	#validar
	# | 2 |
	# | 5 |
	# | 8 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion2Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion8Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila

	blt $s2, 3, hacerJugadaMaquinaColumna2BajaPrioridad #si la l�nea s�lo tiene 1 marca
	
	#validar
	# | 3 |
	# | 6 |
	# | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion3Ocupada
	jal validarPosicion6Ocupada
	jal validarPosicion9Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	blt $s2, 3, hacerJugadaMaquinaColumna3BajaPrioridad #si la l�nea s�lo tiene 1 marca
	
	#validar
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion1Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion9Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	blt $s2, 3, hacerJugadaMaquinaTranversal1BajaPrioridad #si la l�nea s�lo tiene 1 marca
	
	#validar
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   | 
	
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	li $s2, 0 # asignar valor de 0 a s2
	jal validarPosicion7Ocupada
	jal validarPosicion5Ocupada
	jal validarPosicion3Ocupada
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	blt $s2, 3, hacerJugadaMaquinaTranversal2BajaPrioridad #si la l�nea s�lo tiene 1 marca	
	
revisarJugadaCentro:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de las esquinas
	add $t0,$t1,$t3 #sumar
	add $t0,$t0,$t7 #sumar
	add $t0,$t0,$t9 #sumar
	beq $t0, 1, _adicionarSimbolo5 #si el humano marca en una esquina entonces marcar en centro
	
	beq $t5, 1, generarAleatorioEsquinas #si marc� en el centro del tablero marcar en una esquina
	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de los centros en periferia
	add $t0,$t2,$t4 #sumar
	add $t0,$t0,$t8 #sumar
	add $t0,$t0,$t6 #sumar
	beq $t0, 1, lanzarAleatorioEsquinaAdyacente #sino
	
	beq $t0, 0, irPorLineaEnCeros #sino
	
lanzarAleatorioEsquinaAdyacente:
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	jal generarAleatorioEsquinaAdyacente
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	
	beq $t4, 1, aleatorioEsquinaAdyacente1
	beq $t8, 1, aleatorioEsquinaAdyacente2
	beq $t6, 1, aleatorioEsquinaAdyacente3
	beq $t2, 1, aleatorioEsquinaAdyacente4
	
aleatorioEsquinaAdyacente1:
	beq $s5, 0, _adicionarSimbolo1
	beq $s5, 1, _adicionarSimbolo7
	beq $s5, 2, _adicionarSimbolo1
	beq $s5, 3, _adicionarSimbolo7
	
aleatorioEsquinaAdyacente2:
	beq $s5, 0, _adicionarSimbolo7
	beq $s5, 1, _adicionarSimbolo9
	beq $s5, 2, _adicionarSimbolo7
	beq $s5, 3, _adicionarSimbolo9
	
aleatorioEsquinaAdyacente3:
	beq $s5, 0, _adicionarSimbolo3
	beq $s5, 1, _adicionarSimbolo9
	beq $s5, 2, _adicionarSimbolo3
	beq $s5, 3, _adicionarSimbolo9
	
aleatorioEsquinaAdyacente4:
	beq $s5, 0, _adicionarSimbolo1
	beq $s5, 1, _adicionarSimbolo3
	beq $s5, 2, _adicionarSimbolo1
	beq $s5, 3, _adicionarSimbolo3
	
generarAleatorioEsquinaAdyacente:
	li $v0, 42  # 42 is system call code to generate random int
	li $a1, 3 # $a1 is where you set the upper bound
	syscall     # your generated number will be at $a0
	move $s5, $a0
	jr $ra
	
generarAleatorioLinea:
	li $v0, 42  # 42 is system call code to generate random int
	li $a1, 2 # $a1 is where you set the upper bound
	syscall     # your generated number will be at $a0
	move $s5, $a0
	jr $ra
	
generarAleatorioEsquinas:
	li $v0, 42  # 42 is system call code to generate random int
	li $a1, 3 # $a1 is where you set the upper bound
	syscall     # your generated number will be at $a0
	beq $a0, 0, generarAleatorioEsquinas
	move $s5, $a0
	b lanzarAleatorioEsquinas
	
lanzarAleatorioEsquinas:
	beq $s5, 0, _adicionarSimbolo1
	beq $s5, 1, _adicionarSimbolo3
	beq $s5, 2, _adicionarSimbolo7
	beq $s5, 3, _adicionarSimbolo9
	#li $v0, 1   # 1 is the system call code to show an int number
	#syscall     # as I said your generated number is at $a0, so it will be printed

evitarJugadaCentroPeriferiayEsquina:
	beq $t1, -1, evitarJugadaCentroPeriferiayEsquina1 #esquina 1
	beq $t7, -1, evitarJugadaCentroPeriferiayEsquina2 #esquina 2
	beq $t9, -1, evitarJugadaCentroPeriferiayEsquina3 #esquina 3
	beq $t3, -1, evitarJugadaCentroPeriferiayEsquina4 #esquina 4
	
	b revisarJugadaDosCentrosPeriferia

evitarJugadaCentroPeriferiayEsquina1:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de fila 1
	add $t0,$t1,$t2 #sumar
	add $t0,$t0,$t3 #sumar
	
	beq $t0, -1, _adicionarSimbolo3
	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de columna 1
	add $t0,$t1,$t4 #sumar
	add $t0,$t0,$t7 #sumar
	
	beq $t0, -1, _adicionarSimbolo7
	
	b _adicionarSimbolo5
	
evitarJugadaCentroPeriferiayEsquina2:
	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de fila 3
	add $t0,$t7,$t8 #sumar
	add $t0,$t0,$t9 #sumar
	
	beq $t0, -1, _adicionarSimbolo9
	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de columna 1
	add $t0,$t1,$t4 #sumar
	add $t0,$t0,$t7 #sumar
	
	beq $t0, -1, _adicionarSimbolo1
	
	b _adicionarSimbolo5
	
evitarJugadaCentroPeriferiayEsquina3:
	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de fila 3
	add $t0,$t7,$t8 #sumar
	add $t0,$t0,$t9 #sumar
	
	beq $t0, -1, _adicionarSimbolo7
	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de columna 3
	add $t0,$t3,$t6 #sumar
	add $t0,$t0,$t9 #sumar
	
	beq $t0, -1, _adicionarSimbolo3
	
	b _adicionarSimbolo5
	
evitarJugadaCentroPeriferiayEsquina4:
	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de fila 1
	add $t0,$t1,$t2 #sumar
	add $t0,$t0,$t3 #sumar
	
	beq $t0, -1, _adicionarSimbolo1
	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valor de columna 3
	add $t0,$t3,$t6 #sumar
	add $t0,$t0,$t9 #sumar
	
	beq $t0, -1, _adicionarSimbolo9
	
	b _adicionarSimbolo5
	
revisarJugadaPeligrosaCentroTablaYEsquina1:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t9 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina1
	
	b revisarJugadaCentroPeriferiayEsquina
	
revisarJugadaPeligrosaCentroTablaYEsquina2:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t3 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina2
	
	b revisarJugadaCentroPeriferiayEsquina
	
revisarJugadaPeligrosaCentroTablaYEsquina3:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t1 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina3
	
	b revisarJugadaCentroPeriferiayEsquina
	
revisarJugadaPeligrosaCentroTablaYEsquina4:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t7 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina4
	
	b revisarJugadaCentroPeriferiayEsquina

revisarJugadaCentroYEsquina:
	#revisar las dos diagonales
	
	beq $t1, -1, revisarJugadaPeligrosaCentroTablaYEsquina1	#esquina 1	
	beq $t7, -1, revisarJugadaPeligrosaCentroTablaYEsquina2 #esquina 2
	beq $t9, -1, revisarJugadaPeligrosaCentroTablaYEsquina3 #esquina 3
	beq $t3, -1, revisarJugadaPeligrosaCentroTablaYEsquina4 #esquina 4
	
	b revisarJugadaCentroPeriferiayEsquina
	
revisarJugadaCentroPeriferiayEsquina:	
	#si humano jug� en una en centro en periferia y otra en una esquina contraria

	#2 en centro y 9 en esquina	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t2,$t9 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#2 en centro y 7 en esquina	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t2,$t7 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#4 en centro y 3 en esquina	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t4,$t3 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#4 en centro y 9 en esquina	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t4,$t9 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#8 en centro y 1 en esquina	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t8,$t1 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#8 en centro y 3 en esquina	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t8,$t3 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#6 en centro y 1 en esquina	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t6,$t1 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#6 en centro y 7 en esquina	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t6,$t7 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	b revisarJugadaDosCentrosPeriferia
	
revisarJugadaDosCentrosPeriferia:
	#si humano jug� en dos centros en periferia
	
	#2 en centro y 4 en centro	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t2,$t4 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#2 en centro y 6 en centro	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t2,$t6 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#4 en centro y 2 en centro	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t4,$t2 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#4 en centro y 8 en centro	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t4,$t8 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#8 en centro y 4 en centro	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t8,$t4 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#8 en centro y 6 en centro	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t8,$t6 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#6 en centro y 2 en centro	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t6,$t2 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina
	
	#6 en centro y 8 en centro	
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t6,$t8 #sumar
	beq $t0, 2, evitarJugadaCentroPeriferiayEsquina

	b jugadasAltaPrioridad
	
revisarJugadaRiesgosa:

	#caso 1
	
	#  --- --- ---
	# | A |   | X |
	#  --- --- ---
	# | X | O | O |
	#  --- --- ---
	# |   | X |   |
	#  --- --- ---
		
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t8,$t3 #sumar
	add $t0,$t0,$t4 #sumar
	beq $t0, 3, evitarJugadaRiesgosa1
	
	#caso 2
	
	#  --- --- ---
	# | X |   | A |
	#  --- --- ---
	# | O | O | X |
	#  --- --- ---
	# |   | X |   |
	#  --- --- ---
		
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t8,$t1 #sumar
	add $t0,$t0,$t6 #sumar
	beq $t0, 3, evitarJugadaRiesgosa2
	
	#caso 3
	
	#  --- --- ---
	# |   | O | X |
	#  --- --- ---
	# | X | O |   |
	#  --- --- ---
	# |   | X | A |
	#  --- --- ---
		
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t4,$t3 #sumar
	add $t0,$t0,$t8 #sumar
	beq $t0, 3, evitarJugadaRiesgosa3
	
	#caso 4
	
	#  --- --- ---
	# |   | X | A |
	#  --- --- ---
	# | X | O |   |
	#  --- --- ---
	# |   | O | X |
	#  --- --- ---
		
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t4,$t9 #sumar
	add $t0,$t0,$t2 #sumar
	beq $t0, 3, evitarJugadaRiesgosa4
	
	#caso 5
	
	#  --- --- ---
	# |   | X |   |
	#  --- --- ---
	# | O | O | X |
	#  --- --- ---
	# | X |   | A |
	#  --- --- ---
		
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t2,$t7 #sumar
	add $t0,$t0,$t6 #sumar
	beq $t0, 3, evitarJugadaRiesgosa5
	
	#caso 6
	
	#  --- --- ---
	# |   | X |   |
	#  --- --- ---
	# | X | O | O |
	#  --- --- ---
	# | A |   | X |
	#  --- --- ---
		
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t2,$t9 #sumar
	add $t0,$t0,$t4 #sumar
	beq $t0, 3, evitarJugadaRiesgosa6
	
	#caso 7
	
	#  --- --- ---
	# | X | O |   |
	#  --- --- ---
	# |   | O | X |
	#  --- --- ---
	# | A | X |   |
	#  --- --- ---
		
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t8,$t1 #sumar
	add $t0,$t0,$t6 #sumar
	beq $t0, 3, evitarJugadaRiesgosa7
	
	#caso 8
	
	#  --- --- ---
	# | A | X |   |
	#  --- --- ---
	# |   | O | X |
	#  --- --- ---
	# | X | O |   |
	#  --- --- ---
		
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t6,$t7 #sumar
	add $t0,$t0,$t2 #sumar
	beq $t0, 3, evitarJugadaRiesgosa8

	b jugadasAltaPrioridad
	
evitarJugadaRiesgosa1:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t6 #sumar
	beq $t0, -2, _adicionarSimbolo1
	
	b jugadasAltaPrioridad
	
evitarJugadaRiesgosa2:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t4,$t5 #sumar
	beq $t0, -2, _adicionarSimbolo3
	
	b jugadasAltaPrioridad
	
evitarJugadaRiesgosa3:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t2,$t5 #sumar
	beq $t0, -2, _adicionarSimbolo9
	
	b jugadasAltaPrioridad
	
evitarJugadaRiesgosa4:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t8 #sumar
	beq $t0, -2, _adicionarSimbolo3
	
	b jugadasAltaPrioridad
	
evitarJugadaRiesgosa5:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t4,$t5 #sumar
	beq $t0, -2, _adicionarSimbolo9
	
	b jugadasAltaPrioridad
	
evitarJugadaRiesgosa6:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t6 #sumar
	beq $t0, -2, _adicionarSimbolo7
	
	b jugadasAltaPrioridad
	
evitarJugadaRiesgosa7:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t2 #sumar
	beq $t0, -2, _adicionarSimbolo7
	
	b jugadasAltaPrioridad
	
evitarJugadaRiesgosa8:
	li $t0, 0 # asignar valor de 0 a t0
	# sumar valores
	add $t0,$t5,$t8 #sumar
	beq $t0, -2, _adicionarSimbolo1
	
	b jugadasAltaPrioridad
	
validarPosicion1Ocupada: 
	bnez $t1, _sumarOcupados #si es !=0 entonces sumar a ocupados
	jr $ra #regresar a pedirPosicionMaquina	
validarPosicion2Ocupada: 
	bnez $t2, _sumarOcupados #si es !=0 entonces sumar a ocupados
	jr $ra #regresar a pedirPosicionMaquina	
validarPosicion3Ocupada: 
	bnez $t3, _sumarOcupados #si es !=0 entonces sumar a ocupados
	jr $ra #regresar a pedirPosicionMaquina	
validarPosicion4Ocupada: 
	bnez $t4, _sumarOcupados #si es !=0 entonces sumar a ocupados
	jr $ra #regresar a pedirPosicionMaquina	
validarPosicion5Ocupada: 
	bnez $t5, _sumarOcupados #si es !=0 entonces sumar a ocupados
	jr $ra #regresar a pedirPosicionMaquina	
validarPosicion6Ocupada: 
	bnez $t6, _sumarOcupados #si es !=0 entonces sumar a ocupados
	jr $ra #regresar a pedirPosicionMaquina	
validarPosicion7Ocupada: 
	bnez $t7, _sumarOcupados #si es !=0 entonces sumar a ocupados
	jr $ra #regresar a pedirPosicionMaquina	
validarPosicion8Ocupada: 
	bnez $t8, _sumarOcupados #si es !=0 entonces sumar a ocupados
	jr $ra #regresar a pedirPosicionMaquina	
validarPosicion9Ocupada:
	bnez $t9, _sumarOcupados #si es !=0 entonces sumar a ocupados	
	jr $ra #regresar a pedirPosicionMaquina
_sumarOcupados:
	add $s2,$s2,1 #sumar uno
	jr $ra #regresar a pedirPosicionMaquina
	
hacerJugadaMaquinaFila1AltaPrioridad:
	# | 1 | 2 | 3 |
	beq $t1, 0, _adicionarSimbolo1
	beq $t2, 0, _adicionarSimbolo2
	beq $t3, 0, _adicionarSimbolo3

hacerJugadaMaquinaFila2AltaPrioridad:
	# | 4 | 5 | 6 |
	beq $t4, 0, _adicionarSimbolo4
	beq $t5, 0, _adicionarSimbolo5
	beq $t6, 0, _adicionarSimbolo6
	
hacerJugadaMaquinaFila3AltaPrioridad:
	# | 7 | 8 | 9 |
	beq $t7, 0, _adicionarSimbolo7
	beq $t8, 0, _adicionarSimbolo8
	beq $t9, 0, _adicionarSimbolo9
	
hacerJugadaMaquinaColumna1AltaPrioridad:
	# | 1 | 
	# | 4 |
	# | 7 | 
	beq $t1, 0, _adicionarSimbolo1
	beq $t4, 0, _adicionarSimbolo4
	beq $t7, 0, _adicionarSimbolo7

hacerJugadaMaquinaColumna2AltaPrioridad:
	# | 2 |
	# | 5 |
	# | 8 |
	beq $t2, 0, _adicionarSimbolo2
	beq $t5, 0, _adicionarSimbolo5
	beq $t8, 0, _adicionarSimbolo8
	
hacerJugadaMaquinaColumna3AltaPrioridad:
	# | 3 |
	# | 6 |
	# | 9 |
	beq $t3, 0, _adicionarSimbolo3
	beq $t6, 0, _adicionarSimbolo6
	beq $t9, 0, _adicionarSimbolo9
	
hacerJugadaMaquinaTranversal1AltaPrioridad:
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	beq $t1, 0, _adicionarSimbolo1
	beq $t5, 0, _adicionarSimbolo5
	beq $t9, 0, _adicionarSimbolo9
	
hacerJugadaMaquinaTranversal2AltaPrioridad:
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   |
	beq $t3, 0, _adicionarSimbolo3
	beq $t5, 0, _adicionarSimbolo5
	beq $t7, 0, _adicionarSimbolo7
	
	
hacerJugadaMaquinaFila1MediaPrioridad:
	# | 1 | 2 | 3 |	
	beq $t1, -1, _adicionarSimbolo2 #si la casilla 1 est� ocupada entonces ir por la 2
	beq $t2, -1, _adicionarSimbolo1 #si la casilla 2 est� ocupada entonces ir por la 1 o 3
	beq $t3, -1, _adicionarSimbolo2 #si la casilla 3 est� ocupada entonces ir por la 2
	
	b jugadaMediaPrioridadFila2

hacerJugadaMaquinaFila2MediaPrioridad:
	# | 4 | 5 | 6 |
	beq $t4, -1, _adicionarSimbolo5 #si la casilla 4 est� ocupada entonces ir por la 5
	beq $t5, -1, _adicionarSimbolo4 #si la casilla 5 est� ocupada entonces ir por la 4 o 6
	beq $t6, -1, _adicionarSimbolo5 #si la casilla 6 est� ocupada entonces ir por la 5
	
	b jugadaMediaPrioridadFila3
	
hacerJugadaMaquinaFila3MediaPrioridad:
	# | 7 | 8 | 9 |
	beq $t7, -1, _adicionarSimbolo8 #si la casilla 7 est� ocupada entonces ir por la 8
	beq $t8, -1, _adicionarSimbolo7 #si la casilla 8 est� ocupada entonces ir por la 7 o 9
	beq $t9, -1, _adicionarSimbolo8 #si la casilla 9 est� ocupada entonces ir por la 8
	
	b jugadaMediaPrioridadColumna1
	
hacerJugadaMaquinaColumna1MediaPrioridad:
	# | 1 | 
	# | 4 |
	# | 7 |
	beq $t1, -1, _adicionarSimbolo4 #si la casilla 1 est� ocupada entonces ir por la 4
	beq $t4, -1, _adicionarSimbolo7 #si la casilla 4 est� ocupada entonces ir por la 1 o 7
	beq $t7, -1, _adicionarSimbolo4 #si la casilla 7 est� ocupada entonces ir por la 4
	
	b jugadaMediaPrioridadColumna2
	
hacerJugadaMaquinaColumna2MediaPrioridad:
	# | 2 |
	# | 5 |
	# | 8 |
	beq $t2, -1, _adicionarSimbolo5 #si la casilla 2 est� ocupada entonces ir por la 5
	beq $t5, -1, _adicionarSimbolo2 #si la casilla 5 est� ocupada entonces ir por la 2 o 8
	beq $t8, -1, _adicionarSimbolo5 #si la casilla 8 est� ocupada entonces ir por la 5
	
	b jugadaMediaPrioridadColumna3

hacerJugadaMaquinaColumna3MediaPrioridad:
	# | 3 |
	# | 6 |
	# | 9 |
	beq $t3, -1, _adicionarSimbolo6 #si la casilla 3 est� ocupada entonces ir por la 6
	beq $t6, -1, _adicionarSimbolo3 #si la casilla 6 est� ocupada entonces ir por la 3 o 9
	beq $t9, -1, _adicionarSimbolo6 #si la casilla 9 est� ocupada entonces ir por la 6
	
	b jugadaMediaPrioridadTransversal1
	
hacerJugadaMaquinaTranversal1MediaPrioridad:
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	beq $t1, -1, _adicionarSimbolo5 #si la casilla 1 est� ocupada entonces ir por la 5
	beq $t5, -1, _adicionarSimbolo1 #si la casilla 5 est� ocupada entonces ir por la 1 o 9
	beq $t9, -1, _adicionarSimbolo5 #si la casilla 9 est� ocupada entonces ir por la 5
	
	b jugadaMediaPrioridadTransversal2
	
hacerJugadaMaquinaTranversal2MediaPrioridad:
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   |
	beq $t7, -1, _adicionarSimbolo5 #si la casilla 7 est� ocupada entonces ir por la 5
	beq $t5, -1, _adicionarSimbolo7 #si la casilla 6 est� ocupada entonces ir por la 7 o 3
	beq $t3, -1, _adicionarSimbolo5 #si la casilla 3 est� ocupada entonces ir por la 5
	
	b irPorLineaEnCeros

hacerJugadaLineaCeroFila1:
	# | 1 | 2 | 3 |
	beq $s5, 0, _adicionarSimbolo1 #ir por la que est� desocupada
	beq $s5, 1, _adicionarSimbolo2 
	beq $s5, 2, _adicionarSimbolo3
	
hacerJugadaLineaCeroFila2:
	# | 4 | 5 | 6 |
	beq $s5, 0, _adicionarSimbolo4 #ir por la que est� desocupada
	beq $s5, 1, _adicionarSimbolo5 
	beq $s5, 2, _adicionarSimbolo6
	
hacerJugadaLineaCeroFila3:
	# | 7 | 8 | 9 |
	beq $s5, 0, _adicionarSimbolo7 #ir por la que est� desocupada
	beq $s5, 1, _adicionarSimbolo8 
	beq $s5, 2, _adicionarSimbolo9
	
hacerJugadaLineaCeroColumna1:
	# | 1 | 
	# | 4 |
	# | 7 |
	beq $s5, 0, _adicionarSimbolo1 #ir por la que est� desocupada
	beq $s5, 1, _adicionarSimbolo4 
	beq $s5, 2, _adicionarSimbolo7

hacerJugadaLineaCeroColumna2:
	# | 2 |
	# | 5 |
	# | 8 |
	beq $s5, 0, _adicionarSimbolo2 #ir por la que est� desocupada
	beq $s5, 1, _adicionarSimbolo5 
	beq $s5, 2, _adicionarSimbolo8
	
hacerJugadaLineaCeroColumna3:
	# | 3 |
	# | 6 |
	# | 9 |
	beq $s5, 0, _adicionarSimbolo3 #ir por la que est� desocupada
	beq $s5, 1, _adicionarSimbolo6 
	beq $s5, 2, _adicionarSimbolo9
	
hacerJugadaLineaCeroTransversal1:
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	beq $s5, 0, _adicionarSimbolo1 #ir por la que est� desocupada
	beq $s5, 1, _adicionarSimbolo5 
	beq $s5, 2, _adicionarSimbolo9
	
hacerJugadaLineaCeroTransversal2:
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   |
	beq $s5, 0, _adicionarSimbolo7 #ir por la que est� desocupada
	beq $s5, 1, _adicionarSimbolo5 
	beq $s5, 2, _adicionarSimbolo3

hacerJugadaMaquinaFila1BajaPrioridad:
	# | 1 | 2 | 3 |
	beq $t1, 0, _adicionarSimbolo1 #ir por la que est� desocupada
	beq $t3, 0, _adicionarSimbolo3
	beq $t2, 0, _adicionarSimbolo2
	
hacerJugadaMaquinaFila2BajaPrioridad:
	# | 4 | 5 | 6 |
	beq $t4, 0, _adicionarSimbolo4
	beq $t6, 0, _adicionarSimbolo6
	beq $t5, 0, _adicionarSimbolo5
	
hacerJugadaMaquinaFila3BajaPrioridad:
	# | 7 | 8 | 9 |
	beq $t7, 0, _adicionarSimbolo7
	beq $t9, 0, _adicionarSimbolo9
	beq $t8, 0, _adicionarSimbolo8 
	
hacerJugadaMaquinaColumna1BajaPrioridad:
	# | 1 | 
	# | 4 |
	# | 7 |
	beq $t1, 0, _adicionarSimbolo1
	beq $t7, 0, _adicionarSimbolo7
	beq $t4, 0, _adicionarSimbolo4
	
hacerJugadaMaquinaColumna2BajaPrioridad:
	# | 2 |
	# | 5 |
	# | 8 |
	beq $t2, 0, _adicionarSimbolo2
	beq $t8, 0, _adicionarSimbolo8
	beq $t5, 0, _adicionarSimbolo5

hacerJugadaMaquinaColumna3BajaPrioridad:
	# | 3 |
	# | 6 |
	# | 9 |
	beq $t3, 0, _adicionarSimbolo3
	beq $t9, 0, _adicionarSimbolo9
	beq $t6, 0, _adicionarSimbolo6
	
hacerJugadaMaquinaTranversal1BajaPrioridad:
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	beq $t1, 0, _adicionarSimbolo1
	beq $t9, 0, _adicionarSimbolo9
	beq $t5, 0, _adicionarSimbolo5
	
hacerJugadaMaquinaTranversal2BajaPrioridad:
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   |
	beq $t7, 0, _adicionarSimbolo7
	beq $t3, 0, _adicionarSimbolo3
	beq $t5, 0, _adicionarSimbolo5
	
inicializarTabla:	
	li $t1, 0 # asignar valor a casilla 1 (t1)
	li $t2, 0 # asignar valor a casilla 2 (t2)
	li $t3, 0 # asignar valor a casilla 3 (t3)
	li $t4, 0 # asignar valor a casilla 4 (t4)
	li $t5, 0 # asignar valor a casilla 5 (t5)
	li $t6, 0 # asignar valor a casilla 6 (t6)
	li $t7, 0 # asignar valor a casilla 7 (t7)
	li $t8, 0 # asignar valor a casilla 8 (t8)
	li $t9, 0 # asignar valor a casilla 9 (t9)	
	jr $ra #return
	
lanzarTurnoJugador1:
	#turno 1
	
	#imprimir turno jugador 1
	la $a0 turnoJugador1 # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	
	b pedirPosicionJugador1	

lanzarTurnoJugador2:
	#turno 2
	
	#imprimir turno jugador 1
	la $a0 turnoJugador2 # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	
	b pedirPosicionJugador2
	
loopTurnos:    	    	
    	#turno jugador 1
    	jal lanzarTurnoJugador1
    	jal imprimirTabla	
	jal validarTresEnLinea #validar si alguno gan�
	add $v1,$v1,1 #incrementar v1 en 1 (contador)
	
	bgt $v1,9,empateJugadores #cuando llega a 9 rompe el ciclo (hay empate)
	
	#turno jugador 2
    	jal lanzarTurnoJugador2    	
	jal imprimirTabla	
	jal validarTresEnLinea #validar si alguno gan�
	add $v1,$v1,1 #incrementar v1 en 1 (contador)
	
	b loopTurnos #volver a ejecutar la funci�n

imprimirTabla:
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack
	
	jal imprimirSaltoLinea
	jal imprimirBarrasHorizontales
	
	#imprimir gu�a de tabla a la derecha
	jal imprimirEspacio
	jal imprimirBarrasHorizontales
	
	jal imprimirSaltoLinea
	jal imprimirBarra
	
	move $a1, $t1 #asignar a a1 el valor de casilla 1
	jal imprimirPos #imprimir posici�n 1
	jal imprimirBarra
	move $a1, $t2 #asignar a a1 el valor de casilla 2
	jal imprimirPos #imprimir posici�n 2
	jal imprimirBarra
	move $a1, $t3 #asignar a a1 el valor de casilla 3
	jal imprimirPos #imprimir posici�n 3
	jal imprimirBarra
	
	#imprimir gu�a de tabla a la derecha
	jal imprimirEspacio
	jal imprimirReferencia1	
	jal imprimirSaltoLinea
	jal imprimirBarrasHorizontales
	
	#imprimir gu�a de tabla a la derecha
	jal imprimirEspacio
	jal imprimirBarrasHorizontales
	
	jal imprimirSaltoLinea
	jal imprimirBarra
	move $a1, $t4 #asignar a a1 el valor de casilla 4
	jal imprimirPos #imprimir posici�n 4
	jal imprimirBarra
	move $a1, $t5 #asignar a a1 el valor de casilla 5
	jal imprimirPos #imprimir posici�n 5
	jal imprimirBarra
	move $a1, $t6 #asignar a a1 el valor de casilla 6
	jal imprimirPos #imprimir posici�n 6
	jal imprimirBarra
	
	#imprimir gu�a de tabla a la derecha
	jal imprimirEspacio
	jal imprimirReferencia2
	jal imprimirSaltoLinea
	jal imprimirBarrasHorizontales
	
	jal imprimirEspacio
	jal imprimirBarrasHorizontales
	
	jal imprimirSaltoLinea
	jal imprimirBarra
	move $a1, $t7 #asignar a a1 el valor de casilla 7
	jal imprimirPos #imprimir posici�n 7
	jal imprimirBarra
	move $a1, $t8 #asignar a a1 el valor de casilla 8
	jal imprimirPos #imprimir posici�n 8
	jal imprimirBarra
	move $a1, $t9 #asignar a a1 el valor de casilla 9
	jal imprimirPos #imprimir posici�n 9
	jal imprimirBarra
	
	#imprimir gu�a de tabla a la derecha
	jal imprimirEspacio
	jal imprimirReferencia3	
	jal imprimirSaltoLinea
	jal imprimirBarrasHorizontales
	
	jal imprimirEspacio
	jal imprimirBarrasHorizontales
	
	jal imprimirSaltoLinea
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	jr $ra #return
		
imprimirPos:	
	beq $a1, 1, imprimirX
	beq $a1, -1, imprimirO
	beq $a1, 0, imprimirVacio
	
imprimirEspacio:
	la $a0 espacio # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return
	
imprimirReferencia1:
	la $a0 referenciaLinea1 # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return
	
imprimirReferencia2:
	la $a0 referenciaLinea2 # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return
	
imprimirReferencia3:
	la $a0 referenciaLinea3 # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return

imprimirBarra:
	la $a0 barra # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return
	
imprimirSaltoLinea:
	la $a0 saltoLinea # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return
	
imprimirBarrasHorizontales:
	la $a0 barrasHorizontales # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return

imprimirO:
	la $a0 simboloO # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return

imprimirVacio:
	la $a0 vacio # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string	
	jr $ra #return

imprimirX:	
	la $a0 simboloX # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	jr $ra #return

pedirPosicionJugador1:
	li $a2, 1 #asignar a a2 el valor de jugador 1

	#pedir posici�n jugada jugador 1
	
	la $a0 digitarPosicion # load address of mensaje
	li $v0 4 # system call code for print_str
	#syscall # print the string

	li $v0, 5 # system call code for Read Integer
	syscall # reads the value into $v0
	
	bltz $v0, fin # si el valor es menor a cero se va a fin
	beqz $v0, fin # si el valor es igual a cero se va a fin
	bgt $v0, 9, rectificarPosicion # si el valor es mayor a 9
	
	li $a3, 1 #asignar a a3 valor de 1 para adicionar una X en la casilla
	
	beq $v0, 1, verificarCasilla1 # si es casilla 1
	beq $v0, 2, verificarCasilla2 # si es casilla 2
	beq $v0, 3, verificarCasilla3 # si es casilla 3
	beq $v0, 4, verificarCasilla4 # si es casilla 4
	beq $v0, 5, verificarCasilla5 # si es casilla 5
	beq $v0, 6, verificarCasilla6 # si es casilla 6
	beq $v0, 7, verificarCasilla7 # si es casilla 7
	beq $v0, 8, verificarCasilla8 # si es casilla 8
	beq $v0, 9, verificarCasilla9 # si es casilla 9
	
pedirPosicionJugador2:
	li $a2, 2 #asignar a a2 el valor de jugador 2

	#pedir posici�n jugada jugador 2

	la $a0 digitarPosicion # load address of mensaje
	li $v0 4 # system call code for print_str
	#syscall # print the string

	li $v0, 5 # system call code for Read Integer
	syscall # reads the value into $v0
	
	bltz $v0, fin # si el valor es menor a cero se va a fin
	beqz $v0, fin # si el valor es igual a cero
	bgt $v0, 9, rectificarPosicion # si el valor es mayor a 9
	
	li $a3, -1 #asignar a a3 valor de -1 para adicionar un O en la casilla
	
	beq $v0, 1, verificarCasilla1 # si es casilla 1
	beq $v0, 2, verificarCasilla2 # si es casilla 2
	beq $v0, 3, verificarCasilla3 # si es casilla 3
	beq $v0, 4, verificarCasilla4 # si es casilla 4
	beq $v0, 5, verificarCasilla5 # si es casilla 5
	beq $v0, 6, verificarCasilla6 # si es casilla 6
	beq $v0, 7, verificarCasilla7 # si es casilla 7
	beq $v0, 8, verificarCasilla8 # si es casilla 8
	beq $v0, 9, verificarCasilla9 # si es casilla 9
	
verificarCasilla1:
	beq $t1, 0, _adicionarSimbolo1 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo1:
	move $t1, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_uno
	beq $a3, -1, circulo_uno

verificarCasilla2:
	beq $t2, 0, _adicionarSimbolo2 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo2:
	move $t2, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_dos
	beq $a3, -1, circulo_dos

verificarCasilla3:
	beq $t3, 0, _adicionarSimbolo3 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo3:
	move $t3, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_tres
	beq $a3, -1, circulo_tres
	
verificarCasilla4:
	beq $t4, 0, _adicionarSimbolo4 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo4:
	move $t4, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_cuatro
	beq $a3, -1, circulo_cuatro
	
verificarCasilla5:	
	beq $t5, 0, _adicionarSimbolo5 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo5:
	move $t5, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_cinco
	beq $a3, -1, circulo_cinco
	
verificarCasilla6:
	beq $t6, 0, _adicionarSimbolo6 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo6:
	move $t6, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_seis
	beq $a3, -1, circulo_seis
	
verificarCasilla7:
	beq $t7, 0, _adicionarSimbolo7 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo7:
	move $t7, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_siete
	beq $a3, -1, circulo_siete
	
verificarCasilla8:
	beq $t8, 0, _adicionarSimbolo8 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo8:
	move $t8, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_ocho
	beq $a3, -1, circulo_ocho
	
verificarCasilla9:
	beq $t9, 0, _adicionarSimbolo9 # si la casilla est� en 0 (se puede adicionar)
	b rectificarPosicion
_adicionarSimbolo9:
	move $t9, $a3 #asignar a la casilla 1 el valor de jugador (1 o 2)
	li $s5, 0xFFFFFF
	beq $a3, 1, x_nueve
	beq $a3, -1, circulo_nueve
	
rectificarPosicion:
	la $a0 posicionIncorrecta # load address of msg8. into $a0
	li $v0 4 # system call code for print_str
	syscall # print the string
	beq $a2, 1, pedirPosicionJugador1 # si el valor es 1 corresponde a jugador 1
	beq $a2, 2, pedirPosicionJugador2 # si el valor es 1 corresponde a jugador 1
	
validarTresEnLinea:
	li $t0, 0 # asignar valor de 0 a t1
	# validar | 1 | 2 | 3 |
	add $t0,$t1,$t2 #sumar
	add $t0,$t0,$t3 #sumar
	li $v0, 1
	beq $t0, 3, ganaJugador1 # si la suma da 3 entonces gana jugador 1
	beq $t0, -3, ganaJugador2 # si la suma da 6 entonces gana jugador 2
	
	li $t0, 0 # asignar valor de 0 a t1
	# validar | 4 | 5 | 6 |
	add $t0,$t4,$t5 #sumar
	add $t0,$t0,$t6 #sumar
	li $v0, 2
	beq $t0, 3, ganaJugador1 # si la suma da 3 entonces gana jugador 1
	beq $t0, -3, ganaJugador2 # si la suma da 6 entonces gana jugador 2
	
	li $t0, 0 # asignar valor de 0 a t1
	# validar | 7 | 8 | 9 |
	add $t0,$t7,$t8 #sumar
	add $t0,$t0,$t9 #sumar
	li $v0, 3
	beq $t0, 3, ganaJugador1 # si la suma da 3 entonces gana jugador 1
	beq $t0, -3, ganaJugador2 # si la suma da 6 entonces gana jugador 2
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 1 | 
	# | 4 |
	# | 7 | 
	li $v0, 4
	add $t0,$t1,$t4 #sumar
	add $t0,$t0,$t7 #sumar
	beq $t0, 3, ganaJugador1 # si la suma da 3 entonces gana jugador 1
	beq $t0, -3, ganaJugador2 # si la suma da 6 entonces gana jugador 2
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 2 |
	# | 5 |
	# | 8 |
	add $t0,$t2,$t5 #sumar
	add $t0,$t0,$t8 #sumar
	li $v0, 5
	beq $t0, 3, ganaJugador1 # si la suma da 3 entonces gana jugador 1
	beq $t0, -3, ganaJugador2 # si la suma da 6 entonces gana jugador 2
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 3 |
	# | 6 |
	# | 9 |
	add $t0,$t3,$t6 #sumar
	add $t0,$t0,$t9 #sumar
	li $v0, 6
	beq $t0, 3, ganaJugador1 # si la suma da 3 entonces gana jugador 1
	beq $t0, -3, ganaJugador2 # si la suma da 6 entonces gana jugador 2
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# | 1 |   |   |
	# |   | 5 |   |
	# |   |   | 9 |
	add $t0,$t1,$t5 #sumar
	add $t0,$t0,$t9 #sumar
	li $v0, 7
	beq $t0, 3, ganaJugador1 # si la suma da 3 entonces gana jugador 1
	beq $t0, -3, ganaJugador2 # si la suma da 6 entonces gana jugador 2
	
	li $t0, 0 # asignar valor de 0 a t1
	#validar
	# |   |   | 3 |
	# |   | 5 |   |
	# | 7 |   |   |
	add $t0,$t7,$t5 #sumar
	add $t0,$t0,$t3 #sumar
	li $v0, 8
	beq $t0, 3, ganaJugador1 # si la suma da 3 entonces gana jugador 1
	beq $t0, -3, ganaJugador2 # si la suma da 6 entonces gana jugador 2
	
	jr $ra #retornar a ciclo de turnos
	
ganaJugador1:
	jal dibujarTriqui
	la $a0 ganaPartidaJugador1 # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	b main #retorna a main

ganaJugador2:
	jal dibujarTriqui
	nop
	beq $s1, 2, ganaOrdenador
	la $a0 ganaPartidaJugador2 # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	b main #retorna a main

ganaOrdenador:
	la $a0 ganaMaquina # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string	
	b main #retorna a main

empateJugadores:
	la $a0 empate # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	b main #retorna a main
	
dibujarTriqui:
	li $s5, 0xFFFFFF #color blanco en hexa
	beq $v0, 1, marcarTriquiFila1
	beq $v0, 2, marcarTriquiFila2
	beq $v0, 3, marcarTriquiFila3
	beq $v0, 4, marcarTriquiColumna1
	beq $v0, 5, marcarTriquiColumna2
	beq $v0, 6, marcarTriquiColumna3
	beq $v0, 7, marcarTriquiDiagonal1
	beq $v0, 8, marcarTriquiDiagonal2

fin:
	#imprimir adi�s
	la $a0 finalizacion # load address of mensaje
	li $v0 4 # system call code for print_str
	syscall # print the string
	
	#terminar ejecuci�n
	li $v0, 10 # terminate program run and
	syscall # return control to system

limpiarJugadasGUI:
	addi $sp, $sp, -4 #pedir espacio en pila
	sw $ra, 0($sp) #save return address to stack

	jal x_uno
	jal x_dos
	jal x_tres
	jal x_cuatro
	jal x_cinco
	jal x_seis
	jal x_siete
	jal x_ocho
	jal x_nueve
	jal circulo_uno
	jal circulo_dos
	jal circulo_tres
	jal circulo_cuatro
	jal circulo_cinco
	jal circulo_seis
	jal circulo_siete
	jal circulo_ocho
	jal circulo_nueve
	
	jal marcarTriquiFila1
	jal marcarTriquiFila2
	jal marcarTriquiFila3
	jal marcarTriquiColumna1
	jal marcarTriquiColumna2
	jal marcarTriquiColumna3
	jal marcarTriquiDiagonal1
	jal marcarTriquiDiagonal2
	
	lw $ra, 0($sp) #load return address
	addi $sp, $sp, 4  #realocar espacio en pila
	jr $ra #return
	
imprimirTablaGUI:
	
	lui $s0, 0x1001 #1er pixel arriba a la izquierda

	li $s3, 1024 #constante para saltar entre filas
	li $s4, 85 #contador para filas
	mult $s3, $s4 #multiplicaci�n entre 1024 con el # de fila
	mflo $s4 #traer resultado de la multiplicaci�n anterior a s4

	add $s0, $s0, $s4 #para correr verticalmente sumar a s0 
		#el resultado de multiplicaci�n anterior

	addi $s0, $s0, 0 #correr 56 pixeles a la derecha

	li $s6, 0 # contador
	
	pintarLineaHorizontal1:	
		sw $s5, 0($s0) #pintar el pixel del color definido	
		addi $s0, $s0, 4 #aumentar s0 en 4 bytes para ir a siguiente pixel a la derecha	
		addi $s6, $s6, 1 #incrementar en 1 el contador
		bne $s6, 256, pintarLineaHorizontal1
		nop
	
	#ir a posici�n para la segunda l�nea
	lui $s0, 0x1001
	li $s3, 1024
	li $s4, 170
	mult $s3, $s4
	mflo $s4
	#VERTICAL
	add $s0, $s0, $s4
	#Horizontal
	addi $s0, $s0, 0
	li $s6, 0
	
	pintarLineaHorizontal2:	
		sw $s5, 0($s0) #pintar el pixel del color definido	
		addi $s0, $s0, 4 #aumentar s0 en 4 bytes para ir a siguiente pixel a la derecha	
		addi $s6, $s6, 1 #incrementar en 1 el contador
		bne $s6, 256, pintarLineaHorizontal2
		nop
	
	# ahora pintar las l�neas verticales
	lui $s0, 0x1001
	li $s4, 0
	mult $s3, $s4
	mflo $s4
	#VERTICAL
	add $s0, $s0, $s4
	#HORIZONTAL
	addi $s0, $s0, 340
	li $s6, 0
	
	pintarLineaVertical1:
		addi $s0, $s0, 1024
		sw $s5, 0($s0)
		addi $s6, $s6, 1
		bne $s6, 256, pintarLineaVertical1
		nop
	
	lui $s0, 0x1001
	#HORIZONTAL
	addi $s0, $s0, 680
	li $s6, 0
	#vertical
	li $s4, 0
	mult $s3, $s4
	mflo $s4
	add $s0, $s0, $s4
	
	pintarLineaVertical2:
		addi $s0, $s0, 1024
		sw $s5, 0($s0)
		addi $s6, $s6, 1
		bne $s6, 256, pintarLineaVertical2
		nop
	
	jr $ra
	nop

x_uno:	
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 25
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	addi $s0, $s0, 116
	b pintarPrimeraLineaX
	nop
	
x_dos:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 25
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	addi $s0, $s0, 452	
	b pintarPrimeraLineaX
	nop	
x_tres:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 25
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	add $s0, $s0, 792
	b pintarPrimeraLineaX
	nop	
x_cuatro:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 108
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	add $s0, $s0, 116	
	b pintarPrimeraLineaX
	nop
x_cinco:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 108
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	add $s0, $s0, 452
	b pintarPrimeraLineaX
	nop
x_seis:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 108
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	add $s0, $s0, 792
	b pintarPrimeraLineaX
	nop	
x_siete:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 194
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	addi $s0, $s0, 116
	b pintarPrimeraLineaX
	nop
x_ocho:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 194
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	add $s0, $s0, 452
	b pintarPrimeraLineaX
	nop
x_nueve:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 194
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	add $s0, $s0, 792
	b pintarPrimeraLineaX
	nop
	
pintarPrimeraLineaX:
	addi $s0, $s0, 1024
	addi $s0, $s0, 4
	sw $s5, 0($s0)
	addi $s6, $s6, 1
	bne $s6, 30, pintarPrimeraLineaX
	nop
	subu $s0, $s0, 120
	ori $s6, $0, 0
pintarSegundaLineaX:
	sub $s0, $s0, 1024
	addi $s0, $s0, 4
	sw $s5, 0($s0)
	addi $s6, $s6, 1	
	bne $s6, 30, pintarSegundaLineaX
	nop
	jr $ra
	nop

circulo_uno:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 100
	#VERTICAL
	li $s7, 27
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop

circulo_dos:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 432
	#VERTICAL
	li $s7, 27
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop
circulo_tres:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 772
	#VERTICAL
	li $s7, 27
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop
circulo_cuatro:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 100
	#VERTICAL
	li $s7, 112
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop
circulo_cinco:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 432
	#VERTICAL
	li $s7, 112
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop
circulo_seis:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 772
	#VERTICAL	
	li $s7, 112
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop
circulo_siete:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 100
	#VERTICAL
	li $s7, 195
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop
circulo_ocho:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 432
	#VERTICAL
	li $s7, 195
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop
circulo_nueve:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#HORIZONTAL
	addi $s0, $s0, 772
	#VERTICAL
	li $s7, 195
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	b pintarCirculo
	nop
	
pintarCirculo:	
	segundaParte:
		addi $s0, $s0, 108
		addi $s0, $s0, 30720
		li $s6, 0
	segundaLineaH:
		sw $s5, 0($s0)
		subu $s0, $s0, 4
		addi $s6, $s6, 1
		bne $s6, 15, segundaLineaH
		nop
	terceraParte:
		ori $s6, $0, 0
	primeraDiagonal:
		sw $s5, 0($s0)
		subu $s0, $s0, 1024
		sub $s0, $s0, 4
		addi $s6, $s6, 1
		bne $s6, 9, primeraDiagonal
		nop
	cuartaParte:
		ori $s6, $0, 0
	primeraLineaV:
		sw $s5, 0($s0)	
		subu $s0, $s0, 1024
		addi $s6, $s6, 1
		bne $s6, 15, primeraLineaV
		nop
	quintaParte:
		ori $s6, $0, 0
	segundaDiagonal:
		sw $s5, 0($s0)
		addi $s0, $s0, 4
		subu $s0, $s0, 1024
		addi $s6, $s6, 1
		bne $s6, 9, segundaDiagonal
		nop
	sextaParte:
		ori $s6, $0, 0
	segundaLineaHo:
		sw $s5, 0($s0)
		addi $s0, $s0, 4
		addi $s6, $s6, 1
		bne $s6, 15, segundaLineaHo
		nop
	septimaParte:
		ori $s6, $0, 0
	terceraDiagonal:
		sw $s5, 0($s0)
		addi $s0, $s0, 4
		addi $s0, $s0, 1024
		addi $s6, $s6, 1
		bne $s6, 9, terceraDiagonal
		nop
	octavaParte:
		ori $s6, $0, 0
	segundaVertical:
		sw $s5, 0($s0)
		addi $s0, $s0, 1024
		addi $s6, $s6, 1
		bne $s6, 15, segundaVertical
		nop
	novenaParte:
		ori $s6, $0, 0
	cuartaDiagonal:
		sw $s5, 0($s0)
		addi $s0, $s0, 1024
		subu $s0, $s0, 4
		addi $s6, $s6, 1
		bne $s6, 9, cuartaDiagonal
		nop
		
		jr $ra
		nop
		
marcarTriquiDiagonal1:
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 25
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	addi $s0, $s0, 116
	b dibujarLineaDiagonal1
	nop
	
marcarTriquiDiagonal2:	
	lui $s0, 0x1001
	ori $s6, $0, 0
	#VERTICAL
	li $s7, 194
	li $t0, 1024
	mult $s7, $t0
	mflo $s3
	add $s0, $s0, $s3
	#HORIZONTAL
	addi $s0, $s0, 116
	
	procesoPrimeraLineaX:
		addi $s0, $s0, 1024
		addi $s0, $s0, 4
		#sw $s5, 0($s0)
		addi $s6, $s6, 1
		bne $s6, 30, procesoPrimeraLineaX
		nop
		subu $s0, $s0, 120
		ori $s6, $0, 0
	
	b dibujarLineaDiagonal2
	nop	
	
dibujarLineaDiagonal1:
	addi $s0, $s0, 1024
	addi $s0, $s0, 4
	sw $s5, 0($s0)
	addi $s6, $s6, 1
	bne $s6, 200, dibujarLineaDiagonal1
	nop
	jr $ra
	nop
	
dibujarLineaDiagonal2:
	sub $s0, $s0, 1024
	addi $s0, $s0, 4
	sw $s5, 0($s0)
	addi $s6, $s6, 1	
	bne $s6, 200, dibujarLineaDiagonal2
	nop
	jr $ra
	nop
	
marcarTriquiFila1:
	lui $s0, 0x1001 #1er pixel arriba a la izquierda

	li $s3, 1024 #constante para saltar entre filas
	li $s4, 40 #contador para filas
	mult $s3, $s4 #multiplicaci�n entre 1024 con el # de fila
	mflo $s4 #traer resultado de la multiplicaci�n anterior a s4

	add $s0, $s0, $s4 #para correr verticalmente sumar a s0 
		#el resultado de multiplicaci�n anterior

	addi $s0, $s0, 0 #correr 56 pixeles a la derecha

	li $s6, 0 # contador
	
	dibujarLineaFila1:	
		sw $s5, 0($s0) #pintar el pixel del color definido	
		addi $s0, $s0, 4 #aumentar s0 en 4 bytes para ir a siguiente pixel a la derecha	
		addi $s6, $s6, 1 #incrementar en 1 el contador
		bne $s6, 256, dibujarLineaFila1
		nop
	
	jr $ra
	nop

marcarTriquiFila2:
	lui $s0, 0x1001 #1er pixel arriba a la izquierda

	li $s3, 1024 #constante para saltar entre filas
	li $s4, 126 #contador para filas
	mult $s3, $s4 #multiplicaci�n entre 1024 con el # de fila
	mflo $s4 #traer resultado de la multiplicaci�n anterior a s4

	add $s0, $s0, $s4 #para correr verticalmente sumar a s0 
		#el resultado de multiplicaci�n anterior

	addi $s0, $s0, 0 #correr 56 pixeles a la derecha

	li $s6, 0 # contador
	
	dibujarLineaFila2:	
		sw $s5, 0($s0) #pintar el pixel del color definido	
		addi $s0, $s0, 4 #aumentar s0 en 4 bytes para ir a siguiente pixel a la derecha	
		addi $s6, $s6, 1 #incrementar en 1 el contador
		bne $s6, 256, dibujarLineaFila2
		nop
	
	jr $ra
	nop

marcarTriquiFila3:
	lui $s0, 0x1001 #1er pixel arriba a la izquierda

	li $s3, 1024 #constante para saltar entre filas
	li $s4, 207 #contador para filas
	mult $s3, $s4 #multiplicaci�n entre 1024 con el # de fila
	mflo $s4 #traer resultado de la multiplicaci�n anterior a s4

	add $s0, $s0, $s4 #para correr verticalmente sumar a s0 
		#el resultado de multiplicaci�n anterior

	addi $s0, $s0, 0 #correr 56 pixeles a la derecha

	li $s6, 0 # contador
	
	dibujarLineaFila3:	
		sw $s5, 0($s0) #pintar el pixel del color definido	
		addi $s0, $s0, 4 #aumentar s0 en 4 bytes para ir a siguiente pixel a la derecha	
		addi $s6, $s6, 1 #incrementar en 1 el contador
		bne $s6, 256, dibujarLineaFila3
		nop
	
	jr $ra
	nop

marcarTriquiColumna1:
	lui $s0, 0x1001
	li $s4, 0
	mult $s3, $s4
	mflo $s4
	#VERTICAL
	add $s0, $s0, $s4
	#HORIZONTAL
	addi $s0, $s0, 172
	li $s6, 0
	
	dibujarLineaColumna1:
		addi $s0, $s0, 1024
		sw $s5, 0($s0)
		addi $s6, $s6, 1
		bne $s6, 256, dibujarLineaColumna1
		nop
	jr $ra
	nop

marcarTriquiColumna2:
	lui $s0, 0x1001
	li $s4, 0
	mult $s3, $s4
	mflo $s4
	#VERTICAL
	add $s0, $s0, $s4
	#HORIZONTAL
	addi $s0, $s0, 508
	li $s6, 0
	
	dibujarLineaColumna2:
		addi $s0, $s0, 1024
		sw $s5, 0($s0)
		addi $s6, $s6, 1
		bne $s6, 256, dibujarLineaColumna2
		nop
	jr $ra
	nop
	
marcarTriquiColumna3:
	lui $s0, 0x1001
	li $s4, 0
	mult $s3, $s4
	mflo $s4
	#VERTICAL
	add $s0, $s0, $s4
	#HORIZONTAL
	addi $s0, $s0, 844
	li $s6, 0
	
	dibujarLineaColumna3:
		addi $s0, $s0, 1024
		sw $s5, 0($s0)
		addi $s6, $s6, 1
		bne $s6, 256, dibujarLineaColumna3
		nop
	
	jr $ra
	nop
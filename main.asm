.data
alfabeto: .asciiz "abcdefghijklmnopqrstuvwxyz"
fileInput: .asciiz "C://Users//Andres T//Desktop//Taller Arq/input.txt"
fileWords: .space 1024
messageLoop: .asciiz "After while loop is done"
salto: .asciiz "\n"
messageForKey: .asciiz "insert the key for encryption: "
keyInput: .space 20
letraBuscada: .asciiz "d"
finTextoAscii: .asciiz 


.text
main:
	#Show message asking for key input to user
	li $v0,4
	la $a0,messageForKey
	syscall
	
	# Getting users imput as text
	li $v0,8   #Prepare for rear user text
	la $a0,keyInput
	li $a1,20
	syscall
	
	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileInput     	# get the file name
    	li $a1,0           	# file flag = read (0)
    	syscall
    	move $s0,$v0        	# save the file descriptor. $s0 = file
    	
    	
    	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1,fileWords  	# The buffer that holds the string of the WHOLE file
	la $a2,1024		# hardcoded buffer length
	syscall
    	
    	li $v0,4
	la $a0,fileWords
	syscall
	
	#Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s0      		# file descriptor to close
    	syscall
    	
    	#Empieza codificación vignere
    	li $t0,0
    	la $a0 fileWords #Cargo dirección del texto input
    	jal strlenWhile #Obtengo lenght del input (fileWords)
    	
    	
    	#li $v0,1   #Imprimo el contador del lenght del input
        #move $a0, $t0 
        #syscall
        
        
        #EN T0 TENGO EL LENGHT DEL STRING INPUT
        
        #move $t1,$t0 #Cantidad de caracteres de la palabra a encriptar (fileWords)
        li $t1,0   #Cantidad de posiciones iteradas del string input
        la $t4 fileWords #Cargo dirección del texto input
        jal while #Llamado función while
        
        li $v0, 10
    	syscall
    		
    	
    	
    	
while:


        beq $t1, $t0, exit #Condición de que si t1 es mayor a t0 salta al exit
        #addi $t0,$t0,1 
        #Guardar numero iteracion del while 
        addi $sp,$sp, -8
        sw $t0, 0($sp)
        sw $t1, 4($sp)
        
        #Preparar valores necesarios para el searchInput
       
        lb $t0, 0($t4)         # Cargar el valor ASCII de la primera letra en $t0  #AQUI TENGO QUE PONER QUE LA POSICION DE BYTE TIENE QUE SER LA POSICION O EL  VALOR DE T1 DEBIDO A QUE ES LA POSICION DE LA CADENA INPUT
        la  $t1, alfabeto    #Cargar direccion de la cadena del alfabeto en $t0
    	add $t2,$zero,0     #Contador de posiciones del alfabeto
    	li $s0, 26	    #L o lenght del arreglo de letras    
        jal searchInputWord
        
        #Restaurar numero iteracion del while
        lw $t0, 0($sp)
        lw $t1, 4($sp)
        addi $t1,$t1,1
        addi $t4,$t4,1 #Aumento la dirección que estoy apuntando de las letras que recorro (apunto a la siguiente letra)
        addi $sp, $sp, 8
        j while  #Volver a ir al procedimiento while     	
    
strlenWhile:
	lb $t1,0($a0) #Cargo en t1 el valor en la posición actual de ese str del input
	beqz $t1, exit  #Si la variable t1 es 0, es decir nulo dejo de leer
	addi $t0,$t0,1 #Aumento contador de cuantas letras hay
	addi $a0,$a0,1 #Aumento la dirección que estoy apuntando de las letras que recorro (apunto a la siguiente letra)
	j strlenWhile
	
	
        

searchInputWord:

	bge $t2,$s0,exit  #Si t2 es mayor a s0 se va a exit, debido a que esto es un error
         
        # Cargar la letra actual de la cadena en $t3
    	lb $t3, ($t1) # t1 en el primer llamado equivale a la dirección inicial del string (la letra)
        
        # Comparar con la letra buscada
    	beq $t3, $t0, letra_encontrada 
        
        addi $t2, $t2, 1 #Contador del loop sobre el abecedario
        addi $t1, $t1, 1 #Contador sobre la palabra en t1 (direcciones de ese string)
        j searchInputWord  #Volver a ir al procedimiento searchInputWord 	
        
 

letra_encontrada:
    # $t2 contiene la posición de la letra buscada en el alfabeto
    # Realizar acciones necesarias con $t2
    
    
    #Show position of the letter
        li $v0,1
        move $a0, $t2
        syscall
   # Esto me debe devolver a la iteracion del while donde me llamaron a searchInputWord
   jr $ra        
        
exit:
	li $v0,1
        move $a0, $t0
        syscall
        jr $ra

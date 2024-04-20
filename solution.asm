.data
alfabeto: .asciiz "abcdefghijklmnopqrstuvwxyz"
fileInput: .asciiz "C://Users//Andres T//Desktop//Taller Arq//input.txt"
fileOutput: .asciiz "C://Users//Andres T//Desktop//Taller Arq//clon.txt"
fileWords: .space 1024
messageLoop: .asciiz "After while loop is done"
salto: .asciiz "\n"
messageForKey: .asciiz "insert the key for encryption: "
keyInput: .space 20
letraBuscada: .asciiz "d"
finTextoAscii: .asciiz
encryptedFileWords: .space 1024 



.text
main:
    
    jal askEncryptionKeyMsg
    jal receiveUserEncryptionKey
    jal openFileToEncode
    #Now s0 Holds file descriptor
    jal readFileToEncode

    

    la $a0, fileWords
    la $a1, keyInput
    la $a2, alfabeto
    la $a3, encryptedFileWords
    li $t0, 0
    li $t1, 0
    li $t2, 0
    li $t6, 26
    jal iterateOverFileContent
    
    #Close the file
    li $v0, 16         		# close_file syscall code
    move $a0,$s0      		# file descriptor to close
    syscall

    #open file 
    li $v0,13           	# open_file syscall code = 13
    la $a0,fileOutput     	# get the file name
    li $a1,1           	# file flag = write (1)
    syscall
    move $s1,$v0        	# save the file descriptor. $s0 = file
    
    #Write the file
    li $v0,15		# write_file syscall code = 15
    move $a0,$s1		# file descriptor
    la $a1,encryptedFileWords		# the string that will be written
    move $a2, $t0		# length of the toWrite string
    syscall
    
    #MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    li $v0,16         		# close_file syscall code
    move $a0,$s1      		# file descriptor to close
    syscall



    li $v0, 10
    syscall


#
# Primeros pasos setup del codigo
# Se pide la llave de encriptacion
#

askEncryptionKeyMsg:
    li $v0,4
    la $a0,messageForKey
    syscall
    jr $ra

receiveUserEncryptionKey:
    li $v0,8   #Prepare for read user text
	la $a0,keyInput
	li $a1,20
	syscall
    jr $ra

openFileToEncode:
    li $v0,13           	# open_file syscall code = 13
    la $a0,fileInput     	# get the file name
    li $a1,0           	    # file flag = read (0)
    syscall
    move $s0,$v0        	# save the file descriptor. $s0 = file
    jr $ra

readFileToEncode:
    li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1,fileWords  	# The buffer that holds the string of the WHOLE file
	la $a2,1024		# hardcoded buffer length
	syscall

    #Guardar $ra que apunta a main en estos momentos
    addi $sp,$sp, -4
    sw $ra, 0($sp)

    la $a0,fileWords
    move $t0,$a0
    jal printInput
    

    #Restaurar $ra a main
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra


printInput:
    li $v0,4
    move $a0, $t0
    syscall
    jr $ra

returnFn:
    jr $ra

#
# Segunda etapa codigo para iterar sobre las letras
# Vamos a iterar sobre el contenido del archivo
# Realizaremos la codificacion de vignere
#


# Argumentos
# $a0 = Direccion sobre el contenido
# $a1 = Direccion sobre la key
# $a2 = Direccion sobre el alfabeto
# $a3 = Direccion sobre el contenido cifrado
# $t0 = Indice actual sobre el contenido del documento
# $t1 = Bandera para indicar si es encriptar (0) , desencriptar(1)
# $t2 = Indice actual sobre el key
# $t3 = caracter del contenido
# $t4 = caracter de la key
# $t5 = Indice cifrado
# $t6 = Longitud del abecedario
iterateOverFileContent:

    #Si el caracter es nulo retornar
    lb $t3, 0($a0)
    beqz $t3,returnFn

    #Cargar caracter de la llave secreta
    #Cargar en pila a1
    addi $sp,$sp, -4
    sw $a1, 0($sp)

    add $a1, $a1,$t2
    lb $t4, 0($a1)

    #Setear valor de a1 de pila
    lw $a1, 0($sp)
    addi $sp,$sp, 4

    #Vignere al caracter
    #Calculo del indice Cifrado
    #Restamos con 32 ya que 32 representa nuestro inicio del abecedario
    beq $t1,0,calcEncryptedIndex
    beq $t1,1,calcDecryptedIndex
 
    


onKeyPositionOverflow:
    li $t2,0
    j iterateOverFileContent

calcEncryptedIndex:
    subi $t5,$t3,97
    add $t5,$t5,$t4
    subi $t5,$t5,97
    j calcNewChar

calcDecryptedIndex:
    sub $t5,$t3,$t4 #Esto no se debe hacer a t5
    bltz $t5,hacerPositivo
    j calcNewChar

hacerPositivo:
    addi $t5,$t5, 26
    j calcNewChar
 
calcNewChar:

    #Calcular la division para poder tener el residuo en t5
    
    div $t5,$t6
    mfhi $t5

    
    la $a2, alfabeto
    add $a2, $a2,$t5
    lb $t5, 0($a2)


    #Ahora t5 es el caracter cifrado
    #Guardar caracter cifrado en el texto cifrado
    la $a3, encryptedFileWords
    add $a3, $a3, $t0
    sb $t5, ($a3)


    #Avanzamos al siguiente caracter
    addi $a0,$a0,1
    addi $t2,$t2,1
    addi $t0,$t0,1
    
    #Verificamos posible overflow del caracter de la key
    
    #Cargar caracter de la llave secreta
    #Cargar en pila a1
    addi $sp,$sp, -4
    sw $a1, 0($sp)

    add $a1, $a1,$t2
    lb $t4, 0($a1)

    #Setear valor de a1 de pila
    lw $a1, 0($sp)
    addi $sp,$sp, 4
    beqz $t4,onKeyPositionOverflow

    j iterateOverFileContent



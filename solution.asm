.data
alfabeto: .asciiz "abcdefghijklmnopqrstuvwxyz""
fileInput: .asciiz "C://Users//Andres T//Desktop//Taller Arq//input.txt"
encodedOutput: .asciiz "C://Users//Andres T//Desktop//Taller Arq//criptogram.txt"
decodedOutput: .asciiz "C://Users//Andres T//Desktop//Taller Arq//decoded.txt"
fileWords: .space 1024
messageForKey: .asciiz "Insert the key for encryption: "
keyInput: .space 20
newFileWords: .space 1024 
alertText: .asciiz "The program has ended successfully!!!!"


.text
main:
    
    jal askEncryptionKeyMsg
    jal receiveUserEncryptionKey
    
    la $a0,fileInput     	
    jal openFile
    jal readFile
    jal closeFile
    

    la $a0, fileWords           #Dirección de texto a encriptar
    la $a1, keyInput            #Dirección de key
    la $a2, alfabeto            #Dirección de alfabeto
    la $a3, newFileWords        #Dirección de buffer donde estará el texto encriptado
    li $t0, 0                   #Indice actual sobre el contenido del documento
    li $t1, 0                   #Bandera para encriptar
    li $t2, 0                   #Indice actual sobre el key
    li $t6, 26                  #Cantidad de caracteres en el alfabeto
    jal iterateOverFileContent
    
    #Argumento para escribir codigo encriptado
    la $a0,encodedOutput     	# Obtener dirección de archivo encriptado de salida
    jal writeText               # Escribir texto encriptado en el archivo
    jal closeFile               # Cerrar archivo
    

    #Argumentos para leer archivo encriptado
    la $a0,encodedOutput     	# Obtener dirección de archivo encriptado de salida
    jal openFile                # Abrir archivo
    jal readFile                # Leer texto encriptado del archivo
    jal closeFile
    
    
    la $a0, fileWords           #Dirección de texto encriptado
    la $a1, keyInput            #Dirección de key
    la $a2, alfabeto            #Dirección de alfabeto
    la $a3, newFileWords        #Dirección de buffer donde estará el texto desencriptado
    li $t0, 0                   #Indice actual sobre el contenido del documento
    li $t1, 1                   #Bandera para descrifrar
    li $t2, 0                   #Indice actual sobre el key
    li $t6, 26                  #Cantidad de caracteres en el alfabeto
    jal iterateOverFileContent
    
    
    la $a0,decodedOutput     	#Dirección de archivo decodificado
    jal writeText               #Escribir texto decodificado
    jal closeFile               #Cerrar el archivo

    li $v0, 4                   
    la $a0, alertText           #Mostrar mensaje de finalización exitosa
    syscall


    li $v0, 10                  #Finalizar el programa
    syscall


#Función para abrir archivo en modo lectura
openFile:
    li $v0,13           	# Abrir archivo syscall code = 13
    
    li $a1,0           	    # Bandera de lectura read (0)
    syscall
    move $s0,$v0        	# Guardar la descripción del achivo $s0 = file
    jr $ra


#Función para abrir leer contenido de archivo y guardarlo en un buffer
readFile:
    li $v0, 14		    # Leer archivo syscall code = 14
    move $a0,$s0		# Archivo
    la $a1,fileWords  	# Buffer que contiene el el texto del archivo
    la $a2,1024		    # Tamaño del buffer a escribir
    syscall
    
    jr $ra

#Función para abrir archivo en modo escritura y escribir lo que se encuentre en buffer
writeText:
    #Open file 
    li $v0,13           	# Abrir archivo syscall code = 13
    li $a1,1           		# Bandera de escritura (1)
    syscall
    move $s0,$v0        	# Guardar la dirección del achivo $s0 = file
    
    #Write the file
    li $v0,15			    # Escribir en archivo syscall code = 15
    move $a0,$s0		    # Archivo
    la $a1,newFileWords		# Buffer que contiene el el texto del archivo 
    move $a2, $t0		    # Tamaño del buffer a escribir
    syscall
    
    jr $ra
    
#Funcion para cerrar archivo abierto
closeFile:
    
    li $v0, 16         		# Cerrar archivo syscall code =16
    move $a0,$s0      		# $s0 Tiene la dirección del archivo a cerrar
    syscall
    
    jr $ra


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





#
# Segunda etapa codigo para iterar sobre las letras
# Vamos a iterar sobre el contenido del archivo
# Realizaremos la codificacion de vignere
#

returnFn:
    jr $ra


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

    
    
    addi $sp,$sp, -4
    sw $a1, 0($sp)                  #Guardar en pila a1

    add $a1, $a1,$t2                #Mover a1 tomando t2 como un offset
    lb $t4, 0($a1)                  #Cargar caracter de la llave secreta

    #Setear valor de a1 de pila
    lw $a1, 0($sp)                  #Resetear valor de a1 con el valor de la pila
    addi $sp,$sp, 4


    #Vignere al caracter
    #Calculo del indice Cifrado
    beq $t1,0,calcEncryptedIndex
    beq $t1,1,calcDecryptedIndex
 
#Argumentos
# $t3 = caracter del contenido
# $t4 = caracter de la key
# $t5 = Indice cifrado
#
# Descripcion:
# Esta función calcula el indice encriptado con la siguiente operación:
# t5 = (t3 - 97) + (t4 - 97)
# 97 representa el valor ascii de nuestra primera letra del abecedario
# Lo cual se puede resumir a:
# t5 = t3 + t4 - 194
calcEncryptedIndex:
    subi $t5,$t3,194
    add $t5,$t5,$t4
    j calcNewChar

# Argumentos
# $t3 = caracter del contenido
# $t4 = caracter de la key
# $t5 = Indice cifrado
#
# Descripcion:
# Esta función calcula el indice desencriptado con la siguiente operación:
# t5 = (t3 - 97) - (t4 - 97)
# 97 representa el valor ascii de nuestra primera letra del abecedario
# Lo cual se puede resumir a:
# t5 = t3 - t4
#
# En caso que t5 resulte negativo lo convertimos a positivo sumando 26
# 26 representa la longitud de nuestro abecedario
calcDecryptedIndex:
    sub $t5,$t3,$t4 
    bltz $t5,convertToPositive
    j calcNewChar    

# Argumentos
# $t5 = Indice cifrado
# 26 = Longitud del abecedario
convertToPositive:
    addi $t5,$t5, 26
    j calcNewChar

# Argumentos
# $a2 = Direccion sobre el alfabeto
# $a3 = Direccion sobre el nuevo contenido
# $t5 = Indice cifrado
# $t6 = Longitud del abecedario
calcNewChar:

    #Calcular la division para poder tener el residuo en t5
    
    div $t5,$t6
    mfhi $t5

    
    la $a2, alfabeto
    add $a2, $a2,$t5
    lb $t5, 0($a2)


    #Ahora t5 es el caracter cifrado

    la $a3, newFileWords
    add $a3, $a3, $t0
    bge $t3,97,onNormalChar
    bge $t3,32,onSpecialChar

# Argumentos
# $a3 = Direccion sobre el nuevo contenido
# $t5 = Nuevo caracter
onNormalChar:
    sb $t5, ($a3)
    j goNextChar

# Argumentos
# $a3 = Direccion sobre el nuevo contenido
# $t2 = Indice actual sobre el key
# $t3 = caracter del contenido
onSpecialChar:
    sb $t3, ($a3)
    # Cuando es un caracter especial no debemos avanzar en la llave secreta
    # Con esto reseteamos el avance que se realizara en goNextChar
    subi $t2, $t2,1
    j goNextChar

    
#Argumentos
# $a0 = Direccion sobre el contenido
# $a1 = Direccion sobre la key
# $t0 = Indice actual sobre el contenido del documento
# $t2 = Indice actual sobre el key
# $t4 = caracter de la key
goNextChar:
    #Avanzamos al siguiente caracter
    addi $a0,$a0,1
    addi $t2,$t2,1
    addi $t0,$t0,1
    
    #Guardar en pila el inicio a1
    addi $sp,$sp, -4
    sw $a1, 0($sp)

   
    add $a1, $a1,$t2            #Tomar t2 como un offset del inicio de a1
    lb $t4, 0($a1)              #Cargar caracter de la llave secreta

    #Setear nuevamente el inicio de a1 que guardamos en la pila
    lw $a1, 0($sp)
    addi $sp,$sp, 4
    
    #Verificar Overflow de la llave secreta contra LF,CR, ZERO
    beq $t4,10,onKeyPositionOverflow #LF
    beq $t4,13,onKeyPositionOverflow #CR
    beqz $t4,onKeyPositionOverflow

    j iterateOverFileContent

#Argumentos
# $t2 = Indice actual sobre el key
# En caso de overflow seteamos a 0 y continuamos a la siguiente iteracion
onKeyPositionOverflow:
    li $t2,0
    j iterateOverFileContent





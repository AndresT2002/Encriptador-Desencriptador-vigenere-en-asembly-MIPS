alphabet:str = "abcdefghijklmnopqrstuvwxyz"
mod:int = 26
def encrypt(input:str,key:str)-> str:
    cipherText:str = ""
    posKeyIni:int = 0
    pos:int = 0

    while(pos < len(input)):

        # Este .index lo vas a reemplazar por
        # Tomar el valor ascii de la letra y restarle 32
        # input[pos] retorna una letra
        #  mi = letra - 32
        mi = alphabet.index(input[pos])

        # Este .index lo vas a reemplazar por
        # Tomar el valor ascii de la letra y restarle 32
        # key[posKeyIni] retorna una letra
        # ki = letra - 32
        ki = alphabet.index(key[posKeyIni])

        # Mod representa el tamaño del alfabeto
        posCipher = (mi + ki) % mod

        # Concatenar la letra cifrada
        # con PosCipher ir al alphabet y tomar la letra 
        # que esta en esa posicion "posCipher"

        cipherText += alphabet[posCipher]

        # Avanzamos al siguiente caracter
        pos += 1

        # Avanzamos al siguiente caracter de la clave
        posKeyIni += 1

        # Si la clave llega al final, reiniciar
        if posKeyIni == len(key):
            posKeyIni = 0
       
    return cipherText

print(encrypt("hola","pene"))


def decrypt(encryptedText:str,key:str)-> str:
    plainText = ""
    posKeyIni = 0
    pos = 0
    

    while pos < len(encryptedText):
        # Este .index lo vas a reemplazar por
        # Tomar el valor ascii de la letra y restarle 32
        # input[pos] retorna una letra
        #  mi = letra - 32
        mi = alphabet.index(encryptedText[pos])

        # Este .index lo vas a reemplazar por
        # Tomar el valor ascii de la letra y restarle 32
        # key[posKeyIni] retorna una letra
        # ki = letra - 32
        ki = alphabet.index(key[posKeyIni])

        # Mod representa el tamaño del alfabeto
        posPlain = (mi - ki) % mod

        # Concatenar la letra cifrada
        # con PosCipher ir al alphabet y tomar la letra 
        # que esta en esa posicion "posCipher"

        plainText += alphabet[posPlain]

        # Avanzamos al siguiente caracter
        pos += 1

        # Avanzamos al siguiente caracter de la clave
        posKeyIni += 1

        # Si la clave llega al final, reiniciar
        if posKeyIni == len(key):
            posKeyIni = 0

    return plainText
print(decrypt("wsye","pene"))
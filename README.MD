# Equipo
Roberto Betancourt Hernández - A01551525
Luis Edgar Flores Carpinteyro - A01329971
Alan Rodrigo Albert Morán - A01328928
		
# Comandos para ejecutar y compilar
flex interprete.l
bison -d interprete.y
gcc lex.yy.c interprete.tab.c -lfl -lm
./a.out prueba.txt

# Descripción del programa
Se ha diseñado un programa que contiene un analizador léxico y sintáctico que procesa una gramática definida por el profesor, simulando el comportamiento de un simulador.

Se trata de un compilador de tipo fuerte, lo que significa que los tipos en cada instrucción deberán ser los mismos, de otra forma, el compilador mandará un error.

Se emplean las tecnologías de Flex, Bison y el lenguaje C.

Como información de las restricciones del programa, no se implementó el input para números negativos.
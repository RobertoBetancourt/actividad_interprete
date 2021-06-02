/* 
	Este archivo contiene un reconocedor de expresiones aritméticas junto
   con algunas reglas semánticas que calculan los valores de las
   expresiones que se reconocen. Las expresiones son muy sencillas y
   consisten únicamente de sumas, restas, multiplicaciones, divisiones, módulo y potencias de números enteros.

  Los comandos para compilar y ejecutar son: 
    flex calculadora.l
    bison -d calculadora.y
    gcc lex.yy.c calculadora.tab.c -lfl -lm
    ./a.out prueba.txt
*/

%{
#include<stdio.h>
#include<math.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct estructura_tabla_simbolos nodo_lista_ligada;
typedef struct estructura_arbol nodo_arbol;
typedef struct estructura_punto_y_coma nodo_punto_y_coma;


struct estructura_tabla_simbolos {
	char nombre_variable[20];
	int tipo; // 0 es int, 1 es float
	float valor;
	nodo_lista_ligada* simbolo_siguiente;
};

struct estructura_arbol {
	int definicion; // 0 es variable, 1 es constante, 2 es stmt de asignacion, 3 es if fi, 4 es if else, 7 es print, 8 es begin, 10 es suma, 11 es resta, 12 es multiplicación, 13 es división, 14 es menor que 
	int tipo; // 0 es int, 1 es float
	float valor; // Campo utilizado solo para constantes
	nodo_lista_ligada* direccion_tabla_simbolos; // Campo utilizado solo para variables
	nodo_punto_y_coma* inicio_instrucciones;
	nodo_arbol* izq;
	nodo_arbol* centro; // Campo utilizado solo en los if y print
	nodo_arbol* der;
};

struct estructura_punto_y_coma {
	nodo_arbol* inicio;
	nodo_punto_y_coma* siguiente_instruccion;
}; 

extern int numero_linea;
extern int yylex();
extern FILE *yyin;
int yyerror(char const * s);
void imprimir_valor(nodo_arbol* n);
void recorrer_arbol(nodo_arbol* n);

nodo_arbol* buscar_identificador(char nombre_variable[20], nodo_lista_ligada* nodo_a_buscar);
nodo_arbol* crear_nodo_arbol(int definicion, int tipo, float valor, nodo_lista_ligada* direccion_tabla_simbolos, nodo_punto_y_coma* inicio_instrucciones, nodo_arbol* izq, nodo_arbol* centro, nodo_arbol* der);
nodo_arbol* asignar_tipo(nodo_arbol* nodo);

nodo_lista_ligada* unir_tabla_de_simbolos(nodo_lista_ligada* nodo1, nodo_lista_ligada* nodo2);
nodo_lista_ligada* crear_nodo_de_tabla_de_simbolos(char nombre_variable[20], int tipo); // 0 es int, 1 es float

nodo_punto_y_coma* crear_instruccion(nodo_arbol* inicio, nodo_punto_y_coma* siguiente_instruccion);
nodo_punto_y_coma* unir_instrucciones(nodo_punto_y_coma* nodo1, nodo_punto_y_coma* nodo2);

int type_of_input(const char *str);

float sumar(nodo_arbol* izq, nodo_arbol* der);
float restar(nodo_arbol* izq, nodo_arbol* der);
float multiplicar(nodo_arbol* izq, nodo_arbol* der);
float dividir(nodo_arbol* izq, nodo_arbol* der);
void leer(nodo_arbol* nodo);

void imprimir_tabla_de_simbolos(nodo_lista_ligada* nodo);
void imprimir_nodo(nodo_arbol* nodo);
void imprimir_instrucciones(nodo_punto_y_coma* nodo);
void ejecutar_instrucciones(nodo_punto_y_coma* nodo);
void imprimir(nodo_arbol* nodo);
void asignacion(nodo_arbol* nodo_izq, nodo_arbol* nodo_der);

nodo_lista_ligada* cabeza_tabla_de_simbolos = NULL;
nodo_punto_y_coma* cabeza_instrucciones = NULL;

%}

%union {
  int numero_entero;
	float numero_flotante;
	char cadena[20];
  struct estructura_arbol* nodo_arbol;
	struct estructura_tabla_simbolos* nodo_lista_ligada;
	struct estructura_punto_y_coma* nodo_punto_y_coma;
}

%token ASIGNACION SUMA RESTA DIVIDE MULTI PAREND PARENI DOS_PUNTOS PUNTO_Y_COMA BEGIN_RESERVADA END_RESERVADA IF_RESERVADA FI_RESERVADA ELSE_RESERVADA WHILE_RESERVADA FOR_RESERVADA TO_RESERVADA STEP_RESERVADA DO_RESERVADA READ_RESERVADA PRINT_RESERVADA MENOR_QUE MAYOR_QUE IGUAL_QUE MENOR_O_IGUAL_QUE MAYOR_O_IGUAL_QUE
%token <numero_entero> ENTERO TIPO_ENTERO TIPO_FLOTANTE
%token <numero_flotante> FLOTANTE
%token <cadena> IDENTIFICADOR
%type <numero_entero> tipo
%type <nodo_lista_ligada> decl decl_lst opt_decls
%type <nodo_arbol> factor term expr stmt expression
%type <nodo_punto_y_coma> stmt_lst opt_stmts
%start prog

%%

prog : opt_decls BEGIN_RESERVADA opt_stmts END_RESERVADA		{cabeza_instrucciones = $3;}
;

opt_decls : /*epsilon*/											{cabeza_tabla_de_simbolos = NULL; $$ = NULL;}
					| decl_lst												{cabeza_tabla_de_simbolos = $1; $$ = $$;}
;

decl_lst : decl PUNTO_Y_COMA decl_lst				{$$ = unir_tabla_de_simbolos($1, $3);}
				 | decl															{$$ = $$;}
;

decl : IDENTIFICADOR DOS_PUNTOS tipo				{$$ = crear_nodo_de_tabla_de_simbolos($1, $3);}
;

tipo : TIPO_ENTERO													{$$ = 0;}
		 | TIPO_FLOTANTE												{$$ = 1;}
;

opt_stmts : /*epsilon*/											{$$ = NULL;}
					| stmt_lst												{$$ = $$;}
;

stmt_lst : stmt PUNTO_Y_COMA stmt_lst				{$$ = crear_instruccion($1, $3);}
				 | stmt															{$$ = crear_instruccion($1, NULL);}
;

stmt : IDENTIFICADOR ASIGNACION expr						{	nodo_arbol* nodo = crear_nodo_arbol(2, -1, -1, NULL, NULL, buscar_identificador($1, cabeza_tabla_de_simbolos), NULL, $3);
																						 			asignar_tipo(nodo);
																						 			$$ = nodo;	}
		 | IF_RESERVADA PARENI expression PAREND stmt FI_RESERVADA	{	$$ = crear_nodo_arbol(3, -1, -1, NULL, NULL, $3, $5, NULL);	}
		 | IF_RESERVADA PARENI expression PAREND stmt ELSE_RESERVADA stmt {	$$ = crear_nodo_arbol(4, -1, -1, NULL, NULL, $3, $5, $7);	}
		 | WHILE_RESERVADA PARENI expression PAREND stmt
		 | FOR_RESERVADA IDENTIFICADOR ASIGNACION expr TO_RESERVADA expr STEP_RESERVADA expr DO_RESERVADA stmt
		 | READ_RESERVADA IDENTIFICADOR							{	nodo_arbol* nodo = crear_nodo_arbol(6, -1, -1, NULL, NULL, NULL, buscar_identificador($2, cabeza_tabla_de_simbolos), NULL);
																						 			asignar_tipo(nodo);
																						 			$$ = nodo;	}
		 | PRINT_RESERVADA expr											{	nodo_arbol* nodo = crear_nodo_arbol(7, -1, -1, NULL, NULL, NULL, $2, NULL);
																						 			asignar_tipo(nodo);
																						 			$$ = nodo;	}
		 | BEGIN_RESERVADA opt_stmts END_RESERVADA	{$$ = crear_nodo_arbol(8, -1, -1, NULL, $2, NULL, NULL, NULL);}
;

expr : expr SUMA term							{	nodo_arbol* nodo = crear_nodo_arbol(10, -1, -1, NULL, NULL, $1, NULL, $3);
																		asignar_tipo(nodo);
																		$$ = nodo;	}
     | expr RESTA term						{	nodo_arbol* nodo = crear_nodo_arbol(11, -1, -1, NULL, NULL, $1, NULL, $3);
																		asignar_tipo(nodo);
																		$$ = nodo;	}
     | term												{ $$ = $$; }
;

term : term MULTI factor					{	nodo_arbol* nodo = crear_nodo_arbol(12, -1, -1, NULL, NULL, $1, NULL, $3);
																		asignar_tipo(nodo);
																		$$ = nodo;	}
     | term DIVIDE factor					{	nodo_arbol* nodo = crear_nodo_arbol(13, -1, -1, NULL, NULL, $1, NULL, $3);
																		asignar_tipo(nodo);
																		$$ = nodo;	}
     | factor											{ $$ = $$; }
;

factor : PARENI expr PAREND				{$$ = $2;}
       | IDENTIFICADOR						{$$ = buscar_identificador($1, cabeza_tabla_de_simbolos);}
			 | ENTERO										{$$ = crear_nodo_arbol(1, 0, $1, NULL, NULL, NULL, NULL, NULL);}
			 | FLOTANTE									{$$ = crear_nodo_arbol(1, 1, $1, NULL, NULL, NULL, NULL, NULL);}
;

expression : expr MENOR_QUE expr							{	nodo_arbol* nodo = crear_nodo_arbol(14, -1, -1, NULL, NULL, $1, NULL, $3);
																								asignar_tipo(nodo);
																								$$ = nodo;	}
					 | expr MAYOR_QUE expr							{	nodo_arbol* nodo = crear_nodo_arbol(15, -1, -1, NULL, NULL, $1, NULL, $3);
																								asignar_tipo(nodo);
																								$$ = nodo;	}
					 | expr IGUAL_QUE expr							{	nodo_arbol* nodo = crear_nodo_arbol(16, -1, -1, NULL, NULL, $1, NULL, $3);
																								asignar_tipo(nodo);
																								$$ = nodo;	}
					 | expr MENOR_O_IGUAL_QUE expr 			{	nodo_arbol* nodo = crear_nodo_arbol(17, -1, -1, NULL, NULL, $1, NULL, $3);
																								asignar_tipo(nodo);
																								$$ = nodo;	}
					 | expr MAYOR_O_IGUAL_QUE expr			{	nodo_arbol* nodo = crear_nodo_arbol(18, -1, -1, NULL, NULL, $1, NULL, $3);
																								asignar_tipo(nodo);
																								$$ = nodo;	}
;

%%

void asignacion(nodo_arbol* nodo_izq, nodo_arbol* nodo_der) {
	if(nodo_der->definicion == 0) {
		nodo_izq->direccion_tabla_simbolos->valor = nodo_der->direccion_tabla_simbolos->valor;
	}

	if(nodo_der->definicion == 1) {
		nodo_izq->direccion_tabla_simbolos->valor = nodo_der->valor;
	}

	if(nodo_der->definicion == 10) {
		nodo_izq->direccion_tabla_simbolos->valor = sumar(nodo_der->izq, nodo_der->der);
	}

	if(nodo_der->definicion == 11) {
		nodo_izq->direccion_tabla_simbolos->valor = restar(nodo_der->izq, nodo_der->der);
	}

	if(nodo_der->definicion == 12) {
		nodo_izq->direccion_tabla_simbolos->valor = multiplicar(nodo_der->izq, nodo_der->der);
	}

	if(nodo_der->definicion == 13) {
		nodo_izq->direccion_tabla_simbolos->valor = dividir(nodo_der->izq, nodo_der->der);
	}
	
}

float sumar(nodo_arbol* izq, nodo_arbol* der) {
	float izquierda = 0.0;
	float derecha = 0.0;

	switch(izq->definicion) {
		case 0: izquierda = izq->direccion_tabla_simbolos->valor; break;
		case 1: izquierda = izq->valor; break;
		case 10: izquierda = sumar(izq->izq, izq->der); break;
		case 11: izquierda = restar(izq->izq, izq->der); break;
		case 12: izquierda = multiplicar(izq->izq, izq->der); break;
		case 13: izquierda = dividir(izq->izq, izq->der); break;
	}

	switch(der->definicion) {
		case 0: derecha = der->direccion_tabla_simbolos->valor; break;
		case 1: derecha = der->valor; break;
		case 10: derecha = sumar(der->izq, der->der); break;
		case 11: derecha = restar(der->izq, der->der); break;
		case 12: derecha = multiplicar(der->izq, der->der); break;
		case 13: derecha = dividir(der->izq, der->der); break;
	}
	
	/* printf("Suma izquierda: %f, derecha: %f\n", izquierda, derecha);  */
	return izquierda + derecha;
}

float restar(nodo_arbol* izq, nodo_arbol* der) {
	float izquierda = 1.0;
	float derecha = 1.0;

	switch(izq->definicion) {
		case 0: izquierda = izq->direccion_tabla_simbolos->valor; break;
		case 1: izquierda = izq->valor; break;
		case 10: izquierda = sumar(izq->izq, izq->der); break;
		case 11: izquierda = restar(izq->izq, izq->der); break;
		case 12: izquierda = multiplicar(izq->izq, izq->der); break;
		case 13: izquierda = dividir(izq->izq, izq->der); break;
	}

	switch(der->definicion) {
		case 0: derecha = der->direccion_tabla_simbolos->valor; break;
		case 1: derecha = der->valor; break;
		case 10: derecha = sumar(der->izq, der->der); break;
		case 11: derecha = restar(der->izq, der->der); break;
		case 12: derecha = multiplicar(der->izq, der->der); break;
		case 13: derecha = dividir(der->izq, der->der); break;
	}
	
	/* printf("Resta izquierda: %f, derecha: %f\n", izquierda, derecha); */
	return izquierda - derecha;
}

float multiplicar(nodo_arbol* izq, nodo_arbol* der) {
	float izquierda = 1.0;
	float derecha = 1.0;

	switch(izq->definicion) {
		case 0: izquierda = izq->direccion_tabla_simbolos->valor; break;
		case 1: izquierda = izq->valor; break;
		case 10: izquierda = sumar(izq->izq, izq->der); break;
		case 11: izquierda = restar(izq->izq, izq->der); break;
		case 12: izquierda = multiplicar(izq->izq, izq->der); break;
		case 13: izquierda = dividir(izq->izq, izq->der); break;
	}

	switch(der->definicion) {
		case 0: derecha = der->direccion_tabla_simbolos->valor; break;
		case 1: derecha = der->valor; break;
		case 10: derecha = sumar(der->izq, der->der); break;
		case 11: derecha = restar(der->izq, der->der); break;
		case 12: derecha = multiplicar(der->izq, der->der); break;
		case 13: derecha = dividir(der->izq, der->der); break;
	}
	
	/* printf("Multiplicacion izquierda: %f, derecha: %f\n", izquierda, derecha); */
	return izquierda * derecha;
}

float dividir(nodo_arbol* izq, nodo_arbol* der) {
	float izquierda = 1.0;
	float derecha = 1.0;

	switch(izq->definicion) {
		case 0: izquierda = izq->direccion_tabla_simbolos->valor; break;
		case 1: izquierda = izq->valor; break;
		case 10: izquierda = sumar(izq->izq, izq->der); break;
		case 11: izquierda = restar(izq->izq, izq->der); break;
		case 12: izquierda = multiplicar(izq->izq, izq->der); break;
		case 13: izquierda = dividir(izq->izq, izq->der); break;
	}

	switch(der->definicion) {
		case 0: derecha = der->direccion_tabla_simbolos->valor; break;
		case 1: derecha = der->valor; break;
		case 10: derecha = sumar(der->izq, der->der); break;
		case 11: derecha = restar(der->izq, der->der); break;
		case 12: derecha = multiplicar(der->izq, der->der); break;
		case 13: derecha = dividir(der->izq, der->der); break;		
	}
	
	/* printf("Multiplicacion izquierda: %f, derecha: %f\n", izquierda, derecha); */
	return izquierda / derecha;
}

void imprimir(nodo_arbol* nodo) {
	if(nodo->definicion == 0) {
		if(nodo->tipo == 0) {
			printf("%d\n", (int)nodo->direccion_tabla_simbolos->valor);
		} else {
			printf("%f\n", nodo->direccion_tabla_simbolos->valor);
		}	
	}

	if(nodo->definicion == 10) {
		float resultado = sumar(nodo->izq, nodo->der);
		if(nodo->tipo == 0) {
			printf("%d\n", (int)resultado);
		} else {
			printf("%f\n", resultado);
		}
	}

	if(nodo->definicion == 11) {
		float resultado = restar(nodo->izq, nodo->der);
		if(nodo->tipo == 0) {
			printf("%d\n", (int)resultado);
		} else {
			printf("%f\n", resultado);
		}
	}

	if(nodo->definicion == 12) {
		float resultado = multiplicar(nodo->izq, nodo->der);
		if(nodo->tipo == 0) {
			printf("%d\n", (int)resultado);
		} else {
			printf("%f\n", resultado);
		}
	}

	if(nodo->definicion == 13) {
		float resultado = dividir(nodo->izq, nodo->der);
		if(nodo->tipo == 0) {
			printf("%d\n", (int)resultado);
		} else {
			printf("%f\n", resultado);
		}
	}
}

int type_of_input(const char *str) {
  while(*str != '\0') {
    if(*str < '0' || *str > '9') {
			if(*str != '.') {
      	return -1;
			} else {
				return 1;
			}	
		}
    str++;
  }

  return 0;
}

void evaluar_condicional(nodo_arbol* nodo_comparacion, nodo_arbol* nodo_ejecucion_if, nodo_arbol* nodo_ejecucion_else) {
	float comparador_izquierda = 0.0;
	float comparador_derecha = -1.0;
	int comparacion = 0;

	if(nodo_comparacion->izq->definicion == 0) {
		comparador_izquierda = nodo_comparacion->izq->direccion_tabla_simbolos->valor;
	}

	if(nodo_comparacion->izq->definicion == 1) {
		comparador_izquierda = nodo_comparacion->izq->valor;
	}

	if(nodo_comparacion->der->definicion == 0) {
		comparador_derecha = nodo_comparacion->der->direccion_tabla_simbolos->valor;
	}
	
	if(nodo_comparacion->der->definicion == 1) {
		comparador_derecha = nodo_comparacion->der->valor;
	}

	if(nodo_comparacion->definicion == 14) {
		if(comparador_izquierda < comparador_derecha) {
			comparacion = 1;
		}
	}

	if(nodo_comparacion->definicion == 15) {
		if(comparador_izquierda > comparador_derecha) {
			comparacion = 1;
		}
	}

	if(nodo_comparacion->definicion == 16) {
		if(comparador_izquierda == comparador_derecha) {
			comparacion = 1;
		}
	}

	if(nodo_comparacion->definicion == 17) {
		if(comparador_izquierda <= comparador_derecha) {
			comparacion = 1;
		}
	}

	if(nodo_comparacion->definicion == 18) {
		if(comparador_izquierda >= comparador_derecha) {
			comparacion = 1;
		}
	}

	if(comparacion) {
		if(nodo_ejecucion_if->definicion == 7) {
			imprimir(nodo_ejecucion_if->centro);
		}

		if(nodo_ejecucion_if->definicion == 8) {
			ejecutar_instrucciones(nodo_ejecucion_if->inicio_instrucciones);
		}
	} else {
		if(nodo_ejecucion_else != NULL) {
			if(nodo_ejecucion_else->definicion == 7) {
				imprimir(nodo_ejecucion_else->centro);
			}

			if(nodo_ejecucion_else->definicion == 8) {
				ejecutar_instrucciones(nodo_ejecucion_else->inicio_instrucciones);
			}
		}
	}
}

void leer(nodo_arbol* nodo) {
	char variable[20];
	float num;
	
	fflush( stdin );
	scanf("%s", variable);
	num = atof(variable);

	if(type_of_input(variable) == 0 && nodo->tipo == 0) {
		nodo->direccion_tabla_simbolos->valor = num;
	} else if(type_of_input(variable) == 1 && nodo->tipo == 1) {
		nodo->direccion_tabla_simbolos->valor = num;
	} else {
		yyerror("La entrada ingresada no es de un tipo valido\n");
	}
}



void ejecutar_instrucciones(nodo_punto_y_coma* nodo) {
	// Caso en el que se debe ejecutar una asignacion
	if(nodo->inicio->definicion == 2) {
		printf("Entre a asignacion\n");
		asignacion(nodo->inicio->izq, nodo->inicio->der);
	}

	// Caso en el que se debe ejecutar un read
	if(nodo->inicio->definicion == 6) {
		leer(nodo->inicio->centro);
	}

	// Caso en el que se debe ejecutar un print
	if(nodo->inicio->definicion == 7) {
		imprimir(nodo->inicio->centro);
	}

	// Caso en el que se debe ejecutar un if...fi
	if(nodo->inicio->definicion == 3) {
		evaluar_condicional(nodo->inicio->izq, nodo->inicio->centro, NULL);
	}

	// Caso en el que se debe ejecutar un if...else
	if(nodo->inicio->definicion == 4) {
		evaluar_condicional(nodo->inicio->izq, nodo->inicio->centro, nodo->inicio->der);
	}

	if(nodo->siguiente_instruccion != NULL) {
		ejecutar_instrucciones(nodo->siguiente_instruccion);
	}

}

void imprimir_tabla_de_simbolos(nodo_lista_ligada* nodo) {
	// Si la cabeza de la lista ligada es NULL, la tabla de símbolos está vacía
	if(nodo == NULL) {
		printf("Tabla de simbolos vacia\n");
		return;
	}

	// Se imprime el nodo actual
	printf("Variable: %s\tTipo: %d\n", nodo->nombre_variable, nodo->tipo);

	// Si el nodo actual no es el último elemento de la lista ligada, se manda a imprimir el siguiente nodo
	if(nodo->simbolo_siguiente != NULL) {
		imprimir_tabla_de_simbolos(nodo->simbolo_siguiente);
	}	
}

nodo_lista_ligada* unir_tabla_de_simbolos(nodo_lista_ligada* nodo1, nodo_lista_ligada* nodo2) {
	// El nodo1 guarda un apuntador hacia el nodo2
	nodo1->simbolo_siguiente = nodo2;
	return nodo1;
}

nodo_lista_ligada* crear_nodo_de_tabla_de_simbolos(char variable[20], int tipo) {
	// Se crea un nodo en el que se almacenará la variable
	nodo_lista_ligada* nuevo_nodo;
	nuevo_nodo = (nodo_lista_ligada*)malloc( sizeof(nodo_lista_ligada) );

	// Se almacenan los datos en el nodo
	nuevo_nodo->tipo = tipo;
	nuevo_nodo->valor = 0;
	nuevo_nodo->simbolo_siguiente = NULL;
	strncpy(nuevo_nodo->nombre_variable, variable, 20);

	return nuevo_nodo;
}

nodo_arbol* crear_nodo_arbol(int definicion, int tipo, float valor, nodo_lista_ligada* direccion_tabla_simbolos, nodo_punto_y_coma* inicio_instrucciones, nodo_arbol* izq, nodo_arbol* centro, nodo_arbol* der) {
	// Si se trata de un stmt de una asignación, comprobar que a la izq esté una variable
	if(definicion == 2) {
		if(izq->definicion != 0) {
			yyerror("A la izquierda de una asignacion debe encontrarse una variable");
			return NULL;
		}
	}

	if(inicio_instrucciones != NULL) {
		printf("Asignando un nodo punto y coma\n");
	}

	// Se crea un nodo
	nodo_arbol* nuevo_nodo;
	nuevo_nodo = (nodo_arbol*)malloc( sizeof(nodo_arbol) );

	// Se almacenan los datos en el nodo
	nuevo_nodo->definicion = definicion;
	nuevo_nodo->tipo = tipo;
	nuevo_nodo->valor = valor;
	nuevo_nodo->direccion_tabla_simbolos = direccion_tabla_simbolos;
	nuevo_nodo->inicio_instrucciones = inicio_instrucciones;
	nuevo_nodo->izq = izq;
	nuevo_nodo->centro = centro;
	nuevo_nodo->der = der;

	return nuevo_nodo;
}

nodo_arbol* buscar_identificador(char nombre_variable[20], nodo_lista_ligada* nodo_a_buscar) {
	if(nodo_a_buscar == NULL) {
		yyerror("Simbolo no encontrado en la tabla de simbolos");
		return NULL;
	}
	
	if(strcmp(nombre_variable, nodo_a_buscar->nombre_variable) == 0) {
		nodo_arbol* nodo_encontrado;
		nodo_encontrado = (nodo_arbol*)malloc( sizeof(nodo_arbol) );

		nodo_encontrado->definicion = 0;
		nodo_encontrado->tipo = nodo_a_buscar->tipo;
		nodo_encontrado->valor = -1;
		nodo_encontrado->direccion_tabla_simbolos = nodo_a_buscar;
		nodo_encontrado->izq = NULL;
		nodo_encontrado->centro = NULL;
		nodo_encontrado->der = NULL;

		return nodo_encontrado;
	}
	
	if(nodo_a_buscar->simbolo_siguiente == NULL) {
			yyerror("Simbolo no encontrado en la tabla de simbolos");
			return NULL;
	}

	buscar_identificador(nombre_variable, nodo_a_buscar->simbolo_siguiente);	
}

nodo_arbol* asignar_tipo(nodo_arbol* nodo) {
	if(nodo->definicion == 2 || nodo->definicion == 10 || nodo->definicion == 11 || nodo->definicion == 12 || nodo->definicion == 13 || nodo->definicion == 14 || nodo->definicion == 15 || nodo->definicion == 16 || nodo->definicion == 17 || nodo->definicion == 18) {
		if(nodo->izq->tipo != nodo->der->tipo) {
			yyerror("Los tipos no coinciden");
			return nodo;
		}
		nodo->tipo = nodo->izq->tipo;
	}

	if(nodo->definicion == 3) {
		if(nodo->izq->tipo != nodo->centro->tipo) {
			yyerror("Los tipos no coinciden");
			return nodo;
		}
		nodo->tipo = nodo->izq->tipo;
	}

	if(nodo->definicion == 6 || nodo->definicion == 7) {
		nodo->tipo = nodo->centro->tipo;
	}

	return nodo;
}

nodo_punto_y_coma* crear_instruccion(nodo_arbol* inicio, nodo_punto_y_coma* siguiente_instruccion) {
	nodo_punto_y_coma* nodo_instruccion;
	nodo_instruccion = (nodo_punto_y_coma*)malloc( sizeof(nodo_punto_y_coma) );

	nodo_instruccion->inicio = inicio;
	nodo_instruccion->siguiente_instruccion = siguiente_instruccion;

	return nodo_instruccion;
}

nodo_punto_y_coma* unir_instrucciones(nodo_punto_y_coma* nodo1, nodo_punto_y_coma* nodo2) {
	// El nodo1 guarda un apuntador hacia el nodo2
	nodo1->siguiente_instruccion = nodo2;
	return nodo1;
}

// Funciones para debuggear
void imprimir_instrucciones(nodo_punto_y_coma* nodo) {
	imprimir_nodo(nodo->inicio);

	if(nodo->siguiente_instruccion != NULL) {
		imprimir_instrucciones(nodo->siguiente_instruccion);
	}
}

void imprimir_nodo(nodo_arbol* nodo) {
	printf("Informacion nodo: definicion -> %d, tipo -> %d, valor -> %f\n", nodo->definicion, nodo->tipo, nodo->valor);

	if(nodo->izq != NULL) {
		imprimir_nodo(nodo->izq);
	}

	if(nodo->der != NULL) {
		imprimir_nodo(nodo->der);
	}
}

int yyerror(char const * s) {
	if(numero_linea > 0) {
		fprintf(stderr, "Error en linea %d: %s\n\n", numero_linea, s);
	} else {
		fprintf(stderr, "Error: %s\n\n", s);
	}	
	exit(1);
}

void main(int argc, char **argv) {
  if (argc < 2) {
    printf ("Error, falta el nombre de un archivo\n");
    exit(1);
  }

  yyin = fopen(argv[1], "r");

  if (yyin == NULL) {
    printf("Error: el archivo no existe\n");
    exit(1);
  }

  yyparse();

	numero_linea = 0;
	if(cabeza_instrucciones != NULL) {
		ejecutar_instrucciones(cabeza_instrucciones); 
	}
  
}
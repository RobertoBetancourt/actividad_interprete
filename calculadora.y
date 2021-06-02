/* 
	Este archivo contiene un reconocedor de expresiones aritméticas junto
   con algunas reglas semánticas que calculan los valores de las
   expresiones que se reconocen. Las expresiones son muy sencillas y
   consisten únicamente de sumas, restas, multiplicaciones, divisiones, módulo y potencias de números enteros.

  Los comandos para compilar y ejecutar son: 
    flex calculadora.l
    bison -d calculadora.y
    gcc lex.yy.c calculadora.tab.c -lfl -lm
    ./a.out < prueba.txt
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
	int definicion; // 0 es variable, 1 es constante, 2 es stmt de asignacion, 7 es stmt de print, 10 es suma, 11 es resta, 12 es multiplicación, 13 es división
	int tipo; // 0 es int, 1 es float
	float valor; // Campo utilizado solo para constantes
	nodo_lista_ligada* direccion_tabla_simbolos; // Campo utilizado solo para variables
	nodo_arbol* izq;
	nodo_arbol* centro; // Campo utilizado solo en los if
	nodo_arbol* der;
};

struct estructura_punto_y_coma {
	nodo_arbol* inicio;
	nodo_punto_y_coma* siguiente_instruccion;
}; 

extern int numero_linea;
extern int yylex();
int yyerror(char const * s);
void imprimir_valor(nodo_arbol* n);
void recorrer_arbol(nodo_arbol* n);

nodo_arbol* buscar_identificador(char nombre_variable[20], nodo_lista_ligada* nodo_a_buscar);
nodo_arbol* crear_nodo_arbol(int definicion, int tipo, float valor, nodo_lista_ligada* direccion_tabla_simbolos, nodo_arbol* izq, nodo_arbol* centro, nodo_arbol* der);
nodo_arbol* asignar_tipo(nodo_arbol* nodo);

nodo_lista_ligada* unir_tabla_de_simbolos(nodo_lista_ligada* nodo1, nodo_lista_ligada* nodo2);
nodo_lista_ligada* crear_nodo_de_tabla_de_simbolos(char nombre_variable[20], int tipo); // 0 es int, 1 es float

nodo_punto_y_coma* crear_instruccion(nodo_arbol* inicio, nodo_punto_y_coma* siguiente_instruccion);
nodo_punto_y_coma* unir_instrucciones(nodo_punto_y_coma* nodo1, nodo_punto_y_coma* nodo2);

float sumar(nodo_arbol* izq, nodo_arbol* der);
float restar(nodo_arbol* izq, nodo_arbol* der);
float multiplicar(nodo_arbol* izq, nodo_arbol* der);
float dividir(nodo_arbol* izq, nodo_arbol* der);

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

prog : opt_decls BEGIN_RESERVADA opt_stmts END_RESERVADA		/*{printf("TABLA DE SIMBOLOS:\n"); imprimir_tabla_de_simbolos($1);}*/
;

opt_decls : /*epsilon*/											{$$ = NULL;}		
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

opt_stmts : /*epsilon*/									
					| stmt_lst												{cabeza_instrucciones = $1; ejecutar_instrucciones(cabeza_instrucciones); $$ = $$;}
;

stmt_lst : stmt PUNTO_Y_COMA stmt_lst				{$$ = crear_instruccion($1, $3);}
				 | stmt															{$$ = crear_instruccion($1, NULL);}
;

stmt : IDENTIFICADOR ASIGNACION expr						{	nodo_arbol* nodo = crear_nodo_arbol(2, -1, -1, NULL, buscar_identificador($1, cabeza_tabla_de_simbolos), NULL, $3);
																						 			asignar_tipo(nodo);
																						 			$$ = nodo;	}
		 | IF_RESERVADA PARENI expression PAREND stmt FI_RESERVADA
		 | IF_RESERVADA PARENI expression PAREND stmt ELSE_RESERVADA stmt
		 | WHILE_RESERVADA PARENI expression PAREND stmt
		 | FOR_RESERVADA IDENTIFICADOR ASIGNACION expr TO_RESERVADA expr STEP_RESERVADA expr DO_RESERVADA stmt
		 | READ_RESERVADA IDENTIFICADOR
		 | PRINT_RESERVADA expr											{	nodo_arbol* nodo = crear_nodo_arbol(7, -1, -1, NULL, NULL, $2, NULL);
																						 			asignar_tipo(nodo);
																						 			$$ = nodo;	}
		 | BEGIN_RESERVADA opt_stmts END_RESERVADA
;

expr : expr SUMA term							{	nodo_arbol* nodo = crear_nodo_arbol(10, -1, -1, NULL, $1, NULL, $3);
																		asignar_tipo(nodo);
																		$$ = nodo;	}
     | expr RESTA term						{	nodo_arbol* nodo = crear_nodo_arbol(11, -1, -1, NULL, $1, NULL, $3);
																		asignar_tipo(nodo);
																		$$ = nodo;	}
     | term												{ $$ = $$; }
;

term : term MULTI factor					{	nodo_arbol* nodo = crear_nodo_arbol(12, -1, -1, NULL, $1, NULL, $3);
																		asignar_tipo(nodo);
																		$$ = nodo;	}
     | term DIVIDE factor					{	nodo_arbol* nodo = crear_nodo_arbol(13, -1, -1, NULL, $1, NULL, $3);
																		asignar_tipo(nodo);
																		$$ = nodo;	}
     | factor											{ $$ = $$; }
;

factor : PARENI expr PAREND				{$$ = $2;}
       | IDENTIFICADOR						{$$ = buscar_identificador($1, cabeza_tabla_de_simbolos);}
			 | ENTERO										{$$ = crear_nodo_arbol(1, 0, $1, NULL, NULL, NULL, NULL);}
			 | FLOTANTE									{$$ = crear_nodo_arbol(1, 1, $1, NULL, NULL, NULL, NULL);}
;

expression : expr MENOR_QUE expr
					 | expr MAYOR_QUE expr
					 | expr IGUAL_QUE expr
					 | expr MENOR_O_IGUAL_QUE expr
					 | expr MAYOR_O_IGUAL_QUE expr
;

%%


/* void recorrer_arbol(nodo_arbol* n) {
	if(n->tipo == 0) {
		imprimir_valor(n);
		return;
	}
	
	recorrer_arbol(n->izq);
	recorrer_arbol(n->der);
	imprimir_valor(n);
} */

void asignacion(nodo_arbol* nodo_izq, nodo_arbol* nodo_der) {
	nodo_izq->direccion_tabla_simbolos->valor = nodo_der->valor;
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

void ejecutar_instrucciones(nodo_punto_y_coma* nodo) {
	// Caso en el que se debe ejecutar una asignacion
	if(nodo->inicio->definicion == 2) {
		asignacion(nodo->inicio->izq, nodo->inicio->der);
	}

	// Caso en el que se debe ejecutar un print
	if(nodo->inicio->definicion == 7) {
		imprimir(nodo->inicio->centro);
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

nodo_arbol* crear_nodo_arbol(int definicion, int tipo, float valor, nodo_lista_ligada* direccion_tabla_simbolos, nodo_arbol* izq, nodo_arbol* centro, nodo_arbol* der) {
	// Si se trata de un stmt de una asignación, comprobar que a la izq esté una variable
	if(definicion == 2) {
		if(izq->definicion != 0) {
			yyerror("A la izquierda de una asignacion debe encontrarse una variable");
			return NULL;
		}
	}

	// Se crea un nodo
	nodo_arbol* nuevo_nodo;
	nuevo_nodo = (nodo_arbol*)malloc( sizeof(nodo_arbol) );

	// Se almacenan los datos en el nodo
	nuevo_nodo->definicion = definicion;
	nuevo_nodo->tipo = tipo;
	nuevo_nodo->valor = valor;
	nuevo_nodo->direccion_tabla_simbolos = direccion_tabla_simbolos;
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
	if(nodo->definicion == 2 || nodo->definicion == 10 || nodo->definicion == 11 || nodo->definicion == 12 || nodo->definicion == 13) {
		if(nodo->izq->tipo != nodo->der->tipo) {
			yyerror("Los tipos no coinciden");
			return nodo;
		}
		nodo->tipo = nodo->izq->tipo;
	}

	if(nodo->definicion == 7) {
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
  fprintf(stderr, "Error en linea %d: %s\n\n", numero_linea, s);
	exit(1);
}

void main() {
  yyparse();
}

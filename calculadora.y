/* 
	Este archivo contiene un reconocedor de expresiones aritméticas junto
   con algunas reglas semánticas que calculan los valores de las
   expresiones que se reconocen. Las expresiones son muy sencillas y
   consisten únicamente de sumas, restas, multiplicaciones, divisiones, módulo y potencias de números enteros.

  Los comandos para compilar y ejecutar son: 
    flex calculadora.lex
    bison -d calculadora.y
    gcc lex.yy.c calculadora.tab.c -lfl -lm
    ./a.out
*/

%{
#include<stdio.h>
#include<math.h>
#include <stdint.h>
#define YYSTYPE nodo*

typedef struct estructura_tabla nodo_simbolo;

typedef struct estructura_nodo nodo;

struct estructura_tabla {
	char nombre_variable[10];
	int tipo;
	float valor_inicial;
	nodo_simbolo* simbolo_siguiente;
};

struct estructura_nodo {
	int tipo; // 0 es un numero, 1 es un operando
	int valor; // Si el tipo es operando, 0 es suma, 1 es resta, 2 es multiplicación, 3 es división, 4 es módulo, 5 es potencia
	nodo* izq;
	nodo* der;
};

extern int yylex();
int yyerror(char const * s);
void imprimir_valor(nodo* n);
void recorrer_arbol(nodo* n);
nodo* nuevo_nodo(int tipo, float valor, nodo* izq, nodo* der);
nodo* agregar_tabla(int tipo, float valor_inicial, nodo_simbolo* simbolo_anterior, char nombre_variable [10], nodo_simbolo* nodo_raiz);
nodo_simbolo* nodo_raiz = NULL;
nodo_simbolo* nodo_anterior = NULL;

%}

/* Los elementos terminales de la gramática. La declaración de abajo se
   convierte en definición de constantes en el archivo calculadora.tab.h
   que hay que incluir en el archivo de flex. */
%union {
  int entero;
	float flotante;
  nodo* n;
}

%token <entero> ENTERO
%token <flotante> FLOTANTE
%token <n> IDENTIFICADOR ASIGNACION TIPO_ENTERO TIPO_FLOTANTE SUMA RESTA DIVIDE MULTI PAREND PARENI DOS_PUNTOS PUNTO_Y_COMA BEGIN_RESERVADA END_RESERVADA IF_RESERVADA FI_RESERVADA ELSE_RESERVADA WHILE_RESERVADA FOR_RESERVADA TO_RESERVADA STEP_RESERVADA DO_RESERVADA READ_RESERVADA PRINT_RESERVADA MENOR_QUE MAYOR_QUE IGUAL_QUE MENOR_O_IGUAL_QUE MAYOR_O_IGUAL_QUE
%start prog

%%

prog : opt_decls BEGIN_RESERVADA opt_stmts END_RESERVADA
;

opt_decls : /*epsilon*/
					| decl_lst
;

decl_lst : decl PUNTO_Y_COMA decl_lst
				 | decl
;

decl : IDENTIFICADOR DOS_PUNTOS tipo {$$ = agregar_tabla($3, 0, nodo_anterior, $1, nodo_raiz);}
;

tipo : TIPO_ENTERO
		 | TIPO_FLOTANTE
;

stmt : IDENTIFICADOR ASIGNACION expr
		 | IF_RESERVADA PARENI expression PAREND stmt FI_RESERVADA
		 | IF_RESERVADA PARENI expression PAREND stmt ELSE_RESERVADA stmt
		 | WHILE_RESERVADA PARENI expression PAREND stmt
		 | FOR_RESERVADA IDENTIFICADOR ASIGNACION expr TO_RESERVADA expr STEP_RESERVADA expr DO_RESERVADA stmt
		 | READ_RESERVADA IDENTIFICADOR
		 | PRINT_RESERVADA expr
		 | BEGIN_RESERVADA opt_stmts END_RESERVADA
;

opt_stmts : /*epsilon*/
					| stmt_lst
;

stmt_lst : stmt PUNTO_Y_COMA stmt_lst
				 | stmt
;

expr : expr SUMA term    		{$$ = nuevo_nodo(1, 0, $1, $3);}
     | expr RESTA term   		{$$ = nuevo_nodo(1, 1, $1, $3);}
     | term									{$$ = $$;}
;

term : term MULTI factor   	{$$ = nuevo_nodo(1, 2, $1, $3);}
     | term DIVIDE factor  	{$$ = nuevo_nodo(1, 3, $1, $3);}
     | factor								{$$ = $$;}
;

factor : PARENI expr PAREND  	{$$ = $2;}
       | IDENTIFICADOR				{$$ = nuevo_nodo(0, (intptr_t)$1, NULL, NULL);}
			 | ENTERO								
			 | FLOTANTE
;

expression : expr MENOR_QUE expr
					 | expr MAYOR_QUE expr
					 | expr IGUAL_QUE expr
					 | expr MENOR_O_IGUAL_QUE expr
					 | expr MAYOR_O_IGUAL_QUE expr
;

%%


void imprimir_valor(nodo* n) {
	if(n->tipo == 0) {
		printf("%d\n", n->valor);
	} else {
		switch(n->valor) {
			case 0: printf("+\n"); break;
			case 1: printf("-\n"); break;
			case 2: printf("*\n"); break;
			case 3: printf("/\n"); break;
			case 4: printf("%%\n"); break;
			case 5: printf("^\n"); break;
			default: break;
		}
	}
}

void recorrer_arbol(nodo* n) {
	if(n->tipo == 0) {
		imprimir_valor(n);
		return;
	}
	
	recorrer_arbol(n->izq);
	recorrer_arbol(n->der);
	imprimir_valor(n);
}

nodo* agregar_tabla(int tipo, float valor_inicial, nodo_simbolo* simbolo_anterior, char nombre_variable [10], nodo_simbolo* nodo_raiz) {
	nodo_simbolo* temp;
	temp = (nodo*)malloc(sizeof(nodo));

	temp->valor_inicial = valor_inicial;
	temp->simbolo_anterior = simbolo_anterior;
	temp->tipo = tipo;
	temp->nombre_variable = nombre_variable;

	if (nodo_raiz == NULL) nodo_raiz = temp;
	
	nodo_anterior = temp;

	return nuevo_nodo(tipo, valor_inicial, NULL, NULL);
}

nodo* nuevo_nodo(int tipo, float valor, nodo* izq, nodo* der) {
	nodo* temp;
	temp = (nodo*)malloc( sizeof(nodo) );
	
	temp->tipo = tipo;
	temp->valor = valor;
	temp->izq = izq;
	temp->der = der;	
	
	return temp;
}

int yyerror(char const * s) {
  fprintf(stderr, "%s\n", s);
}

void main() {

  yyparse();
}

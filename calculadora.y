/*	
		Roberto Betancourt Hernández - A01551525
		Luis Edgar Flores Carpinteyro - A01329971
		Alan Rodrigo Albert Morán - A01328928
		
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
typedef struct estructura_programa nodo_programa;

struct estructura_tabla_simbolos {
	char nombre_variable[20];
	int tipo; // 0 es int, 1 es float
	float valor;
	nodo_lista_ligada* simbolo_siguiente;
};

struct estructura_arbol {
	int definicion; // 0 es variable, 1 es constante, 2 es asignacion, 3 es if fi, 4 es if else, 5 es while, 6 es read, 7 es print, 8 es begin, 10 es suma, 11 es resta, 12 es multiplicación, 13 es división, 14 es menor que 
	int tipo; // 0 es int, 1 es float
	float valor; // Campo utilizado solo para constantes
	char nombre_variable[20]; // Campo utilizado solo para variables
	nodo_punto_y_coma* inicio_instrucciones; // Campo utilizado solo en los bloques begin...end
	nodo_arbol* izq;
	nodo_arbol* centro; // Campo utilizado solo en los if y print
	nodo_arbol* der;
	nodo_arbol* step; // Campo utilizado solo en los for
	nodo_lista_ligada* direccion_tabla_simbolos; // Campo utilizado solo para variables
};

struct estructura_punto_y_coma {
	nodo_arbol* inicio;
	nodo_punto_y_coma* siguiente_instruccion;
};

struct estructura_programa {
	nodo_lista_ligada* inicio_tabla_de_simbolos;
	nodo_punto_y_coma* inicio_instrucciones;
};

extern int numero_linea;
extern int yylex();
extern FILE *yyin;
int yyerror(char const * s);

nodo_arbol* buscar_identificador(char nombre_variable[20], nodo_lista_ligada* nodo_a_buscar);
nodo_arbol* crear_nodo_arbol(int definicion, int tipo, float valor, char nombre_variable[20], nodo_punto_y_coma* inicio_instrucciones, nodo_arbol* izq, nodo_arbol* centro, nodo_arbol* der, nodo_arbol* step);
nodo_arbol* asignar_tipo(nodo_arbol* nodo);

nodo_lista_ligada* crear_nodo_de_tabla_de_simbolos(char nombre_variable[20], int tipo); // 0 es int, 1 es float
nodo_lista_ligada* unir_nodos_de_tabla_de_simbolos(nodo_lista_ligada* nodo1, nodo_lista_ligada* nodo2);

nodo_punto_y_coma* crear_instruccion(nodo_arbol* inicio, nodo_punto_y_coma* siguiente_instruccion);
nodo_punto_y_coma* unir_instrucciones(nodo_punto_y_coma* nodo1, nodo_punto_y_coma* nodo2);

nodo_programa* crear_nodo_programa(nodo_lista_ligada* inicio_tabla_de_simbolos, nodo_punto_y_coma* inicio_instrucciones);

int tipo_de_entrada(const char *str);

float obtener_valor_nodo(nodo_arbol* nodo);
float sumar(nodo_arbol* izq, nodo_arbol* der);
float restar(nodo_arbol* izq, nodo_arbol* der);
float multiplicar(nodo_arbol* izq, nodo_arbol* der);
float dividir(nodo_arbol* izq, nodo_arbol* der);

void imprimir(nodo_arbol* nodo);
void asignar_valor(nodo_arbol* nodo_izq, nodo_arbol* nodo_der);
void leer(nodo_arbol* nodo);
void ejecutar_if(nodo_arbol* nodo_comparacion, nodo_arbol* nodo_ejecucion_if, nodo_arbol* nodo_ejecucion_else);
void ejecutar_while(nodo_arbol* nodo_comparacion, nodo_arbol* nodo_ejecucion_while);
void ejecutar_for(nodo_arbol* nodo_inicializacion, nodo_arbol* nodo_finalizacion, nodo_arbol* nodo_ejecucion_for, nodo_arbol* nodo_step);
void continuar_for(nodo_arbol* nodo_inicializacion, nodo_arbol* nodo_finalizacion, nodo_arbol* nodo_ejecucion_for, nodo_arbol* nodo_step, float valor_finalizacion, float step);
void ejecutar_instruccion(nodo_arbol* nodo);
void ejecutar_lista_de_instrucciones(nodo_punto_y_coma* nodo);


void revisar_tipos_operacion(nodo_arbol* nodo_operacion, nodo_lista_ligada* inicio_tabla_de_simbolos);
void revisar_tipos(nodo_punto_y_coma* nodo, nodo_lista_ligada* inicio_tabla_de_simbolos);
void ejecutar_revision_de_tipos(nodo_arbol* nodo, nodo_lista_ligada* inicio_tabla_de_simbolos);
void revisar_tipos_for(nodo_arbol* nodo_for, nodo_lista_ligada* inicio_tabla_de_simbolos);
void revisar_tipos_if(nodo_arbol* nodo_if, nodo_lista_ligada* inicio_tabla_de_simbolos);
void revisar_tipos_while(nodo_arbol* nodo_while, nodo_lista_ligada* inicio_tabla_de_simbolos);
void revisar_tipos_read(nodo_arbol* nodo_read, nodo_lista_ligada* inicio_tabla_de_simbolos);
void revisar_tipos_print(nodo_arbol* nodo_read, nodo_lista_ligada* inicio_tabla_de_simbolos);
void revisar_tipos_asignacion(nodo_arbol* nodo_read, nodo_lista_ligada* inicio_tabla_de_simbolos);
void revisar_tipos_nodo(nodo_arbol* nodo_read, nodo_lista_ligada* inicio_tabla_de_simbolos);
// void revisar_tipos_expr(nodo_arbol* nodo_read, nodo_lista_ligada* inicio_tabla_de_simbolos);


nodo_lista_ligada* cabeza_tabla_de_simbolos = NULL;
nodo_punto_y_coma* cabeza_instrucciones = NULL;

nodo_programa* root = NULL;
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

prog : opt_decls BEGIN_RESERVADA opt_stmts END_RESERVADA		{root = crear_nodo_programa($1, $3);}
;

opt_decls : /*epsilon*/											{$$ = NULL;}
					| decl_lst												{$$ = $$;}
;

decl_lst : decl PUNTO_Y_COMA decl_lst				{$$ = unir_nodos_de_tabla_de_simbolos($1, $3);}
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

stmt : IDENTIFICADOR ASIGNACION expr						{ nodo_arbol* nodo_identificador = crear_nodo_arbol(0, -1, -1, $1, NULL, NULL, NULL, NULL, NULL);
																									nodo_arbol* nodo = crear_nodo_arbol(2, -1, -1, "", NULL, nodo_identificador, NULL, $3, NULL);
																						 			$$ = nodo;	}
		 | IF_RESERVADA PARENI expression PAREND stmt FI_RESERVADA				{	$$ = crear_nodo_arbol(3, -1, -1, "", NULL, $3, $5, NULL, NULL);	}
		 | IF_RESERVADA PARENI expression PAREND stmt ELSE_RESERVADA stmt {	$$ = crear_nodo_arbol(4, -1, -1, "", NULL, $3, $5, $7, NULL);	}
		 | WHILE_RESERVADA PARENI expression PAREND stmt									{	$$ = crear_nodo_arbol(5, -1, -1, "", NULL, $3, NULL, $5, NULL);	}
		 | FOR_RESERVADA IDENTIFICADOR ASIGNACION expr TO_RESERVADA expr STEP_RESERVADA expr DO_RESERVADA stmt					{	nodo_arbol* nodo_identificador = crear_nodo_arbol(0, -1, -1, $2, NULL, NULL, NULL, NULL, NULL);
			 																																																								nodo_arbol* nodo_izq = crear_nodo_arbol(2, -1, -1, "", NULL, nodo_identificador, NULL, $4, NULL);
																						 																																					
																																																											nodo_arbol* nodo_step = crear_nodo_arbol(20, -1, -1, "", NULL, NULL, $10, NULL, NULL);
																																																											nodo_arbol* nodo_for = crear_nodo_arbol(19, -1, -1, "", NULL, nodo_izq, $6, $10, $8);
																						 																																					$$ = nodo_for;	}
		 | READ_RESERVADA IDENTIFICADOR							{	nodo_arbol* nodo_identificador = crear_nodo_arbol(0, -1, -1, $2, NULL, NULL, NULL, NULL, NULL);
			 																						nodo_arbol* nodo = crear_nodo_arbol(6, -1, -1, "", NULL, NULL, nodo_identificador, NULL, NULL);
																						 			
																						 			$$ = nodo;	}
		 | PRINT_RESERVADA expr											{	nodo_arbol* nodo = crear_nodo_arbol(7, -1, -1, "", NULL, NULL, $2, NULL, NULL);
																						 			
																						 			$$ = nodo;	}
		 | BEGIN_RESERVADA opt_stmts END_RESERVADA	{$$ = crear_nodo_arbol(8, -1, -1, "", $2, NULL, NULL, NULL, NULL);}
;

expr : expr SUMA term							{	nodo_arbol* nodo = crear_nodo_arbol(10, -1, -1, "", NULL, $1, NULL, $3, NULL);
																		//asignar_tipo(nodo);
																		$$ = nodo;	}
     | expr RESTA term						{	nodo_arbol* nodo = crear_nodo_arbol(11, -1, -1, "", NULL, $1, NULL, $3, NULL);
																		//asignar_tipo(nodo);
																		$$ = nodo;	}
     | term												{ $$ = $$; }
;

term : term MULTI factor					{	nodo_arbol* nodo = crear_nodo_arbol(12, -1, -1, "", NULL, $1, NULL, $3, NULL);
																		//asignar_tipo(nodo);
																		$$ = nodo;	}
     | term DIVIDE factor					{	nodo_arbol* nodo = crear_nodo_arbol(13, -1, -1, "", NULL, $1, NULL, $3, NULL);
																		//asignar_tipo(nodo);
																		$$ = nodo;	}
     | factor											{ $$ = $$; }
;

factor : PARENI expr PAREND				{$$ = $2;}
       | IDENTIFICADOR						{$$ = crear_nodo_arbol(0, -1, -1, $1, NULL, NULL, NULL, NULL, NULL);}
			 | ENTERO										{$$ = crear_nodo_arbol(1, 0, $1, "", NULL, NULL, NULL, NULL, NULL);}
			 | FLOTANTE									{$$ = crear_nodo_arbol(1, 1, $1, "", NULL, NULL, NULL, NULL, NULL);}
;

expression : expr MENOR_QUE expr							{	nodo_arbol* nodo = crear_nodo_arbol(14, -1, -1, "", NULL, $1, NULL, $3, NULL);
																								$$ = nodo;	}
					 | expr MAYOR_QUE expr							{	nodo_arbol* nodo = crear_nodo_arbol(15, -1, -1, "", NULL, $1, NULL, $3, NULL);
																								$$ = nodo;	}
					 | expr IGUAL_QUE expr							{	nodo_arbol* nodo = crear_nodo_arbol(16, -1, -1, "", NULL, $1, NULL, $3, NULL);
																								$$ = nodo;	}
					 | expr MENOR_O_IGUAL_QUE expr 			{	nodo_arbol* nodo = crear_nodo_arbol(17, -1, -1, "", NULL, $1, NULL, $3, NULL);
																								$$ = nodo;	}
					 | expr MAYOR_O_IGUAL_QUE expr			{	nodo_arbol* nodo = crear_nodo_arbol(18, -1, -1, "", NULL, $1, NULL, $3, NULL);
																								$$ = nodo;	}
;

%%

// Función que regresa el valor de un nodo
float obtener_valor_nodo(nodo_arbol* nodo) {
	switch(nodo->definicion) {
		// Caso base 1: el nodo es una variable, por lo que se obtiene su valor de la tabla de símbolos
		case 0: return nodo->direccion_tabla_simbolos->valor; break;
		// Caso base 2: el nodo es una constante, por lo que se obtiene su valor directamente
		case 1: return nodo->valor; break;
		// Casos recursivos de suma, resta, multiplicación y división
		case 10: return sumar(nodo->izq, nodo->der); break;
		case 11: return restar(nodo->izq, nodo->der); break;
		case 12: return multiplicar(nodo->izq, nodo->der); break;
		case 13: return dividir(nodo->izq, nodo->der); break;
	}

	return 0.0;
}

// Funciones para sumar, restar, multiplicar y dividir el valor de dos nodos
float sumar(nodo_arbol* izq, nodo_arbol* der) {
	return obtener_valor_nodo(izq) + obtener_valor_nodo(der);
}

float restar(nodo_arbol* izq, nodo_arbol* der) {
	return obtener_valor_nodo(izq) - obtener_valor_nodo(der);
}

float multiplicar(nodo_arbol* izq, nodo_arbol* der) {
	return obtener_valor_nodo(izq) * obtener_valor_nodo(der);
}

float dividir(nodo_arbol* izq, nodo_arbol* der) {
	return obtener_valor_nodo(izq) / obtener_valor_nodo(der);
}

// Función para imprimir el valor de un nodo
void imprimir(nodo_arbol* nodo) {
	float output = obtener_valor_nodo(nodo);
	if(nodo->tipo == 0) {
		printf("%d\n", (int)output);
	} else {
		printf("%f\n", output);
	}
}

// Función para almacenar en la tabla de símbolos el valor de un nodo
void asignar_valor(nodo_arbol* nodo_izq, nodo_arbol* nodo_der) {
	nodo_izq->direccion_tabla_simbolos->valor = obtener_valor_nodo(nodo_der);
}

// Función que regresa -1 si la entrada es un string, 0 si es un entero, y 1 si es un flotante
int tipo_de_entrada(const char *str) {
	float tipo_entrada = 0;
  while(*str != '\0') {
    if(*str < '0' || *str > '9') {
			if(*str != '.') {
      	tipo_entrada = -1;
			} else if(tipo_entrada == 0) {
				tipo_entrada = 1;
			} else {
				tipo_entrada = -1;
			}
		}
    str++;
  }
  return tipo_entrada;
}

// Función que acepta como input un valor para almacenarlo en una variable
void leer(nodo_arbol* nodo) {
	char input[20];
	float num;
	
	fflush( stdin );
	scanf("%s", input);
	num = atof(input);

	if(tipo_de_entrada(input) == 0 && nodo->tipo == 0) {
		nodo->direccion_tabla_simbolos->valor = num;
	} else if(tipo_de_entrada(input) == 1 && nodo->tipo == 1) {
		nodo->direccion_tabla_simbolos->valor = num;
	} else {
		yyerror("input is not of a valid type\n");
	}

	printf("Leer finalizado\n");
}

// Función que regresa 1 si la comparación de valores entre dos nodos es verdadera
int comparar_valores(nodo_arbol* nodo) {
	float comparador_izquierda = obtener_valor_nodo(nodo->izq);
	float comparador_derecha = obtener_valor_nodo(nodo->der);
	
	switch(nodo->definicion) {
		case 14: if(comparador_izquierda < comparador_derecha) { return 1; } break;
		case 15: if(comparador_izquierda > comparador_derecha) { return 1; } break;
		case 16: if(comparador_izquierda == comparador_derecha) { return 1; } break;
		case 17: if(comparador_izquierda <= comparador_derecha) { return 1; } break;
		case 18: if(comparador_izquierda >= comparador_derecha) { return 1; } break;
	}

	return 0;
}

void ejecutar_if(nodo_arbol* nodo_comparacion, nodo_arbol* nodo_ejecucion_if, nodo_arbol* nodo_ejecucion_else) {
	int comparacion = comparar_valores(nodo_comparacion);

	if(comparacion) {
		ejecutar_instruccion(nodo_ejecucion_if);
	} else if(nodo_ejecucion_else != NULL) {
		ejecutar_instruccion(nodo_ejecucion_else);
	}
}

void ejecutar_while(nodo_arbol* nodo_comparacion, nodo_arbol* nodo_ejecucion_while) {
	int comparacion = comparar_valores(nodo_comparacion);

	if(comparacion) {
		ejecutar_instruccion(nodo_ejecucion_while);
		ejecutar_while(nodo_comparacion, nodo_ejecucion_while);
	}
}

void continuar_for(nodo_arbol* nodo_inicializacion, nodo_arbol* nodo_finalizacion, nodo_arbol* nodo_ejecucion_for, nodo_arbol* nodo_step, float valor_finalizacion, float step) {
	float valor_actual = 0.0;
	valor_actual = nodo_inicializacion->izq->direccion_tabla_simbolos->valor;

	if(valor_actual <= valor_finalizacion) {
		ejecutar_instruccion(nodo_ejecucion_for);
		nodo_inicializacion->izq->direccion_tabla_simbolos->valor += step;
		continuar_for(nodo_inicializacion, nodo_finalizacion, nodo_ejecucion_for, nodo_step, valor_finalizacion, step);
	}	
}

void ejecutar_for(nodo_arbol* nodo_inicializacion, nodo_arbol* nodo_finalizacion, nodo_arbol* nodo_ejecucion_for, nodo_arbol* nodo_step) {
	float valor_inicializacion = 0.0;
	float valor_finalizacion = 0.0;
	float step = 1.0;

	asignar_valor(nodo_inicializacion->izq, nodo_inicializacion->der);
	valor_inicializacion = nodo_inicializacion->izq->direccion_tabla_simbolos->valor;

	switch(nodo_finalizacion->definicion) {
		case 0: valor_finalizacion = nodo_finalizacion->direccion_tabla_simbolos->valor; break;
		case 1: valor_finalizacion = nodo_finalizacion->valor; break;
	}

	if(valor_inicializacion <= valor_finalizacion) {
		ejecutar_instruccion(nodo_ejecucion_for);
		switch(nodo_step->definicion) {
			case 10: step = sumar(nodo_step->izq, nodo_step->der); break;
			case 11: step = restar(nodo_step->izq, nodo_step->der); break;
			case 12: step = multiplicar(nodo_step->izq, nodo_step->der); break;
			case 13: step = dividir(nodo_step->izq, nodo_step->der); break;
		}

		nodo_inicializacion->izq->direccion_tabla_simbolos->valor += step;
		continuar_for(nodo_inicializacion, nodo_finalizacion, nodo_ejecucion_for, nodo_step, valor_finalizacion, step);
	}
}

void ejecutar_instruccion(nodo_arbol* nodo) {
	// Se ejecuta la instrucción dependiendo de si se trata de una asignación, un for, while, print, etc.
	switch(nodo->definicion) {
		case 2: printf("nodo->der->definicion: %d\n", nodo->der->definicion); asignar_valor(nodo->izq, nodo->der); break;
		case 3: ejecutar_if(nodo->izq, nodo->centro, NULL); break;
		case 4: ejecutar_if(nodo->izq, nodo->centro, nodo->der); break;
		case 5: ejecutar_while(nodo->izq, nodo->der); break;
		case 6: leer(nodo->centro); break;
		case 7: imprimir(nodo->centro); break;
		case 8: ejecutar_lista_de_instrucciones(nodo->inicio_instrucciones); break;
		case 19: ejecutar_for(nodo->izq, nodo->centro, nodo->der, nodo->step); break;	
	}
}

// Función que ejecuta las instrucciones que se encuentran en el árbol sintáctico
void ejecutar_lista_de_instrucciones(nodo_punto_y_coma* nodo) {
	printf("Ejecutar instruccion con definicion: %d\n", nodo->inicio->definicion);
	ejecutar_instruccion(nodo->inicio);

	// Si existe, se ejecuta la siguiente instrucción
	if(nodo->siguiente_instruccion != NULL) {
		ejecutar_lista_de_instrucciones(nodo->siguiente_instruccion);
	}
}

// INICIAN FUNCIONES PARA REVISAR Y ASIGNAR TIPOS
void asignar_informacion_variable(nodo_arbol* nodo_variable, nodo_lista_ligada* nodo_a_buscar) {
	if(strcmp(nodo_variable->nombre_variable, nodo_a_buscar->nombre_variable) == 0) {
		printf("Asignando tipo %d a variable %s\n", nodo_a_buscar->tipo, nodo_variable->nombre_variable);
		nodo_variable->tipo = nodo_a_buscar->tipo;
		nodo_variable->direccion_tabla_simbolos = nodo_a_buscar;
	} else {
		if(nodo_a_buscar->simbolo_siguiente != NULL) {
			asignar_informacion_variable(nodo_variable, nodo_a_buscar->simbolo_siguiente);
		} else {
			yyerror("identifier not found\n");
		}
	}
}

void revisar_tipos_nodo(nodo_arbol* nodo, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	if(nodo != NULL) {
		switch(nodo->definicion) {	
			case 0: asignar_informacion_variable(nodo, inicio_tabla_de_simbolos); break;
			case 2: revisar_tipos_asignacion(nodo, inicio_tabla_de_simbolos); break;
			case 5: revisar_tipos_while(nodo, inicio_tabla_de_simbolos); break;
			case 6: revisar_tipos_read(nodo, inicio_tabla_de_simbolos); break;
			case 7: revisar_tipos_print(nodo, inicio_tabla_de_simbolos); break;
			case 8: revisar_tipos(nodo->inicio_instrucciones, inicio_tabla_de_simbolos); break;
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 17:
			case 18:
				revisar_tipos_nodo(nodo->izq, inicio_tabla_de_simbolos); revisar_tipos_nodo(nodo->der, inicio_tabla_de_simbolos); break;
		}
	}	
}

void revisar_tipos_asignacion(nodo_arbol* nodo_asignacion, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	if(nodo_asignacion->izq->definicion != 0) {
		yyerror("an identifier must appear to the left\n");
	}
	asignar_informacion_variable(nodo_asignacion->izq, inicio_tabla_de_simbolos);

	switch(nodo_asignacion->der->definicion) {
		case 0: asignar_informacion_variable(nodo_asignacion->der, inicio_tabla_de_simbolos); break;
		case 10:
		case 11:
		case 12:
		case 13:
			revisar_tipos_operacion(nodo_asignacion->der, inicio_tabla_de_simbolos); break; 
	}

	if(nodo_asignacion->izq->tipo != nodo_asignacion->der->tipo) {
		yyerror("data types do not match");
	}
	nodo_asignacion->tipo = nodo_asignacion->izq->tipo;
}

void revisar_tipos_operacion(nodo_arbol* nodo_operacion, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	switch(nodo_operacion->izq->definicion) {
		case 0: asignar_informacion_variable(nodo_operacion->izq, inicio_tabla_de_simbolos); break;
		case 10:
		case 11:
		case 12:
		case 13:
		case 14:
		case 15:
		case 16:
		case 17:
		case 18:
			revisar_tipos_operacion(nodo_operacion->izq, inicio_tabla_de_simbolos); break;
	}

	switch(nodo_operacion->der->definicion) {
		case 0: asignar_informacion_variable(nodo_operacion->der, inicio_tabla_de_simbolos); break;
		case 10:
		case 12:
		case 13:
		case 14:
		case 15:
		case 16:
		case 17:
		case 18:
			revisar_tipos_operacion(nodo_operacion->der, inicio_tabla_de_simbolos); break;
	}

	if(nodo_operacion->izq->tipo != nodo_operacion->der->tipo) {
		yyerror("different data types\n");
	}
	nodo_operacion->tipo = nodo_operacion->izq->tipo;
}

void revisar_tipos_read(nodo_arbol* nodo_read, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	asignar_informacion_variable(nodo_read->centro, inicio_tabla_de_simbolos);
	nodo_read->tipo = nodo_read->centro->tipo;
}

void revisar_tipos_print(nodo_arbol* nodo_print, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	switch(nodo_print->centro->definicion) {
		case 0: asignar_informacion_variable(nodo_print->centro, inicio_tabla_de_simbolos); break;
		case 10:
		case 11:
		case 12:
		case 13:
			revisar_tipos_operacion(nodo_print->centro, inicio_tabla_de_simbolos); break;
	}
}

void revisar_tipos_while(nodo_arbol* nodo_while, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	revisar_tipos_operacion(nodo_while->izq, inicio_tabla_de_simbolos);

	switch(nodo_while->der->definicion) {
		case 2: revisar_tipos_asignacion(nodo_while->der, inicio_tabla_de_simbolos); break;
		case 5: revisar_tipos_while(nodo_while->der, inicio_tabla_de_simbolos); break;
		case 6: revisar_tipos_read(nodo_while->der, inicio_tabla_de_simbolos); break;
		case 7: revisar_tipos_print(nodo_while->der, inicio_tabla_de_simbolos); break;
		case 8: revisar_tipos(nodo_while->der->inicio_instrucciones, inicio_tabla_de_simbolos); break;
	}
}

void revisar_tipos_if(nodo_arbol* nodo_if, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	revisar_tipos_operacion(nodo_if->izq, inicio_tabla_de_simbolos);

	switch(nodo_if->centro->definicion) {
		case 2: revisar_tipos_asignacion(nodo_if->centro, inicio_tabla_de_simbolos); break;
		case 5: revisar_tipos_while(nodo_if->centro, inicio_tabla_de_simbolos); break;
		case 6: revisar_tipos_read(nodo_if->centro, inicio_tabla_de_simbolos); break;
		case 7: revisar_tipos_print(nodo_if->centro, inicio_tabla_de_simbolos); break;
		case 8: revisar_tipos(nodo_if->centro->inicio_instrucciones, inicio_tabla_de_simbolos); break;
	}

	if(nodo_if->der != NULL) {
		switch(nodo_if->der->definicion) {
			case 2: revisar_tipos_asignacion(nodo_if->der, inicio_tabla_de_simbolos); break;
			case 5: revisar_tipos_while(nodo_if->der, inicio_tabla_de_simbolos); break;
			case 6: revisar_tipos_read(nodo_if->der, inicio_tabla_de_simbolos); break;
			case 7: revisar_tipos_print(nodo_if->der, inicio_tabla_de_simbolos); break;
			case 8: revisar_tipos(nodo_if->der->inicio_instrucciones, inicio_tabla_de_simbolos); break;
		}
	}
}

void revisar_tipos_for(nodo_arbol* nodo_for, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	revisar_tipos_operacion(nodo_for->izq, inicio_tabla_de_simbolos);
	switch(nodo_for->centro->definicion) {
		case 0: asignar_informacion_variable(nodo_for->centro, inicio_tabla_de_simbolos); break;
		case 10:
		case 11:
		case 12:
		case 13:
			revisar_tipos_operacion(nodo_for->centro, inicio_tabla_de_simbolos); break; 
	}

	ejecutar_revision_de_tipos(nodo_for->der, inicio_tabla_de_simbolos);

	switch(nodo_for->step->definicion) {
		case 0: asignar_informacion_variable(nodo_for->step, inicio_tabla_de_simbolos); break;
		case 10:
		case 11:
		case 12:
		case 13:
			revisar_tipos_operacion(nodo_for->step, inicio_tabla_de_simbolos); break; 
	}
}

void ejecutar_revision_de_tipos(nodo_arbol* nodo, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	// Se ejecuta la revision de tipos dependiendo de si se trata de una asignación, un for, while, print, etc.
	switch(nodo->definicion) {
		case 2: revisar_tipos_asignacion(nodo, inicio_tabla_de_simbolos); break;
		case 3:
		case 4:
			revisar_tipos_if(nodo, inicio_tabla_de_simbolos); break;
		case 5: revisar_tipos_while(nodo, inicio_tabla_de_simbolos); break;
		case 6: revisar_tipos_read(nodo, inicio_tabla_de_simbolos); break;
		case 7: revisar_tipos_print(nodo, inicio_tabla_de_simbolos); break;
		case 8: revisar_tipos(nodo->inicio_instrucciones, inicio_tabla_de_simbolos); break;
		case 19: revisar_tipos_for(nodo, inicio_tabla_de_simbolos); break;
	}
}

// Función que revisa tipos
void revisar_tipos(nodo_punto_y_coma* nodo, nodo_lista_ligada* inicio_tabla_de_simbolos) {
	printf("nodo->inicio->definicion: %d\n", nodo->inicio->definicion);
	ejecutar_revision_de_tipos(nodo->inicio, inicio_tabla_de_simbolos);

	// Si existe, se ejecuta la siguiente instrucción
	if(nodo->siguiente_instruccion != NULL) {
		revisar_tipos(nodo->siguiente_instruccion, inicio_tabla_de_simbolos);
	}
}
// TERMINAN FUNCIONES PARA REVISAR Y ASIGNAR TIPOS

// Se crea la tabla de símbolos con las distintas variables
nodo_lista_ligada* unir_nodos_de_tabla_de_simbolos(nodo_lista_ligada* nodo1, nodo_lista_ligada* nodo2) {
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

// Se busca un identificador en la tabla de símbolos
nodo_arbol* buscar_identificador(char nombre_variable[20], nodo_lista_ligada* nodo_a_buscar) {
	if(nodo_a_buscar == NULL) {
		yyerror("Identifier not found");
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
			yyerror("identifier not found");
			return NULL;
	}

	buscar_identificador(nombre_variable, nodo_a_buscar->simbolo_siguiente);
}

nodo_arbol* crear_nodo_arbol(int definicion, int tipo, float valor, char nombre_variable[20], nodo_punto_y_coma* inicio_instrucciones, nodo_arbol* izq, nodo_arbol* centro, nodo_arbol* der, nodo_arbol* step) {
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
	nuevo_nodo->direccion_tabla_simbolos = NULL;
	nuevo_nodo->inicio_instrucciones = inicio_instrucciones;
	nuevo_nodo->izq = izq;
	nuevo_nodo->centro = centro;
	nuevo_nodo->der = der;
	nuevo_nodo->step = step;
	strncpy(nuevo_nodo->nombre_variable, nombre_variable, 20);

	return nuevo_nodo;
}


// Se asigna el tipo de un nodo con base en su(s) nodo(s) hijo(s)
nodo_arbol* asignar_tipo(nodo_arbol* nodo) {
	switch(nodo->definicion) {
		// Para el read y print, se asigna el tipo del único nodo hijo
		case 6:
		case 7:
			nodo->tipo = nodo->centro->tipo;
			break;
		// Para la asignación, operaciones, comparaciones, se debe comprobar los tipos de su nodo hijo izquierdo y derecho
		case 2:
		case 10:
		case 11:
		case 12:
		case 13:
		case 14:
		case 15:
		case 16:
		case 17:
		case 18:
			if(nodo->izq->tipo != nodo->der->tipo) {
				yyerror("data types do not match");
				return nodo;
			}
			nodo->tipo = nodo->izq->tipo;
			break;
	}

	return nodo;
}

// A cada instrucción se le asigna un "nodo punto y coma" como nodo padre: estos serán los que lleven la secuencia de las instrucciones
nodo_punto_y_coma* crear_instruccion(nodo_arbol* inicio, nodo_punto_y_coma* siguiente_instruccion) {
	nodo_punto_y_coma* nodo_instruccion;
	nodo_instruccion = (nodo_punto_y_coma*)malloc( sizeof(nodo_punto_y_coma) );
	nodo_instruccion->inicio = inicio;
	nodo_instruccion->siguiente_instruccion = siguiente_instruccion;
	return nodo_instruccion;
}

// Se unen los "nodos punto y coma" para posteriormente ejecutar las instrucciones
nodo_punto_y_coma* unir_instrucciones(nodo_punto_y_coma* nodo1, nodo_punto_y_coma* nodo2) {
	nodo1->siguiente_instruccion = nodo2;
	return nodo1;
}

nodo_programa* crear_nodo_programa(nodo_lista_ligada* inicio_tabla_de_simbolos, nodo_punto_y_coma* inicio_instrucciones) {
	nodo_programa* nodo;
	nodo = (nodo_programa*)malloc( sizeof(nodo_programa) );
	nodo->inicio_instrucciones = inicio_instrucciones;
	nodo->inicio_tabla_de_simbolos = inicio_tabla_de_simbolos;
	return nodo;
}

int yyerror(char const * s) {
	if(numero_linea > 0) {
		fprintf(stderr, "Error on line %d: %s\n\n", numero_linea, s);
	} else {
		fprintf(stderr, "Error: %s\n\n", s);
	}	
	exit(1);
}

void main(int argc, char **argv) {
  if (argc < 2) {
    printf ("Error: falta el nombre de un archivo\n");
    exit(1);
  }

  yyin = fopen(argv[1], "r");

  if (yyin == NULL) {
    printf("Error: el archivo no existe\n");
    exit(1);
  }

  yyparse();

	numero_linea = 0;
	printf("Sigo vivo1\n");
	if(root->inicio_instrucciones != NULL) {
		printf("Sigo vivo2\n");
		revisar_tipos(root->inicio_instrucciones, root->inicio_tabla_de_simbolos);
		printf("Sigo vivo3\n\n\n");
		ejecutar_lista_de_instrucciones(root->inicio_instrucciones);
	}
}
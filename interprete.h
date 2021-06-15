#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct estructura_tabla_simbolos nodo_tabla_de_simbolos;
typedef struct estructura_arbol nodo_arbol;
typedef struct estructura_punto_y_coma nodo_punto_y_coma;
typedef struct estructura_programa nodo_programa;
typedef struct estructura_parametros nodo_parametro;
typedef struct estructura_funciones nodo_funcion;
typedef struct estructura_tabla_y_parametro nodo_tabla_y_parametro;
typedef struct estructura_argumento nodo_argumento;

struct estructura_argumento {
	nodo_arbol* nodo_expresion;
	nodo_argumento* siguiente_nodo;
};

struct estructura_tabla_y_parametro {
	nodo_tabla_de_simbolos* nodo_tabla;
	nodo_parametro* nodo_parametro;
	nodo_tabla_y_parametro* nodo_siguiente;
};

struct estructura_funciones {
	char nombre_funcion[20];
	int tipo; // -1 es void, 0 es int, 1 es float
	nodo_tabla_de_simbolos* tabla_de_simbolos_local;
	int num_parametros;
	nodo_parametro* parametro_inicial;
	nodo_punto_y_coma* inicio_instrucciones;
	nodo_funcion* siguiente_funcion;
};

struct estructura_parametros {
	char nombre_parametro[20];
	nodo_parametro* siguiente_parametro;
};

struct estructura_tabla_simbolos {
	char nombre_variable[20];
	int tipo; // 0 es int, 1 es float
	float valor;
	nodo_tabla_de_simbolos* simbolo_siguiente;
};

struct estructura_arbol {
	int definicion; // 0 es variable, 1 es constante, 2 es asignacion, 3 es if fi, 4 es if else, 5 es while, 6 es read, 7 es print, 8 es begin, 10 es suma, 11 es resta, 12 es multiplicación, 13 es división, 14 es menor que, 19 es for, 20 es return, 21 es para llamar a una funcion
	int tipo; // 0 es int, 1 es float
	float valor; // Campo utilizado solo para constantes
	char nombre_variable[20]; // Campo utilizado solo para variables
	nodo_punto_y_coma* inicio_instrucciones; // Campo utilizado solo en los bloques begin...end
	nodo_arbol* izq;
	nodo_arbol* centro; // Campo utilizado solo en los if y print
	nodo_arbol* der;
	nodo_arbol* step; // Campo utilizado solo en los for
	nodo_tabla_de_simbolos* direccion_tabla_simbolos; // Campo utilizado solo para variables
	nodo_argumento* argumento_funcion; // Campo utilizado solo en las llamadas a funciones
};

struct estructura_punto_y_coma {
	nodo_arbol* inicio;
	nodo_punto_y_coma* siguiente_instruccion;
};

struct estructura_programa {
	nodo_tabla_de_simbolos* inicio_tabla_de_simbolos;
	nodo_punto_y_coma* inicio_instrucciones;
	nodo_funcion* inicio_funciones;
};

extern nodo_programa* root;
extern int numero_linea;
extern int yylex();
extern FILE *yyin;
int yyerror(char const * s);
float retorno = 0;

// nodo_arbol* buscar_identificador(char nombre_variable[20], nodo_tabla_de_simbolos* nodo_a_buscar);
nodo_arbol* crear_nodo_arbol(int definicion, int tipo, float valor, char nombre_variable[20], nodo_punto_y_coma* inicio_instrucciones, nodo_arbol* izq, nodo_arbol* centro, nodo_arbol* der, nodo_arbol* step);
nodo_arbol* asignar_tipo(nodo_arbol* nodo);

nodo_tabla_de_simbolos* crear_nodo_de_tabla_de_simbolos(char nombre_variable[20], int tipo); // 0 es int, 1 es float
nodo_tabla_de_simbolos* unir_nodos_de_tabla_de_simbolos(nodo_tabla_de_simbolos* nodo1, nodo_tabla_de_simbolos* nodo2);

nodo_punto_y_coma* crear_instruccion(nodo_arbol* inicio, nodo_punto_y_coma* siguiente_instruccion);
nodo_punto_y_coma* unir_instrucciones(nodo_punto_y_coma* nodo1, nodo_punto_y_coma* nodo2);

nodo_parametro* crear_nodo_parametro(char nombre_parametro[20], nodo_parametro* siguiente_parametro);
nodo_tabla_y_parametro* unir_nodo_tabla_y_parametro(nodo_tabla_y_parametro* nodo1, nodo_tabla_y_parametro* nodo2);
nodo_tabla_y_parametro* crear_nodo_tabla_y_parametro(nodo_tabla_de_simbolos* nodo_tabla, nodo_parametro* nodo_parametro, nodo_tabla_y_parametro* nodo_siguiente);

nodo_funcion* crear_funcion(char nombre_funcion[20], int tipo, nodo_tabla_de_simbolos* tabla_de_simbolos_local, int num_parametros, nodo_parametro* parametro_inicial, nodo_punto_y_coma* inicio_instrucciones, nodo_funcion* siguiente_funcion);

nodo_programa* crear_nodo_programa(nodo_tabla_de_simbolos* inicio_tabla_de_simbolos, nodo_punto_y_coma* inicio_instrucciones, nodo_funcion* inicio_funciones);

int tipo_de_entrada(const char *str);

float obtener_valor_nodo(nodo_arbol* nodo);
float sumar(nodo_arbol* izq, nodo_arbol* der);
float restar(nodo_arbol* izq, nodo_arbol* der);
float multiplicar(nodo_arbol* izq, nodo_arbol* der);
float dividir(nodo_arbol* izq, nodo_arbol* der);

void imprimir_nodos_tabla_y_parametro(nodo_tabla_y_parametro* nodo);

void imprimir(nodo_arbol* nodo);
void asignar_valor(nodo_arbol* nodo_izq, nodo_arbol* nodo_der);
void leer(nodo_arbol* nodo);
void ejecutar_if(nodo_arbol* nodo_comparacion, nodo_arbol* nodo_ejecucion_if, nodo_arbol* nodo_ejecucion_else);
void ejecutar_while(nodo_arbol* nodo_comparacion, nodo_arbol* nodo_ejecucion_while);
void ejecutar_for(nodo_arbol* nodo_inicializacion, nodo_arbol* nodo_finalizacion, nodo_arbol* nodo_ejecucion_for, nodo_arbol* nodo_step);
void continuar_for(nodo_arbol* nodo_inicializacion, nodo_arbol* nodo_finalizacion, nodo_arbol* nodo_ejecucion_for, nodo_arbol* nodo_step, float valor_finalizacion, float step);
void ejecutar_instruccion(nodo_arbol* nodo);
void ejecutar_lista_de_instrucciones(nodo_punto_y_coma* nodo);
void revisar_tipos(nodo_punto_y_coma* nodo, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void ejecutar_revision_de_tipos(nodo_arbol* nodo, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipos_for(nodo_arbol* nodo_for, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipos_if(nodo_arbol* nodo_if, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipos_while(nodo_arbol* nodo_while, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipos_read(nodo_arbol* nodo_read, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipos_print(nodo_arbol* nodo_read, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipos_return(nodo_arbol* nodo_return, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipos_asignacion(nodo_arbol* nodo_read, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipo_nodo(nodo_arbol* nodo_read, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void ejecutar_programa(nodo_programa* programa);

void unir_parametros_con_variables_locales(nodo_tabla_y_parametro* nodo_tabla_y_parametro, nodo_tabla_de_simbolos* inicio_variables_locales);
nodo_tabla_de_simbolos* formar_tabla_de_simbolos_funcion(nodo_tabla_y_parametro* nodo_tabla_y_parametro, nodo_tabla_de_simbolos* inicio_variables_locales);
void unir_parametros(nodo_tabla_y_parametro* nodo_tabla_y_parametro);
nodo_parametro* formar_lista_de_parametros(nodo_tabla_y_parametro* nodo_tabla_y_parametro);
void imprimir_tabla_de_simbolos(nodo_tabla_de_simbolos* nodo_tabla);
void imprimir_parametros(nodo_parametro* nodo_parametro);
int obtener_numero_parametros(nodo_parametro* nodo_parametro, int contador);

nodo_argumento* crear_argumento(nodo_arbol* nodo_expresion);
nodo_argumento* unir_argumentos(nodo_argumento* nodo1, nodo_argumento* nodo2);
void agregar_argumentos(nodo_arbol* nodo_llamada_a_funcion, nodo_argumento* inicio_argumentos);
void revisar_tipos_llamada_funcion(nodo_arbol* nodo_llamada_a_funcion, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);

nodo_funcion* unir_funciones(nodo_funcion* nodo1, nodo_funcion* nodo2);

nodo_funcion* buscar_funcion(char funcion_a_buscar[20], nodo_funcion* funcion_actual);
void realizar_copia_de_tabla_de_simbolos(nodo_tabla_de_simbolos* tabla_a_copiar, nodo_tabla_de_simbolos* copia_tabla);
void realizar_copia_de_arbol(nodo_arbol* arbol_a_copiar, nodo_arbol* copia_arbol);
void realizar_copia_de_parametro(nodo_parametro* parametro_a_copiar, nodo_parametro* copia_parametro);
void realizar_copia_de_arbol(nodo_arbol* arbol_a_copiar, nodo_arbol* copia_arbol);
void realizar_copia_de_instruccion(nodo_punto_y_coma* instruccion_a_copiar, nodo_punto_y_coma* copia_instruccion);
nodo_funcion* realizar_copia_de_funcion(nodo_funcion* funcion_a_copiar);
void revisar_tipos(nodo_punto_y_coma* nodo, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos);
void revisar_tipos_expr(nodo_argumento* argumento_actual, nodo_tabla_de_simbolos* tabla);

nodo_funcion* buscar_funcion(char funcion_a_buscar[20], nodo_funcion* funcion_actual) {
	if(strcmp(funcion_a_buscar, funcion_actual->nombre_funcion) == 0) {
		return funcion_actual;
	}

	if(funcion_actual->siguiente_funcion == NULL) {
		yyerror("function not found\n");
	}

	buscar_funcion(funcion_a_buscar, funcion_actual->siguiente_funcion);
}

void realizar_copia_de_tabla_de_simbolos(nodo_tabla_de_simbolos* tabla_a_copiar, nodo_tabla_de_simbolos* copia_tabla) {
	strncpy(copia_tabla->nombre_variable, tabla_a_copiar->nombre_variable, 20);
	copia_tabla->tipo = tabla_a_copiar->tipo;
	copia_tabla->valor = tabla_a_copiar->valor;
	copia_tabla->simbolo_siguiente = NULL;

	if(tabla_a_copiar->simbolo_siguiente != NULL) {
		nodo_tabla_de_simbolos* tabla_siguiente;
		tabla_siguiente = (nodo_tabla_de_simbolos*)malloc( sizeof(nodo_tabla_de_simbolos) );

		copia_tabla->simbolo_siguiente = tabla_siguiente;
		realizar_copia_de_tabla_de_simbolos(tabla_a_copiar->simbolo_siguiente, tabla_siguiente);
	}
}

void realizar_copia_de_parametro(nodo_parametro* parametro_a_copiar, nodo_parametro* copia_parametro) {
	strncpy(copia_parametro->nombre_parametro, parametro_a_copiar->nombre_parametro, 20);
	copia_parametro->siguiente_parametro = NULL;

	if(parametro_a_copiar->siguiente_parametro != NULL) {
		nodo_parametro* parametro_siguiente;
		parametro_siguiente = (nodo_parametro*)malloc( sizeof(nodo_parametro) );

		copia_parametro->siguiente_parametro = parametro_siguiente;
		realizar_copia_de_parametro(parametro_a_copiar->siguiente_parametro, parametro_siguiente);
	}
}

void realizar_copia_de_argumento(nodo_argumento* argumento_a_copiar, nodo_argumento* copia_argumento) {
	copia_argumento->nodo_expresion = NULL;
	copia_argumento->siguiente_nodo = NULL;

	if(argumento_a_copiar->nodo_expresion != NULL) {
		nodo_arbol* copia_de_expresion;
		copia_de_expresion = (nodo_arbol*)malloc( sizeof(nodo_arbol) );
		copia_argumento->nodo_expresion = copia_de_expresion;
		realizar_copia_de_arbol(argumento_a_copiar->nodo_expresion, copia_de_expresion);
	}

	if(argumento_a_copiar->siguiente_nodo != NULL) {
		nodo_argumento* siguiente_nodo;
		siguiente_nodo = (nodo_argumento*)malloc( sizeof(nodo_argumento) );
		copia_argumento->siguiente_nodo = siguiente_nodo;
		realizar_copia_de_argumento(argumento_a_copiar->siguiente_nodo, siguiente_nodo);
	}
}

void realizar_copia_de_arbol(nodo_arbol* arbol_a_copiar, nodo_arbol* copia_arbol) {
	copia_arbol->definicion = arbol_a_copiar->definicion;
	copia_arbol->tipo = arbol_a_copiar->tipo;
	copia_arbol->valor = arbol_a_copiar->valor;
	strncpy(copia_arbol->nombre_variable, arbol_a_copiar->nombre_variable, 20);
	copia_arbol->inicio_instrucciones = NULL;
	copia_arbol->izq = NULL;
	copia_arbol->centro = NULL;
	copia_arbol->der = NULL;
	copia_arbol->step = NULL;
	copia_arbol->direccion_tabla_simbolos = NULL;
	copia_arbol->argumento_funcion = NULL;

	if(arbol_a_copiar->inicio_instrucciones != NULL) {
		nodo_punto_y_coma* copia_de_instruccion;
		copia_de_instruccion = (nodo_punto_y_coma*)malloc( sizeof(nodo_punto_y_coma) );
		copia_arbol->inicio_instrucciones = copia_de_instruccion;
		realizar_copia_de_instruccion(arbol_a_copiar->inicio_instrucciones, copia_de_instruccion);
	}

	if(arbol_a_copiar->izq != NULL) {
		nodo_arbol* copia_izq;
		copia_izq = (nodo_arbol*)malloc( sizeof(nodo_arbol) );
		copia_arbol->izq = copia_izq;
		realizar_copia_de_arbol(arbol_a_copiar->izq, copia_izq);
	}
	
	if(arbol_a_copiar->centro != NULL) {
		nodo_arbol* copia_centro;
		copia_centro = (nodo_arbol*)malloc( sizeof(nodo_arbol) );
		copia_arbol->centro = copia_centro;
		realizar_copia_de_arbol(arbol_a_copiar->centro, copia_centro);
	}

	if(arbol_a_copiar->der != NULL) {
		nodo_arbol* copia_der;
		copia_der = (nodo_arbol*)malloc( sizeof(nodo_arbol) );
		copia_arbol->der = copia_der;
		realizar_copia_de_arbol(arbol_a_copiar->der, copia_der);
	}

	if(arbol_a_copiar->step != NULL) {
		nodo_arbol* copia_step;
		copia_step = (nodo_arbol*)malloc( sizeof(nodo_arbol) );
		copia_arbol->step = copia_step;
		realizar_copia_de_arbol(arbol_a_copiar->step, copia_step);
	}

	if(arbol_a_copiar->direccion_tabla_simbolos != NULL) {
		nodo_tabla_de_simbolos* copia_direccion_tabla_simbolos;
		copia_direccion_tabla_simbolos = (nodo_tabla_de_simbolos*)malloc( sizeof(nodo_tabla_de_simbolos) );
		copia_arbol->direccion_tabla_simbolos = copia_direccion_tabla_simbolos;
		realizar_copia_de_tabla_de_simbolos(arbol_a_copiar->direccion_tabla_simbolos, copia_direccion_tabla_simbolos);
	}

	if(arbol_a_copiar->argumento_funcion != NULL) {
		nodo_argumento* copia_argumento;
		copia_argumento = (nodo_argumento*)malloc( sizeof(nodo_argumento) );
		copia_arbol->argumento_funcion = copia_argumento;
		realizar_copia_de_argumento(arbol_a_copiar->argumento_funcion, copia_argumento);
	}
	
}

void realizar_copia_de_instruccion(nodo_punto_y_coma* instruccion_a_copiar, nodo_punto_y_coma* copia_instruccion) {
	copia_instruccion->inicio = NULL;
	copia_instruccion->siguiente_instruccion = NULL;

	if(instruccion_a_copiar->inicio != NULL) {
		nodo_arbol* copia_de_arbol;
		copia_de_arbol = (nodo_arbol*)malloc( sizeof(nodo_arbol) );
		copia_instruccion->inicio = copia_de_arbol;
		realizar_copia_de_arbol(instruccion_a_copiar->inicio, copia_de_arbol);
	}

	if(instruccion_a_copiar->siguiente_instruccion != NULL) {
		nodo_punto_y_coma* siguiente_instruccion;
		siguiente_instruccion = (nodo_punto_y_coma*)malloc( sizeof(nodo_punto_y_coma) );
		copia_instruccion->siguiente_instruccion = siguiente_instruccion;
		realizar_copia_de_instruccion(instruccion_a_copiar->siguiente_instruccion, siguiente_instruccion);
	}
}

nodo_funcion* realizar_copia_de_funcion(nodo_funcion* funcion_a_copiar) {
	nodo_funcion* copia_funcion;
	copia_funcion = (nodo_funcion*)malloc( sizeof(nodo_funcion) );

	strncpy(copia_funcion->nombre_funcion, funcion_a_copiar->nombre_funcion, 20);
	copia_funcion->tipo = funcion_a_copiar->tipo;
	copia_funcion->tabla_de_simbolos_local = NULL;
	copia_funcion->num_parametros = funcion_a_copiar->num_parametros;
	copia_funcion->parametro_inicial = NULL;
	copia_funcion->inicio_instrucciones = NULL;
	copia_funcion->siguiente_funcion = NULL;

	if(funcion_a_copiar->tabla_de_simbolos_local != NULL) {
		nodo_tabla_de_simbolos* copia_de_tabla_de_simbolos;
		copia_de_tabla_de_simbolos = (nodo_tabla_de_simbolos*)malloc( sizeof(nodo_tabla_de_simbolos) );
		copia_funcion->tabla_de_simbolos_local = copia_de_tabla_de_simbolos;
		realizar_copia_de_tabla_de_simbolos(funcion_a_copiar->tabla_de_simbolos_local, copia_de_tabla_de_simbolos);
	}
	
	if(funcion_a_copiar->parametro_inicial != NULL) {
		nodo_parametro* copia_de_parametro;
		copia_de_parametro = (nodo_parametro*)malloc( sizeof(nodo_parametro) );
		copia_funcion->parametro_inicial = copia_de_parametro;
		realizar_copia_de_parametro(funcion_a_copiar->parametro_inicial, copia_de_parametro);
	}
	
	if(funcion_a_copiar->inicio_instrucciones != NULL) {
		nodo_punto_y_coma* copia_de_instruccion;
		copia_de_instruccion = (nodo_punto_y_coma*)malloc( sizeof(nodo_punto_y_coma) );
		copia_funcion->inicio_instrucciones = copia_de_instruccion;
		realizar_copia_de_instruccion(funcion_a_copiar->inicio_instrucciones, copia_de_instruccion);
	}

	return copia_funcion;
}

void asignar_valor_parametro(nodo_tabla_de_simbolos* tabla_de_simbolos, char nombre_variable[20], float valor) {
	if(strcmp(tabla_de_simbolos->nombre_variable, nombre_variable) == 0) {
		// printf("ASIGNANDO VALOR DE %f EN TABLA DE SIMBOLOS\n", valor);
		tabla_de_simbolos->valor = valor;
	} else {
		if(tabla_de_simbolos->simbolo_siguiente == NULL) {
			yyerror("symbol not found");
		}

		asignar_valor_parametro(tabla_de_simbolos->simbolo_siguiente, nombre_variable, valor);
	}
}

void inicializar_parametros(nodo_funcion* funcion, nodo_parametro* parametro, nodo_argumento* argumento) {
	// printf("Entrando a funcion\n");
	// printf("Inicializando parametro %s\n", parametro->nombre_parametro);
	int valor_argumento = obtener_valor_nodo(argumento->nodo_expresion);
	// printf("Terminando de obtener valor nodo\n");
	asignar_valor_parametro(funcion->tabla_de_simbolos_local, parametro->nombre_parametro, valor_argumento);
	
	if(parametro->siguiente_parametro != NULL && argumento->siguiente_nodo != NULL) {
		inicializar_parametros(funcion, parametro->siguiente_parametro, argumento->siguiente_nodo);
	} else {
		if((parametro->siguiente_parametro == NULL && argumento->siguiente_nodo != NULL)
			|| (parametro->siguiente_parametro != NULL && argumento->siguiente_nodo == NULL)) {
			yyerror("arguments and parameters differ in length");
		}
	}

	// printf("Terminando inicializacion parametro %s\n", parametro->nombre_parametro);
}

float llamada_a_funcion(char nombre_funcion[20], nodo_argumento* argumento_funcion) {
	nodo_funcion* funcion = buscar_funcion(nombre_funcion, root->inicio_funciones);
	
	nodo_funcion* copia_funcion = realizar_copia_de_funcion(funcion);

	// printf("copia_funcion->nombre_funcion: %s\n", copia_funcion->nombre_funcion);
	// printf("===============================================================\n");
	// imprimir_tabla_de_simbolos(copia_funcion->tabla_de_simbolos_local);
	// printf("===============================================================\n");

	if(copia_funcion->parametro_inicial != NULL && argumento_funcion != NULL) {
		inicializar_parametros(copia_funcion, copia_funcion->parametro_inicial, argumento_funcion);
		// printf("No hay segmentation fault\n");
		imprimir_tabla_de_simbolos(copia_funcion->tabla_de_simbolos_local);
		revisar_tipos(copia_funcion->inicio_instrucciones, copia_funcion->tabla_de_simbolos_local);
		ejecutar_lista_de_instrucciones(copia_funcion->inicio_instrucciones);
		
	}

	return retorno;
	// return copia_funcion->valor_de_retorno;
}

// Función que regresa el valor de un nodo
float obtener_valor_nodo(nodo_arbol* nodo) {
	// printf("nodo->definicion: %d\n", nodo->definicion);
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
		case 21: return llamada_a_funcion(nodo->nombre_variable, nodo->argumento_funcion); break;
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
    step = obtener_valor_nodo(nodo_step);
		nodo_inicializacion->izq->direccion_tabla_simbolos->valor += step;
		continuar_for(nodo_inicializacion, nodo_finalizacion, nodo_ejecucion_for, nodo_step, valor_finalizacion, step);
	}
}

void ejecutar_instruccion(nodo_arbol* nodo) {
	// Se ejecuta la instrucción dependiendo de si se trata de una asignación, un for, while, print, etc.
	switch(nodo->definicion) {
		case 2: asignar_valor(nodo->izq, nodo->der); break;
		case 3: ejecutar_if(nodo->izq, nodo->centro, NULL); break;
		case 4: ejecutar_if(nodo->izq, nodo->centro, nodo->der); break;
		case 5: ejecutar_while(nodo->izq, nodo->der); break;
		case 6: leer(nodo->centro); break;
		case 7: imprimir(nodo->centro); break;
		case 8: ejecutar_lista_de_instrucciones(nodo->inicio_instrucciones); break;
		case 19: ejecutar_for(nodo->izq, nodo->centro, nodo->der, nodo->step); break;	
		case 20: retorno = obtener_valor_nodo(nodo->centro); break;
	}
}

// Función que ejecuta las instrucciones que se encuentran en el árbol sintáctico
void ejecutar_lista_de_instrucciones(nodo_punto_y_coma* nodo) {
	ejecutar_instruccion(nodo->inicio);

	// Si existe, se ejecuta la siguiente instrucción
	if(nodo->siguiente_instruccion != NULL) {
		ejecutar_lista_de_instrucciones(nodo->siguiente_instruccion);
	}
}

// INICIAN FUNCIONES PARA REVISAR Y ASIGNAR TIPOS
void asignar_informacion_variable(nodo_arbol* nodo_variable, nodo_tabla_de_simbolos* nodo_a_buscar, int global) {
	if(strcmp(nodo_variable->nombre_variable, nodo_a_buscar->nombre_variable) == 0) {
		nodo_variable->tipo = nodo_a_buscar->tipo;
		nodo_variable->direccion_tabla_simbolos = nodo_a_buscar;
	} else {
		if(nodo_a_buscar->simbolo_siguiente != NULL) {
			asignar_informacion_variable(nodo_variable, nodo_a_buscar->simbolo_siguiente, global);
		} else {
			if(global == 1) {
				yyerror("identifier not found\n");
			}

			asignar_informacion_variable(nodo_variable, root->inicio_tabla_de_simbolos, 1);
		}
	}
}

void revisar_tipo_nodo(nodo_arbol* nodo, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	if(nodo != NULL) {
		switch(nodo->definicion) {	
			case 0: asignar_informacion_variable(nodo, inicio_tabla_de_simbolos, 0); break;
			case 2: revisar_tipos_asignacion(nodo, inicio_tabla_de_simbolos); break;
			case 3:
			case 4:
				revisar_tipos_if(nodo, inicio_tabla_de_simbolos); break;
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
				revisar_tipo_nodo(nodo->izq, inicio_tabla_de_simbolos);
				revisar_tipo_nodo(nodo->der, inicio_tabla_de_simbolos);
				if(nodo->izq->tipo != nodo->der->tipo) {
					yyerror("different data types\n");
				}
				nodo->tipo = nodo->izq->tipo;
				break;
			case 20: revisar_tipo_nodo(nodo->centro, inicio_tabla_de_simbolos); break;
			case 21: revisar_tipos_llamada_funcion(nodo, inicio_tabla_de_simbolos); break;
		}
	}
}

void revisar_tipos_asignacion(nodo_arbol* nodo_asignacion, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	if(nodo_asignacion->izq->definicion != 0) {
		yyerror("an identifier must appear to the left\n");
	}

	revisar_tipo_nodo(nodo_asignacion->izq, inicio_tabla_de_simbolos);
	// printf("nodo_asignacion->der->definicion: %d\n", nodo_asignacion->der->definicion);
	revisar_tipo_nodo(nodo_asignacion->der, inicio_tabla_de_simbolos);

	if(nodo_asignacion->izq->tipo != nodo_asignacion->der->tipo) {
		yyerror("data types do not match");
	}
	nodo_asignacion->tipo = nodo_asignacion->izq->tipo;
}

void revisar_tipos_read(nodo_arbol* nodo_read, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	asignar_informacion_variable(nodo_read->centro, inicio_tabla_de_simbolos, 0);
	nodo_read->tipo = nodo_read->centro->tipo;
}

void revisar_tipos_print(nodo_arbol* nodo_print, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	revisar_tipo_nodo(nodo_print->centro, inicio_tabla_de_simbolos);
	nodo_print->tipo = nodo_print->centro->tipo;
}

void revisar_tipos_return(nodo_arbol* nodo_return, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	revisar_tipo_nodo(nodo_return->centro, inicio_tabla_de_simbolos);
	nodo_return->tipo = nodo_return->centro->tipo;
}

void revisar_tipos_while(nodo_arbol* nodo_while, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	revisar_tipo_nodo(nodo_while->izq, inicio_tabla_de_simbolos);
	revisar_tipo_nodo(nodo_while->der, inicio_tabla_de_simbolos);
}

void revisar_tipos_if(nodo_arbol* nodo_if, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	revisar_tipo_nodo(nodo_if->izq, inicio_tabla_de_simbolos);
	revisar_tipo_nodo(nodo_if->centro, inicio_tabla_de_simbolos);
	revisar_tipo_nodo(nodo_if->der, inicio_tabla_de_simbolos);
}

void revisar_tipos_for(nodo_arbol* nodo_for, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	revisar_tipo_nodo(nodo_for->izq, inicio_tabla_de_simbolos);
	revisar_tipo_nodo(nodo_for->centro, inicio_tabla_de_simbolos);
	ejecutar_revision_de_tipos(nodo_for->der, inicio_tabla_de_simbolos);
	revisar_tipo_nodo(nodo_for->step, inicio_tabla_de_simbolos);
}

int buscar_tipo_de_funcion(char nombre_funcion[20], nodo_funcion* funcion_actual) {
	if(strcmp(nombre_funcion, funcion_actual->nombre_funcion) == 0) {
		return funcion_actual->tipo;
	}

	if(funcion_actual->siguiente_funcion == NULL) {
		yyerror("function not found\n");
	}

	buscar_tipo_de_funcion(nombre_funcion, funcion_actual->siguiente_funcion);
}

void revisar_tipos_expr(nodo_argumento* argumento_actual, nodo_tabla_de_simbolos* tabla) {
	revisar_tipo_nodo(argumento_actual->nodo_expresion, tabla);

	if(argumento_actual->siguiente_nodo != NULL) {
		revisar_tipos_expr(argumento_actual->siguiente_nodo, tabla);
	}
}

void revisar_tipos_llamada_funcion(nodo_arbol* nodo_llamada_a_funcion, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	if(root->inicio_funciones != NULL) {
		nodo_llamada_a_funcion->tipo = buscar_tipo_de_funcion(nodo_llamada_a_funcion->nombre_variable, root->inicio_funciones);
		revisar_tipos_expr(nodo_llamada_a_funcion->argumento_funcion, inicio_tabla_de_simbolos);
	} else {
		yyerror("function not found\n");
	}
}

void ejecutar_revision_de_tipos(nodo_arbol* nodo, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	// Se ejecuta la revision de tipos dependiendo de si se trata de una asignación, un for, while, print, etc.
	// printf("Definicion de nodo en revision de tipos: %d\n", nodo->definicion);
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
		case 20: revisar_tipos_return(nodo, inicio_tabla_de_simbolos); break;
		case 21: revisar_tipos_llamada_funcion(nodo, inicio_tabla_de_simbolos); break;
	}
}

// Función que revisa tipos
void revisar_tipos(nodo_punto_y_coma* nodo, nodo_tabla_de_simbolos* inicio_tabla_de_simbolos) {
	ejecutar_revision_de_tipos(nodo->inicio, inicio_tabla_de_simbolos);
	// Si existe, se ejecuta la siguiente instrucción
	if(nodo->siguiente_instruccion != NULL) {
		revisar_tipos(nodo->siguiente_instruccion, inicio_tabla_de_simbolos);
	}
}
// TERMINAN FUNCIONES PARA REVISAR Y ASIGNAR TIPOS

// Se crea la tabla de símbolos con las distintas variables
nodo_tabla_de_simbolos* unir_nodos_de_tabla_de_simbolos(nodo_tabla_de_simbolos* nodo1, nodo_tabla_de_simbolos* nodo2) {
	// El nodo1 guarda un apuntador hacia el nodo2
	nodo1->simbolo_siguiente = nodo2;
	return nodo1;
}

nodo_tabla_de_simbolos* crear_nodo_de_tabla_de_simbolos(char variable[20], int tipo) {
	// Se crea un nodo en el que se almacenará la variable
	nodo_tabla_de_simbolos* nuevo_nodo;
	nuevo_nodo = (nodo_tabla_de_simbolos*)malloc( sizeof(nodo_tabla_de_simbolos) );

	// Se almacenan los datos en el nodo
	nuevo_nodo->tipo = tipo;
	nuevo_nodo->valor = 0;
	nuevo_nodo->simbolo_siguiente = NULL;
	strncpy(nuevo_nodo->nombre_variable, variable, 20);

	return nuevo_nodo;
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
	nuevo_nodo->argumento_funcion = NULL;
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

nodo_parametro* crear_nodo_parametro(char nombre_parametro[20], nodo_parametro* siguiente_parametro) {
	// Se crea un nodo
	nodo_parametro* nuevo_nodo;
	nuevo_nodo = (nodo_parametro*)malloc( sizeof(nodo_parametro) );

	// Se almacenan los datos en el nodo
	/* nuevo_nodo->nombre_parametro = nombre_parametro; */
	strncpy(nuevo_nodo->nombre_parametro, nombre_parametro, 20);
	nuevo_nodo->siguiente_parametro = siguiente_parametro;

	return nuevo_nodo;
}

nodo_tabla_y_parametro* crear_nodo_tabla_y_parametro(nodo_tabla_de_simbolos* nodo_tabla, nodo_parametro* nodo_parametro, nodo_tabla_y_parametro* nodo_siguiente) {
	// Se crea un nodo
	nodo_tabla_y_parametro* nuevo_nodo;
	nuevo_nodo = (nodo_tabla_y_parametro*)malloc( sizeof(nodo_tabla_y_parametro) );

	// Se almacenan los datos en el nodo
	nuevo_nodo->nodo_tabla = nodo_tabla;
	nuevo_nodo->nodo_parametro = nodo_parametro;
	nuevo_nodo->nodo_siguiente = nodo_siguiente;

	return nuevo_nodo;
}

// Se crea la tabla de símbolos con las distintas variables
nodo_tabla_y_parametro* unir_nodo_tabla_y_parametro(nodo_tabla_y_parametro* nodo1, nodo_tabla_y_parametro* nodo2) {
	// El nodo1 guarda un apuntador hacia el nodo2
	nodo1->nodo_siguiente = nodo2;
	return nodo1;
}

void imprimir_nodos_tabla_y_parametro(nodo_tabla_y_parametro* nodo) {
	// printf("nodo->nodo_tabla->nombre_variable: %s\n", nodo->nodo_tabla->nombre_variable);

	if(nodo->nodo_siguiente != NULL) {
		imprimir_nodos_tabla_y_parametro(nodo->nodo_siguiente);
	}
}

nodo_programa* crear_nodo_programa(nodo_tabla_de_simbolos* inicio_tabla_de_simbolos, nodo_punto_y_coma* inicio_instrucciones, nodo_funcion* inicio_funciones) {
	nodo_programa* nodo;
	nodo = (nodo_programa*)malloc( sizeof(nodo_programa) );
	nodo->inicio_instrucciones = inicio_instrucciones;
	nodo->inicio_tabla_de_simbolos = inicio_tabla_de_simbolos;
	nodo->inicio_funciones = inicio_funciones;
	return nodo;
}

void revisar_tipos_funciones(nodo_funcion* inicio_funciones) {
	revisar_tipos(inicio_funciones->inicio_instrucciones, inicio_funciones->tabla_de_simbolos_local);
}

void ejecutar_programa(nodo_programa* programa) {
	if(programa->inicio_instrucciones != NULL && programa->inicio_tabla_de_simbolos != NULL) {
		revisar_tipos(programa->inicio_instrucciones, programa->inicio_tabla_de_simbolos);
	}
	
	if(programa->inicio_funciones != NULL) {
		revisar_tipos_funciones(programa->inicio_funciones);
	}
	
	if(programa->inicio_instrucciones != NULL) {
		ejecutar_lista_de_instrucciones(programa->inicio_instrucciones);
	}	
}


// MANEJO DE FUNCIONES
nodo_funcion* crear_funcion(char nombre_funcion[20], int tipo, nodo_tabla_de_simbolos* tabla_de_simbolos_local, int num_parametros, nodo_parametro* parametro_inicial, nodo_punto_y_coma* inicio_instrucciones, nodo_funcion* siguiente_funcion) {
	nodo_funcion* nodo;
	nodo = (nodo_funcion*)malloc( sizeof(nodo_funcion) );

	strncpy(nodo->nombre_funcion, nombre_funcion, 20);
	nodo->tipo = tipo;
	nodo->tabla_de_simbolos_local = tabla_de_simbolos_local;
	nodo->num_parametros = num_parametros;
	nodo->parametro_inicial = parametro_inicial;
	nodo->inicio_instrucciones = inicio_instrucciones;
	nodo->siguiente_funcion = siguiente_funcion;
	return nodo;
}

nodo_funcion* unir_funciones(nodo_funcion* nodo1, nodo_funcion* nodo2) {
	if(nodo1->inicio_instrucciones == NULL) {
		return nodo2;
	} else if(nodo2->inicio_instrucciones == NULL) {
		if(nodo2->siguiente_funcion == NULL) {
			return nodo1;
		} else {
			nodo1->siguiente_funcion = nodo2->siguiente_funcion;
			return nodo1;
		}
	}

	nodo1->siguiente_funcion = nodo2;
	return nodo1;
}


void unir_parametros_con_variables_locales(nodo_tabla_y_parametro* nodo_tabla_y_parametro, nodo_tabla_de_simbolos* inicio_variables_locales) {
	if(nodo_tabla_y_parametro->nodo_siguiente != NULL) {
		nodo_tabla_y_parametro->nodo_tabla->simbolo_siguiente = nodo_tabla_y_parametro->nodo_siguiente->nodo_tabla;
		unir_parametros_con_variables_locales(nodo_tabla_y_parametro->nodo_siguiente, inicio_variables_locales);
	} else {
		nodo_tabla_y_parametro->nodo_tabla->simbolo_siguiente = inicio_variables_locales;
	}
}

nodo_tabla_de_simbolos* formar_tabla_de_simbolos_funcion(nodo_tabla_y_parametro* nodo_tabla_y_parametro, nodo_tabla_de_simbolos* inicio_variables_locales) {
	if(nodo_tabla_y_parametro == NULL) {
		if(inicio_variables_locales == NULL) {
			return NULL;
		} else {
			return inicio_variables_locales;
		}
	}

	unir_parametros_con_variables_locales(nodo_tabla_y_parametro, inicio_variables_locales);
	return nodo_tabla_y_parametro->nodo_tabla;	
}

void unir_parametros(nodo_tabla_y_parametro* nodo_tabla_y_parametro) {
	if(nodo_tabla_y_parametro->nodo_siguiente != NULL) {
		nodo_tabla_y_parametro->nodo_parametro->siguiente_parametro = nodo_tabla_y_parametro->nodo_siguiente->nodo_parametro;
		unir_parametros(nodo_tabla_y_parametro->nodo_siguiente);
	}
}

nodo_parametro* formar_lista_de_parametros(nodo_tabla_y_parametro* nodo_tabla_y_parametro) {
	if(nodo_tabla_y_parametro == NULL) {
		return NULL;
	}

	unir_parametros(nodo_tabla_y_parametro);
	return nodo_tabla_y_parametro->nodo_parametro;
}

void imprimir_tabla_de_simbolos(nodo_tabla_de_simbolos* nodo_tabla) {
	// printf("Variable: %s, tipo: %d, valor: %f\n", nodo_tabla->nombre_variable, nodo_tabla->tipo, nodo_tabla->valor);

	if(nodo_tabla->simbolo_siguiente != NULL) {
		imprimir_tabla_de_simbolos(nodo_tabla->simbolo_siguiente);
	}
}

int obtener_numero_parametros(nodo_parametro* nodo_parametro, int contador) {
	if(nodo_parametro == NULL) {
		return contador;
	}

	return obtener_numero_parametros(nodo_parametro->siguiente_parametro, contador + 1);
}

void imprimir_parametros(nodo_parametro* nodo_parametro) {
	if(nodo_parametro != NULL) {
		// printf("Parametro: %s\n", nodo_parametro->nombre_parametro);

		if(nodo_parametro->siguiente_parametro != NULL) {
			imprimir_parametros(nodo_parametro->siguiente_parametro);
		}
	}
}

void agregar_argumentos(nodo_arbol* nodo_llamada_a_funcion, nodo_argumento* inicio_argumentos) {
	nodo_llamada_a_funcion->argumento_funcion = inicio_argumentos;
}

nodo_argumento* unir_argumentos(nodo_argumento* nodo1, nodo_argumento* nodo2) {
	// El nodo1 guarda un apuntador hacia el nodo2
	nodo1->siguiente_nodo = nodo2;
	return nodo1;
}

nodo_argumento* crear_argumento(nodo_arbol* nodo_expresion) {
	nodo_argumento* nodo;
	nodo = (nodo_argumento*)malloc( sizeof(nodo_argumento) );

	nodo->nodo_expresion = nodo_expresion;
	nodo->siguiente_nodo = NULL;
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
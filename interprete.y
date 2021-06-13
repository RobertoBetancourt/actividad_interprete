/*	
		Roberto Betancourt Hernández - A01551525
		Luis Edgar Flores Carpinteyro - A01329971
		Alan Rodrigo Albert Morán - A01328928
		
		Los comandos para compilar y ejecutar son: 
    	flex interprete.l
    	bison -d interprete.y
    	gcc lex.yy.c interprete.tab.c -lfl -lm
    	./a.out prueba.txt
*/

%{
#include "interprete.h"

nodo_programa* root = NULL;
%}

%union {
  int numero_entero;
	float numero_flotante;
	char cadena[20];
  struct estructura_arbol* nodo_arbol;
	struct estructura_tabla_simbolos* nodo_lista_ligada;
	struct estructura_punto_y_coma* nodo_punto_y_coma;
	struct estructura_parametros* nodo_parametro;
	struct estructura_tabla_y_parametro* nodo_tabla_y_parametro;
}

%token ASIGNACION SUMA RESTA DIVIDE MULTI PAREND PARENI DOS_PUNTOS PUNTO_Y_COMA BEGIN_RESERVADA END_RESERVADA IF_RESERVADA FI_RESERVADA ELSE_RESERVADA WHILE_RESERVADA FOR_RESERVADA TO_RESERVADA STEP_RESERVADA DO_RESERVADA READ_RESERVADA PRINT_RESERVADA MENOR_QUE MAYOR_QUE IGUAL_QUE MENOR_O_IGUAL_QUE MAYOR_O_IGUAL_QUE FUNCION COMA
%token <numero_entero> ENTERO TIPO_ENTERO TIPO_FLOTANTE
%token <numero_flotante> FLOTANTE
%token <cadena> IDENTIFICADOR
%type <numero_entero> tipo
%type <nodo_lista_ligada> decl decl_lst opt_decls
%type <nodo_arbol> factor term expr stmt expression
%type <nodo_punto_y_coma> stmt_lst opt_stmts
%type <nodo_tabla_y_parametro> param params oparams
%start prog

%%

prog : opt_decls opt_fun_decls BEGIN_RESERVADA opt_stmts END_RESERVADA		{root = crear_nodo_programa($1, $4);}
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

opt_fun_decls : /*epsilon*/
							| fun_decls
;

fun_decls : fun_decls fun_decl
					| fun_decl
;

fun_decl : FUNCION IDENTIFICADOR PARENI oparams PAREND DOS_PUNTOS tipo opt_decls BEGIN_RESERVADA opt_stmts END_RESERVADA
				 | FUNCION IDENTIFICADOR PARENI oparams PAREND DOS_PUNTOS tipo PUNTO_Y_COMA
;

oparams : /*epsilon*/												{ $$ = NULL; }
				| params														{ imprimir_nodos_tabla_y_parametro($1); $$ = $$; }
;

params  : param COMA params									{ $$ = unir_nodo_tabla_y_parametro($1, $3); }
				| param															{ $$ = $$;  }
;

param : IDENTIFICADOR DOS_PUNTOS tipo				{	nodo_tabla_de_simbolos* nodo_tabla = crear_nodo_de_tabla_de_simbolos($1, $3);
																							nodo_parametro* nodo_p = crear_nodo_parametro($1, NULL);
																							$$ = crear_nodo_tabla_y_parametro(nodo_tabla, nodo_p, NULL); }
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

	if(root->inicio_instrucciones != NULL) {
		ejecutar_programa(root);
	}
}
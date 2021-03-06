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

/* Archivo con el reconocedor léxico */
%{
#include<stdlib.h>
#include<math.h>
  /* Se incluye el archivo generado por bison para tener las definiciones
     de los tokens */
#include "calculadora.tab.h"

int numero_linea = 1;
%}

LETRA [A-Za-z]
DIGITO [1-9][0-9]*

%%

\n 																{numero_linea++;}
(([1-9][0-9]*)|0)[.][0-9][0-9]* 	{yylval.numero_flotante = atof(yytext); return FLOTANTE;}
([1-9][0-9]*)|0              			{yylval.numero_entero = atoi(yytext); return ENTERO;}
"<-"                        			{return ASIGNACION;}
"+"                         			{return SUMA;}
"-"                         			{return RESTA;}
"*"                         			{return MULTI;}
"/"                         			{return DIVIDE;}
"("                         			{return PARENI;}
")"                         			{return PAREND;}
"int"			                  			{return TIPO_ENTERO;}
"float"		          	      			{return TIPO_FLOTANTE;}
"begin"                     			{return BEGIN_RESERVADA;}
"end"                       			{return END_RESERVADA;}
"if"                        			{return IF_RESERVADA;}
"fi"                        			{return FI_RESERVADA;}
"for"                       			{return FOR_RESERVADA;}
"else"                      			{return ELSE_RESERVADA;}
"to"                        			{return TO_RESERVADA;}
"step"                      			{return STEP_RESERVADA;}
"do"                        			{return DO_RESERVADA;}
"read"                      			{return READ_RESERVADA;}
"print"                     			{return PRINT_RESERVADA;}
"while"                     			{return WHILE_RESERVADA;}
"<"                         			{return MENOR_QUE;}
"<="                        			{return MENOR_O_IGUAL_QUE;}
">"                         			{return MAYOR_QUE;}
">="                        			{return MAYOR_O_IGUAL_QUE;}
"="                         			{return IGUAL_QUE;}
":"                         			{return DOS_PUNTOS;}
";"                         			{return PUNTO_Y_COMA;}
[A-Za-z$_][0-9a-zA-Z$_]*    			{strcpy(yylval.cadena, yytext); return IDENTIFICADOR;}
.|\n    													;

%%


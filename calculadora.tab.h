/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_CALCULADORA_TAB_H_INCLUDED
# define YY_YY_CALCULADORA_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IDENTIFICADOR = 258,
    ASIGNACION = 259,
    ENTERO = 260,
    FLOTANTE = 261,
    SUMA = 262,
    RESTA = 263,
    DIVIDE = 264,
    MULTI = 265,
    PAREND = 266,
    PARENI = 267,
    DOS_PUNTOS = 268,
    PUNTO_Y_COMA = 269,
    BEGIN_RESERVADA = 270,
    END_RESERVADA = 271,
    IF_RESERVADA = 272,
    FI_RESERVADA = 273,
    ELSE_RESERVADA = 274,
    WHILE_RESERVADA = 275,
    FOR_RESERVADA = 276,
    TO_RESERVADA = 277,
    STEP_RESERVADA = 278,
    DO_RESERVADA = 279,
    READ_RESERVADA = 280,
    PRINT_RESERVADA = 281,
    MENOR_QUE = 282,
    MAYOR_QUE = 283,
    IGUAL_QUE = 284,
    MENOR_O_IGUAL_QUE = 285,
    MAYOR_O_IGUAL_QUE = 286
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_CALCULADORA_TAB_H_INCLUDED  */

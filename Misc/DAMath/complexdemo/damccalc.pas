unit DAMCcalc;

{Parse and evaluate complex expressions}

interface

{$i STD.INC}

{$X+}
{$ifdef BIT16}
  {$N+}
{$endif}


uses
  BTypes, DAMath, DAMCmplx;

(*************************************************************************

 DESCRIPTION   :  Parse and evaluate complex expressions

 REQUIREMENTS  :  BP7, D1-D7/D9-D10/D12/D17-D18, FPC, VP

 EXTERNAL DATA :  ---

 MEMORY USAGE  :  heap

 DISPLAY MODE  :  ---

 REFERENCES    :  [19] T. Norvell: Parsing Expressions by Recursive Descent,
                       http://www.engr.mun.ca/~theo/Misc/exp_parsing.htm
                  [20] G. Toal's tutorial pages OperatorPrecedence.html,CompilersOneOhOne.html,
                       GrahamToalsCompilerDemo.html at http://www.gtoal.com/software/
                  [21] T.R. Nicely's parser.c in factor1.zip from http://www.trnicely.net
                       derived from GMP demo pexpr.c (see [15])

 Version  Date      Author      Modification
 -------  --------  -------     ------------------------------------------
 0.0.10   18.10.18  W.Ehrhardt  First BP version derived from MPArith/mp_rcalc
 0.0.11   18.10.18  we          constant I
 0.0.12   18.10.18  we          0/0 = Nan, z/0 = Inf
 0.0.13   18.10.18  we          remove unsupported operations and func names
 0.0.14   18.10.18  we          _GAMMA, _LnGAMMA
 0.0.15   18.10.18  we          _SN, _CN, _DN
 0.0.16   18.10.18  we          remove unicode junk
 0.0.17   18.10.18  we          _ARG, _PSI, _DILOG
 0.0.18   19.10.18  we          _ERF, _ERFC, _RSTHETA, _LAMBERTWK
 0.0.19   20.10.18  we          _CBRT, _CONJ, _RE, _IM
 0.0.20   20.10.18  we          Return Division_by_zero
 0.0.21   23.10.18  we          Fix return values for cot,csc,sec
 0.0.22   25.10.18  we          _EXPM1 in FuncTab
 0.0.23   06.11.18  we          _ZETA
 0.0.24   09.11.18  we          _EI, _E1, _LI
 0.0.25   14.11.18  we          _NROOT, _SURD
**************************************************************************)


(*-------------------------------------------------------------------------
 (C) Copyright 2008-2018 Wolfgang Ehrhardt

 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from
 the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------*)


{#Z+} {Turn off reference for help}

{Parse errors >0, eval errors < 0}
const
  Err_Missing_LeftBracket  =  1;   {Missing "("}
  Err_Missing_Comma        =  2;   {Missing argument separator}
  Err_Missing_RightBracket =  3;   {Missing ")"}
  Err_Unknown_Function     =  4;   {Unknown function}
  Err_Unknown_Element      =  5;   {Unknown element}
  Err_Trailing_Garbage     =  6;   {Trailing garbage}
  Err_Invalid_Number       =  7;   {Invalid number}
  Err_Unknown_Operation    =  8;   {Unknown operation}

  Err_Division_by_zero     = -2;   {Division by zero}
  Err_Invalid_argument     = -3;   {Invalid arg}
  Err_Overflow             = -8;   {Overflow}
{#Z-}


type
  TFOperation = (_CONST, _CHS, _ABS, _ARG, _ADD, _SUB, _MUL, _DIV, _EXPT,
                 _SQRT,_SQR, _X, _Y, _Z, _ARCCOSH,
                 _AGM, _ARCCOS, _ARCSIN, _ARCTAN, _ARCSINH, _ARCTANH,
                 _CCELL1, _COS, _COSH, _EXP, _EXPM1,
                 _LN, _LN1P, _LOG10, _SIN, _SINH, _TAN, _TANH,
                 _COT, _CSC, _SEC, _COTH, _CSCH, _SECH,
                 _ARCCOT,_ARCCOTC,_ARCCSC,_ARCSEC,_ARCCOTH,_ARCCSCH,_ARCSECH,
                 _LAMBERTW, _EK, _EE, _GAMMA, _LNGAMMA, _PSI, _DILOG,
                 _SN, _CN, _DN, _ERF, _ERFC, _RSTHETA, _LAMBERTWK,
                 _CBRT, _CONJ, _RE, _IM, _ZETA, _EI, _E1, _LI, _NROOT, _SURD,
                 _TEST);
                 {implemented operators, functions, and variables}

type
  PFExpr  = ^TFExpr;                       {Expression node pointer}
  TFExpr  = record                         {binary tree node}
              op:  TFOperation;            {operation/function/variable}
              nn:  byte;                   {number of nodes}
              case integer of
                0: (Value: complex);       {value if op=_CONST}
                1: (SNode: PFExpr);        {expr = (SNode op) or op(SNode)}
                2: (LNode, RNode: PFExpr;) {expr = LNode op RNode or op(LNode,RNode)}
            end;

  TFEval  = record                         {Evaluation record}
              X  : complex;                {Variable X}
              Y  : complex;                {Variable Y}
              Z  : complex;                {Variable Z}
              Res: complex;                {Evaluation result}
              Err: integer;                {Eval error code}
            end;


function  amc_parse(psz: pchar8; var e: PFExpr; var Err: integer): pchar8;
  {-Parse string psz into expression tree e, if OK Err=0 and result^=#0,}
  { else Err=Err_xx and result points to error position}

procedure amc_eval(e: PFExpr; var evr: TFEval);
  {-Evaluate expression tree e, result in evr}

procedure amc_clear_expr(var e: PFExpr);
  {-Release memory used by e}

procedure amc_calculate(psz: pchar8; var evr: TFEval; var EPos: integer);
  {-Parse and evaluate string psz}

function  amc_calc_errorstr(Err: integer): str255;
  {-Translate known error codes}

procedure amc_init_eval(var evr: TFEval);
  {-Initialize the complexs of evr}


implementation


uses
  memh;
(* Approx. grammar for expression parser:

  <Expr>    ::=   <Term> '+' <Term>
                | <Term> '-' <Term>
                | '+'<Term>
                | '-'<Term>;
  <Term>    ::=   <Factor> '*' <Factor>
                | <Factor> '/' <Factor>
                | <Factor>;
  <Factor>  ::=   <Element> '^' <Factor>
                | <Element>;
  <Element> ::= <Func> | <Var> | <number> | 'i' | 'pi' | '(' <Expr> ')';
  <Func>    ::= <Ident> '(' <Arglist> ')';
  <Var>     ::= 'X'..'Z' | 'x'..'z';
  <Arglist  ::= <Expr> | <Expr> ',' <Expr>;
  <Ident>   ::= <alpha> {<alpha> | <digit>};
  <intnum>  ::= <digit> { <digit> };
  <expo>    ::=   'e' ['+' | '-'] <intnum>
                | 'E' ['+' | '-'] <intnum>
  <number>  ::= ['+' | '-'] [<intnum>] ['.' [<intnum>] <expo>];
  <digit>   ::= '0'..'9';
  <alpha>   ::= 'A'..'Z'| 'a'..'z';
*)



type
  str10  = string[10];
  TFunc  = record
               op: TFOperation;
             arg2: boolean;
             name: str10;
           end;
type
  TOpVar = _X.._Z;

const
  MaxFun = 61;

const
  FuncTab : array[1..MaxFun] of TFunc = (
             (op: _SQRT      ; arg2: false; name: 'SQRT'),
             (op: _SQR       ; arg2: false; name: 'SQR'),
             (op: _ABS       ; arg2: false; name: 'ABS'),
             (op: _ARG       ; arg2: false; name: 'ARG'),
             (op: _ARCCOSH   ; arg2: false; name: 'ARCCOSH'),
             (op: _AGM       ; arg2: true ; name: 'AGM'),
             (op: _ARCCOS    ; arg2: false; name: 'ARCCOS'),
             (op: _ARCSIN    ; arg2: false; name: 'ARCSIN'),
             (op: _ARCTAN    ; arg2: false; name: 'ARCTAN'),
             (op: _ARCSINH   ; arg2: false; name: 'ARCSINH'),
             (op: _ARCTANH   ; arg2: false; name: 'ARCTANH'),
             (op: _CCELL1    ; arg2: false; name: 'CK'),
             (op: _COS       ; arg2: false; name: 'COS'),
             (op: _COSH      ; arg2: false; name: 'COSH'),
             (op: _EXP       ; arg2: false; name: 'EXP'),
             (op: _LN        ; arg2: false; name: 'LN'),
             (op: _LN1P      ; arg2: false; name: 'LN1P'),
             (op: _LOG10     ; arg2: false; name: 'LOG10'),
             (op: _SIN       ; arg2: false; name: 'SIN'),
             (op: _SINH      ; arg2: false; name: 'SINH'),
             (op: _TAN       ; arg2: false; name: 'TAN'),
             (op: _TANH      ; arg2: false; name: 'TANH'),
             (op: _COT       ; arg2: false; name: 'COT'),
             (op: _CSC       ; arg2: false; name: 'CSC'),
             (op: _SEC       ; arg2: false; name: 'SEC'),
             (op: _COTH      ; arg2: false; name: 'COTH'),
             (op: _CSCH      ; arg2: false; name: 'CSCH'),
             (op: _SECH      ; arg2: false; name: 'SECH'),
             (op: _ARCCOT    ; arg2: false; name: 'ARCCOT'),
             (op: _ARCCOTC   ; arg2: false; name: 'ARCCOTC'),
             (op: _ARCCSC    ; arg2: false; name: 'ARCCSC'),
             (op: _ARCSEC    ; arg2: false; name: 'ARCSEC'),
             (op: _ARCCOTH   ; arg2: false; name: 'ARCCOTH'),
             (op: _ARCCSCH   ; arg2: false; name: 'ARCCSCH'),
             (op: _ARCSECH   ; arg2: false; name: 'ARCSECH'),
             (op: _LAMBERTW  ; arg2: false; name: 'LAMBERTW'),
             (op: _EK        ; arg2: false; name: 'EK'),
             (op: _EE        ; arg2: false; name: 'EE'),
             (op: _LNGAMMA   ; arg2: false; name: 'LNGAMMA'),
             (op: _GAMMA     ; arg2: false; name: 'GAMMA'),
             (op: _PSI       ; arg2: false; name: 'PSI'),
             (op: _DILOG     ; arg2: false; name: 'DILOG'),
             (op: _ERF       ; arg2: false; name: 'ERF'),
             (op: _ERFC      ; arg2: false; name: 'ERFC'),
             (op: _RSTHETA   ; arg2: false; name: 'RSTHETA'),
             (op: _SN        ; arg2: true;  name: 'SN'),
             (op: _CN        ; arg2: true;  name: 'CN'),
             (op: _DN        ; arg2: true;  name: 'DN'),
             (op: _LAMBERTWK ; arg2: true;  name: 'WK'),
             (op: _CBRT      ; arg2: false; name: 'CBRT'),
             (op: _CONJ      ; arg2: false; name: 'CONJ'),
             (op: _RE        ; arg2: false; name: 'RE'),
             (op: _IM        ; arg2: false; name: 'IM'),
             (op: _EXPM1     ; arg2: false; name: 'EXPM1'),
             (op: _ZETA      ; arg2: false; name: 'ZETA'),
             (op: _EI        ; arg2: false; name: 'EI'),
             (op: _E1        ; arg2: false; name: 'E1'),
             (op: _LI        ; arg2: false; name: 'LI'),
             (op: _NROOT     ; arg2: true;  name: 'NROOT'),
             (op: _SURD      ; arg2: true;  name: 'SURD'),
             (op: _TEST      ; arg2: false; name: 'TEST')  {used for tests, development etc}
           );


{---------------------------------------------------------------------------}
function SkipWhite(psz: pchar8): pchar8;
  {-Skip white space}
begin
  while psz^ in [' ',#13,#10,#9] do inc(psz);
  SkipWhite := psz;
end;


{---------------------------------------------------------------------------}
procedure mkNode(var r: PFExpr; op: TFOperation; nn: byte; e1, e2: PFExpr);
  {-Make a new expression node for (e1 op e2) or (e1 op)}
begin
  r := malloc(sizeof(TFExpr));
  r^.nn := nn;
  r^.op := op;
  r^.LNode := e1;
  r^.RNode := e2;
end;


{---------------------------------------------------------------------------}
procedure mkNode0c(var r: PFExpr);
  {-Make a new node for a constant}
begin
  {alloc Value node initialize complex}
  r := calloc(sizeof(TFExpr));
  r^.op := _CONST;
  r^.nn := 0;
end;


{---------------------------------------------------------------------------}
procedure mkNode0v(var r: PFExpr; const v: TOpVar);
  {-Make a new node for a variable v = _X, _Y, or _Z}
begin
  {alloc Value node initialize complex}
  r := malloc(sizeof(TFExpr));
  r^.op := v;
  r^.nn := 0;
end;


{---------------------------------------------------------------------------}
procedure mkNode1(var r: PFExpr; op: TFOperation; e: PFExpr);
  {-Make a new expression node for r := e op}
begin
  mkNode(r,op,1,e,nil);
end;


{---------------------------------------------------------------------------}
procedure mkNode2(var r: PFExpr; op: TFOperation; e1, e2: PFExpr);
  {-Make a new expression node for r := e1 op e2}
begin
  mkNode(r,op,2,e1,e2);
end;


{---------------------------------------------------------------------------}
function GetIdent(psz: pchar8): str255;
  {-Gather next identifier, break if not in [A-Z, a-z, 0-9], result is uppercase}
  { first character in must be in [A-Z, a-z]}
var
  s: str255;
begin
  s := '';
  if psz^ in ['A'..'Z', 'a'..'z'] then begin
    while psz^ in ['A'..'Z', 'a'..'z', '0'..'9'] do begin
      s := s+upcase(psz^);
      inc(psz);
    end;
  end;
  GetIdent := s;
end;


{---------------------------------------------------------------------------}
function GetFuncIndex(const s: str255): integer;
  {-Test if s is a known function name, if yes return index else 0}
var
  i: integer;
begin
  for i:=1 to MaxFun do begin
    if FuncTab[i].name=s then begin
      GetFuncIndex := i;
      exit;
    end;
  end;
  GetFuncIndex := 0;
end;


{---------------------------------------------------------------------------}
function Expr(psz: pchar8; var e: PFExpr; var Err: integer): pchar8; forward;
  {-Parse string psz into expression tree}
{---------------------------------------------------------------------------}


{---------------------------------------------------------------------------}
function Func(psz: pchar8; idx: integer; var e: PFExpr; var Err: integer): pchar8;
  {-Build function expression, psz points between function name and "("}
var
  e1,e2: PFExpr;
const
  na: array[boolean] of byte = (1,2);

  procedure clear;
    {-Clear local PFExpr if error}
  begin
    if e1<>nil then amc_clear_expr(e1);
    if e2<>nil then amc_clear_expr(e2);
  end;

begin
  e1 := nil;
  e2 := nil;
  e  := nil;
  Func := psz;
  if Err<>0 then exit;
  psz := SkipWhite(psz);
  if psz^ <> '(' then begin
    Func := psz;
    Err := Err_Missing_LeftBracket;
    exit;
  end;
  {get first argument}
  psz := Expr(psz+1,e1, Err);
  Func := psz;
  if Err<>0 then begin
    clear;
    exit;
  end;
  psz := SkipWhite(psz);
  if FuncTab[idx].arg2 then begin
    {if two arguments search for ","}
    if psz^ <> ',' then begin
      Func := psz;
      Err := Err_Missing_Comma;
      clear;
      exit;
    end;
    {evaluate second argument}
    psz := Expr(psz+1,e2,Err);
    Func := psz;
    if Err<>0 then begin
      clear;
      exit;
    end;
    psz := SkipWhite(psz);
  end
  else e2:=nil;
  {search for closing ")"}
  if psz^ <> ')' then begin
    Func := psz;
    Err := Err_Missing_RightBracket;
    clear;
    exit;
  end;
  inc(psz);
  with FuncTab[idx] do mkNode(e, op, na[arg2], e1, e2);
  Func := psz;
end;


{---------------------------------------------------------------------------}
function Element(psz: pchar8; var e: PFExpr; var Err: integer): pchar8;
  {-Parse an Element}
var
  res: PFExpr;
  s,sc: pchar8;
  lsc: word;
  i,ic: integer;
  s0: char8;
  neg: boolean;
  id: str255;
  x: double;
begin
  Element := psz;
  e := nil;
  if Err<>0 then exit;
  psz := SkipWhite(psz);
  s0 := psz^;
  if s0 in ['A'..'Z', 'a'..'z'] then begin
    id := GetIdent(psz);
    i := GetFuncIndex(id);
    if i=0 then begin
      if id='X' then begin mkNode0v(e, _X); inc(psz); end
      else if id='Y' then begin mkNode0v(e, _Y); inc(psz); end
      else if id='Z' then begin mkNode0v(e, _Z); inc(psz); end
      else if id='I' then begin
        mkNode0c(res);
        res^.Value.im := 1;
        inc(psz,1);
        e := res;
      end
      else if id='PI' then begin
        mkNode0c(res);
        res^.Value.re := Pi;
        inc(psz,2);
        e := res;
      end
      else if id='LN2' then begin
        mkNode0c(res);
        res^.Value.re := ln2;
        inc(psz,3);
        e := res;
      end
      else if id='LN10' then begin
        mkNode0c(res);
        res^.Value.re := ln(10.0);
        inc(psz,4);
        e := res;
      end
      else if id='E' then begin
        mkNode0c(res);
        res^.Value.re := exp(1.0);
        inc(psz,1);
        e := res;
      end
      else begin
        Err := Err_Unknown_Function;
        Element := psz;
        exit;
      end;
    end
    else begin
      inc(psz, length(id));
      psz := Func(psz,i,e, Err);
    end;
  end
  else if s0='(' then begin
    psz := Expr(psz+1,e,Err);
    if Err<>0 then exit;
    psz := SkipWhite(psz);
    if psz^<>')' then begin
      Err := Err_Missing_RightBracket;
      Element := psz;
      exit;
    end;
    inc(psz);
  end
  else if s0 in ['0'..'9','+','-','.'] then begin
    {get sign}
    neg := false;
    if psz^ in ['+','-'] then begin
      if psz^='-' then neg := true;
      inc(psz);
    end;

    {count decimal characters}
    s := psz;
    {integer part}
    while psz^ in ['0'..'9'] do inc(psz);

    if psz^='.' then begin
      inc(psz);
      {fractional part}
      while psz^ in ['0'..'9'] do inc(psz);
    end;

    if (upcase(psz^)='E') and (s<>psz) then begin
       {exponent part}
       inc(psz);
       if psz^ in ['+','-'] then inc(psz);
       while psz^ in ['0'..'9'] do inc(psz);
    end;

    {alloc and move digit string to temp storage}
    if s=psz then begin
      {empty digit string}
      Err := Err_Invalid_Number;
      Element := psz;
      exit;
    end;

    lsc := psz-s+1;
    sc := malloc(lsc);
    move(s^,sc^,lsc-1);
    sc[psz-s] := #0;
    {Make a constant node}
    mkNode0c(res);
    {convert digit string to real}
    {$ifdef UNICODE}
      val(string(sc), x, ic);
    {$else}
      val(sc, x, ic);
    {$endif}
    if ic <> 0 then begin
      Err := Err_Invalid_Number;
      Element := psz;
      exit;
    end;
    {apply sign}
    if neg then x := -x;
    res^.Value.re := x;
    e := res;
    mfree(pointer(sc),lsc);
  end
  else begin
    Err := Err_Unknown_Element;
    Element := psz;
    exit;
  end;
  Element := psz;
end;


{---------------------------------------------------------------------------}
function Factor(psz: pchar8; var e: PFExpr; var Err: integer): pchar8;
  {-Parse a Factor}
var
  t: PFExpr;
begin
  e := nil;
  if Err<>0 then begin
    Factor := psz;
    exit;
  end;
  psz := Element(psz,e,Err);
  if Err<>0 then begin
    Factor := psz;
    exit;
  end;
  {Look for optional power part of Factor}
  psz := SkipWhite(psz);
  if psz^='^' then begin
    inc(psz);
    t := nil;
    psz := Factor(psz, t, Err);
    if Err=0 then mkNode2(e, _EXPT, e, t)
    else if t<>nil then amc_clear_expr(t);
  end;
  Factor := psz;
end;


{---------------------------------------------------------------------------}
function Term(psz: pchar8; var e: PFExpr; var Err: integer): pchar8;
  {-Parse a Term}
var
  t: PFExpr;
begin
  e := nil;
  if Err<>0 then begin
    Term := psz;
    exit;
  end;
  t := nil;
  psz := Factor(psz,e, Err);
  while Err=0 do begin
    psz := SkipWhite(psz);
    case upcase(psz[0]) of
      '*' : begin
              psz := Factor(psz+1, t, Err);
              if Err=0 then mkNode2(e, _MUL, e, t);
            end;
      '/':  begin
              psz := Factor(psz+1, t, Err);
              if Err=0 then mkNode2(e, _DIV, e, t);
            end;
     else   break;
    end;
  end;
  if (Err<>0) and (t<>nil) then amc_clear_expr(t);
  Term := psz;
end;


{---------------------------------------------------------------------------}
function Expr(psz: pchar8; var e: PFExpr; var Err: integer): pchar8;
  {-Parse an Expr}
var
  t: PFExpr;
  c: char8;
begin
  e := nil;
  if Err<>0 then begin
    Expr := psz;
    exit;
  end;
  psz := SkipWhite(psz);
  c  := psz^;
  {Unary prefix operators}
  if c='+' then begin
    {just skip the +}
    psz := Term(psz+1, e, Err)
  end
  else if c='-' then begin
    psz := Term(psz+1, e, Err);
    if Err<>0 then begin
      Expr := psz;
      exit;
    end;
    mkNode1(e, _CHS, e);
  end
  else psz := Term(psz, e, Err);

  t := nil;
  while Err=0 do begin
    psz := SkipWhite(psz);
    case psz^ of
      '+': begin
             psz := Term(psz+1, t, Err);
             if Err=0 then mkNode2(e, _ADD, e, t);
           end;
      '-': begin
             psz := Term(psz+1, t, Err);
             if Err=0 then mkNode2(e, _SUB, e, t);
           end;
      else break;
    end; {case}
  end;
  if (Err<>0) and (t<>nil) then amc_clear_expr(t);
  Expr := psz;
end;


{---------------------------------------------------------------------------}
function amc_parse(psz: pchar8; var e: PFExpr; var Err: integer): pchar8;
  {-Parse string psz into expression tree e, Err=0 and psz^=#0 if OK,}
  { else Err=Err_xx and result points to error postions}
begin
  Err := 0;
  psz := Expr(psz, e, Err);
  if (Err=0) and (psz^<>#0) then Err := Err_Trailing_Garbage;
  amc_parse := psz;
end;


{---------------------------------------------------------------------------}
procedure eval(e: PFExpr; var r: complex; var evr: TFEval);
  {-(internal) evaluate expression tree e, result in r}
var
  v1,v2: complex;
begin
  if evr.Err<>0 then exit;

  if e^.nn=0 then begin
    case e^.op of
      _CONST: begin
                r := e^.Value;
              end;
          _X: begin
                r := evr.X;
              end;
          _Y: begin
                r := evr.Y;
              end;
          _Z: begin
                r := evr.z;
              end;
         else evr.Err := Err_Unknown_Operation;
    end;
    exit;
  end;

  if e^.nn=1 then begin
    eval(e^.LNode, v1, evr);
    if evr.Err=0 then begin
      case e^.op of
            _CHS:  begin
                     cneg(v1,r);
                   end;

            _ABS:  begin
                     r.re := cabs(v1);
                     r.im := 0.0;
                   end;

            _ARG:  begin
                     r.re := carg(v1);
                     r.im := 0.0;
                   end;

            _SQR:  begin
                     csqr(v1,r);
                   end;

           _SQRT:  begin
                     csqrt(v1,r);
                   end;

        _ARCCOSH:  begin
                     carccosh(v1,r);
                   end;

         _ARCCOS:  begin
                     carccos(v1,r);
                   end;

         _ARCSIN:  begin
                     carcsin(v1,r);
                   end;

         _ARCTAN:  begin
                     carctan(v1,r);
                   end;

        _ARCSINH:  begin
                     carcsinh(v1,r);
                   end;

        _ARCTANH:  begin
                     carctanh(v1,r);
                   end;

         _CCELL1:  begin
                     cellck(v1,r);
                   end;

             _EK:  begin
                     cellk(v1,r);
                   end;

             _EE:  begin
                     celle(v1,r);
                   end;

            _COS:  begin
                     ccos(v1,r);
                   end;

           _COSH:  begin
                     ccosh(v1,r);
                   end;

            _EXP:  begin
                     cexp(v1,r);
                   end;

          _EXPM1:  begin
                     cexpm1(v1,r);
                   end;

             _LN:  begin
                     cln(v1,r)
                   end;

           _LN1P:  begin
                     cln1p(v1,r)
                   end;

          _LOG10:  begin
                     clog10(v1,r)
                   end;

            _SIN:  begin
                     csin(v1,r);
                   end;

           _SINH:  begin
                     csinh(v1,r)
                   end;

            _TAN:  begin
                     ctan(v1,r);
                   end;

           _TANH:  begin
                     ctanh(v1,r);
                   end;

            _COT:  begin
                     ccot(v1,r);
                   end;

            _CSC:  begin
                     ccsc(v1,r);
                   end;

            _SEC:  begin
                     csec(v1,r);
                   end;

           _COTH:  begin
                     ccoth(v1,r);
                   end;

           _CSCH:  begin
                     ccsch(v1,r);
                   end;

           _SECH:  begin
                     csech(v1,r);
                   end;

         _ARCCOT:  begin
                     carccot(v1,r);
                   end;

        _ARCCOTC:  begin
                     carccotc(v1,r);
                   end;

         _ARCCSC:  begin
                     carccsc(v1,r)
                   end;

         _ARCSEC:  begin
                     carcsec(v1,r)
                   end;

        _ARCCOTH:  begin
                     carccoth(v1,r);
                   end;

        _ARCCSCH:  begin
                     carccsch(v1,r);
                   end;

        _ARCSECH:  begin
                     carcsech(v1,r)
                   end;

        _LAMBERTW: begin
                     {v1 > -1/e}
                     clambertw(v1,r);
                   end;

        _LNGAMMA:  begin
                     clngamma(v1,r);
                   end;

          _GAMMA:  begin
                     cgamma(v1,r);
                   end;

            _PSI:  begin
                     cpsi(v1,r);
                   end;

          _DILOG:  begin
                     cdilog(v1,r);
                   end;

            _ERF:  begin
                     cerf(v1,r);
                   end;

           _ERFC:  begin
                     cerfc(v1,r);
                   end;

        _RSTHETA:  begin
                     crstheta(v1,r);
                   end;

           _CBRT:  begin
                     ccbrt(v1,r);
                   end;

           _CONJ:  begin
                     cconj(v1,r);
                   end;

             _RE:  begin
                     r.re := v1.re;
                     r.im := 0.0;
                   end;

             _IM:  begin
                     r.re := v1.im;
                     r.im := 0.0;
                   end;

           _ZETA:  begin
                     czeta(v1,r);
                   end;

             _EI:  begin
                     cei(v1,r);
                   end;

             _E1:  begin
                     ce1(v1,r);
                   end;

             _LI:  begin
                     cli(v1,r);
                   end;

           _TEST:  begin
                     ce1(v1,r); {
                     v1.re := v1.re*pi;
                     v1.im := v1.im*Pi;
                     csin(v1,v2);
                     csub(r,v2,r); }
                   end;

            else   evr.Err := Err_Unknown_Operation
      end;
    end;
  end
  else begin
    eval(e^.LNode, v1, evr);
    if evr.Err=0 then begin
      eval(e^.RNode, v2, evr);
    end;
    if evr.Err=0 then begin
      case e^.op of
          _ADD:  cadd(v1,v2,r);
          _SUB:  csub(v1,v2,r);
          _MUL:  cmul(v1,v2,r);
          _DIV:  begin
                   if cabs(v2)=0 then begin
                     r.re := Nan_d;
                     r.im := Nan_d;
                     evr.Err := Err_Division_by_zero
                   end
                   else cdiv(v1,v2,r);
                 end;
         _EXPT:  cpow(v1,v2,r);
          _AGM:  cagm(v1,v2,r);

           _SN:  if v2.im<>0 then evr.Err :=Err_Invalid_argument
                 else csn(v1, v2.re, r);

           _CN:  if v2.im<>0 then evr.Err :=Err_Invalid_argument
                 else ccn(v1, v2.re, r);

           _DN:  if v2.im<>0 then evr.Err :=Err_Invalid_argument
                 else cdn(v1, v2.re, r);

    _LAMBERTWK:  begin
                   if (v1.im<>0) or (abs(v1.re) > MaxInt) then evr.Err :=Err_Invalid_argument
                   else clambertwk(round(v1.re), v2, r);
                 end;

        _NROOT:  begin
                   if (v2.im<>0) or (abs(v2.re) > MaxInt) then evr.Err :=Err_Invalid_argument
                   else cnroot(v1, round(v2.re), r);
                 end;

         _SURD:  begin
                   if (v2.im<>0) or (abs(v2.re) > MaxInt) then evr.Err :=Err_Invalid_argument
                   else csurd(v1, round(v2.re), r);
                 end;

          else   evr.Err := Err_Unknown_Operation
      end;
    end;
  end;
end;


{---------------------------------------------------------------------------}
procedure amc_clear_expr(var e: PFExpr);
  {-Release memory used by e and clear complex values}
begin
  if e<>nil then with e^ do begin
    case nn of
         0:  ;
         1:  amc_clear_expr(SNode);
       else  begin
               if e^.LNode<>nil then amc_clear_expr(e^.LNode);
               if e^.RNode<>nil then amc_clear_expr(e^.RNode);
             end;
    end;
    mfree(pointer(e),sizeof(TFExpr));
  end;
end;


{---------------------------------------------------------------------------}
procedure amc_eval(e: PFExpr; var evr: TFEval);
  {-Evaluate expression tree e, result in evr}
begin
  with evr do begin
    Err := 0;
    eval(e,Res,evr);
  end;
end;


{---------------------------------------------------------------------------}
procedure amc_calculate(psz: pchar8; var evr: TFEval; var EPos: integer);
  {-Parse and evaluate string psz}
var
  e: PFExpr;
  pc: pchar8;
begin
  e := nil;
  pc := amc_parse(psz,e,evr.Err);
  EPos := pc-psz;
  if evr.Err=0 then amc_eval(e, evr);
  amc_clear_expr(e);
end;


{---------------------------------------------------------------------------}
function amc_calc_errorstr(Err: integer): str255;
  {-Translate known error codes}
var
  s: string[20];
begin
  case Err of
    Err_Missing_LeftBracket  : amc_calc_errorstr := 'Missing "("';
    Err_Missing_Comma        : amc_calc_errorstr := 'Missing argument separator (",")';
    Err_Missing_RightBracket : amc_calc_errorstr := 'Missing ")"';
    Err_Unknown_Function     : amc_calc_errorstr := 'Unknown function';
    Err_Unknown_Element      : amc_calc_errorstr := 'Unknown element';
    Err_Trailing_Garbage     : amc_calc_errorstr := 'Trailing garbage';
    Err_Invalid_Number       : amc_calc_errorstr := 'Invalid number';
    Err_Unknown_Operation    : amc_calc_errorstr := 'Unknown operation';
    Err_Division_by_zero     : amc_calc_errorstr := 'Division by zero';
    Err_Invalid_argument     : amc_calc_errorstr := 'Invalid argument(s)';
    Err_Overflow             : amc_calc_errorstr := 'Overflow';
    else begin
      str(Err,s);
      amc_calc_errorstr := 'amc_calc error '+s;
    end;
  end;
end;


{---------------------------------------------------------------------------}
procedure amc_init_eval(var evr: TFEval);
  {-Initialize the complexs of evr}
begin
  fillchar(evr, sizeof(TFEval), 0);
end;


end.


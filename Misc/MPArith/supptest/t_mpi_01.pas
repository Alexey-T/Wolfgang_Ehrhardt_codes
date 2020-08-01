{-Test prog for MP Lib V0.3+, we 26.08.04}
{ associativity/distributivity mult and add/sub}

program t_mpi_01;


{$i STD.INC}

{$i+}
{$x+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses {$ifdef WINCRT} WinCRT, {$endif}
     mp_types, mp_base, mp_supp;

{.$i mp_conf.inc}

var
  aa,bb,cc,x,y,z: mp_int;
  d: mp_digit;
  n: longint;

{---------------------------------------------------------------------------}
procedure randint(var a: mp_int);
begin
  mp_rand_radix(a, 10, 60);
  if random(2)=0 then a.sign := MP_NEG;
end;


{---------------------------------------------------------------------------}
procedure check1;
begin
  randint(aa);
  randint(bb);
  randint(cc);
  d := random(MP_DIGIT_MAX) and MP_MASK;

  {(a+b)+c = a+(b+c)}
  mp_add(aa,bb,x);
  mp_add(x,cc,x);
  mp_add(bb,cc,y);
  mp_add(aa,y,y);
  if mp_is_ne(x,y) then begin
    writeln('Error: (a+b)+c = a+(b+c)');
    writeln('a=',mp_decimal(aa));
    writeln('b=',mp_decimal(bb));
    writeln('c=',mp_decimal(cc));
    writeln('x=',mp_decimal(x));
    writeln('y=',mp_decimal(y));
    halt;
  end;
  {a-(b-c) = (a-b)+c}
  mp_sub(bb,cc,x);
  mp_sub(aa,x,x);
  mp_sub(aa,bb,y);
  mp_add(y,cc,y);

  if mp_is_ne(x,y) then begin
    writeln('Error: a-(b-c) = (a-b)+c');
    writeln('a=',mp_decimal(aa));
    writeln('b=',mp_decimal(bb));
    writeln('c=',mp_decimal(cc));
    writeln('x=',mp_decimal(x));
    writeln('y=',mp_decimal(y));
    halt;
  end;
  {(a+b)*d = a*d + b*d}
  mp_add(aa,bb,x);
  mp_mul_d(x,d,x);
  mp_mul_d(aa,d,y);
  mp_mul_d(bb,d,z);
  mp_add(y,z,y);

  if mp_is_ne(x,y) then begin
    writeln('Error: (a+b)*d = a*d + b*d');
    writeln('a=',mp_decimal(aa));
    writeln('b=',mp_decimal(bb));
    writeln('d=',d);
    writeln('x=',mp_decimal(x));
    writeln('y=',mp_decimal(y));
    halt;
  end;

  {(a-b)*d = a*d - b*d}
  mp_sub(aa,bb,x);
  mp_mul_d(x,d,x);
  mp_mul_d(aa,d,y);
  mp_mul_d(bb,d,z);
  mp_sub(y,z,y);

  if mp_is_ne(x,y) then begin
    writeln('Error: (a-b)*d = a*d - b*d');
    writeln('a=',mp_decimal(aa));
    writeln('b=',mp_decimal(bb));
    writeln('d=',d);
    writeln('x=',mp_decimal(x));
    writeln('y=',mp_decimal(y));
    halt;
  end;

  {(a+b)*c = a*c + b*c}
  mp_add(aa,bb,x);
  mp_mul(x,cc,x);
  mp_mul(aa,cc,y);
  mp_mul(bb,cc,z);
  mp_add(y,z,y);

  if mp_is_ne(x,y) then begin
    writeln('Error: (a+b)*c = a*c + b*c');
    writeln('a=',mp_decimal(aa));
    writeln('b=',mp_decimal(bb));
    writeln('c=',mp_decimal(cc));
    writeln('x=',mp_decimal(x));
    writeln('y=',mp_decimal(y));
    halt;
  end;

  {(a-b)*c = a*c - b*c}
  mp_sub(aa,bb,x);
  mp_mul(x,cc,x);
  mp_mul(aa,cc,y);
  mp_mul(bb,cc,z);
  mp_sub(y,z,y);

  if mp_is_ne(x,y) then begin
    writeln('Error: (a-b)*c = a*c - b*c');
    writeln('a=',mp_decimal(aa));
    writeln('b=',mp_decimal(bb));
    writeln('c=',mp_decimal(cc));
    writeln('x=',mp_decimal(x));
    writeln('y=',mp_decimal(y));
    halt;
  end;

end;


begin
  writeln('Test of MP Lib Version ', MP_VERSION);

  mp_init(aa);
  mp_init(bb);
  mp_init(cc);
  mp_init(x);
  mp_init(y);
  mp_init(z);

  for n:=1 to 500 do begin
    check1;
    if n mod 10 = 0 then write('.');
  end;
  writeln;

  mp_clear(aa);
  mp_clear(bb);
  mp_clear(cc);
  mp_clear(x);
  mp_clear(y);
  mp_clear(z);

  mp_dump_meminfo;

end.

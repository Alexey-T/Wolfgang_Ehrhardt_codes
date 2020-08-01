{Test program comparing different factorial implementations, we Jan.2006}

program t_cmpfac;


{$i STD.INC}
{$i mp_conf.inc}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

{$ifndef FPC}
{$N+}
{$endif}

uses
  {$ifdef WINCRT} WINCRT, {$else} CRT, {$endif}
   hrtimer,
   mp_types, mp_prime, mp_base, mp_numth;



{---------------------------------------------------------------------------}
procedure mp_fact_d(n: mp_digit; var a: mp_int);
  {-calculate a = factorial(n) for an mp_digit}
const
  {factorial small index = maximum b for which all products}
  {i*k in the small factor loop are less than MP_DIGIT_MAX }
  {fsi := trunc(sqrt(8*(1 shl DIGIT_BIT))-3) and (not 1)   }

  {maximum of f(x) = (2x+1)*(i/2-x) is at xm=(i-1)/4 with  }
  {f(xm) = (i+1)^2/8. So for f(xm) to be < 1 shl DIGIT_BIT }
  {fsi takes the value above (with some bells and whistles)}

  FSIVec : array[7..29] of word = (
      28,     42,     60,     86,    124,    178,    252,    358,
     508,    720,   1020,   1444,   2044,   2892,   4092,   5788,
    8188,  11582,  16380,  23166,  32764,  46336,  65532);{ 92678, 131068}
var
  FSI,i,b,k: mp_digit;
  t: mp_int;
begin
  {Basic formula for even n is n! = 2^(n/2)*(n/2)!*n!!}
  {where n!! is the product of all odd integers in [1,n-1]}
  {cf Crandall & Pomerance, Research Problem 1.93}
  if odd(n) then begin
    mp_set(a,n);
    dec(n);
  end
  else mp_set(a,1);
  if n<2 then exit;

  mp_init_set(t,1);
  if mp_error<>MP_OKAY then exit;

  {Note: factors are accumulated into balanced products, }
  {ie the products have nearly the same number of digits.}
  {This needs more memory, but speed is roughly doubled. }
  {Intermediate Karatsuba steps do NOT increase speed.   }

  {get factorial small index from table}
  i := DIGIT_BIT;
  if i<7 then FSI := 0
  else begin
    if i>29 then i := 29;
    FSI := mp_digit(FSIVec[i]);
  end;
  if FSI<n then b := FSI else b := n;

  {i represents the odd factors, k the even factors (div 2)}

  {accumulate small factors with i*b <= MP_DIGIT_MAX}
  i := 3;
  k := b shr 1;
  while i<b do begin
    {try to keep sizes of a and t balanced}
    if a.used<t.used then mp_mul_d(a,mp_digit(i*k),a)
                     else mp_mul_d(t,mp_digit(i*k),t);
    inc(i,2);
    dec(k);
    if mp_error<>MP_OKAY then break;
  end;

  i := FSI+1;
  k := 1 + (FSI shr 1);
  {accumulate remaining factors}
  while i<n do begin
    {try to keep sizes of a and t balanced}
    if a.used<t.used then mp_mul_d(a,mp_digit(i),a) else mp_mul_d(t,mp_digit(i),t);
    if a.used<t.used then mp_mul_d(a,mp_digit(k),a) else mp_mul_d(t,mp_digit(k),t);
    inc(i,2);
    inc(k);
    if mp_error<>MP_OKAY then break;
  end;
  {multiply factors together}
  mp_mul(a,t,a);
  {and shift in powers of 2, ie multiply with 2^(n/2)}
  mp_mul_2k(a, n shr 1, a);
  mp_clear(t);
end;



{---------------------------------------------------------------------------}
procedure mp_fact05(n: word; var a: mp_int);
  {-calculate a = factorial(n), function from mp_int V0.5.x}
var
  d,x,y: mp_int;
  i: word;
begin
  if mp_error<>MP_OKAY then exit;
  {$ifdef MPC_ArgCheck}
    if mp_not_init(a) then begin
      {$ifdef MPC_HaltOnArgCheck}
        {$ifdef MPC_UseExceptions}
          raise MPXNotInit.Create('mp_fact05');
        {$else}
          RunError(MP_RTE_NOTINIT);
        {$endif}
      {$else}
        set_mp_error(MP_NOTINIT);
        exit;
      {$endif}
    end;
  {$endif}

  if mp_word(n) <= MP_DIGIT_MAX then mp_fact_d(mp_digit(n), a)
  else begin
    {here remaining factors don't fit into mp_digits}
    mp_fact_d(MP_DIGIT_MAX, a);
    {the remaining factors accumulated in two products }
    {x and y while trying to keep their sizes balanced }
    mp_init3(d,x,y);
    if mp_error=MP_OKAY then begin
      mp_set(d, MP_DIGIT_MAX);
      mp_set(x,1);
      mp_set(y,1);
      {multiply all remaining factors}
      for i:=word(MP_DIGIT_MAX and $FFFF) to n-1 do begin
        mp_inc(d);
        {try to keep sizes of x and y balanced}
        if x.used<y.used then mp_mul(x,d,x) else mp_mul(y,d,y);
        if mp_error<>MP_OKAY then break;
      end;
      {first multiply nearly equal sized x and y}
      mp_mul(x,y,x);
      {then update then result with x*y}
      mp_mul(a,x,a);
      mp_clear3(d,x,y);
    end;
  end;
end;



{---------------------------------------------------------------------------}
procedure mp_odd_prod(a,b: word; var p: mp_int);
  {-calculate product p=(2a+3)*(2a+5)*..*(2b-1)*(2b+1), a<b<2^15}

  procedure OddProd(a,b: word; var p: mp_int);
    {-internal reursive proc without arg check}
  const
    MIND=8;
  var
    d: word;
    q: mp_int;
  begin
    if mp_error<>MP_OKAY then exit;
    d := b-a;
    if d<MIND then begin
      a := 2*b+1;
      mp_set_w(p,a);
      while d>1 do begin
        dec(a,2);
        mp_mul_w(p,a,p);
        dec(d);
      end;
    end
    else begin
      d := (b+a) shr 1;
      mp_init(q);
      OddProd(a,d,p);
      OddProd(d,b,q);
      mp_mul(p,q,p);
      mp_clear(q);
    end;
  end;

begin
  if mp_error<>MP_OKAY then exit;
  {$ifdef MPC_ArgCheck}
    if mp_not_init(p) then begin
      {$ifdef MPC_HaltOnArgCheck}
        {$ifdef MPC_UseExceptions}
          raise MPXNotInit.Create('mp_odd_prod');
        {$else}
          RunError(MP_RTE_NOTINIT);
        {$endif}
      {$else}
        set_mp_error(MP_NOTINIT);
        exit;
      {$endif}
    end;
  {$endif}
  {Check b=0}
  if (b<=a) or (b>$7FFF) then begin
    {$ifdef MPC_HaltOnError}
      {$ifdef MPC_UseExceptions}
        raise MPXRange.Create('mp_odd_prod: (b<=a) or (b>$7FFF)');
      {$else}
        RunError(MP_RTE_RANGE);
      {$endif}
    {$else}
      set_mp_error(MP_RANGE);
      exit;
    {$endif}
  end;
  OddProd(a,b,p);
end;



{---------------------------------------------------------------------------}
procedure boiten(x: word; var vres: mp_int);
  {E.Boiten: Ch. 3 - Factorization of the factorial, available as}
  {http://www.cs.ru.nl/aio-info/FormerPhD/EerkeBoitenThesis.ps.Z }
  {Appendix 2, Function newfact}
var
  vz: mp_int;
  vy,voddy,vtwo,vn,tood: word;
begin
  mp_set(vres,1);
  if x=0 then exit;
  mp_init(vz);
  mp_set(vz,1);
  vy := 0;
  vn := bitsize32(x)-1;
  vtwo  := 0;
  voddy := 1;
  while vy<>x do begin
    inc(vtwo,vy);
    vy := x shr vn; dec(vn);
    if odd(vy) then tood := vy else tood := vy-1;
    while voddy<>tood do begin
      inc(voddy,2);
      mp_mul_int(vz,voddy,vz);
    end;
    mp_mul(vres,vz,vres);
  end;
  mp_mul_2k(vres, vtwo, vres);
  mp_clear(vz);
end;



{---------------------------------------------------------------------------}
procedure werecfac(n: word; var a: mp_int);
  {-WE's recursive function based on n! = 2^(n/2)*(n/2)!*n!! (n even)}
const
  sfact: array[0..12] of longint = (1,1,2,6,24,120,720,5040,40320,362880,
                                    3628800,39916800,479001600);
var
  p: mp_int;
begin
  if n<=12 then mp_set_int(a,sfact[n])
  else begin
    {Basic formula for even n is n! = 2^(n/2)*(n/2)!*n!!}
    {where n!! is the product of all odd integers in [1,n-1]}
    {cf Crandall & Pomerance, Research Problem 1.93}
    if odd(n) then begin
      werecfac(n-1,a);
      mp_mul_w(a,n,a);
    end
    else begin
      mp_init(p);
      n := n shr 1;
      {calculate (original n)!!}
      mp_odd_prod(0,n-1,p);
      werecfac(n,a);
      mp_mul(p,a,a);
      mp_mul_2k(a, n, a);
      mp_clear(p);
    end;
  end;
end;



{---------------------------------------------------------------------------}
procedure mp_fact06(n: word; var a: mp_int);
  {-calculate a = factorial(n), error if n > MaxFact}
  {Based of P.Luschny's FactorialSplitRecursive.java, available at}
  {http://www.luschny.de/math/factorial/FastFactorialFunctions.htm}
  {See also: Ch. 3 - Factorization of the factorial, available as }
  {http://www.cs.ru.nl/aio-info/FormerPhD/EerkeBoitenThesis.ps.Z  }

var
  np: word; {accumulates product of odd numbers}
  procedure product(var p: mp_int; l: word);
    {-recursive product of odd numbers (depends on np and calling sequence)}
  var
    m: word;
    t: mp_int;
  begin
    if mp_error<>MP_OKAY then exit;
    if l<8 then begin
      inc(np,2);
      mp_set_w(p, np);
      {use while, this allows variable limits}
      while l>1 do begin
        inc(np, 2);
        mp_mul_w(p, np, p);
        dec(l);
      end;
    end
    else begin
      mp_init(t);
      m := l shr 1;
      product(p, m);
      product(t, l-m);
      mp_mul(p, t, p);
      mp_clear(t);
    end;
  end;

var
  p,r: mp_int;
  i,high,len: word;
const
  {factorial for small arguments}
  sfact: array[0..12] of longint = (1,1,2,6,24,120,720,5040,40320,362880,
                                    3628800,39916800,479001600);
begin
  if mp_error<>MP_OKAY then exit;
  {$ifdef MPC_ArgCheck}
    if mp_not_init(a) then begin
      {$ifdef MPC_HaltOnArgCheck}
        {$ifdef MPC_UseExceptions}
          raise MPXNotInit.Create('mp_fact');
        {$else}
          RunError(MP_RTE_NOTINIT);
        {$endif}
      {$else}
        set_mp_error(MP_NOTINIT);
        exit;
      {$endif}
    end;
  {$endif}

  if n <= 12 then mp_set_int(a, sfact[n])
  else begin
    {initialize "private long N"}
    np := 1;
    {create and initialize local mp_ints}
    mp_init2(p,r);
    mp_set(p, 1);
    mp_set(r, 1);

    high := 1;
    for i:=bitsize32(n)-1 downto 0 do begin
      len  := high;
      high := n shr i;
      if not odd(high) then dec(high);
      len := (high-len) shr 1;
      if len>0 then begin
        {use "a" for product result}
        product(a,len);
        mp_mul(p,a,p);
        mp_mul(r,p,r);
      end;
    end;
    {Luschny's final shift is n - popcount(n)}
    mp_mul_2k(r, n - popcount16(n), a);
    mp_clear2(p,r);
  end;
end;



{---------------------------------------------------------------------------}
procedure pfd_fact(n: word; var a: mp_int);
  {-n! by multiplying prime powers}
var
  p,m,d: word;
  x,y: mp_int;
begin
  mp_set(a,1);
  mp_init2(x,y);
  for p:=n downto 3 do begin
    if isprime16(p) then begin
      {calculate d = max. prime power p^d dividing n}
      d := 0;
      m := n;
      while m>0 do begin
        m := m div p;
        inc(d,m);
      end;
      if d<4 then begin
        {direct calculation of small powers}
        for m:=1 to d do mp_mul_w(a,p,a);
      end
      else begin
        {get y = p^d by binary powering}
        mp_set(x,p);
        mp_set(y,1);
        while d<>0 do begin
          if odd(d) then mp_mul(y,x,y);
          mp_sqr(x,x);
          d := d shr 1;
        end;
        mp_mul(a,y,a);
      end;
    end;
  end;
  mp_mul_2k(a, n - popcount16(n), a);
  mp_clear2(x,y);
end;


{$ifdef BIT16}
const
  NF=8000;
{$else}
const
  NF=32000;
{$endif}
var
  a: mp_int;
  HR: THRTimer;
begin
  StartTimer(HR);
  mp_init(a);

  writeln('Test of MPArith V', MP_VERSION, '   (c) W.Ehrhardt 2006');
  writeln('Karatsuba cutoffs: mul/sqr = ',mp_mul_cutoff,'/',mp_sqr_cutoff);

  writeln('MaxFact = ',MaxFact,',  calculate factorial of ',NF);
  writeln('Results are number of decimals digits and calculation time in ms.');
  writeln;
  if NF>MaxFact then halt;

  write('mp_fact V0.5':12);
  RestartTimer(HR);
  mp_fact05(NF,a);
  writeln(mp_radix_size(a,10):10, ReadSeconds(HR)*1000:10:1);

  write('boiten':12);
  RestartTimer(HR);
  boiten(NF,a);
  writeln(mp_radix_size(a,10):10, ReadSeconds(HR)*1000:10:1);

  write('werecfac':12);
  RestartTimer(HR);
  werecfac(NF,a);
  writeln(mp_radix_size(a,10):10, ReadSeconds(HR)*1000:10:1);

  write('pfd_fact':12);
  RestartTimer(HR);
  pfd_fact(NF,a);
  writeln(mp_radix_size(a,10):10, ReadSeconds(HR)*1000:10:1);

  write('mp_fact V0.6':12);
  RestartTimer(HR);
  mp_fact06(NF,a);
  writeln(mp_radix_size(a,10):10, ReadSeconds(HR)*1000:10:1);

  write('mp_fact':12);
  RestartTimer(HR);
  mp_fact(NF,a);
  writeln(mp_radix_size(a,10):10, ReadSeconds(HR)*1000:10:1);

  mp_clear(a);

end.

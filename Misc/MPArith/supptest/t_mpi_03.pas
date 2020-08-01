{-Test prog for MP Lib V0.3+, we 26.08.04}

program t_mpi_03;

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
  a,b,c,t,q,r: mp_int;


function mp_len(const a: mp_int): integer;
begin
  mp_len := mp_radix_size(a, 10);
end;

const
  da='-63546325485464347857834625872356';
  db='347858734687886957634227';
  dc='23648756124738';

begin
  writeln('Test of MP Lib Version ', MP_VERSION);
  mp_show_plus := true;

  mp_init(a);
  mp_init(b);
  mp_init(c);
  mp_init(q);
  mp_init(r);
  mp_init(t);


  mp_read_radix(a,da,10);
  mp_read_radix(b,db,10);
  mp_read_radix(c,dc,10);
  writeln('a<=>1=',mp_cmp_int(a,1));
  writeln('    a=',mp_decimal(a), mp_len(a): 10);
  writeln('    b=',mp_decimal(b), mp_len(b): 10);
  writeln('    c=',mp_decimal(c), mp_len(c): 10);
  mp_mul(b,a,t);
  mp_add(t,c,t);
  writeln('a*b+c=',mp_decimal(t));

  mp_divrem(t,b,@q,@r);
  mp_mul(q,b,a);
  mp_add(a,r,a);
  mp_sub(a,t,a);
  writeln('    q=',mp_decimal(q));
  writeln('    r=',mp_decimal(r));
  writeln('t-(q*b+r)=',mp_decimal(a));

  mp_2expt(a,120);
  mp_set_int(b,longint(1) shl 30);
  mp_mul(b,b,b);
  mp_mul(b,b,b);
  writeln(mp_decimal(a));
  writeln(mp_decimal(b));
  mp_set_int(b,2);
  mp_expt_w(b,120,b);
  writeln(mp_decimal(b));

  mp_set_int(a,22);
  mp_set_int(b,100);
  mp_expt(a,b,c);
  writeln(mp_decimal(c));

{  mp_sqrt(c,c);}
  mp_n_root(c,2,c);

  writeln('mp_sqrt=',mp_decimal(c));

  mp_set_int(a,22);
  mp_set_int(b,50);
  mp_expt(a,b,t);
  writeln('  check=',mp_decimal(t));


  mp_read_radix(a,da,10);
  mp_read_radix(b,db,10);
{  mp_chs(b,b);}
  writeln('    a=',mp_decimal(a));
  writeln('    b=',mp_decimal(b));
  mp_mod(a,b,b);
  writeln('    c=',mp_decimal(b));
  writeln('Check=','293566197247827816516224');

  mp_clear(a);
  mp_clear(b);
  mp_clear(c);
  mp_clear(q);
  mp_clear(r);
  mp_clear(t);

  mp_dump_meminfo;

end.

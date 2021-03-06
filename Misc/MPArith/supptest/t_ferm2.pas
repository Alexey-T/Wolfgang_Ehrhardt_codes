{-Test prog for factorization}
{ find factors of Fermat[p]}

program t_ferm2;

{$i STD.INC}

{$x+,i+}

{$ifdef APPCONS}
  {$apptype console}
{$endif}

uses
  {$ifdef WINCRT} WinCRT, {$else} CRT, {$endif}
  BTypes,mp_types, mp_base, mp_numth, pfdu, pfdu_crt;

var
  num: mp_int;
  ctx: pfd_ctx;


{---------------------------------------------------------------------------}
procedure AppendList(p: word);
var
  f: text;
  i,nc: integer;
begin
  {$i-}
  with ctx do begin
    assign(f,'fermat.pfl');
    append(f);
    if ioresult<>0 then rewrite(f);
    writeln(f,'Fermat[',p,'] = ',mp_decimal(num));
    write(f,'= ');
    for i:=1 to ns do begin
      if sexp[i]<=1 then write(f,sfac[i]) else write(f,sfac[i],'^',sexp[i]);
      if i<ns then write(f,' * ');
    end;
    nc := 0;
    for i:=1 to nb do begin
      if (i>1) or (ns>0) then write(f,' * ');
      if bfac[i].sign=MP_NEG then inc(nc);
      write(f,mp_decimal(bfac[i]));
    end;
    writeln(f);
    if nc>0 then writeln(f,'#######################');
    writeln(f);
    writeln(f);
    close(f);
    {$ifdef IOChecks_on}
      {$i+}
    {$endif}
  end;
end;


{---------------------------------------------------------------------------}
procedure dofactor(p: word);
begin
  {num := 10^p+1}
  mp_fermat(p,num);
  pfd_factor(ctx, num);
  AppendList(p);
end;


var
  p: word;
  ans : char8;
  loop: boolean;
begin
  pfd_banner;
  writeln('Prime factor Fermat[p]');
  write('Start exponent (0=quit)? p = ');
  readln(p);
  if p>0 then begin
    write('Auto increment loop? [Y/N] : ');
    repeat
      ans:=upcase(readkey);
    until (ans='Y') or (ans='N');
    writeln(ans);
    loop := ans='Y';
    pfd_initialize(ctx);
    mp_init(num);
    if mp_error=MP_OKAY then begin
      repeat
        writeln(#13#10'p = ',p);
        dofactor(p);
        inc(p);
        if abort then break;
        while keypressed do if readkey=#27 then break;
      until (mp_error<>MP_OKAY) or (not loop);
      mp_clear(num);
    end;
    pfd_finalize(ctx);
  end;
end.

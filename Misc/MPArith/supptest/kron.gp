/* Pari/GP script to calculate Kronecker test cases, (c) we 2006 */

{ /* First: all pairs in [-10..10] x [-10..10] */
  for (a=-10, 10,
    for (n=-10, 10,
        print("");
        print(a);
        print(n);
        print(kronecker(a,n))
    )
  );
  /* Second: growing random pairs */
  for (i=1, 20,
    h = 2^(10*i);
    r = 2*h;
    for (k=1, 5,
        a = random(r)-h;
        n = random(r)-h;
        print("");
        print(a);
        print(n);
        print(kronecker(a,n))
    )
  )

}

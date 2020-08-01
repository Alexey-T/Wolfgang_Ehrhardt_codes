/* Pari/GP script to calculate rational exponentiation test cases, (c) we 2007 */

{
    a=0;
    for (n=0, 5,
        print("");
        print(a);
        print(n);
        print(a^n)
    );
    a=1;
    for (n=-5, 5,
        print("");
        print(a);
        print(n);
        print(a^n)
    );
    a=-1;
    for (n=-5, 5,
        print("");
        print(a);
        print(n);
        print(a^n)
    );
    a=-3/5;
    for (n=-20, 20,
        print("");
        print(a);
        print(n);
        print(a^n)
    );
    a=-120/17;
    for (n=-10, 10,
        print("");
        print(a);
        print(n);
        print(a^n)
    );
    a=12023476142/31734513;
    for (n=-10, 10,
        print("");
        print(a);
        print(n);
        print(a^n)
    );
    a=-509252236125428/47889593208724507642867;
    for (n=-10, 10,
        print("");
        print(a);
        print(n);
        print(a^n)
    );
}

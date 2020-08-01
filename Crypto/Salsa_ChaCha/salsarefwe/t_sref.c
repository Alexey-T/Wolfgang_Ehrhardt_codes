/*
** Speed test program for Salsa20   (c) 2006 W.Ehrhardt
*/

#include <stdio.h>
#include <time.h>
#include <string.h>
#include "ecrypt-sync.h"

extern int salsa_rounds;

static int ks=1;

#define NCnt 1000000

void usage(void) {
  printf("usage: t_sref [k8 | k12 | k20 | e8 | e12 | e20]\n");
  printf(" kx: key stream with salsa20/x\n");
  printf(" ex: encrypt with salsa20/x\n");
}

int main(int argc, char* argv[]) {
  int i;
  unsigned char buf[576];
  u8 iv[8] = {0,0,0,0,0,0,0,0};
  u8 key[32];
  clock_t t1,t2;
  ECRYPT_ctx x;


  if (argc==1) {
    usage();
    return(-1);
  }
  if (!strcmp(argv[1],"k8")) {
    /* keystream,  8 rounds */
    salsa_rounds = 8;
  }
  else if (!strcmp(argv[1],"k12")) {
    /* keystream,  12 rounds */
    salsa_rounds = 12;
  }
  else if (!strcmp(argv[1],"k20")) {
    /* keystream,  20 rounds */
    salsa_rounds = 20;
  }
  else if (!strcmp(argv[1],"e8")) {
    /* encrypt,  8 rounds */
    salsa_rounds = 8;
    ks = 0;
  }
  else if (!strcmp(argv[1],"e12")) {
    /* encrypt,  12 rounds */
    salsa_rounds = 12;
    ks = 0;
  }
  else if (!strcmp(argv[1],"e20")) {
    /* encrypt,  20 rounds */
    salsa_rounds = 20;
    ks = 0;
  }
  else {
    usage();
    return(-1);
  }
  ECRYPT_keysetup(&x, key, 128, 64);
  ECRYPT_ivsetup(&x, iv);

  t1 = clock();
  if (ks==0) {
    for (i=0; i<NCnt; i++) ECRYPT_encrypt_bytes(&x, buf, buf, 576);
  }
  else {
    for (i=0; i<NCnt; i++) ECRYPT_keystream_bytes(&x, buf, 576);
  }
  t2 = clock();
  printf("Time in s for %s = %1.3f\n",argv[1], (double)(t2-t1)/CLOCKS_PER_SEC);
  return(0);
}


/*
** Speed test program for Sosemanuk   (c) 2009 W.Ehrhardt
*/

#include <stdio.h>
#include <time.h>
#include <string.h>
#include "ecrypt-sync.h"

extern int salsa_rounds;

#define NCnt 1000000

void usage(void) {
  printf("usage: t_sref [k128 | k256 | e128 | e256]\n");
  printf(" kx: key stream with Sosemanuk\n");
  printf(" ex: encrypt with Sosemanuk\n");
}

int main(int argc, char* argv[]) {
  int i;
  unsigned char buf[800];
  u8 iv[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
  u8 key[32];
  u32 ks=0;
  u32 es=0;
  u32 sum=0;
  double sec,mbs;
  clock_t t1,t2;
  ECRYPT_ctx x;


  if (argc==1) {
    usage();
    return(-1);
  }
  if (!strcmp(argv[1],"k256")) {
    ks = 256;
  }
  else if (!strcmp(argv[1],"k128")) {
    ks = 128;
  }
  else if (!strcmp(argv[1],"e128")) {
    es = 1;
    ks = 128;
  }
  else if (!strcmp(argv[1],"e256")) {
    es = 1;
    ks = 256;
  }
  else {
    usage();
    return(-1);
  }

  for (i=0; i<sizeof(key); i++) key[i]=0;
  for (i=0; i<sizeof(buf); i++) buf[i]=0;

  ECRYPT_keysetup(&x, key, ks, 128);
  ECRYPT_ivsetup(&x, iv);

  t1 = clock();
  if (es>0) {
    for (i=0; i<NCnt; i++) ECRYPT_encrypt_bytes(&x, buf, buf, 800);
  }
  else {
    for (i=0; i<NCnt; i++) ECRYPT_keystream_bytes(&x, buf, 800);
  }
  t2 = clock();

  sec = (double)(t2-t1)/CLOCKS_PER_SEC;
  mbs = 800.0E-6*NCnt/sec;
  for (i=0; i<800; i++) sum += buf[i];
  printf("Results for %s: time in s = %6.3f,   MB/s = %5.1f,   CS = 0x%08x\n",
         argv[1], sec, mbs, sum);

  return(0);
}


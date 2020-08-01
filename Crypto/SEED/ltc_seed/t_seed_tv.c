#include "tomcrypt.h"

/* SEED test program, W.Ehrhardt June 2007 */
/* Calculate test vectors for Block Cipher Modes*/

#define LOOPS (1)

int main(int argc, char * argv[])
{
  unsigned char key[16]    = {0x2b,0x7e,0x15,0x16,0x28,0xae,0xd2,0xa6,0xab,0xf7,0x15,0x88,0x09,0xcf,0x4f,0x3c};
  unsigned char IV[16]     = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f};
  unsigned char CTR[16]    = {0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0xff};
  unsigned char buffer[64] = {0x6b,0xc1,0xbe,0xe2,0x2e,0x40,0x9f,0x96,0xe9,0x3d,0x7e,0x11,0x73,0x93,0x17,0x2a,
                              0xae,0x2d,0x8a,0x57,0x1e,0x03,0xac,0x9c,0x9e,0xb7,0x6f,0xac,0x45,0xaf,0x8e,0x51,
                              0x30,0xc8,0x1c,0x46,0xa3,0x5c,0xe4,0x11,0xe5,0xfb,0xc1,0x19,0x1a,0x0a,0x52,0xef,
                              0xf6,0x9f,0x24,0x45,0xdf,0x4f,0x9b,0x17,0xad,0x2b,0x41,0x7b,0xe6,0x6c,0x37,0x10};


  symmetric_CTR ctr;
  symmetric_CFB cfb;
  symmetric_OFB ofb;
  symmetric_ECB ecb;
  symmetric_CBC cbc;
  omac_state omac;
  unsigned char tag[16];
  int error, i, oidx;
  unsigned k;
  unsigned long taglen;

  if (register_cipher(&kseed_desc) == -1) {
    printf("Error registering cipher.\n");
    return -1;
  }


  if (argc<2) {
    printf("Usage: %s  [cbc | cfb | ctr | ecb | ofb | omac]", argv[0]);
    return -1;
  }


  if (!strcmp(argv[1],"ctr")) {
    if ((error = ctr_start(find_cipher("seed"), CTR, key, 16, 0,CTR_COUNTER_BIG_ENDIAN
    , &ctr)) != CRYPT_OK) {
      printf("ctr_start error: %s\n", error_to_string(error));
      return -1;
    }
    for (i=0; i<LOOPS; i++) {
      if ((error = ctr_encrypt(buffer, buffer, sizeof(buffer), &ctr)) != CRYPT_OK) {
        printf("ctr_encrypt error: %s\n", error_to_string(error));
        return -1;
      }
    }
  }

  else if (!strcmp(argv[1],"cfb")) {
    if ((error = cfb_start(find_cipher("seed"), IV, key, 16, 0, &cfb)) != CRYPT_OK) {
      printf("cfb_start error: %s\n", error_to_string(error));
      return -1;
    }
    for (i=0; i<LOOPS; i++) {
      if ((error = cfb_encrypt(buffer, buffer, sizeof(buffer), &cfb)) != CRYPT_OK) {
        printf("cfb_encrypt error: %s\n", error_to_string(error));
        return -1;
      }
    }
  }

  else if (!strcmp(argv[1],"ofb")) {
    /* start up OFB mode */
    if ((error = ofb_start(find_cipher("seed"), IV, key, 16, 0, &ofb)) != CRYPT_OK) {
      printf("ofb_start error: %s\n", error_to_string(error));
      return -1;
    }

    for (i=0; i<LOOPS; i++) {
      if ((error = ofb_encrypt(buffer, buffer, sizeof(buffer), &ofb)) != CRYPT_OK) {
        printf("ofb_encrypt error: %s\n", error_to_string(error));
        return -1;
      }
    }
  }

  else if (!strcmp(argv[1],"ecb")) {
    /* start up ecb mode */
    if ((error = ecb_start(find_cipher("seed"), key, 16, 0, &ecb)) != CRYPT_OK) {
      printf("ecb_start error: %s\n", error_to_string(error));
      return -1;
    }

    for (i=0; i<LOOPS; i++) {
      if ((error = ecb_encrypt(buffer, buffer, sizeof(buffer), &ecb)) != CRYPT_OK) {
        printf("ecb_encrypt error: %s\n", error_to_string(error));
        return -1;
      }
    }
  }

  else if (!strcmp(argv[1],"cbc")) {
    /* start up cbc mode */
    if ((error = cbc_start(find_cipher("seed"), IV, key, 16, 0, &cbc)) != CRYPT_OK) {
      printf("cbc_start error: %s\n", error_to_string(error));
      return -1;
    }

    for (i=0; i<LOOPS; i++) {
      if ((error = cbc_encrypt(buffer, buffer, sizeof(buffer), &cbc)) != CRYPT_OK) {
        printf("cbc_encrypt error: %s\n", error_to_string(error));
        return -1;
      }
    }
  }

  else if (!strcmp(argv[1],"omac")) {
    if ((oidx = find_cipher("seed")) == -1) {
      printf("OMAC: Unable to find seed cipher\n");
      return -1;
    }
    if ((error = omac_init(&omac, oidx, key, 16)) != CRYPT_OK) {
      printf("omac_init error: %s\n", error_to_string(error));
      return -1;
    }
    for (i=0; i<LOOPS; i++) {
      if ((error = omac_process(&omac, buffer, sizeof(buffer))) != CRYPT_OK) {
        printf("omac_process error: %s\n", error_to_string(error));
        return -1;
      }
    }

    taglen = sizeof(tag);
    if ((error = omac_done(&omac, tag, &taglen)) != CRYPT_OK) {
      printf("omac_done error: %s\n", error_to_string(error));
      return -1;
    }

    printf(";omac tag\n");
    for (i=0; i<taglen; i++) {printf("%02X", tag[i]); }
    printf("\n");
    return 0;

  }

  else {
    printf("Usage: %s  [cbc | cfb | ctr | ecb | ofb | omac]", argv[0]);
    return -1;
  }

  printf(";%s\n", argv[1]);
  for (i=0; i<64; i++) {printf("%02X", buffer[i]); }
  printf("\n");


  return 0;
}

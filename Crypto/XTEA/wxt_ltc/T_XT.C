#include "tomcrypt.h"



/*
 * XTEA vector calculation program, W.Ehrhardt Jan 2005
 * use xtea_we.c to be compatible with Botan
 */


int main(int argc, char * argv[])
{
  unsigned char key[16]   = {0x78, 0x56, 0x34, 0x12, 0xf0, 0xcd, 0xcb, 0x9a,
                             0x48, 0x37, 0x26, 0x15, 0xc0, 0xbf, 0xae, 0x9d};
  unsigned char IV[8]     = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07};
  unsigned char CIV[8]    = {0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7};
  unsigned char plain[64] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                             0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
                             0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28,
                             0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38,
                             0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
                             0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
                             0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68,
                             0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78};

  unsigned char buffer[64];
  symmetric_CTR ctr;
  symmetric_CFB cfb;
  symmetric_OFB ofb;
  symmetric_ECB ecb;
  symmetric_CBC cbc;
  int error, i;

  if (register_cipher(&xtea_desc) == -1) {
    printf("Error registering cipher.\n");
    return -1;
  }

  //ctr
  if ((error = ctr_start(find_cipher("xtea"), CIV, key, 16, 0, &ctr)) != CRYPT_OK) {
    printf("ctr_start error: %s\n", error_to_string(error));
    return -1;
  }
  ctr.mode = 1;
  if ((error = ctr_encrypt(plain, buffer, sizeof(buffer), &ctr)) != CRYPT_OK) {
    printf("ctr_encrypt error: %s\n", error_to_string(error));
    return -1;
  }
  printf(";CTR cipher\n");
  for (i=0; i<sizeof(buffer); i++) {printf("%02X",buffer[i]);}
  printf("\n\n");

  //cfb
  if ((error = cfb_start(find_cipher("xtea"), IV, key, 16, 0, &cfb)) != CRYPT_OK) {
    printf("cfb_start error: %s\n", error_to_string(error));
    return -1;
  }
  if ((error = cfb_encrypt(plain, buffer, sizeof(buffer), &cfb)) != CRYPT_OK) {
    printf("cfb_encrypt error: %s\n", error_to_string(error));
    return -1;
  }
  printf(";CFB cipher\n");
  for (i=0; i<sizeof(buffer); i++) {printf("%02X",buffer[i]);}
  printf("\n\n");

  //ofb
  if ((error = ofb_start(find_cipher("xtea"), IV, key, 16, 0, &ofb)) != CRYPT_OK) {
    printf("ofb_start error: %s\n", error_to_string(error));
    return -1;
  }
  if ((error = ofb_encrypt(plain, buffer, sizeof(buffer), &ofb)) != CRYPT_OK) {
    printf("ofb_encrypt error: %s\n", error_to_string(error));
    return -1;
  }
  printf(";OFB cipher\n");
  for (i=0; i<sizeof(buffer); i++) {printf("%02X",buffer[i]);}
  printf("\n\n");

  //ecb
  if ((error = ecb_start(find_cipher("xtea"), key, 16, 0, &ecb)) != CRYPT_OK) {
    printf("ecb_start error: %s\n", error_to_string(error));
    return -1;
  }
  for (i=0; i<sizeof(buffer); i+=8) {
    if ((error = ecb_encrypt(plain+i, buffer+i, &ecb)) != CRYPT_OK) {
      printf("ecb_encrypt error: %s\n", error_to_string(error));
      return -1;
    }
  }
  printf(";ECB cipher\n");
  for (i=0; i<sizeof(buffer); i++) {printf("%02X",buffer[i]);}
  printf("\n\n");

  //cbc
  if ((error = cbc_start(find_cipher("xtea"), IV, key, 16, 0, &cbc)) != CRYPT_OK) {
    printf("cbc_start error: %s\n", error_to_string(error));
    return -1;
  }
  for (i=0; i<sizeof(buffer); i+=8) {
    if ((error = cbc_encrypt(plain+i, buffer+i, &cbc)) != CRYPT_OK) {
      printf("cbc_encrypt error: %s\n", error_to_string(error));
      return -1;
    }
  }
  printf(";CBC cipher\n");
  for (i=0; i<sizeof(buffer); i++) {printf("%02X",buffer[i]);}
  printf("\n\n");

  return 0;
}


/* gbcrypt Version 2022.13
 *
 * Copyright (c) 2022 Guenther Brunthaler. All rights reserved.
 *
 * This source file is free software.
 * Distribution is permitted under the terms of the GPLv3. */

#if !defined __STDC_VERSION__ || __STDC_VERSION__ < 199901
   #error "This source file requires a C99-compliant C compiler!"
#endif

#include <stdint.h>

#define PHASE -1
#include "arc4algo.h"
#define PHASE 1
#include "arc4algo.h"
struct {
   uint_least8_t s[SBOX_SIZE];
   uint_fast8_t i, j;
} arc4context;

static void arc4_setkey(
   arc4context *ctx, uint8_t const *key, unsigned length
) {
   uint_fast8_t t;
   #define PHASE 0
   #define i ctx->i
   #define j ctx->j
   #define s ctx->s
   #define KEY_SETUP 1
   #define LOOP 0
   #include "arc4algo.h"
   #undef LOOP
   #define LOOP 1
   #define KEY_ELEMENT *key
   while (length--) {
      #include "arc4algo.h"
      ++key;
   }
}

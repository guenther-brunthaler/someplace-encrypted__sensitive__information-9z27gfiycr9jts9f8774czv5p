/* Version 2022.13 */

#if PHASE == -1
   /* Cleanup. */
   #ifdef i
      #undef i
   #endif
   #ifdef j
      #undef j
   #endif
   #ifdef t
      #undef t
   #endif
   #ifdef s
      #undef s
   #endif
   #ifdef SBOX_SIZE
      #undef SBOX_SIZE
   #endif
   #ifdef MOD_SBOX_SIZE
      #undef MOD_SBOX_SIZE
   #endif
   #ifdef SWAP
      #undef SWAP
   #endif
   #ifdef LOOP
      #undef LOOP
   #endif
   #ifdef KEY_SETUP
      #undef KEY_SETUP
   #endif
   #ifdef KEY_ELEMENT
      #undef KEY_ELEMENT
   #endif
   #ifdef OUTPUT
      #undef OUTPUT
   #endif
   #undef PHASE
#elif PHASE == 1
   /* Initialize. */
   #ifndef SBOX_SIZE
      #define SBOX_SIZE 1 << 8
   #endif
   #define MOD_SBOX_SIZE(x) ((x) & (SBOX_SIZE) - 1)
   #define SWAP(a, b) { (t)= (a); (a)= (b); (b)= (t); }
#elif LOOP == 0
   /* 1. Only for key setup: s[i]= i for all i where s[all indices mod 256] */
   #if KEY_SETUP
      for (t= SBOX_SIZE; t--; ) s[t]= t;
   #endif

   /* 2. i= j= 0 */
   i= j= 0;
#else
   /* 3. Except for key setup: Move i one position to the right */
   #if !KEY_SETUP
      i= MOD_SBOX_SIZE((i) + 1);
   #endif

   /* 4. Move j by (s[i] + optional_next_key_octet()) positions to the right */
   #ifdef KEY_ELEMENT
      j= MOD_SBOX_SIZE((j) + s[i] + (KEY_ELEMENT));
   #else
      j= MOD_SBOX_SIZE((j) + s[i]);
   #endif

   /* 5. Swap s[] values at indices i and j. */
   SWAP(s[i], s[j]);

   /* 6. Optionally output s[index equal to sum of values just swapped] */
   #ifdef OUTPUT
      OUTPUT= s[MOD_SBOX_SIZE(s[i] + s[j])]
   #endif

   /* 7. Only for key setup: Move i one position to the right */
   #if KEY_SETUP
      i= MOD_SBOX_SIZE((i) + 1);
   #endif

   /* 8. Go back to step 3 unless finished */
#endif

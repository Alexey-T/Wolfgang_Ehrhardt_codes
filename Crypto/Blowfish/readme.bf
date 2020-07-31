This archive contains Pascal/Delphi sources for the Blowfish cipher.
There is code for a DLL and the following modes of operation are
supported: CBC, CFB64, CTR, ECB,OFB, OMAC, and EAX. All modes allow
plain and cipher text lengths that need not be multiples of the block
length (for ECB and CBC cipher text stealing is used for the short
block). CTR mode can use 4 built-in incrementing functions or a user
supplied one, and provides seek functions for random access reads.

All modes (except OMAC/EAX) support a reset function that re-initializes
the chaining variables without the (time consuming) recalculation of the
round keys.

The unit BCrypt implements OpenBSD-style Blowfish password hashing.


-----------------------------------------------------------------------
Last changes (Nov. 2017)
- Adjustments for FPC/ARM and Delphi Tokyo


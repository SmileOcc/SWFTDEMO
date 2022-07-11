//
//  YXDodmot.c
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2019/9/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#include "YXDodmot.h"
#include <string.h>

#define DOT_MOT_KEY 0xFC

#if defined(PRD) || defined(PRD_HK)
static const char ldmlqq[] = {
    // MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCp1hORHq6Cx7/bNFObrs3i12UUKAiqVRTCQFJNnse/VurZZaxXQtgstjLSsDe3w0gVZmfEosSunhmTWAP5b2gFAcRYtaemT5JxZuf5E+aJWKvEuFP4ycjVaKcux9PNSia5CHd91HnRMg5MMZBWJ8R59oVpQwOJinvy0+j7VfzJMQIDAQAB
    (DOT_MOT_KEY ^ 'M'),
    (DOT_MOT_KEY ^ 'I'),(DOT_MOT_KEY ^ 'G'),(DOT_MOT_KEY ^ 'f'),(DOT_MOT_KEY ^ 'M'),(DOT_MOT_KEY ^ 'A'),
    (DOT_MOT_KEY ^ '0'),(DOT_MOT_KEY ^ 'G'),(DOT_MOT_KEY ^ 'C'),(DOT_MOT_KEY ^ 'S'),(DOT_MOT_KEY ^ 'q'),
    (DOT_MOT_KEY ^ 'G'),(DOT_MOT_KEY ^ 'S'),(DOT_MOT_KEY ^ 'I'),(DOT_MOT_KEY ^ 'b'),(DOT_MOT_KEY ^ '3'),
    (DOT_MOT_KEY ^ 'D'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'E'),(DOT_MOT_KEY ^ 'B'),(DOT_MOT_KEY ^ 'A'),
    (DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'U'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ '4'),
    (DOT_MOT_KEY ^ 'G'),(DOT_MOT_KEY ^ 'N'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'D'),(DOT_MOT_KEY ^ 'C'),
    (DOT_MOT_KEY ^ 'B'),(DOT_MOT_KEY ^ 'i'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'K'),(DOT_MOT_KEY ^ 'B'),
    (DOT_MOT_KEY ^ 'g'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'C'),(DOT_MOT_KEY ^ 'p'),(DOT_MOT_KEY ^ '1'),
    (DOT_MOT_KEY ^ 'h'),(DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'R'),(DOT_MOT_KEY ^ 'H'),(DOT_MOT_KEY ^ 'q'),
    (DOT_MOT_KEY ^ '6'),(DOT_MOT_KEY ^ 'C'),(DOT_MOT_KEY ^ 'x'),(DOT_MOT_KEY ^ '7'),(DOT_MOT_KEY ^ '/'),
    (DOT_MOT_KEY ^ 'b'),(DOT_MOT_KEY ^ 'N'),(DOT_MOT_KEY ^ 'F'),(DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'b'),
    (DOT_MOT_KEY ^ 'r'),(DOT_MOT_KEY ^ 's'),(DOT_MOT_KEY ^ '3'),(DOT_MOT_KEY ^ 'i'),(DOT_MOT_KEY ^ '1'),
    (DOT_MOT_KEY ^ '2'),(DOT_MOT_KEY ^ 'U'),(DOT_MOT_KEY ^ 'U'),(DOT_MOT_KEY ^ 'K'),(DOT_MOT_KEY ^ 'A'),
    (DOT_MOT_KEY ^ 'i'),(DOT_MOT_KEY ^ 'q'),(DOT_MOT_KEY ^ 'V'),(DOT_MOT_KEY ^ 'R'),(DOT_MOT_KEY ^ 'T'),
    (DOT_MOT_KEY ^ 'C'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'F'),(DOT_MOT_KEY ^ 'J'),(DOT_MOT_KEY ^ 'N'),
    (DOT_MOT_KEY ^ 'n'),(DOT_MOT_KEY ^ 's'),(DOT_MOT_KEY ^ 'e'),(DOT_MOT_KEY ^ '/'),(DOT_MOT_KEY ^ 'V'),
    (DOT_MOT_KEY ^ 'u'),(DOT_MOT_KEY ^ 'r'),(DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'a'),
    (DOT_MOT_KEY ^ 'x'),(DOT_MOT_KEY ^ 'X'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 't'),(DOT_MOT_KEY ^ 'g'),
    (DOT_MOT_KEY ^ 's'),(DOT_MOT_KEY ^ 't'),(DOT_MOT_KEY ^ 'j'),(DOT_MOT_KEY ^ 'L'),(DOT_MOT_KEY ^ 'S'),
    (DOT_MOT_KEY ^ 's'),(DOT_MOT_KEY ^ 'D'),(DOT_MOT_KEY ^ 'e'),(DOT_MOT_KEY ^ '3'),(DOT_MOT_KEY ^ 'w'),
    (DOT_MOT_KEY ^ '0'),(DOT_MOT_KEY ^ 'g'),(DOT_MOT_KEY ^ 'V'),(DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'm'),
    (DOT_MOT_KEY ^ 'f'),(DOT_MOT_KEY ^ 'E'),(DOT_MOT_KEY ^ 'o'),(DOT_MOT_KEY ^ 's'),(DOT_MOT_KEY ^ 'S'),
    (DOT_MOT_KEY ^ 'u'),(DOT_MOT_KEY ^ 'n'),(DOT_MOT_KEY ^ 'h'),(DOT_MOT_KEY ^ 'm'),(DOT_MOT_KEY ^ 'T'),
    (DOT_MOT_KEY ^ 'W'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'P'),(DOT_MOT_KEY ^ '5'),(DOT_MOT_KEY ^ 'b'),
    (DOT_MOT_KEY ^ '2'),(DOT_MOT_KEY ^ 'g'),(DOT_MOT_KEY ^ 'F'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'c'),
    (DOT_MOT_KEY ^ 'R'),(DOT_MOT_KEY ^ 'Y'),(DOT_MOT_KEY ^ 't'),(DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ 'e'),
    (DOT_MOT_KEY ^ 'm'),(DOT_MOT_KEY ^ 'T'),(DOT_MOT_KEY ^ '5'),(DOT_MOT_KEY ^ 'J'),(DOT_MOT_KEY ^ 'x'),
    (DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'u'),(DOT_MOT_KEY ^ 'f'),(DOT_MOT_KEY ^ '5'),(DOT_MOT_KEY ^ 'E'),
    (DOT_MOT_KEY ^ '+'),(DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ 'J'),(DOT_MOT_KEY ^ 'W'),(DOT_MOT_KEY ^ 'K'),
    (DOT_MOT_KEY ^ 'v'),(DOT_MOT_KEY ^ 'E'),(DOT_MOT_KEY ^ 'u'),(DOT_MOT_KEY ^ 'F'),(DOT_MOT_KEY ^ 'P'),
    (DOT_MOT_KEY ^ '4'),(DOT_MOT_KEY ^ 'y'),(DOT_MOT_KEY ^ 'c'),(DOT_MOT_KEY ^ 'j'),(DOT_MOT_KEY ^ 'V'),
    (DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ 'K'),(DOT_MOT_KEY ^ 'c'),(DOT_MOT_KEY ^ 'u'),(DOT_MOT_KEY ^ 'x'),
    (DOT_MOT_KEY ^ '9'),(DOT_MOT_KEY ^ 'P'),(DOT_MOT_KEY ^ 'N'),(DOT_MOT_KEY ^ 'S'),(DOT_MOT_KEY ^ 'i'),
    (DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ '5'),(DOT_MOT_KEY ^ 'C'),(DOT_MOT_KEY ^ 'H'),(DOT_MOT_KEY ^ 'd'),
    (DOT_MOT_KEY ^ '9'),(DOT_MOT_KEY ^ '1'),(DOT_MOT_KEY ^ 'H'),(DOT_MOT_KEY ^ 'n'),(DOT_MOT_KEY ^ 'R'),
    (DOT_MOT_KEY ^ 'M'),(DOT_MOT_KEY ^ 'g'),(DOT_MOT_KEY ^ '5'),(DOT_MOT_KEY ^ 'M'),(DOT_MOT_KEY ^ 'M'),
    (DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'B'),(DOT_MOT_KEY ^ 'W'),(DOT_MOT_KEY ^ 'J'),(DOT_MOT_KEY ^ '8'),
    (DOT_MOT_KEY ^ 'R'),(DOT_MOT_KEY ^ '5'),(DOT_MOT_KEY ^ '9'),(DOT_MOT_KEY ^ 'o'),(DOT_MOT_KEY ^ 'V'),
    (DOT_MOT_KEY ^ 'p'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'w'),(DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'J'),
    (DOT_MOT_KEY ^ 'i'),(DOT_MOT_KEY ^ 'n'),(DOT_MOT_KEY ^ 'v'),(DOT_MOT_KEY ^ 'y'),(DOT_MOT_KEY ^ '0'),
    (DOT_MOT_KEY ^ '+'),(DOT_MOT_KEY ^ 'j'),(DOT_MOT_KEY ^ '7'),(DOT_MOT_KEY ^ 'V'),(DOT_MOT_KEY ^ 'f'),
    (DOT_MOT_KEY ^ 'z'),(DOT_MOT_KEY ^ 'J'),(DOT_MOT_KEY ^ 'M'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'I'),
    (DOT_MOT_KEY ^ 'D'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'B'),
    (DOT_MOT_KEY ^ '\0')
};
#else

static const char ldmlqq[] = {
    // MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCajLOdwFMIBQ8k3W48/e4bIj2EFc3O/T54oiLOk+KQgAknvmUHJp/1arN8g9tjAaBKPSbznTe4ZYX3VXI7VTRF7Dhi1+vCkas1OwWkdwzZWg3LOqfUORF3tFmvNOiLLzJQ6H5oLsNNZjMOr2QZrm4srzc1aX3O0BRwQhPkP/XhYwIDAQAB
    (DOT_MOT_KEY ^ 'M'),
    (DOT_MOT_KEY ^ 'I'),(DOT_MOT_KEY ^ 'G'),(DOT_MOT_KEY ^ 'f'),(DOT_MOT_KEY ^ 'M'),(DOT_MOT_KEY ^ 'A'),
    (DOT_MOT_KEY ^ '0'),(DOT_MOT_KEY ^ 'G'),(DOT_MOT_KEY ^ 'C'),(DOT_MOT_KEY ^ 'S'),(DOT_MOT_KEY ^ 'q'),
    (DOT_MOT_KEY ^ 'G'),(DOT_MOT_KEY ^ 'S'),(DOT_MOT_KEY ^ 'I'),(DOT_MOT_KEY ^ 'b'),(DOT_MOT_KEY ^ '3'),
    (DOT_MOT_KEY ^ 'D'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'E'),(DOT_MOT_KEY ^ 'B'),(DOT_MOT_KEY ^ 'A'),
    (DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'U'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ '4'),
    (DOT_MOT_KEY ^ 'G'),(DOT_MOT_KEY ^ 'N'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'D'),(DOT_MOT_KEY ^ 'C'),
    (DOT_MOT_KEY ^ 'B'),(DOT_MOT_KEY ^ 'i'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'K'),(DOT_MOT_KEY ^ 'B'),
    (DOT_MOT_KEY ^ 'g'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'C'),(DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ 'j'),
    (DOT_MOT_KEY ^ 'L'),(DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'd'),(DOT_MOT_KEY ^ 'w'),(DOT_MOT_KEY ^ 'F'),
    (DOT_MOT_KEY ^ 'M'),(DOT_MOT_KEY ^ 'I'),(DOT_MOT_KEY ^ 'B'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ '8'),
    (DOT_MOT_KEY ^ 'k'),(DOT_MOT_KEY ^ '3'),(DOT_MOT_KEY ^ 'W'),(DOT_MOT_KEY ^ '4'),(DOT_MOT_KEY ^ '8'),
    (DOT_MOT_KEY ^ '/'),(DOT_MOT_KEY ^ 'e'),(DOT_MOT_KEY ^ '4'),(DOT_MOT_KEY ^ 'b'),(DOT_MOT_KEY ^ 'I'),
    (DOT_MOT_KEY ^ 'j'),(DOT_MOT_KEY ^ '2'),(DOT_MOT_KEY ^ 'E'),(DOT_MOT_KEY ^ 'F'),(DOT_MOT_KEY ^ 'c'),
    (DOT_MOT_KEY ^ '3'),(DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ '/'),(DOT_MOT_KEY ^ 'T'),(DOT_MOT_KEY ^ '5'),
    (DOT_MOT_KEY ^ '4'),(DOT_MOT_KEY ^ 'o'),(DOT_MOT_KEY ^ 'i'),(DOT_MOT_KEY ^ 'L'),(DOT_MOT_KEY ^ 'O'),
    (DOT_MOT_KEY ^ 'k'),(DOT_MOT_KEY ^ '+'),(DOT_MOT_KEY ^ 'K'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'g'),
    (DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'k'),(DOT_MOT_KEY ^ 'n'),(DOT_MOT_KEY ^ 'v'),(DOT_MOT_KEY ^ 'm'),
    (DOT_MOT_KEY ^ 'U'),(DOT_MOT_KEY ^ 'H'),(DOT_MOT_KEY ^ 'J'),(DOT_MOT_KEY ^ 'p'),(DOT_MOT_KEY ^ '/'),
    (DOT_MOT_KEY ^ '1'),(DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ 'r'),(DOT_MOT_KEY ^ 'N'),(DOT_MOT_KEY ^ '8'),
    (DOT_MOT_KEY ^ 'g'),(DOT_MOT_KEY ^ '9'),(DOT_MOT_KEY ^ 't'),(DOT_MOT_KEY ^ 'j'),(DOT_MOT_KEY ^ 'A'),
    (DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ 'B'),(DOT_MOT_KEY ^ 'K'),(DOT_MOT_KEY ^ 'P'),(DOT_MOT_KEY ^ 'S'),
    (DOT_MOT_KEY ^ 'b'),(DOT_MOT_KEY ^ 'z'),(DOT_MOT_KEY ^ 'n'),(DOT_MOT_KEY ^ 'T'),(DOT_MOT_KEY ^ 'e'),
    (DOT_MOT_KEY ^ '4'),(DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'Y'),(DOT_MOT_KEY ^ 'X'),(DOT_MOT_KEY ^ '3'),
    (DOT_MOT_KEY ^ 'V'),(DOT_MOT_KEY ^ 'X'),(DOT_MOT_KEY ^ 'I'),(DOT_MOT_KEY ^ '7'),(DOT_MOT_KEY ^ 'V'),
    (DOT_MOT_KEY ^ 'T'),(DOT_MOT_KEY ^ 'R'),(DOT_MOT_KEY ^ 'F'),(DOT_MOT_KEY ^ '7'),(DOT_MOT_KEY ^ 'D'),
    (DOT_MOT_KEY ^ 'h'),(DOT_MOT_KEY ^ 'i'),(DOT_MOT_KEY ^ '1'),(DOT_MOT_KEY ^ '+'),(DOT_MOT_KEY ^ 'v'),
    (DOT_MOT_KEY ^ 'C'),(DOT_MOT_KEY ^ 'k'),(DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ 's'),(DOT_MOT_KEY ^ '1'),
    (DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'w'),(DOT_MOT_KEY ^ 'W'),(DOT_MOT_KEY ^ 'k'),(DOT_MOT_KEY ^ 'd'),
    (DOT_MOT_KEY ^ 'w'),(DOT_MOT_KEY ^ 'z'),(DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'W'),(DOT_MOT_KEY ^ 'g'),
    (DOT_MOT_KEY ^ '3'),(DOT_MOT_KEY ^ 'L'),(DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'q'),(DOT_MOT_KEY ^ 'f'),
    (DOT_MOT_KEY ^ 'U'),(DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'R'),(DOT_MOT_KEY ^ 'F'),(DOT_MOT_KEY ^ '3'),
    (DOT_MOT_KEY ^ 't'),(DOT_MOT_KEY ^ 'F'),(DOT_MOT_KEY ^ 'm'),(DOT_MOT_KEY ^ 'v'),(DOT_MOT_KEY ^ 'N'),
    (DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'i'),(DOT_MOT_KEY ^ 'L'),(DOT_MOT_KEY ^ 'L'),(DOT_MOT_KEY ^ 'z'),
    (DOT_MOT_KEY ^ 'J'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ '6'),(DOT_MOT_KEY ^ 'H'),(DOT_MOT_KEY ^ '5'),
    (DOT_MOT_KEY ^ 'o'),(DOT_MOT_KEY ^ 'L'),(DOT_MOT_KEY ^ 's'),(DOT_MOT_KEY ^ 'N'),(DOT_MOT_KEY ^ 'N'),
    (DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'j'),(DOT_MOT_KEY ^ 'M'),(DOT_MOT_KEY ^ 'O'),(DOT_MOT_KEY ^ 'r'),
    (DOT_MOT_KEY ^ '2'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'Z'),(DOT_MOT_KEY ^ 'r'),(DOT_MOT_KEY ^ 'm'),
    (DOT_MOT_KEY ^ '4'),(DOT_MOT_KEY ^ 's'),(DOT_MOT_KEY ^ 'r'),(DOT_MOT_KEY ^ 'z'),(DOT_MOT_KEY ^ 'c'),
    (DOT_MOT_KEY ^ '1'),(DOT_MOT_KEY ^ 'a'),(DOT_MOT_KEY ^ 'X'),(DOT_MOT_KEY ^ '3'),(DOT_MOT_KEY ^ 'O'),
    (DOT_MOT_KEY ^ '0'),(DOT_MOT_KEY ^ 'B'),(DOT_MOT_KEY ^ 'R'),(DOT_MOT_KEY ^ 'w'),(DOT_MOT_KEY ^ 'Q'),
    (DOT_MOT_KEY ^ 'h'),(DOT_MOT_KEY ^ 'P'),(DOT_MOT_KEY ^ 'k'),(DOT_MOT_KEY ^ 'P'),(DOT_MOT_KEY ^ '/'),
    (DOT_MOT_KEY ^ 'X'),(DOT_MOT_KEY ^ 'h'),(DOT_MOT_KEY ^ 'Y'),(DOT_MOT_KEY ^ 'w'),(DOT_MOT_KEY ^ 'I'),
    (DOT_MOT_KEY ^ 'D'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'Q'),(DOT_MOT_KEY ^ 'A'),(DOT_MOT_KEY ^ 'B'),
    (DOT_MOT_KEY ^ '\0')
};
#endif
static char q[sizeof(ldmlqq)];

/**
 指定字符串和key进行异或操作，得到异或后的字符串

 @param str 需要进行异或的字符串
 @param key 异或的key
 */
void xorString(char *str, unsigned char key) {
    char *p = str;
    while( ((*p) ^= key) != '\0')  p++;
}

const char *lDotMot(void) {
    unsigned long length = sizeof(ldmlqq);
    memset(q, 0, length);
    memcpy(q, ldmlqq, length);
    xorString(q, DOT_MOT_KEY);
    return q;
}

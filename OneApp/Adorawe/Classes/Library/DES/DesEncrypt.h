//
//  DesEncrypt.h
//  Fakid
//
//  Created by Peter Yuen on 6/30/14.
//
//

#import <Foundation/Foundation.h>
#import<CommonCrypto/CommonCryptor.h>

typedef struct _desEncrypt{
    const char *(*encryptWithKeyAndType)(char *text,CCOperation operate,char *key,char *iv);
    const char* (*encryptText)(const char *, const char *, const char *);
    const char* (*decryptText)(const char *, const char *, const char *);
}_desEncrypt;


@interface DesEncrypt : NSObject
{

}
@property(nonatomic,copy) NSString *iv;
+(_desEncrypt *)sharedDesEncrypt;

@end

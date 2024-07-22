//
//  DesEncrypt.m
//  Fakid
//
//  Created by Peter Yuen on 6/30/14.
//
//

#import "DesEncrypt.h"
#import "GTMBase64.h"

//char *fixedKey = "Cjh56*-9&#^HJHD&&@!DP0N##$%^&**())LLJGHDAQAZZ,,..///,nm1````1223-asdfdddc777&&*334";

static const char* encryptWithKeyAndType(const char *text,CCOperation encryptOperation,char *key,char *iv)
{
    NSString *textString = [[NSString alloc]initWithCString:text encoding:NSUTF8StringEncoding];
//    NSLog(@"text:%@ key:%@",[NSString stringWithUTF8String:text], [NSString stringWithUTF8String:key]);
    
    const void *dataIn;
    size_t dataInLength;
    
    if (encryptOperation == kCCDecrypt) //decrypt
    {
        NSData *decryptData = [GTMBase64 decodeData:[textString dataUsingEncoding:NSUTF8StringEncoding]];   //转成utf-8并decode
        dataInLength = [decryptData length];
        dataIn = [decryptData bytes];
    }
    else  //encrypt
    {
        NSData* encryptData = [textString dataUsingEncoding:NSUTF8StringEncoding];
        dataInLength = [encryptData length];
        dataIn = (const void *)[encryptData bytes];
    }
    
    /*
     DES加密 ：用CCCrypt函数加密一下，然后用base64编码下，传过去
     DES解密 ：把收到的数据根据base64，decode一下，然后再用CCCrypt函数解密，得到原本的数据
     */
    
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL;
    size_t dataOutAvailable = 0;
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);
    
    const void *vkey = key;
    
    ccStatus = CCCrypt(encryptOperation,        // kCCEncrypt, etc.
                       kCCAlgorithm3DES,        // kCCAlgorithmAES128, etc.
                       kCCOptionPKCS7Padding,
                       vkey,                    //
                       kCCKeySize3DES,          //
                       iv,                      // optional initialization vector
                       dataIn,                  // optional per op and alg
                       dataInLength,            //
                       (void *)dataOut,         // data RETURNED here
                       dataOutAvailable,
                       &dataOutMoved);
    NSString *result = nil;
    
    if (encryptOperation == kCCDecrypt)
    {
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved] encoding:NSUTF8StringEncoding];
    }
    else
    {
        NSData *data = [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
        
        result = [GTMBase64 stringByEncodingData:data];
    }
    
    return [result UTF8String];
}


static const char* encryptText(const char* text, const char *key, const char *iv)
{
    return encryptWithKeyAndType(text, kCCEncrypt, (char*)key, (char*)iv);
}

static const char* decryptText(const char *text, const char *key, const char *iv)
{
    return encryptWithKeyAndType(text, kCCDecrypt, (char*)key, (char*)iv);
}

static _desEncrypt *_methodlist = NULL;

@implementation DesEncrypt

+(_desEncrypt *)sharedDesEncrypt
{
    @synchronized(self)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _methodlist = malloc(sizeof(_desEncrypt));
            _methodlist->encryptText=encryptText;
            _methodlist->decryptText=decryptText;
        });
    }
    return _methodlist;
}


-(void)dealloc
{
    _methodlist ? free(_methodlist) : 0;
}


@end

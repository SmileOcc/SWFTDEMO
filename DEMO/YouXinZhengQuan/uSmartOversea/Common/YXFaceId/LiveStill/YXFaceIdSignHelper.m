//
//  YXFaceIdSignHelper.m
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXFaceIdSignHelper.h"
#import "uSmartOversea-Swift.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation YXFaceIdSignHelper
- (NSString *)getFaceIDSignStr {
    NSString * faceLiveApiKey = [YXFaceIDLiveStill kApiKeyWith:YXFaceIDLiveStill.comparisonType];
    NSString * faceLiveAipSecret = [YXFaceIDLiveStill kApiSecretWith:YXFaceIDLiveStill.comparisonType];
    
    NSAssert(faceLiveApiKey.length != 0 && faceLiveAipSecret.length != 0, @"Please set `kApiKey` and `kApiSecret`");
    int valid_durtion = 1000;
    long int current_time = [[NSDate date] timeIntervalSince1970];
    long int expire_time = current_time + valid_durtion;
    long random = labs(arc4random() % 100000000000);
    NSString* str = [NSString stringWithFormat:@"a=%@&b=%ld&c=%ld&d=%ld", faceLiveApiKey, expire_time, current_time, random];
    const char *cKey  = [faceLiveAipSecret cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [str cStringUsingEncoding:NSUTF8StringEncoding];
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSData* sign_raw_data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* data = [[NSMutableData alloc] initWithData:HMAC];
    [data appendData:sign_raw_data];
    NSString* signStr = [data base64EncodedStringWithOptions:0];
    return signStr;
}

- (NSString *)getFaceIDSignVersionStr {
    return @"hmac_sha1";
}
@end

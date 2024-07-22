//
//  ZFNotificationRequestManager.m
//  NotificationService
//
//  Created by mac on 2019/2/18.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNotificationRequestManager.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation ZFNotificationRequestManager

+ (void)POST:(NSString *)URL parameters:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) return;
    if (![URL isKindOfClass:[NSString class]]) return;
    
    //创建配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //设置请求超时时间：7秒
    configuration.timeoutIntervalForRequest = 7;
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: URL]];
    //设置请求方式：POST
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-Type"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Accept"];
    
    NSString *md5String = @"btxDmBwn#X6KBFVpbrOFKM3gTHBLpNaK";
    NSString *md5AppName = [self stringMD5:[NSString stringWithFormat:@"%@ZZZZZ", md5String]];
    NSString *paramsJson = [md5AppName stringByAppendingString:[self convertToJsonData:dic]];
    NSString *apiToken = [self stringMD5:paramsJson];
    
    //apiToken :通信token(必填), 加密方式:  md5( md5( 接口秘钥 + 站点名称 ) + data )
    NSDictionary *requestParams = @{@"apiToken" : apiToken,
                                    @"data" : [self convertToJsonData:dic]};
    
    //data的字典形式转化为data
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:nil];
    //设置请求体
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            //NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@",responseObject);
        }else{
            //NSLog(@"%@",error);
        }
    }];
    [dataTask resume];
}

+ (NSString *)stringMD5:(NSString *)string {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)convertToJsonData:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = @"";
    if (!jsonData) {
        //NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end

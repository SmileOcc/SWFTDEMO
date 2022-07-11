//
//  YXStatementPdfModel.m
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXStatementPdfModel.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <Photos/Photos.h>
#import "uSmartOversea-Swift.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <QCloudCOSXML/QCloudCOSXMLDownloadObjectRequest.h>

@interface YXStatementPdfModel ()

@end

@implementation YXStatementPdfModel


-(void)getsecretKey:(NSString *) pdfUrl complish:(void(^)(BOOL isSuc, NSString * pdfUrl)) block
{
    self.pdfUrl = pdfUrl;
    NSString * bucket = [self bucket:pdfUrl];
    NSString * fileName = [self fileName:pdfUrl];
    NSString * region = [self region:pdfUrl];
    self.succuessBlock = block;
    
    NSString * savePath = [self cachePdfPath:[self pdfName:pdfUrl]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        if (self.succuessBlock) {
            self.succuessBlock(YES, self.pdfUrl);
        }
        return;
    }
    
    [YXUserManager updateTokenWithFileName:fileName region:region bucket:bucket success:^{
        [self downLoadPdf:pdfUrl];
    } failed:^(NSString * _Nonnull errString) {
        if (self.succuessBlock) {
            self.succuessBlock(NO, [YXLanguageUtility kLangWithKey:@"network_timeout"]);
        }
    }];
  
}


-(void)downLoadPdf:(NSString *)pdfUrl  {
    
    NSString * bucket = [self bucket:pdfUrl];
    NSString * fileName = [self fileName:pdfUrl];
    NSString * region = [self region:pdfUrl];
    
    QCloudCOSXMLDownloadObjectRequest * request = [QCloudCOSXMLDownloadObjectRequest new];
    request.bucket = bucket;
    request.object = fileName;
   
    if (fileName.length == 0) {
        return;
    }

    NSString * localName = [self pdfName:pdfUrl];
    NSString * path = [self cachePdfPath:localName];
    request.downloadingURL = [NSURL URLWithString:path];
    @weakify(self)
    [request setFinishBlock:^(id outputObject, NSError *error) {
        	@strongify(self)
        // outputObject 包含所有的响应 http 头部
        NSDictionary* info = (NSDictionary *) outputObject;
        if (error) {
            if (self.succuessBlock) {
                self.succuessBlock(NO, [YXLanguageUtility kLangWithKey:@"network_timeout"]);
            }
        }else{
            if (self.succuessBlock) {
                self.succuessBlock(YES, self.pdfUrl);
            }
        }
        
    }];
    
    [request setDownProcessBlock:^(int64_t bytesDownload, int64_t totalBytesDownload, int64_t totalBytesExpectedToDownload) {
        NSLog(@"xxx");
    }];
    
    [[QCloudCOSTransferMangerService costransfermangerServiceForKey:[self region:pdfUrl]] DownloadObject:request];
}




-(NSString *)bucket:(NSString *) url
{
    NSString * temp = url;
    if (temp.length > 0) {
        NSArray * firstArr = [temp componentsSeparatedByString:@"://"];
        NSString * lastString = firstArr.lastObject;
        if (lastString.length > 0 && [lastString containsString:@".cos."] ) {
            NSArray * resultArr = [lastString componentsSeparatedByString:@".cos."];
            temp = resultArr.firstObject;
        }
    }
    return  temp;
}

//存储的文件名
-(NSString *)pdfName:(NSString *) url
{
    NSString * temp = url;
    if (temp.length > 0) {
        NSArray * firstArr = [temp componentsSeparatedByString:@"/"];
        NSString * lastString = firstArr.lastObject;
        if (lastString.length > 0 && [lastString containsString:@".pdf"] ) {
           
            temp =  lastString;
        }
    }
    return  temp;
}

-(NSString *)fileName:(NSString *) url {
    NSString * temp = url;
    if (temp.length > 0 && [temp containsString:@".myqcloud.com/"]) {
        NSArray * firstArr = [temp componentsSeparatedByString:@".myqcloud.com/"];
        NSString * lastString = firstArr.lastObject;
        if (lastString.length > 0 && [lastString containsString:@".pdf"] ) {
           
            temp =  lastString;
        }
    }

    return  temp;
}

-(NSString *)region:(NSString *)url {
    NSString * temp = url;
    if (temp.length > 0) {
        NSArray * firstArr = [temp componentsSeparatedByString:@"://"];
        NSString * lastString = firstArr.lastObject;
        if (lastString.length > 0 && [lastString containsString:@".cos."] ) {
            NSArray * resultArr = [lastString componentsSeparatedByString:@".cos."];
            lastString = resultArr.lastObject;
        }
        if (lastString.length > 0 &&[ lastString containsString:@".myqcloud"]) {
            NSArray * reginArr = [lastString componentsSeparatedByString:@".myqcloud"];
            temp = reginArr.firstObject;
        }
    }
    return  temp;
}

-(NSString * )cachePdfPath:(NSString * )pdfName {
    // 获取存储路径
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:pdfName];
    
    return cachesPath;
}

-(NSData *)readPdf:(NSString *) fileName {
    NSString * path = [self cachePdfPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePdfPath:path]]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        return data;
    }
    
    return  nil;
}

-(BOOL)isExist:(NSString *) fileName {
    NSString * path = [self cachePdfPath:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePdfPath:path]]) {

        return YES;
    }
    return NO;
    
}


-(void)saveData:(NSData *) data fileName:(NSString *)fileName {
    NSString * path = [self cachePdfPath:fileName];
    if (data) {
       BOOL issuc = [data writeToFile:path atomically:YES];
        if (issuc) {
            NSLog(@"写入成功");
        }else{
            NSLog(@"写入失败");
        }
    }
}


@end

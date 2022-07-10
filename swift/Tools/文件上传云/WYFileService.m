//
//  WYFileService.m
//  PropertyManagement
//
//  Created by  jiangminjie on 2019/4/23.
//  Copyright © 2019年 qanzone. All rights reserved.
//

#import "WYFileService.h"

#import "OSSService.h"

#define OSS_ACCESSKEY_ID                @"LTAI4FgvrfiNPCSRsTa1Wjhs"
#define OSS_SECRETKEY_ID                @"obrU2T1KLgryk5CWTSS1ZyR6vCztih"

NSString * const endPoint = @"oss-cn-shenzhen.aliyuncs.com";
NSString * const imageEndPoint = @"https://avic-paixiu-2019.oss-cn-shenzhen.aliyuncs.com";
NSString * const BUCKET_NAME = @"avic-paixiu-2019";
@implementation WYFileService {
    OSSClient               *_mainClient;
    OSSPutObjectRequest     *_mainRequest;
    
    NSInteger               _updateFailureCount;//最多3次上传失败记录
}


+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static WYFileService *fileService = nil;
    dispatch_once(&onceToken, ^{
        fileService = [[WYFileService alloc]init];
    });
    return fileService;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 推荐使用OSSAuthCredentialProvider，token过期后会自动刷新。
        id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:OSS_ACCESSKEY_ID secretKey:OSS_SECRETKEY_ID];
        
        _mainClient = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
    }
    return self;
}

#pragma mark - 批量上传图片到阿里云
- (void)onUpdateAliYunImageWithPostData:(NSArray *)imgDatas withSuccess:(void (^)(NSDictionary *responceDic))successBlock withFailure:(void (^)(NSString *error))failureBlock
{
    NSMutableArray *updateArray = [NSMutableArray new];
    _updateFailureCount = 0;
    [self onUpdateAliYunImageWithImageData:imgDatas[0] withCurrentIndex:0 withAllImgDatas:imgDatas withUpdateImgDatas:updateArray withSuccess:^(NSDictionary *responceDic) {
        successBlock(responceDic);
    }];
}

- (void)onUpdateAliYunImageWithImageData:(id)imgData withCurrentIndex:(int)curentIndex withAllImgDatas:(NSArray *)imgDatas withUpdateImgDatas:(NSMutableArray *)updateDatas withSuccess:(void (^)(NSDictionary *responceDic))success
{
    //1.创建请求
    _mainRequest = [OSSPutObjectRequest new];
    _mainRequest.bucketName = BUCKET_NAME;
    
    //图片在阿里云路径
    NSString *imgPath = @"";
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [formatter stringFromDate:date];
    
    //上传图片资源到阿里云
    if ([imgData isKindOfClass:[UIImage class]]) {
        NSDate *date = [NSDate date];
        NSString *fileName = [NSString stringWithFormat:@"%.f",[date timeIntervalSince1970]*1000];
        imgPath = [NSString stringWithFormat:@"zhwy/ios/%@/img_%@.png",dateString,fileName];
        _mainRequest.objectKey = imgPath;
        
        UIImage *img = (UIImage *)imgData;
        _mainRequest.uploadingData = UIImagePNGRepresentation(img);
    }
    else if ([imgData isKindOfClass:[NSString class]]) {
        NSString *imgFile = (NSString *)imgData;
        NSArray *imgAllArr = [imgFile componentsSeparatedByString:@"/"];
        NSString *fileName = @"";
        if (imgAllArr.count > 0) {
            fileName = [imgAllArr lastObject];
            NSArray *fileArrays = [fileName componentsSeparatedByString:@"."];
            if (fileArrays.count > 0) {
                fileName = [fileArrays firstObject];
            }
        } else {
            NSDate *date = [NSDate date];
            fileName = [NSString stringWithFormat:@"%.f",[date timeIntervalSince1970]*1000];
        }
        
        if ([imgFile containsString:@"png"]) {
            imgPath = [NSString stringWithFormat:@"zhwy/ios/%@/img_%@.png",dateString,fileName];
            _mainRequest.objectKey = imgPath;
        }
        else if ([imgFile containsString:@"jpeg"]) {
            imgPath = [NSString stringWithFormat:@"zhwy/ios/%@/img_%@.jpeg",dateString,fileName];
            _mainRequest.objectKey = imgPath;
        }
        else if ([imgFile containsString:@"mp3"]) {
            imgPath = [NSString stringWithFormat:@"zhwy/ios/%@/audio_%@.mp3",dateString,fileName];
            _mainRequest.objectKey = imgPath;
        }
        else if ([imgFile containsString:@"mp4"]) {
            imgPath = [NSString stringWithFormat:@"zhwy/ios/%@/video_%@.mp4",dateString,fileName];
            _mainRequest.objectKey = imgPath;
        }
        _mainRequest.uploadingFileURL = [NSURL fileURLWithPath:imgFile];
    }
    
    //上传进度监听
    _mainRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
      NSLog(@"%lld, %lld, %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    };
    
    
    //2.发送请求
    OSSTask *task = [_mainClient putObject:_mainRequest];
    __block int cutIndex = curentIndex;
    __block NSArray *imgArray = imgDatas;
    [task continueWithBlock:^id (OSSTask *  task) {
        if (!task.error) {
            NSLog(@"上传图片到阿里云成功!");
            //将上传成功的添加到数组
            NSString *aliyPath = [NSString stringWithFormat:@"%@/%@",@"https://avic-paixiu-2019.oss-cn-shenzhen.aliyuncs.com",imgPath];
            if (![updateDatas containsObject:aliyPath]) {
                [updateDatas addObject:aliyPath];
            }
            
            ++cutIndex;
            _updateFailureCount = 0;
            if (cutIndex < imgArray.count) {
                //上传成功了一个,进行下一个上传
                [self onUpdateAliYunImageWithImageData:imgArray[cutIndex] withCurrentIndex:cutIndex withAllImgDatas:imgArray withUpdateImgDatas:updateDatas withSuccess:success];
            } else {
                success(@{@"picUrls": updateDatas});
            }
            
        } else {
            NSLog(@"上传图片到阿里云失败!");
            ++_updateFailureCount;
            //最多上传3次失败,之后进行下一个上传
            if (_updateFailureCount >= 3) {
                ++cutIndex;
                _updateFailureCount = 0;
                if (cutIndex < imgArray.count) {
                    [self onUpdateAliYunImageWithImageData:imgArray[cutIndex] withCurrentIndex:cutIndex withAllImgDatas:imgArray withUpdateImgDatas:updateDatas withSuccess:success];
                } else {
                    success(@{@"picUrls":updateDatas});
                }
            } else {
                [self onUpdateAliYunImageWithImageData:imgArray[cutIndex] withCurrentIndex:cutIndex withAllImgDatas:imgArray withUpdateImgDatas:updateDatas withSuccess:success];
            }
        }
        
        //完成一个清除
        _mainRequest = nil;
        return nil;
    }];
}

@end

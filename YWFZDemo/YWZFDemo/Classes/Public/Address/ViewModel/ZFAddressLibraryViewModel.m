//
//  ZFAddressLibraryViewModel.m
//  Zaful
//
//  Created by occ on 2019/1/14.
//  Copyright © 2019 Zaful. All rights reserved.
//

#import "ZFAddressLibraryManager.h"
#import "ZFAddressLibraryApi.h"

/**主要用于用户信息本地存储*/
static NSString *const kZFAddressLibraryDataKey                     = @"kZFAddressLibraryDataKey";

static NSString *const kZFAddressLibraryRequestTimeKey                     = @"kZFAddressLibraryRequestTimeKey";

@implementation ZFAddressLibraryManager

+(instancetype)manager
{
    static ZFAddressLibraryManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZFAddressLibraryManager alloc] init];
    });
    return manager;
}


/**保存请求时间戳*/
+ (void)saveLoadCountryTimestamp {
    NSString *timestamp = [NSStringUtils getCurrentTimestamp];
    SaveUserDefault(kZFAddressLibraryRequestTimeKey, timestamp);
}

/**超过间隔时间重新加载 1天*/
+ (void)preparatoryRequestCountryCityData:(BOOL)isNeedHold {
    
    NSString *lastTimesTamp = GetUserDefault(kZFAddressLibraryRequestTimeKey);
    NSString *currentTimesTamp = [NSStringUtils getCurrentTimestamp];
    
    ZFLog(@"&&&&&&&&🐔🐔🐔🐔🐔🐔🐔🐔🐔🐔时间间隔：%li",[currentTimesTamp integerValue] - [lastTimesTamp integerValue]);
    
    if ([currentTimesTamp integerValue] - [lastTimesTamp integerValue] >= sec_per_day) {
        [ZFAddressLibraryManager startRequestCountryCityData:^(NSArray *datas) {
            if (isNeedHold && [ZFAddressLibraryManager manager].countryDataArray <= 0 && datas.count) {
                [ZFAddressLibraryManager manager].countryDataArray = [ZFAddressLibraryManager localCountryList];
            }
        }];
    }
    
    if (isNeedHold) {
        [ZFAddressLibraryManager manager].countryDataArray = [ZFAddressLibraryManager localCountryList];
    }
}

+ (void)startRequestCountryCityData:(void (^)(NSArray *datas))completion {
    
    dispatch_queue_t queue = dispatch_queue_create("addressLibraryBook.array", DISPATCH_QUEUE_SERIAL);
    
    ZFAddressLibraryApi *addressLibraryApi = [[ZFAddressLibraryApi alloc] initWithDic:nil];
    [addressLibraryApi startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(addressLibraryApi.class)];
        
        NSDictionary *resultDict = requestJSON[ZFResultKey];
        NSArray *dataArray;
        if (ZFJudgeNSDictionary(resultDict)) {
            dataArray = resultDict[ZFDataKey];
        }
        
        [ZFAddressLibraryManager saveLocalCountry:dataArray];
        [ZFAddressLibraryManager saveLoadCountryTimestamp];
        
        if (completion) {
            completion(dataArray);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        
    } completionQueue:queue];
}



+ (void)saveLocalCountry:(NSArray *)countryArray {
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:countryArray forKey:kZFAddressLibraryDataKey];
//    [archiver finishEncoding];
//    ZFLog(@"%@",ZFPATH_DIRECTORY);
//    [data writeToFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName] atomically:YES];
    
    if (countryArray.count > 0) {
        YYCache *cache = [[YYCache alloc] initWithName:kZFAddressLibraryDataKey];
        [cache setObject:countryArray forKey:kZFAddressLibraryDataKey];
    }
    
}

+ (NSArray *)localCountryList {
//    NSData *data = [[NSData alloc] initWithContentsOfFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]];
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    NSArray *array = [unarchiver decodeObjectForKey:kZFAddressLibraryDataKey];
//    [unarchiver finishDecoding];//一定不要忘记finishDecoding，否则会报错
    
    YYCache *cache = [YYCache cacheWithName:kZFAddressLibraryDataKey];
    id responseObject = [cache objectForKey:kZFAddressLibraryDataKey];
    if ([responseObject isKindOfClass:[NSArray class]]) {
        return responseObject;
    }
    return @[];
}

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_get_country_info);
    requestModel.parmaters = @{
                               @"token"      :   TOKEN,
                               @"region_id"  :   parmaters ?: @""
                               };
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {

        NSDictionary *resultDict = responseObject[ZFResultKey];
        NSArray *goodsArr;
        if (completion && ZFJudgeNSDictionary(resultDict)) {
            goodsArr = resultDict[ZFDataKey];
        }

        if (ZFJudgeNSArray(goodsArr)) {
            [ZFAddressLibraryManager saveLocalCountry:goodsArr];
            if (completion) {
                completion(goodsArr);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
    
//    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
//
//        NSDictionary *resultDict = responseObject[ZFResultKey];
//        NSArray *goodsArr;
//        if (completion && ZFJudgeNSDictionary(resultDict)) {
//            goodsArr = resultDict[ZFDataKey];
//        }
//
//        if (ZFJudgeNSArray(goodsArr)) {
//            [ZFAddressLibraryViewModel saveLocalCountry:goodsArr];
//            if (completion) {
//                completion(goodsArr);
//            }
//        } else {
//            if (failure) {
//                failure(nil);
//            }
//        }
//
//    } failure:^(NSError *error) {
//        if (failure) {
//            failure(nil);
//        }
//    }];
}

@end

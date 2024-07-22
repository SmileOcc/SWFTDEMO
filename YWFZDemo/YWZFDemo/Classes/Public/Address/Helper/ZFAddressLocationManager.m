//
//  ZFAddressLocationManager.m
//  ZZZZZ
//
//  Created by YW on 2017/12/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressLocationManager.h"

static NSString *const kZFLocationDataPath        = @"/Library/AllLocation.dat";

@interface ZFAddressLocationManager()
//{
//    NSString *_locationRootKey;
//    NSMutableDictionary *_locationMap;
//}
@property (nonatomic, copy) NSString *locationRootKey;
@property (nonatomic, strong) NSMutableDictionary *locationMap;

@end

@implementation ZFAddressLocationManager
#pragma mark - init methods
+ (instancetype)shareManager {
    static ZFAddressLocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.locationMap = [NSMutableDictionary dictionary];
    });
    return manager;
}

#pragma mark - interface methods
- (void)parseLocationData:(NSArray<ZFLocationInfoModel *>*)locationArray {
    if (!locationArray) {
        return ;
    }
    //save local location info to sand box
    [self saveLocalLocationListWithArray:locationArray];
    
    [_locationMap removeAllObjects];
    
    [locationArray enumerateObjectsUsingBlock:^(ZFLocationInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            if ([self.locationMap valueForKey:obj.pid]) {
                NSMutableArray *subLevelArray = self.locationMap[obj.pid];
                [subLevelArray addObject:obj];
                [self.locationMap setValue:subLevelArray forKey:obj.pid];
            }else{
                NSMutableArray *subLevelArray = [NSMutableArray array];
                [subLevelArray addObject:obj];
                [self.locationMap setValue:subLevelArray forKey:obj.pid];
            }
        }
    }];
    
    self.locationRootKey = @"0";
}

- (NSArray<ZFLocationInfoModel *> *)queryRootLocationData {
    if ([self hasCacheLocationData]) {
        [self parseLocationData:[self getLocalLocationList]];
    }
    return  _locationMap[_locationRootKey];
}

- (NSArray<ZFLocationInfoModel *> *)querySubLocationDataWithParentID:(NSString *)parentID {
    if ([self hasCacheLocationData]) {
        [self parseLocationData:[self getLocalLocationList]];
    }
    return  _locationMap[parentID];
}

#pragma mark - private methods
- (NSArray<ZFLocationInfoModel *> *)getLocalLocationList {
    NSString *locationPath;
    locationPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),kZFLocationDataPath];
    NSArray *allLocationInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:locationPath];
    return allLocationInfo;
}

- (BOOL)hasCacheLocationData {
    NSArray *dataArray = [self getLocalLocationList];
    return dataArray.count > 0 ? YES : NO;
}


- (void)saveLocalLocationListWithArray:(NSArray<ZFLocationInfoModel *> *)locationList {
    NSString *locationPath;
    locationPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),kZFLocationDataPath];
    BOOL isLocal = [NSKeyedArchiver archiveRootObject:locationList toFile:locationPath];
    if (!isLocal) { //第一次本地化数据失败，重新进行本地化，若再失败则不管。
        [NSKeyedArchiver archiveRootObject:locationList toFile:locationPath];
    }
}

@end

//
//  YXSecuGroupManager.m
//  uSmartOversea
//
//  Created by ellison on 2018/11/14.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSecuGroupManager.h"
#import <MMKV/MMKV.h>
#import <YXTimerSingleton.h>
#import "YYCategoriesMacro.h"
#import <YYModel/YYModel.h>
#import "uSmartOversea-Swift.h"
#import "YXOptionalDBManager.h"

#define kYXSecuGroupUnloginKey @"kYXSecuGroupUnloginKey"
#define kYXSecuGroupLoginedKey @"kYXSecuGroupLoginedKey"
#define kYXAllSecuGroupIndexKey @"kYXAllSecuGroupIndexKey"
#define kYXUnloginSecuGroupVersionKey @"kYXUnloginSecuGroupVersionKey"
#define kYXLoginedSecuGroupVersionKey @"kYXLoginedSecuGroupVersionKey"
#define kYXUnloginSecuGroupSortFlagKey @"kYXUnloginSecuGroupSortFlagKey"
#define kYXLoginedSecuGroupSortFlagKey @"kYXLoginedSecuGroupSortFlagKey"

#define kYXHoldGroupIndexKey @"kYXHoldGroupIndexKey"
#define kYXLatestGroupIndexKey @"kYXLatestGroupIndexKey"

#define kYXCrossMarketDragNoti @"YXCrossMarketDragNoti"
#define kYXHoldSecuGroupDragNoti @"YXHoldSecuGroupDragNoti"

@interface YXSecuGroupManager ()

@property (nonatomic, copy) NSString *key;

@property (nonatomic, strong, readwrite) NSArray<YXSecuGroup *> *allGroupsForPostToServer; // 上传到服务器
@property (nonatomic, strong, readwrite) NSArray<YXSecuGroup *> *allGroupsForShow; // 展示
@property (nonatomic, strong, readwrite) NSArray<YXSecuGroup *> *allGroupList; // 操作

@property (nonatomic, strong, readwrite) NSMutableDictionary<NSNumber *,YXSecuGroup *> *defaultGroupPool;
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSNumber *,YXSecuGroup *> *customGroupPool;

//@property (nonatomic, assign) NSInteger allSecuGroupIndex;
@property (nonatomic, strong, readwrite) YXSecuGroup *allSecuGroup;
@property (nonatomic, strong, readwrite) YXSecuGroup *hkSecuGroup;

@property (nonatomic, strong) NSArray *defaultSecuGroupIDs;
@property (nonatomic, assign) YXTimerFlag holdTimerFlag;

@property (nonatomic, assign) NSInteger holdGroupIndex;
@property (nonatomic, assign) NSInteger latestGroupIndex;

@property (nonatomic, assign) BOOL isGetedLatestTradeData; // 已返回最近交易数据

@end

@implementation YXSecuGroupManager

+ (instancetype)shareInstance {
    static YXSecuGroupManager *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        YXSecuGroup *secuGroup = [[YXSecuGroup alloc] init];
        [secuGroup setDefaultGroupID:YXDefaultGroupIDHOLD];
        self.holdSecuGroup = secuGroup;
        
        YXSecuGroup *latestSecuGroup = [[YXSecuGroup alloc] init];
        [latestSecuGroup setDefaultGroupID:YXDefaultGroupIDLATEST];
        self.latestSecuGroup = latestSecuGroup;
    }
    return self;
}

#pragma mark - latest trade
- (void)checkLatestTrade {
//    if (![YXUserManager isLogin]) {
//        return;
//    }
//    
//    YXLatestTradeRequestModel *requestModel = [[YXLatestTradeRequestModel alloc] init];
//    YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
//    [request startWithBlockWithSuccess:^(YXSecuGroupResponseModel *responseModel) {
//        if (responseModel.code == YXResponseStatusCodeSuccess) {
//            NSArray<YXSecuID *> *array = responseModel.lastDealGroup.list;
//            
//            YXSecuGroup *secuGroup = [[YXSecuGroup alloc] init];
//            [secuGroup setDefaultGroupID:YXDefaultGroupIDLATEST];
//            secuGroup.list = array;
//            self.latestSecuGroup = secuGroup;
//            self.isGetedLatestTradeData = YES;
//            [self _update];
//        }
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        
//    }];
}

- (void)login:(BOOL)isFirst {
    self.version = 0;
    self.sortflag = self.loginedSecuGroupSortflag;
    if (isFirst) {
        [self postGroup];
        NSArray *allGroupList = self.allGroupList;
        self.state = YXSecuGroupStateLogined;
        self.allGroupList = allGroupList;
        [self _update];
    } else {
        self.state = YXSecuGroupStateLogined;
        [self getGroup];
    }
    
    //@weakify(self)
    self.synchroHoldGroup(^{
        //@strongify(self)
        //[self _update];
    });
}

- (void)logout {
    self.state = YXSecuGroupStateUnLogin;
    self.loginedSecuGroupVersion = 0;
    self.version = self.unloginSecuGroupVersion;
    self.sortflag = self.unloginSecuGroupSortflag;
    [self getGroup];
}

- (void)guessLogin {
    self.state = YXSecuGroupStateUnLogin;
    self.loginedSecuGroupVersion = 0;
    self.version = self.unloginSecuGroupVersion;
    self.sortflag = self.unloginSecuGroupSortflag;
    [self getGroup];
}

- (void)reloadData {
    if (_key == nil) { return; }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    MMKV *mmkv = [MMKV defaultMMKV];
    NSData *data = [mmkv getObjectOfClass:NSData.class forKey:_key];
    if (data != nil) {
        [array addObjectsFromArray:[NSArray yy_modelArrayWithClass:YXSecuGroup.class json:data]];
    } else {
        //        self.allSecuGroupIndex = 0;
        NSMutableArray *hkArray = [NSMutableArray array];
        NSMutableArray *usArray = [NSMutableArray array];
        NSMutableArray *sgArray = [NSMutableArray array];
        
//        NSMutableArray *cnArray = [NSMutableArray array];
        NSMutableArray *allArray = [NSMutableArray array];
        NSMutableArray *optionArray = [NSMutableArray array];
        for (NSString *hkIndex in kYXAllHKSecuDefault) {
            YXSecuID *secuId = [YXSecuID secuIdWithString:hkIndex];
            [hkArray addObject:secuId];
        }
        
        for (NSString *usIndex in kYXAllUSSecuDefault) {
            YXSecuID *secuId = [YXSecuID secuIdWithString:usIndex];
            [usArray addObject:secuId];
        }
        
        for (NSString *sgIndex in kYXAllSGSecuDefault) {
            YXSecuID *secuId = [YXSecuID secuIdWithString:sgIndex];
            [sgArray addObject:secuId];
        }
        
//        for (NSString *cnIndex in kYXAllChinaSecuDefault) {
//            YXSecuID *secuId = [YXSecuID secuIdWithString:cnIndex];
//            [cnArray addObject:secuId];
//        }
        
        for (NSString *optionIndex in kYXAllOptionSecuDefault) {
            YXSecuID *secuId = [YXSecuID secuIdWithString:optionIndex];
            [optionArray addObject:secuId];
        }
        
        for (NSNumber *IDNumber in self.defaultSecuGroupIDs) {
            YXSecuGroup *secuGroup = [[YXSecuGroup alloc] init];
            [secuGroup setDefaultGroupID:IDNumber.unsignedIntegerValue];
            if (IDNumber.intValue == YXDefaultGroupIDUS) {
                secuGroup.list = usArray;
            } else if (IDNumber.intValue == YXDefaultGroupIDHK) {
                secuGroup.list = hkArray;
            }  else if (IDNumber.intValue == YXDefaultGroupIDSG) {
                secuGroup.list = sgArray;
            }
//            else if (IDNumber.intValue == YXDefaultGroupIDCHINA) {
//                secuGroup.list = cnArray;
//            }
            else if (IDNumber.intValue == YXDefaultGroupIDAll) {
                [allArray addObjectsFromArray:sgArray];
                [allArray addObjectsFromArray:usArray];
                [allArray addObjectsFromArray:hkArray];
//                [allArray addObjectsFromArray:cnArray];
                secuGroup.list = allArray;
            }else if (IDNumber.intValue == YXDefaultGroupIDUSOPTION) {
                secuGroup.list = optionArray;
            }
            [array addObject:secuGroup];
            self.defaultGroupPool[IDNumber] = secuGroup;
        }
        
        YXSecuGroup *secuGroup = [[YXSecuGroup alloc] init];
        [secuGroup setDefaultGroupID:YXDefaultGroupIDHOLD];
        [array addObject:secuGroup];
    }
    
    self.allGroupList = [array copy];
    [self _update];
}

- (BOOL)containsSecu:(id<YXSecuIDProtocol>)secu {
    if ([self.allSecuGroup.list containsObject:[YXSecuID secuIdWithMarket:secu.market symbol:secu.symbol]]) {
        return YES;
    }
    
    return NO;
}

- (NSArray<YXSecuGroup *> *)customGroupListWithSecu:(id<YXSecuIDProtocol>)secu {
    YXSecuID *secuId = [YXSecuID secuIdWithMarket:secu.market symbol:secu.symbol];
    NSMutableArray<YXSecuGroup *> *groupArray = [[NSMutableArray alloc] init];
    
    [self.customGroupPool enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, YXSecuGroup * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.list containsObject:secuId]) {
            [groupArray addObject:obj];
        }
    }];
    
    return groupArray;
}

- (NSArray<YXSecuGroup *> *)allCustomGroupList {
    NSMutableArray<YXSecuGroup *> *groupArray = [[NSMutableArray alloc] init];
    [self.allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull secuGroup, NSUInteger idx, BOOL * _Nonnull stop) {
        if (secuGroup.groupType == YXSecuGroupTypeCustom) {
            [groupArray addObject:secuGroup];
        }
    }];
    return groupArray;
}


#pragma mark - getter && setter
- (void)setState:(YXSecuGroupState)state {
    if (_key != nil && _state == state) { return; }
    
    _state = state;
    if (_state == YXSecuGroupStateLogined) {
        _key = kYXSecuGroupLoginedKey;
    } else if (_state == YXSecuGroupStateUnLogin) {
        [self.holdSecuGroup setDefaultGroupID:YXDefaultGroupIDHK];
        
        MMKV *mmkv = [MMKV defaultMMKV];
        [mmkv removeValueForKey:_key];
        _key = kYXSecuGroupUnloginKey;
    }
    [self reloadData];
}

- (void)setVersion:(NSInteger)version {
    _version = version;
    
    if (self.state == YXSecuGroupStateUnLogin) {
        self.unloginSecuGroupVersion = _version;
    } else if (self.state == YXSecuGroupStateLogined){
        self.loginedSecuGroupVersion = _version;
    }
}

- (void)setSortflag:(NSInteger)sortflag {
    _sortflag = sortflag;
    
    if (self.state == YXSecuGroupStateUnLogin) {
        self.unloginSecuGroupSortflag = _sortflag;
    } else if (self.state == YXSecuGroupStateLogined){
        self.loginedSecuGroupSortflag = _sortflag;
    }
}

// 用户操作了智能排序开关
- (void)userSetSortflag:(NSInteger)flag {
    self.sortflag = flag;
    [self _update];
    [self postGroup];
}

- (NSArray *)defaultSecuGroupIDs {
    if (_defaultSecuGroupIDs == nil) {
        _defaultSecuGroupIDs = @[@(YXDefaultGroupIDAll), @(YXDefaultGroupIDUS),@(YXDefaultGroupIDSG), @(YXDefaultGroupIDHK), /*@(YXDefaultGroupIDCHINA),*/ @(YXDefaultGroupIDUSOPTION)/*, @(YXDefaultGroupIDLATEST)*/];
    }
    return _defaultSecuGroupIDs;
}

//- (NSInteger)allSecuGroupIndex {
//    NSNumber *number = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:kYXAllSecuGroupIndexKey];
//    return [number unsignedIntegerValue];
//}
//
//- (void)setAllSecuGroupIndex:(NSInteger)allSecuGroupIndex {
//    if (allSecuGroupIndex < 0) {
//        allSecuGroupIndex = 0;
//    }
//    [[MMKV defaultMMKV] setObject:@(allSecuGroupIndex) forKey:kYXAllSecuGroupIndexKey];
//}

- (NSInteger)unloginSecuGroupVersion {
    NSNumber *number = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:kYXUnloginSecuGroupVersionKey];
    return [number integerValue];
}

- (void)setUnloginSecuGroupVersion:(NSInteger)unloginSecuGroupVersion {
    if (unloginSecuGroupVersion < 0) {
        unloginSecuGroupVersion = 0;
    }
    [[MMKV defaultMMKV] setObject:@(unloginSecuGroupVersion) forKey:kYXUnloginSecuGroupVersionKey];
}

- (void)setLoginedSecuGroupVersion:(NSInteger)loginedSecuGroupVersion {
    if (loginedSecuGroupVersion < 0) {
        loginedSecuGroupVersion = 0;
    }
    [[MMKV defaultMMKV] setObject:@(loginedSecuGroupVersion) forKey:kYXLoginedSecuGroupVersionKey];
}

- (NSInteger)loginedSecuGroupVersion {
    NSNumber *number = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:kYXLoginedSecuGroupVersionKey];
    return [number integerValue];
}

- (NSInteger)unloginSecuGroupSortflag {
    NSNumber *number = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:kYXUnloginSecuGroupSortFlagKey];
    return [number intValue];
}

- (void)setUnloginSecuGroupSortflag:(NSInteger)unloginSecuGroupSortflag {
    if (unloginSecuGroupSortflag < 0) {
        unloginSecuGroupSortflag = 0;
    }
    [[MMKV defaultMMKV] setObject:@(unloginSecuGroupSortflag) forKey:kYXUnloginSecuGroupSortFlagKey];
}

- (void)setLoginedSecuGroupSortflag:(NSInteger)loginedSecuGroupSortflag {
    if (loginedSecuGroupSortflag < 0) {
        loginedSecuGroupSortflag = 0;
    }
    [[MMKV defaultMMKV] setObject:@(loginedSecuGroupSortflag) forKey:kYXLoginedSecuGroupSortFlagKey];
}

- (NSInteger)loginedSecuGroupSortflag {
    NSNumber *number = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:kYXLoginedSecuGroupSortFlagKey];
    return [number intValue];
}


- (NSMutableDictionary<NSNumber *,YXSecuGroup *> *)defaultGroupPool {
    if (_defaultGroupPool == nil) {
        _defaultGroupPool = [[NSMutableDictionary alloc] init];
    }
    return _defaultGroupPool;
}

- (NSMutableDictionary<NSNumber *,YXSecuGroup *> *)customGroupPool {
    if (_customGroupPool == nil) {
        _customGroupPool = [[NSMutableDictionary alloc] init];
    }
    return _customGroupPool;
}

#pragma mark - hold methods
- (void)transactCheckHold {
//    [self invalidCheckHold];
//
//    @weakify(self)
//    self.holdTimerFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
//        @strongify(self)
//        self.synchroHoldGroup(^{
//            //            [self _update];
//        });
//    } timeInterval:30 repeatTimes:NSIntegerMax atOnce:YES];
}

- (void)invalidCheckHold {
//    [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.holdTimerFlag];
//    self.holdTimerFlag = 0;
}

- (NSInteger)holdGroupIndex {
    NSNumber *indexNumber = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:kYXHoldGroupIndexKey];
    if (indexNumber == nil) {
        return 3;
    } else {
        return [indexNumber integerValue];
    }
}

- (void)setHoldGroupIndex:(NSInteger)holdGroupIndex {
    [[MMKV defaultMMKV] setObject:@(holdGroupIndex) forKey:kYXHoldGroupIndexKey];
}

- (NSInteger)latestGroupIndex {
    NSNumber *indexNumber = [[MMKV defaultMMKV] getObjectOfClass:[NSNumber class] forKey:kYXLatestGroupIndexKey];
    if (indexNumber == nil) {
        return 5;
    } else {
        return [indexNumber integerValue];
    }
}

- (void)setLatestGroupIndex:(NSInteger)latestGroupIndex {
    [[MMKV defaultMMKV] setObject:@(latestGroupIndex) forKey:kYXLatestGroupIndexKey];
}

#pragma mark - private methods
- (void)postGroup {
    if (self.postGroupIfNeed) {
        self.postGroupIfNeed(nil);
    }
}

- (void)getGroup {
    if (self.getGroupIfNeed) {
        self.getGroupIfNeed(nil);
    }
}

- (void)updateAllGroupListWithList:(NSArray *)list {
    self.allGroupList = [list copy];
    [self _update];
}

- (void)_update {
    NSData *data = [self.allGroupList yy_modelToJSONData];
    MMKV *mmkv = [MMKV defaultMMKV];
    [mmkv setObject:data forKey:_key];
    
    NSMutableDictionary *customDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *defaultDict = [[NSMutableDictionary alloc] init];
    
    __block BOOL containsAllSecuGroup = NO;
    __block BOOL containsSGSecuGroup = NO;
    __block BOOL containsOptionSecuGroup = NO;
    __block YXSecuGroup *allSecuGroup;
    [self.allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.ID == YXDefaultGroupIDAll) {
            allSecuGroup = obj;
            containsAllSecuGroup = YES;
        }
        if (obj.ID == YXDefaultGroupIDSG) {
            containsSGSecuGroup = YES;
        }
        if (obj.ID == YXDefaultGroupIDUSOPTION) {
            containsOptionSecuGroup = YES;
        }
        
        if (containsAllSecuGroup && containsOptionSecuGroup && containsSGSecuGroup) {
            *stop = YES;
        }
    }];
    
    NSMutableArray *allGroupList = [[NSMutableArray alloc] initWithArray:self.allGroupList];
    NSMutableArray *hkArray = [NSMutableArray array];
    NSMutableArray *usArray = [NSMutableArray array];
//    NSMutableArray *cnArray = [NSMutableArray array];
    NSMutableArray *optionArray = [NSMutableArray array];
    
    NSMutableArray *sgArray = [NSMutableArray array];
    
    if (!containsAllSecuGroup) {
        
        allSecuGroup = [[YXSecuGroup alloc] init];
        [allSecuGroup setDefaultGroupID:YXDefaultGroupIDAll];
        allSecuGroup.list = [self allStocks];
        
        [allGroupList insertObject:allSecuGroup atIndex:0];
    }else {
        
        if (allSecuGroup.list.count == 0) {
            allSecuGroup.list = [self allStocks];
        }else if (allSecuGroup.list.count != [self allStocks].count){ // 以全部为准从新生成港、美、A股、期权
            
            @weakify(self);
            [allSecuGroup.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @strongify(self);
                if ([self defaultGroupIDWithSecu:obj] == YXDefaultGroupIDHK) {
                    [hkArray addObject:obj];
                }else if ([self defaultGroupIDWithSecu:obj] == YXDefaultGroupIDUS) {
                    [usArray addObject:obj];
                } else if ([self defaultGroupIDWithSecu:obj] == YXDefaultGroupIDSG) {
                    [sgArray addObject:obj];
                }
//                else if ([self defaultGroupIDWithSecu:obj] == YXDefaultGroupIDCHINA) {
//                    [cnArray addObject:obj];
//                }
                else if ([self defaultGroupIDWithSecu:obj] == YXDefaultGroupIDUSOPTION) {
                    [usArray addObject:obj];
                    [optionArray addObject:obj];
                }
            }];
            
            [allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull secuGroup, NSUInteger idx, BOOL * _Nonnull stop) {
                if (secuGroup.ID == YXDefaultGroupIDHK) {
                    secuGroup.list = [hkArray copy];
                }else if (secuGroup.ID == YXDefaultGroupIDUS) {
                    secuGroup.list = [usArray copy];
                }
                else if (secuGroup.ID == YXDefaultGroupIDSG) {
                    secuGroup.list = [sgArray copy];
                }
//                else if (secuGroup.ID == YXDefaultGroupIDCHINA) {
//                    secuGroup.list = [cnArray copy];
//                }
                else if (secuGroup.ID == YXDefaultGroupIDUSOPTION) {
                    secuGroup.list = [optionArray copy];
                }
            }];
        }
    }
    
    if (!containsSGSecuGroup) {
        YXSecuGroup *sgSecuGroup = [[YXSecuGroup alloc] init];
        [sgSecuGroup setDefaultGroupID:YXDefaultGroupIDSG];
        sgSecuGroup.list = [sgArray copy];

        [allGroupList insertObject:sgSecuGroup atIndex:1];
    }
    
    if (!containsOptionSecuGroup) {
        YXSecuGroup *optionSecuGroup = [[YXSecuGroup alloc] init];
        [optionSecuGroup setDefaultGroupID:YXDefaultGroupIDUSOPTION];
        optionSecuGroup.list = [optionArray copy];

        [allGroupList insertObject:optionSecuGroup atIndex:3];
    }
    
    self.allGroupList = [allGroupList copy];
    [self.allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YXSecuGroupType type = obj.groupType;
        switch (type) {
    
            case YXSecuGroupTypeDefault:
                defaultDict[@(obj.ID)] = obj;
                break;
            case YXSecuGroupTypeCustom:
                customDict[@(obj.ID)] = obj;
                break;
            default:
                break;
        }
    }];
    self.customGroupPool = customDict;
    self.defaultGroupPool = defaultDict;
    
    
    [self _refreshAllSecuGroup];
}

- (NSArray *)allStocks {
    NSMutableArray *hkArray = [NSMutableArray array];
    NSMutableArray *usArray = [NSMutableArray array];
//    NSMutableArray *cnArray = [NSMutableArray array];
    NSMutableArray *sgArray = [NSMutableArray array];
    [self.allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.ID == YXDefaultGroupIDHK) {
            [hkArray addObjectsFromArray:obj.list];
        }
        if (obj.ID == YXDefaultGroupIDUS) {
            [usArray addObjectsFromArray:obj.list];
        }
        if (obj.ID == YXDefaultGroupIDSG) {
            [sgArray addObjectsFromArray:obj.list];
        }
//        if (obj.ID == YXDefaultGroupIDCHINA) {
//            [cnArray addObjectsFromArray:obj.list];
//        }
    }];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSInteger hour = [[calendar components:NSCalendarUnitHour fromDate:date] hour];
    //北京时间早8到晚8应为新股，港股，美股排序顺序，北京时间晚8到早8，应为美股，新股，港股排序
    if (hour >= 20 || hour < 8) {
        [tempArray addObjectsFromArray:usArray];
        [tempArray addObjectsFromArray:sgArray];
        [tempArray addObjectsFromArray:hkArray];
//        [tempArray addObjectsFromArray:cnArray];
    } else {
//        [tempArray addObjectsFromArray:cnArray];
        [tempArray addObjectsFromArray:sgArray];
        [tempArray addObjectsFromArray:hkArray];
        [tempArray addObjectsFromArray:usArray];

    }
    
    return [tempArray copy];
}


- (void)_refreshAllSecuGroup {
    if (self.state == YXSecuGroupStateLogined) {
        __block BOOL containsOwn = NO;
        __block BOOL containsLatest = NO;
        __block BOOL containsCN = NO;
        [self.allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.ID == YXDefaultGroupIDHOLD) {
                containsOwn = YES;
                self.holdGroupIndex = idx;
            }
            
            if (obj.ID == YXDefaultGroupIDLATEST) {
                containsLatest = YES;
                self.latestGroupIndex = idx;
            }
            
            if (obj.ID == YXDefaultGroupIDCHINA) {
                containsCN = YES;
            }
        }];
        
        if (containsCN) {
            NSMutableArray *newGroupList = [self.allGroupList mutableCopy];
            NSArray *resultArr = [newGroupList qmui_filterWithBlock:^BOOL(YXSecuGroup * _Nonnull item) {
                return item.ID != YXDefaultGroupIDCHINA;
            }];
            
            self.allGroupList = [resultArr copy];
            [self _update];
            return;
        }
        
        if (!containsOwn && [self.holdSecuGroup.list count] > 0) {
            YXSecuGroup *secuGroup = [[YXSecuGroup alloc] init];
            [secuGroup setDefaultGroupID:YXDefaultGroupIDHOLD];
            
            NSMutableArray *newGroupList = [self.allGroupList mutableCopy];
            // 此处之所以不插入self.ownSecuGroup是因为自选股跟服务器同步时不得包含持仓的股票
            if (self.holdGroupIndex >= newGroupList.count) {
                [newGroupList addObject:secuGroup];
            } else {
                [newGroupList insertObject:secuGroup atIndex:self.holdGroupIndex];
            }
            self.allGroupList = [newGroupList copy];
            [self _update];
            return;
        } else if (containsOwn && [self.holdSecuGroup.list count] < 1) {
            NSMutableArray *newGroupList = [self.allGroupList mutableCopy];
            [newGroupList removeObjectAtIndex:self.holdGroupIndex];
            self.allGroupList = [newGroupList copy];
            [self _update];
            return;
        }
        
        if (!containsLatest && [self.latestSecuGroup.list count] > 0) {
            YXSecuGroup *secuGroup = [[YXSecuGroup alloc] init];
            [secuGroup setDefaultGroupID:YXDefaultGroupIDLATEST];
            
            NSMutableArray *newGroupList = [self.allGroupList mutableCopy];
            if (self.latestGroupIndex >= newGroupList.count) {
                [newGroupList addObject:secuGroup];
            } else {
                [newGroupList insertObject:secuGroup atIndex:self.latestGroupIndex];
            }
            self.allGroupList = [newGroupList copy];
            [self _update];
            return;
        } else if (containsLatest /*&& self.isGetedLatestTradeData*/ && [self.latestSecuGroup.list count] < 1) {
            self.isGetedLatestTradeData = NO;
            NSMutableArray *newGroupList = [self.allGroupList mutableCopy];
            [newGroupList removeObjectAtIndex:self.latestGroupIndex];
            self.allGroupList = [newGroupList copy];
            [self _update];
            return;
        }
    }
    
    NSMutableArray *allGroupList = [[NSMutableArray alloc] initWithArray:self.allGroupList];
    
    if (self.state == YXSecuGroupStateUnLogin) {
        [allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.ID == YXDefaultGroupIDHOLD) {
                [allGroupList removeObjectAtIndex:idx];
                *stop = YES;
            }
            
            if (obj.ID == YXDefaultGroupIDLATEST) {
                [allGroupList removeObjectAtIndex:idx];
                *stop = YES;
            }
        }];
    }
    
    self.allSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDAll)];
    self.hkSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDHK)];
    self.allGroupList = [allGroupList copy];
    self.allGroupsForPostToServer = self.allGroupList;
    
    
    // 智能排序开启，
    if (self.sortflag == 1) {
        // 对全部里的股票列表分成港股美股
        YXSecuGroup *allSecuGroup = [[YXSecuGroup alloc] init];
        [allSecuGroup setDefaultGroupID:YXDefaultGroupIDAll];
        allSecuGroup.list = [self allStocks];
        
        [allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.ID == YXDefaultGroupIDAll) {
                allGroupList[idx] = allSecuGroup;
            } else if (obj.ID > 10) {
                YXSecuGroup *secuGroup = [[YXSecuGroup alloc] init];
                secuGroup.name = obj.name;
                [secuGroup setDefaultGroupID:obj.ID];
                secuGroup.list = [self secuListWithGroup:obj];
                allGroupList[idx] = secuGroup;
            }
        }];
    }
    
    // 设置sort
    [self _setSort];
    
    self.allGroupsForShow = [allGroupList copy];
}

// 设置sort的值
- (void)_setSort {
    // 设置sort
       YXSecuGroup *allSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDAll)];
       YXSecuGroup *hkSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDHK)];
       YXSecuGroup *usSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDUS)];
       YXSecuGroup *chinaSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDCHINA)];
       YXSecuGroup *optionSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDUSOPTION)];
       //YXSecuGroup *cnSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDCHINA)];
        YXSecuGroup *sgSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDSG)];
    
       [allSecuGroup.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           obj.sort = idx;
           
           if (obj.marketType == YXMarketTypeHongKong) {
               [hkSecuGroup.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull hksecu, NSUInteger hksecuidx, BOOL * _Nonnull stop) {
                   if ([obj.symbol isEqualToString:hksecu.symbol] && [obj.market isEqualToString:hksecu.market]) {
                       hksecu.sort = idx;
                       *stop = YES;
                   }
               }];
           }else if (obj.marketType == YXMarketTypeUnitedStates) {
               [usSecuGroup.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull ussecu, NSUInteger ussecuidx, BOOL * _Nonnull stop) {
                   if ([obj.symbol isEqualToString:ussecu.symbol] && [obj.market isEqualToString:ussecu.market]) {
                       ussecu.sort = idx;
                       *stop = YES;
                   }
               }];
           }else if (obj.marketType == YXMarketTypeSingapore) {
               [sgSecuGroup.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull sgsecu, NSUInteger sgsecuidx, BOOL * _Nonnull stop) {
                   if ([obj.symbol isEqualToString:sgsecu.symbol] && [obj.market isEqualToString:sgsecu.market]) {
                       sgsecu.sort = idx;
                       *stop = YES;
                   }
               }];
           }else {
               [chinaSecuGroup.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull chinasecu, NSUInteger chinasecuidx, BOOL * _Nonnull stop) {
                   if ([obj.symbol isEqualToString:chinasecu.symbol] && [obj.market isEqualToString:chinasecu.market]) {
                       chinasecu.sort = idx;
                       *stop = YES;
                   }
               }];
           }
       }];
       
       [self.allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          if (obj.ID > 10) {
               [obj.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull secu, NSUInteger secuidx, BOOL * _Nonnull stop) {
                   secu.sort = secuidx;
               }];
           }
       }];
}

- (void)_removeArray:(NSArray<id<YXSecuIDProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup  {
    [self _removeArray:secus secuGroup:secuGroup needPost: YES];
}

- (void)_removeArray:(NSArray<id<YXSecuIDProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup needPost:(BOOL)needPost {
    YXSecuGroupType type = [secuGroup groupType];
    
    [secus enumerateObjectsUsingBlock:^(id<YXSecuIDProtocol> _Nonnull secu, NSUInteger idx, BOOL * _Nonnull stop) {
        if (type != YXSecuGroupTypeCustom) {
            [self.allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull secuGroup, NSUInteger idx, BOOL * _Nonnull stop) {
                [secuGroup removeSecu:secu];
            }];
            //[[YXOptionalDBManager shareInstance] deleteDataWithSecu:secu];
        } else {
            YXSecuGroup *customSecuGroup = self.customGroupPool[@(secuGroup.ID)];
            [customSecuGroup removeSecu:secu];
        }
    }];
    
    [self _update];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSecuGroupRemoveSecuNotification object:nil];
    
    if(self.postGroupIfNeed && needPost) {
        @weakify(self)
        self.postGroupIfNeed(^{
            @strongify(self)
            [self _removeArray:secus secuGroup:secuGroup];
        });
    }
}

- (BOOL)_appendArray:(NSArray<id<YXSecuProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup {
    return [self _appendArray:secus secuGroup:secuGroup needPost:YES];
}

- (BOOL)_appendArray:(NSArray<id<YXSecuProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup needPost:(BOOL)needPost {
    if (secuGroup == nil) {
        secuGroup = self.allSecuGroup;
    }
    if ([secuGroup.list count] >= self.stockMaxNum) {
        return NO;
    }
    YXSecuGroupType type = [secuGroup groupType];
    
    if ([self.allSecuGroup.list count] + [secus count] > self.stockMaxNum ) {
        NSMutableArray *array = [NSMutableArray array];
        [secus enumerateObjectsUsingBlock:^(id<YXSecuProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXSecuID *secuId = [YXSecuID secuIdWithMarket:obj.market symbol:obj.symbol];
            if ([self containsSecu:obj]) {
                [secuGroup appendSecu:secuId];
            } else {
                [array addObject:secuId];
            }
        }];
        if (array.count == 0) {
            [self _update];
            return YES;
        }
        
        if ([self.allSecuGroup.list count] + [array count] > self.stockMaxNum ) {
            return NO;
        }
        secus = array;
    }
    
    [secus enumerateObjectsUsingBlock:^(id<YXSecuProtocol> _Nonnull secu, NSUInteger idx, BOOL * _Nonnull stop) {
        if (type == YXSecuGroupTypeDefault || type == YXSecuGroupTypeAll || (type == YXSecuGroupTypeCustom && ![self containsSecu:secu])) {
            NSUInteger ID = [self defaultGroupIDWithSecu:secu];
            YXSecuGroup *defaultSecuGroup = self.defaultGroupPool[@(ID)];
            [defaultSecuGroup appendSecu:secu];
            
            if (ID == YXDefaultGroupIDUSOPTION) { //期权同步添加到美股
                YXSecuGroup *usSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDUS)];
                [usSecuGroup appendSecu:secu];
            }
            
            // 加到全部
            YXSecuGroup *allSecuGroup = self.defaultGroupPool[@(YXDefaultGroupIDAll)];
            [allSecuGroup appendSecu:secu];
            [[YXOptionalDBManager shareInstance] insertOrReplaceData:secu];
        }
        
        if (type == YXSecuGroupTypeCustom) {
            YXSecuGroup *customSecuGroup = self.customGroupPool[@(secuGroup.ID)];
            [customSecuGroup appendSecu:secu];
        }
    }];
    
    [self _update];
    
    if (self.postGroupIfNeed && needPost) {
        @weakify(self)
        self.postGroupIfNeed(^{
            @strongify(self)
            [self _appendArray:secus secuGroup:secuGroup];
        });
    }
    
    return YES;
}

- (NSUInteger)defaultGroupIDWithSecu:(id<YXSecuIDProtocol>)secu {
    YXSecuID *secuId = [YXSecuID secuIdWithMarket:secu.market symbol:secu.symbol];
    YXMarketType marketType = secuId.marketType;
    
    NSUInteger ID = 0;
    if (marketType == YXMarketTypeHongKong) {
        ID = YXDefaultGroupIDHK;
    } else if (marketType == YXMarketTypeUnitedStates) {
        if (secuId.secuType == YXSecuTypeStock) {
            ID = YXDefaultGroupIDUS;
        }else {
            ID = YXDefaultGroupIDUSOPTION;
        }
        
    } else if (marketType == YXMarketTypeChina) {
        ID = YXDefaultGroupIDCHINA;
    } else if (marketType == YXMarketTypeSingapore) {
        ID = YXDefaultGroupIDSG;
    }
    
    return ID;
}

- (void)_exchange:(YXSecuGroup *)secuGroup secu:(id<YXSecuIDProtocol>)secu to:(NSInteger)index {
    YXSecuID *secuId = [YXSecuID secuIdWithMarket:secu.market symbol:secu.symbol];
    // 智能排序开启，如果是对全部和自定义分组进行排序，可当成是单独对港美股A股的排序，对全部分组的排序需要同步到全部分组，对自定义分组的排序，则不需要同步到全部
    if (self.sortflag == 1 && (secuGroup.ID == YXDefaultGroupIDAll || [secuGroup groupType] == YXSecuGroupTypeCustom)) {
        YXSecuGroup *group;
        NSMutableArray<YXSecuID *> *array;
        if ([secuGroup groupType] == YXSecuGroupTypeCustom) {
            group = self.customGroupPool[@(secuGroup.ID)];
            NSMutableArray *arr = [NSMutableArray array];
            [group.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                // 从自定义分组数组里挑出某一个市场的股票
                if (obj.marketType == secuId.marketType) {
                    [arr addObject:[YXSecuID secuIdWithMarket:obj.market symbol:obj.symbol]];
                }
                
            }];
            array = arr;
        }else {
            
            if (secuId.marketType == YXMarketTypeHongKong) {
                group = self.defaultGroupPool[@(YXDefaultGroupIDHK)];
            }else if (secuId.marketType == YXMarketTypeUnitedStates) {
                group = self.defaultGroupPool[@(YXDefaultGroupIDUS)];
            }else if (secuId.marketType == YXMarketTypeChina) {
                group = self.defaultGroupPool[@(YXDefaultGroupIDCHINA)];
            } else if (secuId.marketType == YXMarketTypeSingapore) {
                group = self.defaultGroupPool[@(YXDefaultGroupIDSG)];
            }
            
            if (group.list.count > 0) {
                array = [[NSMutableArray alloc] initWithArray:group.list];
            }
            
        }
        
        // 智能排序下不允许跨市场排序，需要知道此次拖动是否发生了跨市场
        NSArray<YXSecuID *> *arr = [self secuListWithGroup:secuGroup]; // 当前分组混合数组
        // 先找到当前拖动的股票在原数组的位置
        __block NSUInteger sourceIndex;
        [arr enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([secu.symbol isEqualToString:obj.symbol] && [secu.market isEqualToString:obj.market]) {
                sourceIndex = idx;
                *stop = YES;
            }
        }];
        
        YXSecuID *item = arr[index];
        // 当前移动的股票和目标位置的股票比较，如果markettype不同(智能排序下，按市场分成了块)，则说明发了跨市场移动
        if (secuId.marketType != item.marketType) { // 说明移动超出了本市场的范围
            if (index < sourceIndex) { // 往前移
                // 跨了市场，智能模式下最多只能移到本组第一位
                index = 0;
            }else if(index >= sourceIndex){ // 往后移
                // 跨了市场，智能模式下最多只能移到本组末尾
                index = array.count - 1;
            }
        }else {
            // 找到该股票在自己数组中的位置,改股票即将移动到的位置实际上就是位于index处的原来的股票的位置，index处的股票的在本组中的索引就是该股票在本组内需要移动的index
            // 例如：[1,2,3,A,B,C,a,b,c]假如用户拖动C到B的位置，此时index是4，但是在[A,B,C]中，移动的index其实是1，其实就是B在本组中的index
            __block  NSUInteger selfIdex;
            [array enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([item.symbol isEqualToString:obj.symbol] && [item.market isEqualToString:obj.market]) {
                    selfIdex = idx;
                    *stop = YES;
                }
            }];
            index = selfIdex;
        }
        
        // 对数组进行排序
        
        [array enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.symbol isEqualToString:secu.symbol] && [obj.market isEqualToString:secu.market]) {
                if (idx != index) {
                    [array removeObject:obj];
                    [array insertObject:[YXSecuID secuIdWithMarket:secu.market symbol:secu.symbol] atIndex:index];
                }
                *stop = YES;
            }
        }];
        
        // 如果是在全部里进行智能排序，实现上操作的其实是对应的港股或者美股或者A股，最后需要同步到全部分组
        if (secuGroup.ID == YXDefaultGroupIDAll) {
            group.list = array; // array是已经拍好序的数组，group是被排序的组（港 美 A）
            [self synchronizeToGroup:secuGroup withList:group.list]; // 把已经拍好序的数组同步到“全部”分组的股票list
            if (group.ID == YXDefaultGroupIDUS) { // 如果是美股分组，还需要同步到期权固定分组
                YXSecuGroup *usOptionGroup = self.defaultGroupPool[@(YXDefaultGroupIDUSOPTION)];
                usOptionGroup.list = [self optionListFromArray:group.list];
            }
        }else if ([secuGroup groupType] == YXSecuGroupTypeCustom) {
            // 这里是更新自定义分组的list
            [self synchronizeToGroup:secuGroup withList:array];
        }
        
    }else {
        NSMutableArray<YXSecuID *> *exchangeGroupList = [[NSMutableArray alloc] initWithArray:secuGroup.list];
        [exchangeGroupList enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.symbol isEqualToString:secu.symbol] && [obj.market isEqualToString:secu.market]) {
                if (idx != index) {
                    [exchangeGroupList removeObject:obj];
                    [exchangeGroupList insertObject:[YXSecuID secuIdWithMarket:secu.market symbol:secu.symbol] atIndex:index];
                }
                *stop = YES;
            }
        }];
        
        secuGroup.list = exchangeGroupList;
        
        if (secuGroup.ID == YXDefaultGroupIDAll) { // 如果是全部分组，需要同步到对应的港、美股、A股、期权
            
            NSMutableArray *list = [NSMutableArray array];
            NSMutableArray *optionsList = [NSMutableArray array];
            
            [exchangeGroupList enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.marketType == secuId.marketType) {
                    [list addObject:obj];
                    if (obj.secuType == YXSecuTypeOption) { // 期权数组
                        [optionsList addObject:obj];
                    }
                }
            }];
            
            if (secuId.marketType == YXMarketTypeUnitedStates) { // 如果是美股，由于美股里有期权，所以美股分组和期权分组都需要重新生成
                
                YXSecuGroup *usGroup = self.defaultGroupPool[@(YXDefaultGroupIDUS)];
                YXSecuGroup *usOptionsGroup = self.defaultGroupPool[@(YXDefaultGroupIDUSOPTION)];
                usGroup.list = list;
                usOptionsGroup.list = optionsList;
                
            }else {
                NSUInteger ID = [self defaultGroupIDWithSecu:secu];
                YXSecuGroup *group = self.defaultGroupPool[@(ID)];
                group.list = list;
            }
            
        }else if (secuGroup.ID == YXDefaultGroupIDHK || secuGroup.ID == YXDefaultGroupIDUS || secuGroup.ID == YXDefaultGroupIDCHINA || secuGroup.ID == YXDefaultGroupIDSG) { // 如果是港美A股分组，需要同步到全部
            [self synchronizeToGroup:self.allSecuGroup withList:secuGroup.list];
            
            if (secuGroup.ID == YXDefaultGroupIDUS) { // 美股变动了，还需要同步到期权
                YXSecuGroup *usOptionsGroup = self.defaultGroupPool[@(YXDefaultGroupIDUSOPTION)];
                usOptionsGroup.list = [self optionListFromArray:exchangeGroupList];
            }
            
        }else if (secuGroup.ID == YXDefaultGroupIDUSOPTION) { // 如果操作的是期权固定分组，则需要先把期权固定分组的顺序与美股分组同步，再把美股分组的顺序同步到全部
            YXSecuGroup *group = self.defaultGroupPool[@(YXDefaultGroupIDUS)];
            NSMutableArray<YXSecuID *> *groupList = [[NSMutableArray alloc] initWithArray:group.list];
            __block int flag = 0;
            [groupList enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.secuType == YXSecuTypeOption) {
                    groupList[idx] = secuGroup.list[flag];
                    flag++;
                }
            }];

            group.list = groupList;
            
            [self synchronizeToGroup:self.allSecuGroup withList:group.list];
        }
    }

    [self _update];
    
    if (self.postGroupIfNeed) {
        @weakify(self)
        self.postGroupIfNeed(^{
            @strongify(self)
            [self _exchange:secuGroup secu:secu to:index];
        });
    }
    
}

- (NSArray *)optionListFromArray:(NSArray *)arr {
    NSMutableArray *optionsList = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.secuType == YXSecuTypeOption) { // 期权数组
            [optionsList addObject:obj];
        }
    }];
    return [optionsList copy];
}

- (NSArray<YXSecuID *> *)secuListWithGroup:(YXSecuGroup *)secuGroup {
    if ([YXSecuGroupManager shareInstance].sortflag == 1) {
        NSMutableArray<YXSecuID *> *hkArray = [[NSMutableArray alloc] init];
        NSMutableArray<YXSecuID *> *chinaArray = [[NSMutableArray alloc] init];
        NSMutableArray<YXSecuID *> *usArray = [[NSMutableArray alloc] init];
        NSMutableArray<YXSecuID *> *sgArray = [[NSMutableArray alloc] init];
        
        
        [secuGroup.list enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.marketType == YXMarketTypeHongKong) {
                [hkArray addObject: obj];
            } else if (obj.marketType == YXMarketTypeChina) {
                [chinaArray addObject:obj];
            }else if (obj.marketType == YXMarketTypeUnitedStates) {
                [usArray addObject:obj];
            }else if (obj.marketType == YXMarketTypeSingapore) {
                [sgArray addObject:obj];
            }
        }];
        
        [hkArray addObjectsFromArray:chinaArray];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        NSInteger hour = [[calendar components:NSCalendarUnitHour fromDate:date] hour];
        
        if (hour >= 20 || hour < 8) {
            [tempArray addObjectsFromArray:usArray];
            [tempArray addObjectsFromArray:sgArray];
            [tempArray addObjectsFromArray:hkArray];
        } else {
            [tempArray addObjectsFromArray:sgArray];
            [tempArray addObjectsFromArray:hkArray];
            [tempArray addObjectsFromArray:usArray];
        }
        
        return [tempArray copy];
    }else {
        return [secuGroup.list copy];
    }
}

// 将排好序的固定市场股票数组同步到混合大数组
- (void)synchronizeToGroup:(YXSecuGroup *)group withList:(NSArray *)list {
    if (list.count == 0) {return;}
     YXSecuID *oneItem = list[0];
     YXMarketType marketType = oneItem.marketType;
     YXSecuGroup *theGroup;
     if (group.ID == YXDefaultGroupIDAll) {
         theGroup = self.defaultGroupPool[@(YXDefaultGroupIDAll)];
     }else if (group.ID > 10) {
         theGroup = self.customGroupPool[@(group.ID)];
     }
     
     NSMutableArray<YXSecuID *> *groupList = [[NSMutableArray alloc] initWithArray:theGroup.list];
     __block int flag = 0;
     [groupList enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if (obj.marketType == marketType) {
             groupList[idx] = list[flag];
             flag++;
         }
     }];

     theGroup.list = groupList;
}

#pragma mark - group methods
- (void)removeGroupWithGroupID:(NSUInteger)groupID {
    YXSecuGroup *secuGroup = self.customGroupPool[@(groupID)];
    if ([secuGroup groupType] == YXSecuGroupTypeCustom) {
//        [secuGroup.list enumerateObjectsUsingBlock:^(id<YXSecuIDProtocol> _Nonnull secu, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSArray<YXSecuGroup *> *customGroupList = [self customGroupListWithSecu:secu];
//            if (customGroupList.count <= 1) {
//                [self.allGroupList enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull secuGroup, NSUInteger idx, BOOL * _Nonnull stop) {
//                    [secuGroup removeSecu:secu];
//                }];
//                //[[YXOptionalDBManager shareInstance] deleteDataWithSecu:secu];
//            }
//        }];
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.allGroupList];
        [array removeObject:secuGroup];
        self.allGroupList = array;
        
        [self _update];
        
        if (self.postGroupIfNeed) {
            @weakify(self)
            self.postGroupIfNeed(^{
                @strongify(self)
                [self removeGroupWithGroupID:groupID];
            });
        }
    }
}

- (BOOL)createGroup:(NSString *)name {
    BOOL success = NO;
    for (NSNumber *number in kYXCustomGroupIDs) {
        if (self.customGroupPool[number]) {
            continue;
        } else {
            success = YES;
            
            NSUInteger gid = number.unsignedIntegerValue;
            YXSecuGroup *secuGroup = [[YXSecuGroup alloc] init];
            secuGroup.ID = gid;
            secuGroup.name = name;
            secuGroup.list = [NSArray array];
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.allGroupList];
            [array addObject:secuGroup];
            self.allGroupList = [array copy];
            
            [self _update];
            
            @weakify(self)
            if (self.postGroupIfNeed) {
                self.postGroupIfNeed(^{
                    @strongify(self)
                    [self createGroup:name];
                });
            }
            break;
        }
    }
    return success;
}

- (void)change:(YXSecuGroup *)secuGroup name:(NSString *)name {
    YXSecuGroup *customSecuGroup = self.customGroupPool[@(secuGroup.ID)];
    customSecuGroup.name = name;
    [self _update];
    [self postGroup];
}

- (void)exchange:(YXSecuGroup *)secuGroup to:(NSInteger)index {
    NSMutableArray<YXSecuGroup *> *array = [[NSMutableArray alloc] initWithArray:self.allGroupList];
    
    [array enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.ID == secuGroup.ID) {
            if (idx != index) {
                [array removeObject:obj];
                [array insertObject:secuGroup atIndex:index];
            }
            *stop = YES;
        }
    }];
    
    self.allGroupList = array;
    
    [self _update];
    
    [self postGroup];
}


#pragma mark - remove methods
- (void)remove:(id<YXSecuIDProtocol>)secu {
    [self removeArray:@[secu]];
}

- (void)removeArray:(NSArray<id<YXSecuIDProtocol>> *)secus {
    [self removeArray:secus secuGroup:self.allSecuGroup];
}

- (void)removeArray:(NSArray<id<YXSecuIDProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup {
    [self _removeArray:secus secuGroup:secuGroup];
}

- (void)remove:(id<YXSecuIDProtocol>)secu secuGroup:(YXSecuGroup *)secuGroup {
    [self removeArray:@[secu] secuGroup:secuGroup];
}

#pragma exchange methods

- (void)stick:(YXSecuGroup *)secuGroup secu:(id<YXSecuIDProtocol>)secu {
    [self _exchange:secuGroup secu:secu to:0];
}

- (void)exchange:(YXSecuGroup *)secuGroup secu:(id<YXSecuIDProtocol>)secu to:(NSInteger)index {
    [self _exchange:secuGroup secu:secu to:index];
}

#pragma mark - append methods
- (BOOL)append:(id<YXSecuProtocol>)secu {
    return [self append:secu secuGroup:self.allSecuGroup];
}

- (BOOL)appendArray:(NSArray<id<YXSecuProtocol>> *)secus {
    return [self appendArray:secus secuGroup:self.allSecuGroup];
}


- (BOOL)append:(id<YXSecuProtocol>)secu secuGroup:(YXSecuGroup *)secuGroup {
    return [self appendArray:@[secu] secuGroup:secuGroup];
}

- (BOOL)appendArray:(NSArray<id<YXSecuProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup {
    return [self _appendArray:secus secuGroup:secuGroup];
}


@end

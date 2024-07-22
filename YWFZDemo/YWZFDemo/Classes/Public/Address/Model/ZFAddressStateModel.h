//
//  ZFAddressStateModel.h
//  ZZZZZ
//
//  Created by Apple on 2017/9/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressBaseModel.h"
#import "ZFAddressCityModel.h"

@interface ZFAddressStateModel : ZFAddressBaseModel

@property (nonatomic, copy) NSString *stateId;
@property (nonatomic, copy) NSString *country_id;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSArray<ZFAddressCityModel *>     *cityList;

@property (nonatomic, copy) NSString                            *key;

@property (nonatomic, strong) NSMutableArray<NSString *>        *sectionKeys;
@property (nonatomic, strong) NSMutableDictionary               *sectionCityDic;

//- (void)handleSelfKey;
- (void)handleSectionData;
- (NSArray *)sectionDatasForKey:(NSString *)sectionKey;
@end

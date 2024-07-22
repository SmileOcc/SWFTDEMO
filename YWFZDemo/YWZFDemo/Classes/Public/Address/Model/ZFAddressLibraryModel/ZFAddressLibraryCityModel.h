//
//  ZFAddressLibraryCityModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressBaseModel.h"
#import "ZFAddressLibraryTownModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFAddressLibraryCityModel : ZFAddressBaseModel

/** ID*/
//@property (nonatomic, copy) NSString *idx;
/** name*/
//@property (nonatomic, copy) NSString *n;
/** 分组key 暂时没返回key,自己处理名字*/
//@property (nonatomic, copy) NSString *k;

// 自定义
@property (nonatomic, strong) NSArray<ZFAddressLibraryTownModel *>    *town_list;
@property (nonatomic, strong) NSMutableArray<NSString *>              *sectionKeys;
@property (nonatomic, strong) NSMutableDictionary                     *sectionVillageDic;

- (void)handleSelfKey;
- (void)handleSectionData;
- (NSArray *)sectionDatasForKey:(NSString *)sectionKey;

@end

NS_ASSUME_NONNULL_END

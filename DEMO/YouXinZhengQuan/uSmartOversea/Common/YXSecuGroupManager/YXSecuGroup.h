//
//  YXSecuGroupModel.h
//  uSmartOversea
//
//  Created by ellison on 2018/11/14.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSecuID.h"


NS_ASSUME_NONNULL_BEGIN


/**
 组类型
 
 - YXSecuGroupTypeAll: 全部分组
 - YXSecuGroupTypeDefault: 默认分组
 - YXSecuGroupTypeCustom: 自定义分组
 */
typedef NS_ENUM(NSUInteger, YXSecuGroupType) {
    YXSecuGroupTypeAll,
    YXSecuGroupTypeDefault,
    YXSecuGroupTypeCustom,
};


/**
 默认分组
 
 - YXDefaultGroupIDAll: 全部
 - YXDefaultGroupIDHK: 港股
 - YXDefaultGroupIDUS: 美股
 - YXDefaultGroupIDCHINA: 沪深
 - YXDefaultGroupIDOWN: 持仓
 
 */
typedef NS_ENUM(NSUInteger, YXDefaultGroupID) {
    YXDefaultGroupIDAll      =   0,
    YXDefaultGroupIDHK       =   1,
    YXDefaultGroupIDUS       =   2,
    YXDefaultGroupIDCHINA    =   3,
    YXDefaultGroupIDHOLD     =   4,
    YXDefaultGroupIDLATEST   =   5,
    YXDefaultGroupIDUSOPTION   = 6,
    YXDefaultGroupIDSG         = 7,
};

#define kDefaultGroupNameAll    @"全部"
#define kDefaultGroupNameHK     @"港股"
#define kDefaultGroupNameUS     @"美股"
#define kDefaultGroupNameCHINA  @"沪深"
#define kDefaultGroupNameLATEST @"近期交易"
#define kDefaultGroupNameHOLD   @"持仓"
#define kDefaultGroupNameUSOPTION   @"美股期权"
#define kDefaultGroupNameSG   @"新加坡"

#define kYXCustomGroupIDs @[@(11),@(12),@(13),@(14),@(15),@(16),@(17),@(18),@(19),@(20)]

@interface YXSecuGroup : NSObject

@property (nonatomic, assign) NSUInteger ID;
@property (nonatomic, copy) NSString *name;
// 上面的name是中文的，在上传自选股时服务端有校验name的中文，不能修改，智能再提供一个multiLanguageName作为展示用
@property (nonatomic, copy) NSString *multiLanguageName;
@property (nonatomic, strong) NSArray<YXSecuID *> *list;

- (void)appendSecu:(id<YXSecuIDProtocol>)secu;
- (void)removeSecu:(id<YXSecuIDProtocol>)secu;

- (YXSecuGroupType)groupType;
- (void)setDefaultGroupID:(YXDefaultGroupID)groupID;

- (NSString *)groupText;

@end


NS_ASSUME_NONNULL_END

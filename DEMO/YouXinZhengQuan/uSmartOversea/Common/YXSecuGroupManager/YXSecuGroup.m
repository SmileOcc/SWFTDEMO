//
//  YXSecuGroupModel.m
//  uSmartOversea
//
//  Created by ellison on 2018/11/14.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXSecuGroup.h"
#import <YYModel/YYModel.h>
#import "uSmartOversea-Swift.h"

@implementation YXSecuGroup

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"name": @"gname",
             @"ID": @"gid",
             };
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"list": [YXSecuID class]};
}

- (void)removeSecu:(id<YXSecuIDProtocol>)secu {
    YXSecuID *secuId = [YXSecuID secuIdWithMarket:secu.market symbol:secu.symbol];
    NSMutableArray<YXSecuID *> *array = [[NSMutableArray alloc] initWithArray:self.list];
    
    [array enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:secuId]) {
            [array removeObject:obj];
            *stop = YES;
        }
    }];
    self.list = array;
}

- (void)appendSecu:(id<YXSecuIDProtocol>)secu {
    YXSecuID *secuId = [YXSecuID secuIdWithMarket:secu.market symbol:secu.symbol];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.list];
    [array enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:secuId]) {
            [array removeObject:obj];
            *stop = YES;
        }
    }];
    [array insertObject:secuId atIndex:0];
    self.list = [array copy];
}

- (YXSecuGroupType)groupType {
    if (_ID > 10) {
        return YXSecuGroupTypeCustom;
    }
    
    return YXSecuGroupTypeDefault;
}

- (void)setDefaultGroupID:(YXDefaultGroupID)groupID {
    self.ID = groupID;
    self.list = [NSMutableArray array];
    switch (groupID) {
        case YXDefaultGroupIDAll:
            self.name = kDefaultGroupNameAll;
            break;
        case YXDefaultGroupIDHK:
            self.name = kDefaultGroupNameHK;
            break;
        case YXDefaultGroupIDUS:
            self.name = kDefaultGroupNameUS;
            break;
        case YXDefaultGroupIDCHINA:
            self.name = kDefaultGroupNameCHINA;
            break;
        case YXDefaultGroupIDLATEST:
            self.name = kDefaultGroupNameLATEST;
            break;
        case YXDefaultGroupIDHOLD:
            self.name = kDefaultGroupNameHOLD;
            break;
        case YXDefaultGroupIDUSOPTION:
            self.name = kDefaultGroupNameUSOPTION;
            break;
        case YXDefaultGroupIDSG:
            self.name = kDefaultGroupNameSG;
            break;
        default:
            break;
    }
}

- (NSString *)multiLanguageName {
    switch (self.ID) {
        case YXDefaultGroupIDAll:
            return [YXLanguageUtility kLangWithKey:@"common_all"];
            break;
        case YXDefaultGroupIDHK:
            return [YXLanguageUtility kLangWithKey:@"community_hk_stock"];
            break;
        case YXDefaultGroupIDUS:
            return [YXLanguageUtility kLangWithKey:@"community_us_stock"];
            break;
        case YXDefaultGroupIDCHINA:
            return [YXLanguageUtility kLangWithKey:@"community_cn_stock"];
            break;
        case YXDefaultGroupIDLATEST:
            return [YXLanguageUtility kLangWithKey:@"hold_recent_trading"];
            break;
        case YXDefaultGroupIDHOLD:
            return [YXLanguageUtility kLangWithKey:@"hold_holds"];
            break;
        case YXDefaultGroupIDUSOPTION:
            return [YXLanguageUtility kLangWithKey:@"options_options"];
            break;
        case YXDefaultGroupIDSG:
            return [YXLanguageUtility kLangWithKey:@"community_sg_stock"];
            break;
        default:
            return @"";
    }
        
}

- (NSString *)groupText {
    return [NSString stringWithFormat:@"%@ (%zd)", _name, [_list count]];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[YXSecuGroup class]]) {
        return NO;
    }
    
    if (![self.list isEqualToArray:((YXSecuGroup *)object).list]) {
        return NO;
    }
    
    if (![self.name isEqualToString:((YXSecuGroup *)object).name]) {
        return NO;
    }
    
    if (self.ID != ((YXSecuGroup *)object).ID) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return [self.name hash] ^ [self.list hash] ^ self.ID;
}

@end

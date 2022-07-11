//
//  YXModel.m
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXModel.h"

@implementation YXModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return kYXPBMapper;
}

+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{};
}

+ (instancetype)yxModelWithJSON:(id)json {
    return [self yy_modelWithJSON:json];
}

- (id)yxModelToJSONObject {
    return [self yy_modelToJSONObject];

}

+ (NSArray *)mappedKeys {
    NSMutableDictionary *allPropertyPool = [NSMutableDictionary dictionary];
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClass:self];
    YYClassInfo *curClassInfo = classInfo;
    while (curClassInfo && curClassInfo.superCls != nil) {
        for (YYClassPropertyInfo *propertyInfo in curClassInfo.propertyInfos.allValues) {
            if (!propertyInfo.name) continue;
            if (!propertyInfo.setter || !propertyInfo.getter) continue;
            if (propertyInfo.getter && ![curClassInfo.cls instancesRespondToSelector:propertyInfo.getter]) {
                continue;
            }
            if (propertyInfo.setter && ![curClassInfo.cls instancesRespondToSelector:propertyInfo.setter]) {
                continue;
            }
            if (allPropertyPool[propertyInfo.name]) continue;
            allPropertyPool[propertyInfo.name] = propertyInfo;
        }
        curClassInfo = curClassInfo.superClassInfo;
    }
    
    NSDictionary *mapper = [self modelCustomPropertyMapper];
    NSMutableArray *mappedKeys = [NSMutableArray array];
    [allPropertyPool.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (mapper[obj]) {
            [mappedKeys addObject:mapper[obj]];
        } else {
            [mappedKeys addObject:obj];
        }
    }];

    return [mappedKeys copy];
}

@end

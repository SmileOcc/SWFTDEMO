//
//  ZFAddressStateModel.m
//  ZZZZZ
//
//  Created by Apple on 2017/9/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressStateModel.h"
#import "YWCFunctionTool.h"
#import "ZFAddressLibraryManager.h"

@implementation ZFAddressStateModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"stateId"       :@"id",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"cityList" : [ZFAddressCityModel class]
             };
}

//- (void)handleSelfKey {
//    if (ZFIsEmptyString(self.key)) {
//        NSString *firstCharactor = [self pinyinFirstLetter:ZFToString(self.name)];
//        self.key = firstCharactor;
//    }
//}

- (void)handleSectionData {
    if (ZFJudgeNSArray(self.sectionKeys)) {
        if (self.sectionKeys.count > 0) {
            return;
        }
    }
    self.sectionCityDic = [[NSMutableDictionary alloc] init];
    
    [self.cityList enumerateObjectsUsingBlock:^(ZFAddressCityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:obj.name];        
        NSMutableArray *arr;
        if ([[self.sectionCityDic allKeys] containsObject:firstCharactor]) {
            arr = [self.sectionCityDic objectForKey:firstCharactor];
            if (arr) {
                [arr addObject:obj];
                [self.sectionCityDic setObject:arr forKey:firstCharactor];
            } else {
                arr = [[NSMutableArray alloc] init];
                [arr addObject:obj];
                [self.sectionCityDic setObject:arr forKey:firstCharactor];
            }
        } else {
            arr = [[NSMutableArray alloc] init];
            [arr addObject:obj];
            [self.sectionCityDic setObject:arr forKey:firstCharactor];
        }
    }];
    
    // allKey排序
    
    NSMutableArray *groupTempArray= [NSMutableArray arrayWithArray:[[self.sectionCityDic allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    self.sectionKeys = groupTempArray;
}

- (NSArray *)sectionDatasForKey:(NSString *)sectionKey {
    NSArray *sectionDatasArray = [self.sectionCityDic objectForKey:ZFToString(sectionKey)];
    if (ZFJudgeNSArray(sectionDatasArray)) {
        return sectionDatasArray;
    }
    return @[];
}

//系统获取首字母
- (NSString *) pinyinFirstLetter:(NSString*)sourceString {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);//这一行是去声调的
    
    //转化为大写拼音
    NSString *pinYin = [source capitalizedString];
    
    //获取并返回首字母
    if (pinYin.length > 0) {
        return [pinYin substringToIndex:1];
    }
    return @"#";
}


@end

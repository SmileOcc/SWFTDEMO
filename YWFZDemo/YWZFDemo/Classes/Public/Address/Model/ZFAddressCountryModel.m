//
//  ZFAddressCountryModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressCountryModel.h"
#import "YWCFunctionTool.h"
#import "ZFAddressLibraryManager.h"

//当前选择地址model与个人国家页面共用一个model, 只增加了一个exchange字段
@implementation ZFCountryExchangeModel
@end


@implementation ZFAddressCountryModel

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"provinceList" : [ZFAddressStateModel class],
             @"support_lang" : [ZFSupportLangModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"region_code",
             @"region_id",
             @"region_name",
             @"code",
             @"supplier_number_list",
             @"scut_number_list",
             @"number",
             @"is_state",
             @"configured_number",
             @"is_cod",
             @"exchange",
             @"ownCity",
             @"ownState",
             @"provinceList",
             @"showFourLevel",
             @"support_lang",
             @"support_zip_code",
             @"is_emerging_country"
             ];
}

- (void)handleSectionData {
    if (ZFJudgeNSArray(self.sectionKeys)) {
        if (self.sectionKeys.count > 0) {
            return;
        }
    }
        
    self.sectionProvinceDic = [[NSMutableDictionary alloc] init];
    
    [self.provinceList enumerateObjectsUsingBlock:^(ZFAddressStateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:obj.key];
        
        NSMutableArray *arr;
        if ([[self.sectionProvinceDic allKeys] containsObject:firstCharactor]) {
            arr = [self.sectionProvinceDic objectForKey:firstCharactor];
            if (arr) {
                [arr addObject:obj];
                [self.sectionProvinceDic setObject:arr forKey:firstCharactor];
            } else {
                arr = [[NSMutableArray alloc] init];
                [arr addObject:obj];
                [self.sectionProvinceDic setObject:arr forKey:firstCharactor];
            }
        } else {
            arr = [[NSMutableArray alloc] init];
            [arr addObject:obj];
            [self.sectionProvinceDic setObject:arr forKey:firstCharactor];
        }
    }];
    
    // allKey排序
    
    NSMutableArray *groupTempArray= [NSMutableArray arrayWithArray:[[self.sectionProvinceDic allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    self.sectionKeys = groupTempArray;
}

- (NSArray *)sectionDatasForKey:(NSString *)sectionKey {
    NSArray *sectionDatasArray = [self.sectionProvinceDic objectForKey:ZFToString(sectionKey)];
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

- (BOOL)isRussiaCountry {
    if ([ZFToString(self.region_id) isEqualToString:@"32"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isRussiaCountryID:(NSString *)regionId {
    if ([ZFToString(regionId) isEqualToString:@"32"]) {
        return YES;
    }
    return NO;
}
@end

//
//  ZFAddressLibraryStateModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressLibraryStateModel.h"
#import "ZFAddressLibraryManager.h"
#import "YWCFunctionTool.h"

@implementation ZFAddressLibraryStateModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"idx"       :@"id",
             };
}

- (void)handleSelfKey {
    if (ZFIsEmptyString(self.k)) {
        NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:self.n];
        self.k = firstCharactor;
    }
}

- (void)handleSectionData {
    
    [self handleSelfKey];
    
    if (ZFJudgeNSArray(self.sectionKeys)) {
        if (self.sectionKeys.count > 0) {
            return;
        }
    }
    self.sectionCityDic = [[NSMutableDictionary alloc] init];
    
    [self.cityList enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:obj.n];
        obj.k = firstCharactor;
        
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
@end

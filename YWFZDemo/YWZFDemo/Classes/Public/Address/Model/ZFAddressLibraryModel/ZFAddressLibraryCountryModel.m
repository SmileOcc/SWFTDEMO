//
//  ZFAddressLibraryCountryModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressLibraryCountryModel.h"
#import "ZFAddressLibraryManager.h"
#import "YWCFunctionTool.h"

@implementation ZFAddressLibraryCountryModel

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
    
    self.sectionProvinceDic = [[NSMutableDictionary alloc] init];
    
    [self.provinceList enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:obj.n];
        obj.k = firstCharactor;
        
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
@end

//
//  ZFAddressLibraryCityModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressLibraryCityModel.h"
#import "ZFAddressLibraryManager.h"
#import "YWCFunctionTool.h"

@implementation ZFAddressLibraryCityModel

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
    self.sectionVillageDic = [[NSMutableDictionary alloc] init];
    
    [self.town_list enumerateObjectsUsingBlock:^(ZFAddressLibraryTownModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:ZFToString(obj.n)];
        obj.k = firstCharactor;
        
        NSMutableArray *arr;
        if ([[self.sectionVillageDic allKeys] containsObject:firstCharactor]) {
            arr = [self.sectionVillageDic objectForKey:firstCharactor];
            if (arr) {
                [arr addObject:obj];
                [self.sectionVillageDic setObject:arr forKey:firstCharactor];
            } else {
                arr = [[NSMutableArray alloc] init];
                [arr addObject:obj];
                [self.sectionVillageDic setObject:arr forKey:firstCharactor];
            }
        } else {
            arr = [[NSMutableArray alloc] init];
            [arr addObject:obj];
            [self.sectionVillageDic setObject:arr forKey:firstCharactor];
        }
    }];
    
    // allKey排序
    
    NSMutableArray *groupTempArray= [NSMutableArray arrayWithArray:[[self.sectionVillageDic allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    self.sectionKeys = groupTempArray;
}

- (NSArray *)sectionDatasForKey:(NSString *)sectionKey {
    NSArray *sectionDatasArray = [self.sectionVillageDic objectForKey:ZFToString(sectionKey)];
    if (ZFJudgeNSArray(sectionDatasArray)) {
        return sectionDatasArray;
    }
    return @[];
}
@end

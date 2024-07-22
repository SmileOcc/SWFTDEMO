//
//  ZFAddressLibraryTownModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressLibraryTownModel.h"
#import "ZFAddressLibraryManager.h"
#import "YWCFunctionTool.h"

@implementation ZFAddressLibraryTownModel
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

@end

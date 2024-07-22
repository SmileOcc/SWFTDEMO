//
//  ZFBTSModel.m
//  ZZZZZ
//
//  Created by YW on 2019/3/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBTSModel.h"
#import <YYModel/YYModel.h>
#import "YWCFunctionTool.h"

@implementation ZFBTSModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init]; return [self yy_modelInitWithCoder:aDecoder];
}

- (NSDictionary *)getBtsParams {
    return @{
             @"plancode"    : ZFToString(self.plancode),
             @"policy"      : ZFToString(self.policy)
             };
}

- (BOOL)isReallyBTSModel {
    if (ZFIsEmptyString(self.bucketid) || ZFIsEmptyString(self.planid) || ZFIsEmptyString(self.plancode) || ZFIsEmptyString(self.policy) || ZFIsEmptyString(self.versionid)) {
        return NO;
    }
    return YES;
}
@end

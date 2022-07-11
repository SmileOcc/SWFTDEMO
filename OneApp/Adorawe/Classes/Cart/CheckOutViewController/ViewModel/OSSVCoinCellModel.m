//
//  OSSVCoinCellModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCoinCellModel.h"

@implementation OSSVCoinCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)setCoinModel:(OSSVCoinModel *)coinModel {
    _coinModel = coinModel;
}
#pragma mark - protocol
+(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

@end

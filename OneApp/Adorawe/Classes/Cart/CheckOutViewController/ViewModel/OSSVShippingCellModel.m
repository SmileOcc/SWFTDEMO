//
//  OSSVShippingCellModel.m
// XStarlinkProject
//
//  Created by fan wang on 2021/8/4.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVShippingCellModel.h"

@implementation OSSVShippingCellModel

@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

- (NSString *)cellIdentifier {
    return @"OSSVShippingCellModel";
}

+ (NSString *)cellIdentifier {
    return @"OSSVShippingCellModel";
}

@end

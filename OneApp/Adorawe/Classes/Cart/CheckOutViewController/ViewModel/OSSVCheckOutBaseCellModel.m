//
//  OSSVCheckOutBaseCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckOutBaseCellModel.h"

@implementation OSSVCheckOutBaseCellModel
@synthesize showSeparatorStyle = _showSeparatorStyle;
@synthesize indexPath = _indexPath;

+(NSString *)cellIdentifier {
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier {
    return NSStringFromClass(self.class);
}

@end

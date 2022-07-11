//
//  OSSVTotalDetailCellModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTotalDetailCellModel.h"

@implementation OSSVTotalDetailCellModel
@synthesize indexPath = _indexPath;
@synthesize showSeparatorStyle = _showSeparatorStyle;

-(instancetype)init{
    self = [super init];
    
    if (self) {
        self.showSeparatorStyle = NO;
    }
    return self;
}

-(NSString *)title{
    if (_title) {
        return _title;
    }
    return STLLocalizedString_(@"test",nil);
}

- (NSAttributedString *)value{
    if (_value) {
        return _value;
    }
    return [[NSAttributedString alloc] initWithString:STLLocalizedString_(@"test",nil) attributes:nil];
}

#pragma mark - protocol

+(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

-(NSString *)cellIdentifier{
    return NSStringFromClass(self.class);
}

@end

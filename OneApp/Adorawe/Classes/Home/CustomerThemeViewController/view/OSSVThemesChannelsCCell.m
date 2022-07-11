//
//  OSSVThemesChannelsCCell.m
// OSSVThemesChannelsCCell
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVThemesChannelsCCell.h"

@implementation OSSVThemesChannelsCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return self;
}

@end

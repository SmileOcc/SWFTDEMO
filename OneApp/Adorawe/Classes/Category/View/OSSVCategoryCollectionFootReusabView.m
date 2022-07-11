//
//  OSSVCategoryCollectionFootReusabView.m
// XStarlinkProject
//
//  Created by odd on 2020/8/6.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryCollectionFootReusabView.h"

@implementation OSSVCategoryCollectionFootReusabView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors col_F5F5F5];
        
        self.whiteSeparateView = [[UIView alloc] initWithFrame:CGRectZero];
        self.whiteSeparateView.backgroundColor = [OSSVThemesColors stlWhiteColor];

        [self addSubview:self.whiteSeparateView];

        [self.whiteSeparateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self);
            make.height.mas_equalTo(12);
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.whiteSeparateView stlAddCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
}
@end


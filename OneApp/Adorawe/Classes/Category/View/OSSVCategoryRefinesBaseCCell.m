//
//  OSSVCategoryRefinesBaseCCell.m
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesBaseCCell.h"

@implementation OSSVCategoryRefinesBaseCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.mainView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        [self.contentView addSubview:self.mainView];

        [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}
- (UIView *)mainView {
    if(!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        _mainView.layer.cornerRadius = 14;
        _mainView.layer.masksToBounds = YES;
        _mainView.layer.borderWidth = 1;
        _mainView.layer.borderColor = [OSSVThemesColors stlClearColor].CGColor;
    }
    return _mainView;
}

- (void)hightLightState:(BOOL)isHight {
    
    NSArray *subviews = self.mainView.subviews;
    for (UIView *subView in subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *subLabel = (UILabel *)subView;
            subLabel.textColor = isHight ? [OSSVThemesColors col_0D0D0D] : [OSSVThemesColors col_666666];
        }
    }
    self.mainView.backgroundColor = isHight ? [OSSVThemesColors stlWhiteColor] : [OSSVThemesColors col_F5F5F5];
    self.mainView.layer.borderColor = isHight ? [OSSVThemesColors col_0D0D0D].CGColor : [OSSVThemesColors stlClearColor].CGColor;
}

@end

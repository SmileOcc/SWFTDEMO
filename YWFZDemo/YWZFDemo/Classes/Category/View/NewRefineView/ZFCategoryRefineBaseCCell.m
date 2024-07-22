//
//  ZFCategoryRefineBaseCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefineBaseCCell.h"
#import "ZFThemeManager.h"

@implementation ZFCategoryRefineBaseCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.mainView.backgroundColor = ZFC0xF2F2F2();
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
        _mainView.backgroundColor = ZFC0xF2F2F2();
        _mainView.layer.cornerRadius = 2;
        _mainView.layer.masksToBounds = YES;
        _mainView.layer.borderWidth = 0.5;
        _mainView.layer.borderColor = ZFCClearColor().CGColor;
    }
    return _mainView;
}

- (void)hightLightState:(BOOL)isHight {
    
    NSArray *subviews = self.mainView.subviews;
    for (UIView *subView in subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *subLabel = (UILabel *)subView;
            subLabel.textColor = isHight ? ZFC0x2D2D2D() : ZFC0x666666();
        }
    }
    self.mainView.backgroundColor = isHight ? ZFC0xFFFFFF() : ZFC0xF2F2F2();
    self.mainView.layer.borderColor = isHight ? ZFC0x2D2D2D().CGColor : ZFCClearColor().CGColor;
}
@end

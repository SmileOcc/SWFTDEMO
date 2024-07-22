//
//  ZFAddressTableHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressTableHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFAddressTableHeaderView()

@property (nonatomic, strong) UILabel               *titleLabel;

@end

@implementation ZFAddressTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame tip:(NSString *)tipText {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.text = ZFToString(tipText);
        [self addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(8);
            make.leading.mas_equalTo(self.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
        }];
    }
    return self;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.preferredMaxLayoutWidth = KScreenWidth - 32;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = ZFC0x999999();
        [_titleLabel convertTextAlignmentWithARLanguage];
    }
    return _titleLabel;
}

@end

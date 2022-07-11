//
//  YXEditStockHeaderView.m
//  uSmartOversea
//
//  Created by ellison on 2018/10/19.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXEditSecuHeaderView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@implementation YXEditSecuHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews {
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [QMUITheme popSeparatorLineColor];
    [self addSubview:bottomLine];
    
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];

    UILabel *symbolLabel = [[UILabel alloc] init];
    symbolLabel.text = [YXLanguageUtility kLangWithKey:@"stockST_name"];
    symbolLabel.textColor = [QMUITheme textColorLevel3];
    symbolLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:symbolLabel];
    
    [symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(18);
        make.centerY.equalTo(self);
    }];
    
    UILabel *sortLabel = [[UILabel alloc] init];
    sortLabel.text = [YXLanguageUtility kLangWithKey:@"sort"];
    sortLabel.textColor = [QMUITheme textColorLevel3];
    sortLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:sortLabel];
    
    [sortLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-40);
        make.centerY.equalTo(self);
    }];
    
    UILabel *stickLabel = [[UILabel alloc] init];
    stickLabel.text = [YXLanguageUtility kLangWithKey:@"news_label_top"];
    stickLabel.textColor = [QMUITheme textColorLevel3];
    stickLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:stickLabel];
    
    [stickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-122);
        make.centerY.equalTo(self);
    }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

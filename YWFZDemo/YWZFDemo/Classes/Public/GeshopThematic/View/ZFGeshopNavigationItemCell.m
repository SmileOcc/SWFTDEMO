//
//  ZFGeshopNavigationItemCell.m
//  ZZZZZ
//
//  Created by YW on 2019/9/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopNavigationItemCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIColor+ExTypeChange.h"
#import "YWCFunctionTool.h"

@interface ZFGeshopNavigationItemCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ZFGeshopNavigationItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        //styleModel.padding_left : V5.6.0写死12
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        //styleModel.padding_right
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
}

#pragma mark - setter

- (void)setListModel:(ZFGeshopSectionListModel *)listModel {
    _listModel = listModel;
    self.titleLabel.text = ZFToString(listModel.component_title);
}

- (void)setStyleModel:(ZFGeshopComponentStyleModel *)styleModel {
    _styleModel = styleModel;
    
    NSString *textColor = styleModel.text_color;
    NSString *bgColor = styleModel.bg_color;
    if (self.listModel.isActiveNavigatorItem) {
        textColor = styleModel.active_text_color;
        bgColor = styleModel.active_bg_color;
    }
    self.contentView.backgroundColor = [UIColor colorWithAlphaHexColor:bgColor defaultColor:ZFCOLOR(255, 138, 138, 1)];
    
    NSInteger text_size = (styleModel.text_size > 0) ? styleModel.text_size : 14;
    self.titleLabel.font = [UIFont systemFontOfSize:text_size];
    self.titleLabel.textColor = [UIColor colorWithAlphaHexColor:textColor defaultColor:ZFCOLOR_WHITE];
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end

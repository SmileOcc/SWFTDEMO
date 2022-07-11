//
//  YXSearchCell.m
//  YouXinZhengQuan
//
//  Created by rrd on 2018/7/30.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXSearchCell.h"
#import "YXSecu.h"
//#import "YXSearchHistoryManager.h"
#import "YXSecuNameLabel.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXSearchCell ()

@property (nonatomic, strong) UIImageView *marketIconView;
@property (nonatomic, strong) YXSecuNameLabel *nameLabel;
@property (nonatomic, strong) UILabel *symbolLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) YXMarketIconLabel *marketIconLabel;
@property (nonatomic, strong) id<YXSecuProtocol> model;

@end

@implementation YXSearchCell
@dynamic model;

- (void)initialUI {
    [super initialUI];
    self.backgroundColor = QMUITheme.foregroundColor;
    
    self.searchWord = @"";
    
    self.qmui_selectedBackgroundColor = QMUITheme.backgroundColor;
    
//    [self.contentView addSubview:self.marketIconView];
    [self.contentView addSubview:self.marketIconLabel];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.symbolLabel];
    [self.contentView addSubview:self.addButton];
    [self.contentView addSubview:self.lineView];
    
    [self.marketIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.top.equalTo(self.contentView).offset(12);
        make.width.mas_equalTo(17);
        make.height.mas_equalTo(13);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(33);
        make.centerY.equalTo(self.marketIconLabel).offset(0);
        make.height.mas_equalTo(22);
        make.right.equalTo(self.addButton.mas_left).offset(-50);
    }];
    
    
    [self.symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel).offset(0);
        make.top.equalTo(self.nameLabel.mas_bottom);
        
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.height.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(50);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
}

- (void)refreshUI {
    
//    self.marketIconView.image = [UIImage imageNamed:self.model.secuId.marketIcon];
    self.marketIconLabel.market = self.model.secuId.marketIcon;
    
    NSString *name = self.model.name;
    NSRange nameRange = [name rangeOfString:self.searchWord options:NSCaseInsensitiveSearch];
    
    self.nameLabel.text = self.model.name;
    if (nameRange.location != NSNotFound) {
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:name attributes:@{NSForegroundColorAttributeName: self.nameLabel.textColor, NSFontAttributeName: self.nameLabel.font}];
        [attributeString setAttributes:@{NSForegroundColorAttributeName: QMUITheme.themeTextColor} range:nameRange];
        self.nameLabel.attributedText = attributeString;
    } else {
        self.nameLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:name attributes:@{NSForegroundColorAttributeName: [QMUITheme textColorLevel1], NSFontAttributeName: self.nameLabel.font}];;
    }
    
    NSString *symbol = self.model.symbol;
    NSRange symbolRange = [symbol rangeOfString:self.searchWord options:NSCaseInsensitiveSearch];
    
    if (symbolRange.location != NSNotFound) {
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:symbol attributes:@{NSForegroundColorAttributeName:  [QMUITheme textColorLevel2], NSFontAttributeName: [UIFont systemFontOfSize:12]}];
        [attributeString setAttributes:@{NSForegroundColorAttributeName: QMUITheme.themeTextColor} range:symbolRange];
        self.symbolLabel.attributedText = attributeString;
    } else {
        self.symbolLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:symbol attributes:@{NSForegroundColorAttributeName: [QMUITheme textColorLevel2], NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    }
}

#pragma mark - setter
- (void)setAdded:(BOOL)added {
    _added = added;
    
    self.addButton.selected = added;
}

#pragma mark - getter
- (UIImageView *)marketIconView {
    if (_marketIconView == nil) {
        _marketIconView = [[UIImageView alloc] init];
    }
    return _marketIconView;
}

- (YXSecuNameLabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[YXSecuNameLabel alloc] init];
        _nameLabel.textColor = [QMUITheme textColorLevel1];
    }
    return _nameLabel;
}

- (YXMarketIconLabel *)marketIconLabel {
    if (_marketIconLabel == nil) {
        _marketIconLabel = [[YXMarketIconLabel alloc] init];
    }
    return _marketIconLabel;
}

- (UILabel *)symbolLabel {
    if (_symbolLabel == nil) {
        _symbolLabel = [[UILabel alloc] init];
        _symbolLabel.textColor = [QMUITheme textColorLevel2];
        _symbolLabel.font = [UIFont systemFontOfSize:12];
    }
    return _symbolLabel;
}

- (UIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"yx_v2_like"] target:self action:@selector(addButtonAction)];
        [_addButton setImage:[UIImage imageNamed:@"yx_v2_like selected"] forState:UIControlStateSelected];
    }
    return _addButton;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = QMUITheme.separatorLineColor;
    }
    return _lineView;
}

#pragma mark - action
- (void)addButtonAction {
    self.added = !self.addButton.selected;
}

- (void)updateAddButtonSelected:(BOOL)selected {
    self.addButton.selected = selected;
    _added = selected;
}

@end

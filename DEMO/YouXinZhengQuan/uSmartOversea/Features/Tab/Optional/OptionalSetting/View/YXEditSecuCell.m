//
//  YXEditStockCell.m
//  uSmartOversea
//
//  Created by ellison on 2018/10/19.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXEditSecuCell.h"
#import "YXSecuGroupManager.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXEditSecuCell ()

//@property (nonatomic, strong) UIImageView *marketIconView;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *stickButton;


@end

@implementation YXEditSecuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    self.backgroundColor = [QMUITheme popupLayerColor];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.symbolLabel];
    [self.contentView addSubview:self.marketLabel];
//    [self.contentView addSubview:self.lineView];
    
    [self.contentView addSubview:self.stickButton];
    [self.contentView addSubview:self.checkButton];
    
    [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.left.height.top.equalTo(self);
    }];
    
    [self.stickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-76);
        make.top.height.equalTo(self);
        make.width.mas_equalTo(40);
    }];
    
    
    [self.symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(47);
        make.top.equalTo(self).offset(10);
        make.height.mas_equalTo(22);
        
    }];
    
    [self.marketLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.symbolLabel);
        make.top.equalTo(self.symbolLabel.mas_bottom).offset(2);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.marketLabel.mas_right).offset(2);
        make.centerY.equalTo(self.marketLabel);
        make.right.lessThanOrEqualTo(self.stickButton.mas_left).offset(-12);
    }];
    
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.contentView);
//        make.left.equalTo(self).offset(8);
//        make.right.equalTo(self).offset(-8);
//        make.height.mas_equalTo(1);
//    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated: YES];
    
    if (editing) {
        for (UIView * view in self.subviews) {
            if ([NSStringFromClass([view class]) rangeOfString: @"Reorder"].location != NSNotFound) {
                for (UIView * subview in view.subviews) {
                    if ([subview isKindOfClass: [UIImageView class]]) {
                        ((UIImageView *)subview).image = [UIImage imageNamed: @"edit_rank"];
                        ((UIImageView *)subview).contentMode = UIViewContentModeCenter;
                    }
                }
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self).offset(-16);
                    make.top.height.equalTo(self);
                    make.width.mas_equalTo(40);
                }];
            }
        }
    }
}

#pragma mark - actions

- (void)checkButtonAction {
    self.checked = !self.checked;
    
    if (self.onClickCheck) {
        self.onClickCheck();
    }
}

- (void)stickButtonAction {
    if (self.onClickStick) {
        self.onClickStick();
    }
}

#pragma mark - setter
- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
    
    if (indexPath.row == 0) {
        self.stickButton.hidden = YES;
    } else {
        self.stickButton.hidden = NO;
    }
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    self.checkButton.selected = checked;
}

#pragma mark - getter
//- (UIImageView *)marketIconView {
//    if (_marketIconView == nil) {
//        _marketIconView = [[UIImageView alloc] init];
//    }
//    return _marketIconView;
//}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [QMUITheme textColorLevel3];
        _nameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    }
    return _nameLabel;
}

- (UILabel *)symbolLabel {
    if (_symbolLabel == nil) {
        _symbolLabel = [[UILabel alloc] init];
        _symbolLabel.textColor = [QMUITheme textColorLevel1];
        _symbolLabel.font = [UIFont systemFontOfSize:16];
    }
    return _symbolLabel;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [QMUITheme popSeparatorLineColor];
    }
    return _lineView;
}

- (UIButton *)checkButton {
    if (_checkButton == nil) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkButton setImage:[UIImage imageNamed:@"edit_uncheck"] forState: UIControlStateNormal];
        [_checkButton setImage:[UIImage imageNamed:@"edit_checked"] forState: UIControlStateSelected];
        [_checkButton addTarget:self action:@selector(checkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

- (UIButton *)stickButton {
    if (_stickButton == nil) {
        _stickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stickButton setImage:[UIImage imageNamed:@"edit_stick"] forState:UIControlStateNormal];
        [_stickButton addTarget:self action:@selector(stickButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stickButton;
}

- (YXMarketIconLabel *)marketLabel {
    if (!_marketLabel) {
        _marketLabel = [[YXMarketIconLabel alloc] init];
    }
    return _marketLabel;
}

@end

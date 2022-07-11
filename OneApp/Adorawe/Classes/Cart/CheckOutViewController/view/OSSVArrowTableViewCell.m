//
//  OSSVArrowTableViewCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVArrowTableViewCell.h"
#import "YYLabel.h"
#import "Adorawe-Swift.h"

@interface OSSVArrowTableViewCell ()
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) YYLabel *detailLable;

@property (nonatomic, strong) UILabel  *allCountLabel;
@property (nonatomic, strong) UILabel  *noShippedLabel;
@property (nonatomic, strong) UIButton *selectButton;//选择金币的button

@property (weak,nonatomic) UILabel *titleLbl;
@property (nonatomic, strong) BigClickAreaButton *coinExplainButton; //金币？ 按钮
@end

@implementation OSSVArrowTableViewCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.arrowImageView];
        [contentView addSubview:self.detailLable];
        [contentView addSubview:self.allCountLabel];
        [contentView addSubview:self.noShippedLabel];
        [contentView addSubview:self.selectButton];
        [contentView addSubview:self.coinExplainButton];
        
        UILabel *title = [[UILabel alloc] init];
        
        [contentView addSubview:title];
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading).offset(14);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        self.titleLbl = title;
        _titleLbl.font = [UIFont systemFontOfSize:14];
        _titleLbl.textColor = OSSVThemesColors.col_0D0D0D;
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(contentView).mas_offset(-CheckOutCellLeftPadding);
            make.centerY.mas_equalTo(contentView);
            make.width.height.mas_offset(24);
        }];
    
        
        [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(contentView).mas_offset(-CheckOutCellLeftPadding);
            make.centerY.mas_equalTo(contentView);
            make.width.height.mas_offset(24);
        }];

        [self.detailLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-36);
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.centerY.mas_equalTo(self.selectButton.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
        [self.coinExplainButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLbl.mas_trailing).offset(4);
            make.width.height.mas_offset(24);
            make.centerY.mas_equalTo(self.titleLbl.mas_centerY);
        }];

        [self.allCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(contentView.mas_centerY);
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading);
        }];
        
        [self.noShippedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentView.mas_centerY);
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading);
        }];
        
        if (APP_TYPE != 3) {
            [self addBottomLine:CellSeparatorStyle_LeftRightInset];
        }
        
        [self addContentViewTap:@selector(didClickContentView)];
    }
    return self;
}

#pragma mark - target

-(void)didClickContentView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_ArrowDidClick:)]) {
        [self.delegate STL_ArrowDidClick:self.model];
    }
}

-(void)explainButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_ArrowDidClickQuestionMarkButton:)]) {
        [self.delegate STL_ArrowDidClickQuestionMarkButton:self.model];
    }
}

- (void)coinExplainButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_coinButtonDidClickQuestionMarkButton:)]) {
        [self.delegate STL_coinButtonDidClickQuestionMarkButton:self.model];
    }
}

///点击金币cell的
- (void)selectCoinPay:(UIButton *)sender {
    
    if ([self.model isKindOfClass:[OSSVArrowCellModel class]]) {
        OSSVArrowCellModel *currentModel = (OSSVArrowCellModel *)self.model;
        
        BOOL isSelect = currentModel.isUserCoin;
        if (!isSelect) {
            [self.selectButton setImage:[UIImage imageNamed:@"pay_Selected"] forState:UIControlStateNormal];
            [self.selectButton setImage:[UIImage imageNamed:@"pay_Selected"] forState:UIControlStateHighlighted];
        } else {
            [self.selectButton setImage:[UIImage imageNamed:@"pay_UnSelect"] forState:UIControlStateNormal];
            [self.selectButton setImage:[UIImage imageNamed:@"pay_UnSelect"] forState:UIControlStateHighlighted];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(STL_coinSelectPayDidClickButton:)]) {
            [self.delegate STL_coinSelectPayDidClickButton:!isSelect];
        }
    }
}
#pragma mark - setter and getter

-(void)setModel:(OSSVArrowCellModel *)model
{
    _model = model;
    
    self.userInteractionEnabled = model.userInteractionEnabled;
    self.arrowImageView.hidden = !model.userInteractionEnabled;

    self.allCountLabel.hidden = YES;
    self.noShippedLabel.hidden = YES;
    
    self.titleLbl.text = model.titleContent;
    
    switch (model.cellType) {
        case ArrowCellTypeNormal:{
            self.detailLable.hidden = NO;
            self.selectButton.hidden = YES;
            self.coinExplainButton.hidden = YES;
            self.detailLable.attributedText = model.detailContent;
        }
            break;
        case ArrowCellTypeDetail:{//商品列表
            self.coinExplainButton.hidden = YES;
            [self.detailLable mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-36);
            }];
            _titleLbl.font = [UIFont boldSystemFontOfSize:14];
            self.detailLable.hidden = NO;
            self.selectButton.hidden = YES;
            if (model.subTip) {
                
                self.allCountLabel.hidden = NO;
                self.noShippedLabel.hidden = NO;
                self.detailLable.hidden = YES;

                self.allCountLabel.attributedText = model.detailContent;
                self.noShippedLabel.attributedText = model.subTip;
                self.detailTextLabel.attributedText = nil;
            } else {
                self.detailLable.attributedText = model.detailContent;
                self.allCountLabel.attributedText =nil;
                self.noShippedLabel.attributedText = nil;
            }
            
        }
            break;
        case ArrowCellTypeExplain_Detail:{//优惠券
            self.coinExplainButton.hidden = YES;
            self.selectButton.hidden = YES;
            self.detailLable.hidden = NO;
            self.detailLable.attributedText = model.detailContent;
            [self.detailLable mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-36);
            }];
        }
            break;
        case ArrowCellTypeExplain_Button:{//金币
            self.selectButton.enabled = !model.isDisableButton;
            self.selectButton.hidden = NO;
            self.arrowImageView.hidden = YES;
            self.detailLable.hidden = NO;
            [self isHiddenBottomLine:YES];
            
            self.coinExplainButton.hidden = STLToString(model.checkOutModel.rebate_activity_info).length;
            
            
            if (model.isDisableButton) {
                
                NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:STLToString(model.coinSave)];
                attStr.yy_font = [UIFont systemFontOfSize:14];
                attStr.yy_color = OSSVThemesColors.col_6C6C6C;
                self.detailLable.attributedText = attStr;
                
                [self.detailLable mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-14);
                }];
                [self.selectButton setImage:[UIImage imageNamed:@"pay_Disable"] forState:UIControlStateNormal];
                [self.selectButton setImage:[UIImage imageNamed:@"pay_Disable"] forState:UIControlStateHighlighted];
                self.selectButton.hidden = true;
                //更新约束
            } else {
                [self.detailLable mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-36);
                }];
                self.selectButton.hidden = false;
                [self.selectButton setImage:[UIImage imageNamed:@"pay_UnSelect"] forState:UIControlStateNormal];
                [self.selectButton setImage:[UIImage imageNamed:@"pay_UnSelect"] forState:UIControlStateHighlighted];

                if (model.isUserCoin) {
                    [self.selectButton setImage:[UIImage imageNamed:@"pay_Selected"] forState:UIControlStateNormal];
                    [self.selectButton setImage:[UIImage imageNamed:@"pay_Selected"] forState:UIControlStateHighlighted];
                }
                NSString *coinSave = model.coinSave;
                NSString *coinTitle1 = model.coinTitle1;
                NSString *coinTitle2 = model.coinTitle2;
                NSString *coinCount = model.coinCount;
                
                if (model.isUserCoin) {
                    NSString *format = OSSVSystemsConfigsUtils.isRightToLeftShow && !coinSave.isContainArabic ? @"%@ -" : @"- %@";
                    NSString *totalStr = [NSString stringWithFormat:format,coinSave];
                    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:totalStr];
                    [attStr addAttribute:NSForegroundColorAttributeName value: APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : OSSVThemesColors.col_B62B21 range:NSMakeRange(0, totalStr.length)];
                    attStr.yy_font = [UIFont systemFontOfSize:14];
                    self.detailLable.attributedText = attStr;
                }else{
                    NSString *totalStr = [NSString stringWithFormat:@"%@ %@ %@ %@", coinTitle1,coinCount,coinTitle2,coinSave];
                    
                    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:totalStr];
                    [attStr addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_666666 range:NSMakeRange(0, coinTitle1.length +1 + coinCount.length + 1 + coinTitle2.length + 1)];
                    [attStr addAttribute:NSForegroundColorAttributeName value: APP_TYPE == 3 ? OSSVThemesColors.col_9F5123 : OSSVThemesColors.col_B62B21 range:NSMakeRange(coinTitle1.length + 1 +coinCount.length + 1 +coinTitle2.length + 1, coinSave.length)];
                    attStr.yy_font = [UIFont systemFontOfSize:14];
                    self.detailLable.attributedText = attStr;
                }
               
                self.detailLable.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;

            }
        }
        default:
            break;
    }
    self.detailLable.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ?  NSTextAlignmentLeft : NSTextAlignmentRight;
}


- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"address_arr_right"];
            imageView.contentMode = UIViewContentModeCenter;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                imageView.transform = CGAffineTransformMakeRotation(M_PI);
            }
            imageView;
        });
    }
    return _arrowImageView;
}

-(YYLabel *)detailLable
{
    if (!_detailLable) {
        _detailLable = ({
            YYLabel *label = [[YYLabel alloc] init];
//            label.text = STLLocalizedString_(@"test", nil);
            label.textContainerInset = UIEdgeInsetsMake(0, 4, 0, 4);
            label.textColor = OSSVThemesColors.col_666666;
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _detailLable;
}


////商品数量时
-(UILabel *)allCountLabel
{
    if (!_allCountLabel) {
        _allCountLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [OSSVThemesColors col_666666];
            label.font = [UIFont systemFontOfSize:12];
            label.hidden = YES;
            label;
        });
    }
    return _allCountLabel;
}

-(UILabel *)noShippedLabel
{
    if (!_noShippedLabel) {
        _noShippedLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = OSSVThemesColors.col_B62B21;
            label.font = [UIFont systemFontOfSize:11];
            label.hidden = YES;
            label.textAlignment = NSTextAlignmentRight;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentLeft;
            }
            label;
        });
    }
    return _noShippedLabel;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.selected = NO;
        [_selectButton setImage:[UIImage imageNamed:@"pay_Disable"] forState:UIControlStateNormal];
        [self.selectButton setImage:[UIImage imageNamed:@"pay_Disable"] forState:UIControlStateHighlighted];
        [_selectButton addTarget:self action:@selector(selectCoinPay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    _titleLbl.font = [UIFont systemFontOfSize:14];
    _titleLbl.textColor = OSSVThemesColors.col_0D0D0D;
}

-(BigClickAreaButton *)coinExplainButton
{
    if (!_coinExplainButton) {
        _coinExplainButton = ({
            BigClickAreaButton *button = [[BigClickAreaButton alloc] init];
            button.clickAreaRadious = 30;
            [button setImage:[UIImage imageNamed:@"icon_help_24"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(coinExplainButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _coinExplainButton;
}


@end

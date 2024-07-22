//
//  ZFAcceptPaymentTipsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/5/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAcceptPaymentTipsCell.h"
#import "ZFLocalizationString.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import <Masonry/Masonry.h>

@interface ZFAcceptPaymentTipsCell ()

@property (nonatomic, strong) UILabel *acceptTitleLabel;
@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, strong) NSMutableArray *iconList;

@end

@implementation ZFAcceptPaymentTipsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *contentView = self.contentView;
        
        [contentView addSubview:self.acceptTitleLabel];
        [contentView addSubview:self.iconView];
 
        [self.acceptTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentView).mas_offset(12);
            make.leading.mas_equalTo(contentView).mas_offset(16);
        }];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.acceptTitleLabel.mas_bottom).mas_offset(9);
            make.bottom.mas_equalTo(contentView.mas_bottom).mas_offset(-12);
            make.leading.mas_equalTo(self.acceptTitleLabel);
            make.trailing.mas_equalTo(contentView.mas_trailing);
        }];

        //添加icon子视图
        NSArray *iconList = @[
                              [UIImage imageNamed:@"ic_pay_visa_small"],
                              [UIImage imageNamed:@"ic_pay_mastercard_small"],
                              [UIImage imageNamed:@"ic_pay_american_express_small"],
                              [UIImage imageNamed:@"ic_pay_discover_small"],
                              [UIImage imageNamed:@"ic_pay_cartebancaire_small"],
                              [UIImage imageNamed:@"ic_pay_diners_club_small"],
                              [UIImage imageNamed:@"ic_pay_maestro_small"],
                              [UIImage imageNamed:@"ic_pay_elo_small"],
                              [UIImage imageNamed:@"ic_pay_hipercard_small"],
                              [UIImage imageNamed:@"ic_pay_cslo_mada_small"],
                              [UIImage imageNamed:@"ic_pay_jcb_small"],
                              ];
        
        NSInteger count = iconList.count;
        
        __block CGFloat currentMaxY = 0;
        UIView *lastView = nil;
        CGFloat leftPadding = 4;
        CGFloat topPadding = 4;
        for (int i = 0; i < count; i++) {
            UIImageView *payIcon = [[UIImageView alloc] init];
            payIcon.image = iconList[i];
            [self.iconView addSubview:payIcon];
            CGSize size = CGSizeMake(24, 16);
            if (i == 0) {
                [payIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(size);
                    make.leading.mas_equalTo(self.iconView.mas_leading);
                    make.top.mas_equalTo(self.iconView.mas_top);
                }];
            } else {
                lastView = self.iconView.subviews[i - 1];
                BOOL need = currentMaxY > (KScreenWidth - 32);
                [payIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(size);
                    if (need) {
                        currentMaxY = size.width + (leftPadding * i);
                        make.top.mas_equalTo(lastView.mas_bottom).mas_offset(topPadding);
                        make.leading.mas_equalTo(self.iconView.mas_leading);
                    } else {
                        make.leading.mas_equalTo(lastView.mas_trailing).mas_offset(leftPadding);
                        make.top.mas_equalTo(lastView.mas_top);
                    }
                    if (i == count - 1) {
                        make.bottom.mas_equalTo(self.iconView.mas_bottom);
                    }
                }];
            }
        }
        if (count == 1) {
            [self.iconView.subviews.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.iconView.mas_bottom);
            }];
        }
    }
    return self;
}

+ (NSString *)queryReuseIdentifier
{
    return NSStringFromClass(self.class);
}

#pragma mark - Property Method

-(UILabel *)acceptTitleLabel
{
    if (!_acceptTitleLabel) {
        _acceptTitleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = ZFLocalizedString(@"OrderInfo_following_credit_cards", nil);
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _acceptTitleLabel;
}

- (UIView *)iconView
{
    if (!_iconView) {
        _iconView = ({
            UIView *view = [[UIView alloc] init];
            view;
        });
    }
    return _iconView;
}


@end

//
//  ZFAccountPushTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/8/16.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFAccountPushTableViewCell.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFAccountPushTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *pushEnableSwitch;
@property (nonatomic, strong) UILabel *desTitleLabel;

@end

@implementation ZFAccountPushTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.titleLabel];
        [self addSubview:self.pushEnableSwitch];
        [self addSubview:self.desTitleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self).mas_offset(16);
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self);
            make.height.mas_offset(48);
        }];
        
        [self.desTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
            make.top.bottom.mas_equalTo(self);
        }];
        
        [self.pushEnableSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
            make.centerY.mas_equalTo(self);
        }];
    }
    return self;
}

-(void)pushSwitchAction:(UISwitch *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(zfAccountPushTableViewCellDidClickSwitch:)]) {
        [self.delegate zfAccountPushTableViewCellDidClickSwitch:sender];
    }
}

#pragma mark - setter and getter

-(void)setSwitchEnable:(BOOL)switchEnable
{
    _switchEnable = switchEnable;
    
    if (_switchEnable) {
        self.desTitleLabel.hidden = NO;
        self.pushEnableSwitch.hidden = YES;
        self.desTitleLabel.text = ZFLocalizedString(@"Push_Enable", nil);
    }else{
        self.desTitleLabel.hidden = YES;
        self.pushEnableSwitch.hidden = NO;
        [self.pushEnableSwitch setOn:NO];
    }
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = ZFLocalizedString(@"Push_Notifications", nil);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
            label.font = [UIFont systemFontOfSize:16];
            label;
        });
    }
    return _titleLabel;
}

- (UISwitch *)pushEnableSwitch
{
    if (!_pushEnableSwitch) {
        _pushEnableSwitch = ({
            UISwitch *cellSwitch = [[UISwitch alloc] init];
            [cellSwitch addTarget:self action:@selector(pushSwitchAction:) forControlEvents:UIControlEventValueChanged];
            cellSwitch;
        });
    }
    return _pushEnableSwitch;
}

-(UILabel *)desTitleLabel
{
    if (!_desTitleLabel) {
        _desTitleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = ColorHex_Alpha(0x999999, 1.0);
            label.font = [UIFont systemFontOfSize:16];
            label;
        });
    }
    return _desTitleLabel;
}

@end

//
//  ZFUserInfoPhotoCell.m
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFUserInfoPhotoCell.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"

@implementation ZFUserInfoPhotoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.arrowImageView];
        [self.contentView addSubview:self.userImageView];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
    }
    return self;
}

- (void)setTypeModel:(ZFUserInfoTypeModel *)typeModel {
    self.typeLabel.text = ZFToString(typeModel.typeName);
    
}

- (void)setUserImageUrl:(NSString *)userImageUrl {
    _userImageUrl = userImageUrl;
    
    [self.userImageView  yy_setImageWithURL:[NSURL URLWithString:[AccountManager sharedManager].account.avatar]
    placeholder:[UIImage imageNamed:@"account_head"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.font = [UIFont systemFontOfSize:14];
        _typeLabel.textColor = ZFC0x2D2D2D();
    }
    return _typeLabel;
}

- (YYAnimatedImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _userImageView.image = [UIImage imageNamed:@"account_head"];
        _userImageView.layer.cornerRadius = 20;
        _userImageView.clipsToBounds = YES;
    }
    return _userImageView;
}
- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_arrow_right"]];
    }
    return _arrowImageView;
}
@end

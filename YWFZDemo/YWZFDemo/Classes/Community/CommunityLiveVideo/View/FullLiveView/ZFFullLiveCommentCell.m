//
//  ZFFullLiveCommentCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveCommentCell.h"

@interface ZFFullLiveCommentCell ()

@end

@implementation ZFFullLiveCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.messageLabel];
        
        [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.top.mas_equalTo(self.contentView.mas_top).offset(8);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.avatar.mas_trailing).offset(6);
            make.bottom.mas_equalTo(self.avatar.mas_centerY).offset(-2);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        }];
        
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.nameLabel.mas_leading);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(5);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-8);
            make.height.mas_greaterThanOrEqualTo(20);
        }];
    }
    return self;
}

- (YYAnimatedImageView *)avatar {
    if (!_avatar) {
        _avatar = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _avatar.layer.cornerRadius = 16;
        _avatar.layer.masksToBounds = YES;
        //occ测试数据
        _avatar.backgroundColor = ZFCOLOR_RANDOM;
    }
    return _avatar;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = ZFC0x999999();
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nameLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textColor = ZFC0x2D2D2D();
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}

@end

//
//  ZFUserInfoTypeCell.m
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFUserInfoTypeCell.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "NSStringUtils.h"

@implementation ZFUserInfoTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.typeInfoLabel];
        [self.contentView addSubview:self.arrowImageView];
        [self.contentView addSubview:self.bottomLineView];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.typeInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)setTypeModel:(ZFUserInfoTypeModel *)typeModel {
    
    self.typeLabel.attributedText = [NSStringUtils firstAppendStartMark:ZFToString(typeModel.typeName) markColor:ZFC0xEE0024() isAppend:typeModel.isRequiredField];
    self.typeInfoLabel.text = ZFToString(typeModel.content);
    self.arrowImageView.hidden = !typeModel.isShowArrow;
    self.typeInfoLabel.textColor = typeModel.isShowArrow ? ZFC0x999999() : ZFC0xCCCCCC();
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.font = [UIFont systemFontOfSize:14];
        _typeLabel.textColor = ZFC0x2D2D2D();
    }
    return _typeLabel;
}
- (UILabel *)typeInfoLabel {
    if (!_typeInfoLabel) {
        _typeInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeInfoLabel.font = [UIFont systemFontOfSize:14];
        _typeInfoLabel.textColor = ZFC0x999999();
    }
    return _typeInfoLabel;
}


- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_arrow_right"]];
    }
    return _arrowImageView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ZFC0xDDDDDD();
    }
    return _bottomLineView;
}
@end

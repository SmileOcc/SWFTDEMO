//
//  ZFAddressCountryCityCell.m
//  ZZZZZ
//
//  Created by YW on 2019/1/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressCountryCityCell.h"
#import <Masonry/Masonry.h>
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIImage+ZFExtended.h"

@interface ZFAddressCountryCityCell()<ZFInitViewProtocol>

@end
@implementation ZFAddressCountryCityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Private Method

- (void)zfInitView {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectImageView];
    [self.contentView addSubview:self.bottomLine];
}

- (void)zfAutoLayoutView {
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.height.mas_equalTo(41);
    }];
    
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-15);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.height.mas_equalTo(MIN_PIXEL);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
}


#pragma mark - Property Method

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = ZFC0x2D2D2D();
    }
    return _nameLabel;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [UIImageView new];
        _selectImageView.image = [ZFImageWithName(@"refine_select") imageWithColor:ZFC0xFE5269()];
        _selectImageView.hidden = YES;
    }
    return _selectImageView;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [UIView new];
        _bottomLine.backgroundColor = ZFC0xDDDDDD();
    }
    return _bottomLine;
}
@end

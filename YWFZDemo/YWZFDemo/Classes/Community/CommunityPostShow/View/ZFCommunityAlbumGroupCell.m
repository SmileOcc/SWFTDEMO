//
//  ZFCommunityAlbumGroupCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityAlbumGroupCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

@implementation ZFCommunityAlbumGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


- (void)zfInitView {
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.ablumName];
    [self.contentView addSubview:self.ablumNums];

}

- (void)zfAutoLayoutView {
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.top.mas_equalTo(self.mas_top).offset(8);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
        make.width.mas_equalTo(self.coverImageView.mas_height).multipliedBy(1.0);
    }];
    
    [self.ablumName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.coverImageView.mas_centerY);
        make.leading.mas_equalTo(self.coverImageView.mas_trailing).offset(8);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
    }];
    
    [self.ablumNums mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.coverImageView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.coverImageView.mas_centerY);
    }];
    
    [self.ablumName setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    [self.coverImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.coverImageView setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setAblumModel:(PYAblumModel *)ablumModel {
    _ablumModel = ablumModel;
    
    self.coverImageView.image = ablumModel.coverImageView;
    self.ablumName.text = ZFToString(ablumModel.name);
    self.ablumNums.text = [NSString stringWithFormat:@"%lu",(unsigned long)ablumModel.assetfetchResult.count];
}

-(UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _coverImageView;
}

- (UILabel *)ablumName {
    if (!_ablumName) {
        _ablumName = [[UILabel alloc] initWithFrame:CGRectZero];
        _ablumName.textColor = ZFC0x2D2D2D();
        _ablumName.font = [UIFont systemFontOfSize:18];
    }
    return _ablumName;
}

- (UILabel *)ablumNums {
    if (!_ablumNums) {
        _ablumNums = [[UILabel alloc] initWithFrame:CGRectZero];
        _ablumNums.textColor = ZFC0x999999();
        _ablumNums.font = [UIFont systemFontOfSize:14];
    }
    return _ablumNums;
}

@end

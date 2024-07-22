//
//  ZFTrackingEmptyCell.m
//  ZZZZZ
//
//  Created by YW on 8/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingEmptyCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFTrackingEmptyCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView   *topImageView;
@property (nonatomic, strong) UILabel       *tipLabel;
@end

@implementation ZFTrackingEmptyCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self zfInitView];
        [self zfAutoLayoutView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)zfInitView {
    [self.contentView addSubview:self.topImageView];
    [self.contentView addSubview:self.tipLabel];
}

- (void)zfAutoLayoutView {
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(80);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(64, 64));
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topImageView.mas_bottom).mas_offset(8);
        make.centerX.mas_equalTo(self.topImageView.mas_centerX);
    }];
}


#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return NSStringFromClass([self class]);
}


#pragma mark - Getter
- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] init];
        _topImageView.image = [UIImage imageNamed:@"trackingNoData"];
    }
    return _topImageView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 2;
        _tipLabel.preferredMaxLayoutWidth = KScreenWidth - 24;
        _tipLabel.text = ZFLocalizedString(@"ZFTrackingNoData", nil);
    }
    return _tipLabel;
}

@end

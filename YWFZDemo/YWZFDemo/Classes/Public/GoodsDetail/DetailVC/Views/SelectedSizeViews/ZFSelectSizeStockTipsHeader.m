//
//  ZFSelectSizeStockTipsHeader.m
//  ZZZZZ
//
//  Created by YW on 2019/7/16.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSelectSizeStockTipsHeader.h"
#import "ZFInitViewProtocol.h"
#import "UILabel+HTML.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSelectSizeStockTipsHeader() <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView       *iconImageView;
@property (nonatomic, strong) UILabel           *stockTipsLabel;
@end

@implementation ZFSelectSizeStockTipsHeader

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.iconImageView];
    [self addSubview:self.stockTipsLabel];
}

- (void)zfAutoLayoutView {
    [self.stockTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(kStockTipsTopSetY);
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(5);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-kStockTipsTopSetY);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.stockTipsLabel.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
}

#pragma mark - setter

- (void)setStockTipsInfo:(NSString *)stockTipsInfo {
    _stockTipsInfo = stockTipsInfo;
    self.stockTipsLabel.text = ZFToString(stockTipsInfo);
}

#pragma mark - getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"detail_stock_tips"];
    }
    return _iconImageView;
}

- (UILabel *)stockTipsLabel {
    if (!_stockTipsLabel) {
        _stockTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stockTipsLabel.backgroundColor = [UIColor whiteColor];
        _stockTipsLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _stockTipsLabel.font = ZFFontSystemSize(14);
        _stockTipsLabel.numberOfLines = 0;
        _stockTipsLabel.preferredMaxLayoutWidth = kStockTipsWidth;
    }
    return _stockTipsLabel;
}
@end

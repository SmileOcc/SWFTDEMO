//
//  YXWarrantsHeaderView.m
//  uSmartOversea
//
//  Created by 井超 on 2019/7/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXWarrantsHeaderView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXWarrantsHeaderView ()

@property (nonatomic, strong) YXStockDetailLZButton *lzButton;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) CGFloat bottomHeight;

@property (nonatomic, assign) BOOL isShowBullBear;
@property (nonatomic, assign) BOOL isShowSignal;

@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation YXWarrantsHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    
    return self;
}

- (void)initialization {
    self.axis = UILayoutConstraintAxisVertical;
    
    self.backgroundColor = QMUITheme.foregroundColor;
    [self addArrangedSubview:self.searchView];
    [self setupSearch];
    
    [self addArrangedSubview:self.stockView];
    [self setupStockView];
    
    [self addArrangedSubview:self.bottomView];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(58);
    }];
    
    [self.stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(68);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    
}

- (void)showBullBear {
    self.bullBearView.hidden = NO;
    [self.bullBearView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(404);
    }];
    self.isShowBullBear = YES;
    [self updateBottom];
}

- (void)hideBullBear {
    self.bullBearView.hidden = YES;
    [self.bullBearView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    self.isShowBullBear = NO;
    [self updateBottom];
}

- (void)showSignal {
    self.signalView.hidden = NO;
    [self.signalView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.signalView.selfheight);
    }];
    self.isShowSignal = YES;
    [self updateBottom];
}

- (void)hideSignal {
    self.signalView.hidden = YES;
    [self.signalView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    self.isShowSignal = NO;
    [self updateBottom];
}

- (void)updateBottom {
    self.bottomHeight = 0;
    
    if (self.isShowBullBear && self.isShowSignal) {
        self.bottomHeight = self.signalView.selfheight + 404 + 40 + 32 + 20;
    } else if (self.isShowSignal) {
        self.bottomHeight = self.signalView.selfheight + 32 + 20;
    } else if (self.isShowBullBear) {
        self.bottomHeight = 404 + 32 + 20;
    }
    
    self.bottomView.hidden = self.bottomHeight == 0;
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.bottomHeight);
    }];

    if (self.updateHeightBlock) {
        self.updateHeightBlock(68 + self.bottomHeight);
    }
}

- (YXWarrantBullBearView *)bullBearView {
    if (!_bullBearView) {
        _bullBearView = [[YXWarrantBullBearView alloc] init];
        _bullBearView.backgroundColor = [QMUITheme foregroundColor];
        _bullBearView.clipsToBounds = YES;
        _bullBearView.hidden = YES;
    }
    return _bullBearView;
}

- (YXWarrantSignalView *)signalView {
    if (!_signalView) {
        _signalView = [[YXWarrantSignalView alloc] init];
        _signalView.backgroundColor = [QMUITheme foregroundColor];
        _signalView.clipsToBounds = YES;
        _signalView.hidden = YES;
    }
    return _signalView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        
        [_bottomView addSubview:self.bullBearView];
        [_bottomView addSubview:self.signalView];
        
        [self.bullBearView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bottomView).offset(32);
            make.left.right.equalTo(_bottomView);
            make.height.mas_equalTo(0);
        }];
        
        [self.signalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bullBearView.mas_bottom).offset(40);
            make.left.right.equalTo(_bottomView);
            make.height.mas_equalTo(0);
        }];
        
//        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.signalView.mas_bottom);
//            make.left.right.equalTo(_bottomView);
//            make.height.mas_equalTo(0);
//        }];

        _bottomHeight = 0;
    }
    return _bottomView;
}

- (void)hideLZBButton:(BOOL)ishide {
    self.lzButton.hidden = ishide;
}



- (void)setWarrantType:(YXStockWarrantsType)warrantType {
    if (warrantType == YXStockWarrantsTypeBullBear) {
        _lzButton.contentLabel.text = [YXLanguageUtility kLangWithKey:@"warrants_bull_bear1"];
        _lzButton.leftImageView.image = [UIImage imageNamed:@"warrants"];
        //self.sortView.hidden = YES;
        self.tipLabel.text = [YXLanguageUtility kLangWithKey:@"search_inline"];
    } else if (warrantType == YXStockWarrantsTypeInlineWarrants) {
        _lzButton.contentLabel.text = [YXLanguageUtility kLangWithKey:@"warrants_inline_warrants1"];
        _lzButton.leftImageView.image = [UIImage imageNamed:@"inline_warrants"];
        //self.sortView.hidden = NO;
        self.tipLabel.text = [YXLanguageUtility kLangWithKey:@"search_warrant"];
    }
}

- (void)lzButtonEvent {
    if (self.lzButtonBlock) {
        self.lzButtonBlock();
    }
}


- (void)cleanStock {
    self.stockInfoView.model = nil;
}

- (void)setupStockView {
    UIView *line = [UIView lineView];
    [self.stockView addSubview:self.stockInfoView];
    [self.stockView addSubview:self.stockBtn];
    [self.stockView addSubview:self.searchButton];
    [self.stockView addSubview:line];
    
    [self.stockInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stockView).offset(8);
        make.left.right.bottom.equalTo(self.stockView);
    }];
    
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.stockInfoView);
        make.right.equalTo(self.stockView).offset(-16);
        make.height.width.mas_equalTo(40);
    }];
     
     [self.stockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.right.top.bottom.equalTo(self.stockView);
     }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.stockView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setupSearch {
    self.searchBgView = [[UIView alloc] init];
    self.searchBgView.backgroundColor = QMUITheme.blockColor;
    self.searchBgView.layer.cornerRadius = 4;
    [self.searchView addSubview:self.searchBgView];
    
    [self.searchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.equalTo(self.searchView).offset(-16);
        make.top.mas_equalTo(16);
        make.height.mas_equalTo(40);
    }];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage imageNamed:@"icon_search"];
    [self.searchBgView addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.centerY.equalTo(self.searchBgView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    self.tipLabel.text = [YXLanguageUtility kLangWithKey:@"search_warrant"];
    [self.searchBgView addSubview:self.tipLabel];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView.mas_right).offset(8);
        make.right.equalTo(self.searchBgView.mas_right).offset(-8);
        make.centerY.equalTo(self.searchBgView);
    }];
    
}

- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc] init];
        _searchView.backgroundColor = QMUITheme.foregroundColor;
        _searchView.clipsToBounds = YES;
    }
    return _searchView;
}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = [QMUITheme textColorLevel4];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.adjustsFontSizeToFitWidth = true;
        _tipLabel.minimumScaleFactor = 0.8;
        _tipLabel.numberOfLines = 2;
    }
    return _tipLabel;
}

- (UIView *)stockView {
    if (!_stockView) {
        _stockView = [[UIView alloc] init];
        _stockView.backgroundColor = QMUITheme.foregroundColor;
        _stockView.hidden = YES;
    }
    return _stockView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font =  [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];;
        _nameLab.textColor = QMUITheme.themeTintColor;
    }
    return _nameLab;
}

- (UILabel *)marketLab {
    if (!_marketLab) {
        _marketLab = [[UILabel alloc] init];
        _marketLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _marketLab.textColor = [QMUITheme.textColorLevel1 colorWithAlphaComponent:0.4];
    }
    return _marketLab;
}

- (UILabel *)nowLab {
    if (!_nowLab) {
        _nowLab = [[UILabel alloc] init];
        _nowLab.font = [UIFont systemFontOfSize:20 weight:UIFontWeightRegular];
        _nowLab.textColor = QMUITheme.stockGrayColor;
        _nowLab.text = @"--";
    }
    return _nowLab;
}

- (UILabel *)changeLab {
    if (!_changeLab) {
        _changeLab = [[UILabel alloc] init];
        _changeLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _changeLab.textColor = QMUITheme.stockGrayColor;
        _changeLab.text = @"--";
    }
    return _changeLab;
}

- (UILabel *)rocLab {
    if (!_rocLab) {
        _rocLab = [[UILabel alloc] init];
        _rocLab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _rocLab.textColor = QMUITheme.stockGrayColor;
        _rocLab.text = @"--";
    }
    return _rocLab;
}

- (UIButton *)stockBtn {
    if (!_stockBtn) {
        _stockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stockBtn setTitle:@"" forState:UIControlStateNormal];
        _stockBtn.backgroundColor = [UIColor clearColor];
    }
    return _stockBtn;
}

- (YXStockDetailLZButton *)lzButton {
    if (!_lzButton) {
        _lzButton = [[YXStockDetailLZButton alloc] init];
        [_lzButton addTarget:self action:@selector(lzButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lzButton;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[UIButton alloc] init];
        [_searchButton setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
        _searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _searchButton;
}

- (YXStockTopView *)stockInfoView {
    if (!_stockInfoView) {
        _stockInfoView = [[YXStockTopView alloc] init];
        
    }
    return _stockInfoView;
}

@end

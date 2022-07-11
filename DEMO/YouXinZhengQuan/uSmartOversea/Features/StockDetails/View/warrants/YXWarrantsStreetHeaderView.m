//
//  YXWarrantsStreetHeaderView.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXWarrantsStreetHeaderView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@implementation YXWarrantsStreetHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    
    return self;
}

- (void)initialization {
    
    self.backgroundColor = [QMUITheme foregroundColor];
    
    [self addSubview:self.searchView];
    [self setupSearch];
    
    [self addSubview:self.stockView];
    [self.stockView addSubview:self.stockInfoView];
    [self.stockView addSubview:self.stockBtn];
    [self.stockView addSubview:self.searchButton];
    
    [self addSubview:self.sortView];
    [self.sortView addSubview:self.rangeBtn];
    [self.sortView addSubview:self.dateBtn];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.right.top.equalTo(self);
         make.height.mas_equalTo(58);
     }];
     
     [self.stockView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(self.searchView.mas_bottom);
         make.left.right.equalTo(self);
         make.height.mas_equalTo(68);
     }];
    
    [self.stockInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stockView).offset(8);
        make.left.right.bottom.equalTo(self.stockView);
    }];
    
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.stockInfoView);
        make.right.equalTo(self.stockView).offset(-16);
    }];
    
    [self.stockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.stockView);
    }];
    
    [self.sortView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.stockView.mas_bottom).offset(5);
        make.height.mas_equalTo(40);
    }];
    
    CGFloat btnW = (YXConstant.screenWidth-36)/2;
    [self.rangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sortView).offset(16);
        make.centerY.top.bottom.equalTo(self.sortView);
        make.width.mas_equalTo(btnW);
    }];
    
    [self.dateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.sortView);
        make.right.equalTo(self.sortView).offset(-16);
        make.width.mas_equalTo(btnW);
    }];
    
//    [self setBtnEdgeInsets];
}

//- (void)setBtnEdgeInsets {
//    self.dateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -self.dateBtn.imageView.image.size.width, 0, self.dateBtn.imageView.image.size.width);
//    self.dateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.dateBtn.titleLabel.frame.size.width-10, 0, -(self.dateBtn.titleLabel.frame.size.width+13));
//
//    self.rangeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -self.rangeBtn.imageView.image.size.width+10, 0, self.rangeBtn.imageView.image.size.width-10);
//    self.rangeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.rangeBtn.titleLabel.frame.size.width+12, 0, -(self.rangeBtn.titleLabel.frame.size.width-12));
    
//}

- (void)setRangeBtnSelected {
    [self.rangeBtn setTitleColor:QMUITheme.themeTextColor forState:UIControlStateNormal];
    [self.rangeBtn setImage:[UIImage arrowWithColor:QMUITheme.themeTextColor size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
}

- (void)setRangeBtnNormal {
    [self.rangeBtn setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
    [self.rangeBtn setImage:[UIImage arrowWithColor:QMUITheme.textColorLevel1 size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
}

- (void)setDateBtnSelected {
    [self.dateBtn setImage:[UIImage arrowWithColor:QMUITheme.themeTextColor size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
    [self.dateBtn setTitleColor:QMUITheme.themeTextColor forState:UIControlStateNormal];
}

- (void)setDateBtnNormal {
    [self.dateBtn setImage:[UIImage arrowWithColor:QMUITheme.textColorLevel1 size:CGSizeMake(9, 4.5)] forState:UIControlStateNormal];
    [self.dateBtn setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
}
//- (void)setSortBtnState {
//
//    if (self.typeArr.count > self.viewModel.type) {
//
//        switch (self.viewModel.type) {
//            case YXBullAndBellTypeBull:
//                [self.typeBtn setTitle:self.typeArr[1] forState:UIControlStateNormal];
//                break;
//            case YXBullAndBellTypeBear:
//                [self.typeBtn setTitle:self.typeArr[2] forState:UIControlStateNormal];
//                break;
//            case YXBullAndBellTypeSell:
//                [self.typeBtn setTitle:self.typeArr[3] forState:UIControlStateNormal];
//                break;
//            case YXBullAndBellTypeBuy:
//                [self.typeBtn setTitle:self.typeArr[4] forState:UIControlStateNormal];
//                break;
//            default:
//                [self.typeBtn setTitle:@"类型" forState:UIControlStateNormal];
//                break;
//        }
//    }
//
//    if (self.dateArr.count > self.viewModel.expireDate) {
//        if (self.viewModel.expireDate > 0) {
//
//            [self.dateBtn setTitle:self.dateArr[self.viewModel.expireDate] forState:UIControlStateNormal];
//        }else {
//            [self.dateBtn setTitle:@"到期日" forState:UIControlStateNormal];
//        }
//    }
//
//    if (self.viewModel.moneyness > 0 ||
//        self.viewModel.leverageRatio > 0 ||
//        self.viewModel.premium > 0 ||
//        self.viewModel.outstandingRatio > 0 ||
//        self.viewModel.outstandingPctLow.length > 0 ||
//        self.viewModel.outstandingPctHeight.length > 0 ||
//        self.viewModel.exchangeRatioLow.length > 0 ||
//        self.viewModel.exchangeRatioHeight.length > 0 ||
//        self.viewModel.recoveryPriceLow.length > 0 ||
//        self.viewModel.recoveryPriceHeight.length > 0 ||
//        self.viewModel.extendedVolatilityLow.length > 0 ||
//        self.viewModel.extendedVolatilityHeight.length > 0) {
//
//        [self setMoreBtnSelected];
//    }else {
//        [self setMoreBtnNormal];
//    }
//
//    [self setBtnEdgeInsets];
//}

- (void)cleanStock {
//    self.nameLab.text = @"";
//    self.marketLab.text = @"";
//    self.nowLab.text = @"--";
//    self.changeLab.text = @"--";
//    self.rocLab.text = @"--";
    
    self.stockInfoView.model = nil;
}

- (void)setRangeArr:(NSArray *)rangeArr {
    _rangeArr = rangeArr;
    if (_rangeArr == nil || _rangeArr.count < 1) {
        self.rangeBtn.hidden = YES;
    } else {
        self.rangeBtn.hidden = NO;
    }
}

- (void)setDateArr:(NSArray *)dateArr {
    _dateArr = dateArr;
    if (_dateArr == nil || _dateArr.count < 1) {
        self.dateBtn.hidden = YES;
    } else {
        self.dateBtn.hidden = NO;
    }
}

- (void)setRangeIndex:(NSInteger)rangeIndex {
    if (rangeIndex >= self.rangeArr.count) {
        return;
    }
    
    _rangeIndex = rangeIndex;
    NSNumber *range = self.rangeArr[rangeIndex];
    NSNumber *value = @(range.doubleValue / pow(10.0, self.viewModel.priceBase.integerValue));
    NSString *rangeText = [YXLanguageUtility kLangWithKey:@"call_price_range"];
    if ([YXToolUtility isPureInt:value.stringValue]) {
        [self.rangeBtn setTitle:[NSString stringWithFormat: @"%@   %dHKD", rangeText, value.intValue] forState:UIControlStateNormal];
    } else {
        if (value.floatValue < 0.1) {
             [self.rangeBtn setTitle:[NSString stringWithFormat:@"%@   %.2fHKD", rangeText, value.floatValue] forState:UIControlStateNormal];
        } else {
            [self.rangeBtn setTitle:[NSString stringWithFormat:@"%@   %.1fHKD", rangeText, value.floatValue] forState:UIControlStateNormal];
        }
    }
//    [self.rangeBtn setButtonImagePostion:YXButtonSubViewPositonRight interval:2];
}

- (void)setDateIndex:(NSInteger)dateIndex {
    if (dateIndex >= self.dateArr.count) {
        return;
    }
    _dateIndex = dateIndex;
    NSNumber *date = self.dateArr[dateIndex];
    
    YXDateModel *dateModel = [YXDateToolUtility dateTimeAndWeekWithTimeString:date.stringValue];
    NSString* timeString = [YXDateHelper commonDateStringWithNumber:date.longLongValue format:YXCommonDateFormatDF_MDY scaleType:YXCommonDateScaleTypeSlash showWeek:NO];
    [self.dateBtn setTitle:[NSString stringWithFormat:@"%@(%@)", timeString, dateModel.week] forState:UIControlStateNormal];
//    [self.dateBtn setButtonImagePostion:YXButtonSubViewPositonRight interval:2];
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
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [QMUITheme textColorLevel4];
    label.font = [UIFont systemFontOfSize:14];
    label.text = [YXLanguageUtility kLangWithKey:@"search_warrant"];
    [self.searchBgView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView.mas_right).offset(8);
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

- (UIView *)stockView {
    if (!_stockView) {
        _stockView = [[UIView alloc] init];
        _stockView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _stockView;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];        
        _nameLab.textColor = QMUITheme.themeTintColor;
        _nameLab.font =  [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];;
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

- (UIView *)sortView {
    if (!_sortView) {
        _sortView = [[UIView alloc] init];
        _sortView.backgroundColor = [QMUITheme foregroundColor];
        UIView *lineTop = [UIView lineView];
        UIView *lineBottom = [UIView lineView];
        [_sortView addSubview:lineTop];
        [_sortView addSubview:lineBottom];
        
        [lineTop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(_sortView);
            make.height.mas_equalTo(0.5);
        }];
        
        [lineBottom mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_sortView);
            make.height.mas_equalTo(0.5);
        }];
    }
    return _sortView;
}

- (QMUIButton *)creatButton {
    QMUIButton *btn = [[QMUIButton alloc] init];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.spacingBetweenImageAndTitle = 2;
    btn.imagePosition = QMUIButtonImagePositionRight;
    UIImage *arrowImageNormal = [[UIImage imageNamed:@"warrant_filter_arrow"] qmui_imageWithTintColor: [QMUITheme textColorLevel3]];
    UIImage *arrowImageSelected = [[UIImage imageNamed:@"warrant_filter_arrow"] qmui_imageWithTintColor: [QMUITheme themeTintColor]];
    [btn setImage:arrowImageNormal forState:UIControlStateNormal];
    [btn setImage:arrowImageSelected forState:UIControlStateSelected];
    [btn setTitleColor: [QMUITheme textColorLevel3] forState:UIControlStateNormal];
    [btn setTitleColor: [QMUITheme themeTintColor] forState:UIControlStateSelected];
    
    return btn;
}

- (QMUIButton *)rangeBtn {
    if (!_rangeBtn){
        _rangeBtn = [self creatButton];
        _rangeBtn.hidden = YES;
        NSString *rangeText = [YXLanguageUtility kLangWithKey:@"call_price_range"];
        [_rangeBtn setTitle:rangeText forState:UIControlStateNormal];
    }
    return _rangeBtn;
}

- (QMUIButton *)dateBtn {
    if (!_dateBtn){
        _dateBtn =[self creatButton];;
        _dateBtn.hidden = YES;
        [_dateBtn setTitle:@"" forState:UIControlStateNormal];
    }
    return _dateBtn;
}

- (UIButton *)stockBtn {
    if (!_stockBtn) {
        _stockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stockBtn setTitle:@"" forState:UIControlStateNormal];
        _stockBtn.backgroundColor = [UIColor clearColor];
    }
    return _stockBtn;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [[UIButton alloc] init];
        [_searchButton setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    }
    return _searchButton;
}

- (YXStockTopView *)stockInfoView {
    if (!_stockInfoView) {
        _stockInfoView = [[YXStockTopView alloc] init];
        
    }
    return _stockInfoView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  YXKLineOrderDetailView.m
//  uSmartOversea
//
//  Created by youxin on 2020/7/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXKLineOrderDetailView.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>
#import "YXKlineLongPressView.h"
#import "uSmartOversea-Swift.h"

@interface YXKLineOrderDetailView()

@property (nonatomic, assign) YXKlineScreenOrientType oritentType;

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) QMUIButton *detailButton;

@property (nonatomic, assign) int64_t latestTime;
@property (nonatomic, assign) NSInteger pricebase;
@property (nonatomic, assign) int32_t orderType;

@end

@implementation YXKLineOrderDetailView

- (instancetype)initWithFrame:(CGRect)frame andType:(int)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.oritentType = (YXKlineScreenOrientType)type;
        [self initUI];
    }
    return self;
}


- (void)initUI{

    self.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.03];
    [self addSubview: self.leftLabel];
    [self addSubview: self.rightLabel];
    [self addSubview: self.detailButton];

    if (self.oritentType == YXKlineScreenOrientTypeRight) {

        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(10);
            make.centerY.equalTo(self.mas_centerY);
        }];

        [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftLabel.mas_right).offset(20);
            make.centerY.equalTo(self.mas_centerY);
        }];

        [self.detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.rightLabel.mas_right).offset(20);
        }];
    } else {

        CGFloat width = (YXConstant.screenWidth - 90) / 2.0;
        if ([YXUserManager isENMode]) {
            width = (YXConstant.screenWidth - 102) / 2.0;
        }

        [self.detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-6);
        }];
        [self.detailButton sizeToFit];

        [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.detailButton.mas_left).offset(-6);
            make.centerY.equalTo(self.mas_centerY);
            make.width.mas_lessThanOrEqualTo(width);
        }];

        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(8);
            make.centerY.equalTo(self.mas_centerY);
            make.right.lessThanOrEqualTo(self.rightLabel.mas_left).offset(-6);
        }];
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tap];
}


- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    if (self.clickToDetailBlock) {
        NSString *date = @(self.latestTime).stringValue;
        if (date.length >= 8) {
            date = [date substringToIndex:8];
        }
        self.clickToDetailBlock(date, self.orderType);
    }
}

- (void)setKLineSingleModel:(YXKLine *)kLineSingleModel {
    _kLineSingleModel = kLineSingleModel;
    self.latestTime = kLineSingleModel.latestTime.value;
    self.pricebase = kLineSingleModel.priceBase.value;

    YXKLineInsideEvent *orderEvent = nil;
    if (kLineSingleModel.klineEvents.count > 0) {
        for (YXKLineInsideEvent *event in kLineSingleModel.klineEvents) {
            if (event.type.value == 0 && (event.bought.count > 0 || event.sold.count > 0)) {
                orderEvent = event;
                break;
            }
        }
    }

    if (orderEvent) {
        [self setOrderDataWithEvent:orderEvent];
    }
}

- (void)setTimelineSingleModel:(YXTimeLine *)timelineSingleModel {
    _timelineSingleModel = timelineSingleModel;

    self.latestTime = timelineSingleModel.latestTime.value;
    self.pricebase = timelineSingleModel.priceBase.value;

    YXKLineInsideEvent *orderEvent = nil;
    if (timelineSingleModel.klineEvents.count > 0) {
        for (YXKLineInsideEvent *event in timelineSingleModel.klineEvents) {
            if (event.type.value == 0 && (event.bought.count > 0 || event.sold.count > 0)) {
                orderEvent = event;
                break;
            }
        }
    }
    if (orderEvent) {
        [self setOrderDataWithEvent:orderEvent];
    }
}

- (void)setOrderDataWithEvent:(YXKLineInsideEvent * _Nullable)event {

    NSDictionary *sellAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [QMUITheme sellColor]};
    NSDictionary *buyAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [QMUITheme mainThemeColor]};
    NSDictionary *normalAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [QMUITheme textColorLevel1]};

    NSString *buyTitle = [NSString stringWithFormat:@"%@: ", [YXLanguageUtility kLangWithKey:@"buy"]];
    NSString *sellTitle = [NSString stringWithFormat:@"%@: ", [YXLanguageUtility kLangWithKey:@"sale"]];

    YXKLineInsideOrderDetail *boughtFirst = event.bought.firstObject;
    YXKLineInsideOrderDetail *soldFirst = event.sold.firstObject;
    self.orderType = 0;

    if (boughtFirst.orderType.value == 1 || soldFirst.orderType.value == 1) { //日内融
        buyTitle = [NSString stringWithFormat:@"%@: ", [YXLanguageUtility kLangWithKey:@"day_margin_buy"]];
        sellTitle = [NSString stringWithFormat:@"%@: ", [YXLanguageUtility kLangWithKey:@"day_margin_sell"]];

        self.orderType = 1;
    } else if (boughtFirst.orderType.value > 0) {
        self.orderType = boughtFirst.orderType.value;
    } else if (soldFirst.orderType.value > 0) {
        self.orderType = soldFirst.orderType.value;
    }

    if (event.bought.count > 0 && event.sold.count > 0) {

        NSMutableAttributedString *buyAtt = [[NSMutableAttributedString alloc] initWithString: buyTitle];
        [buyAtt addAttributes:buyAttributes range:NSMakeRange(0, buyTitle.length)];
        [buyAtt appendAttributedString:[self orderDetailString:event.bought.firstObject]];
        self.leftLabel.attributedText = buyAtt;

        NSMutableAttributedString *sellAtt = [[NSMutableAttributedString alloc] initWithString: sellTitle];
        [sellAtt addAttributes:sellAttributes range:NSMakeRange(0, sellTitle.length)];
        [sellAtt appendAttributedString:[self orderDetailString:event.sold.firstObject]];
        self.rightLabel.attributedText = sellAtt;

    } else if (event.bought.count > 0) {

        NSMutableAttributedString *buyAtt = [[NSMutableAttributedString alloc] initWithString: buyTitle];
        [buyAtt addAttributes:buyAttributes range:NSMakeRange(0, buyTitle.length)];
        [buyAtt appendAttributedString:[self orderDetailString:event.bought.firstObject]];
        if (event.bought.count > 1) {
            [buyAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"        " attributes:normalAttributes]];
            [buyAtt appendAttributedString:[self orderDetailString:event.bought[1]]];
        }
        self.leftLabel.attributedText = buyAtt;

        self.rightLabel.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10], NSForegroundColorAttributeName : [QMUITheme textColorLevel1]}];

    } else {

        NSMutableAttributedString *sellAtt = [[NSMutableAttributedString alloc] initWithString: sellTitle];
        [sellAtt addAttributes:sellAttributes range:NSMakeRange(0, sellTitle.length)];
        [sellAtt appendAttributedString:[self orderDetailString:event.sold.firstObject]];
        if (event.sold.count > 1) {
            [sellAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"        " attributes:normalAttributes]];
            [sellAtt appendAttributedString:[self orderDetailString:event.sold[1]]];
        }
        self.leftLabel.attributedText = sellAtt;

        self.rightLabel.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:normalAttributes];
    }

}

- (NSAttributedString *)orderDetailString:(YXKLineInsideOrderDetail *)model {

    NSString *priceString =  [YXToolUtility stockData:model.price.value deciPoint:self.pricebase stockUnit:@"" priceBase:self.pricebase];

    int64_t volume = model.volume.value;
    NSInteger deciPoint = 2;
    if ([YXUserManager isENMode]) {
        if (volume < 1000) {
            deciPoint = 0;
        }
    } else {
        if (volume < 10000) {
            deciPoint = 0;
        }
    }

    NSString *unitStr = [YXLanguageUtility kLangWithKey:@"stock_unit_en"];
    if ([self.market isEqualToString:kYXMarketUsOption]) {
        unitStr = [YXLanguageUtility kLangWithKey:@"options_page"];
    }

    NSString *volumnString =  [YXToolUtility stockData:volume deciPoint:deciPoint stockUnit: unitStr priceBase:0];

    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", priceString, volumnString] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12 weight:UIFontWeightRegular], NSForegroundColorAttributeName : [QMUITheme textColorLevel1]}];
}

#pragma mark - Lazy Loading

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:10] textAlignment:(NSTextAlignmentLeft)];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        _leftLabel.minimumScaleFactor = 0.7;
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:10] textAlignment:(NSTextAlignmentLeft)];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.minimumScaleFactor = 0.7;
    }
    return _rightLabel;
}

- (QMUIButton *)detailButton {
    if (!_detailButton) {
        _detailButton = [[QMUIButton alloc] init];
        [_detailButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        [_detailButton setTitle:[YXLanguageUtility kLangWithKey:@"hold_order_detail"] forState:UIControlStateNormal];
        [_detailButton setImage:[UIImage imageNamed:@"mine_arrow"] forState:UIControlStateNormal];
        _detailButton.imagePosition = QMUIButtonImagePositionRight;
        _detailButton.spacingBetweenImageAndTitle = 4;
        _detailButton.titleLabel.font = [UIFont systemFontOfSize:10];
        _detailButton.userInteractionEnabled = NO;
    }
    return _detailButton;
}


@end


//
//  YXStockDealDeatailCell.m
//  uSmartOversea
//
//  Created by rrd on 2018/8/1.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXStockDealDeatailCell.h"
#import "YXDateModel.h"
#import "YXDateToolUtility.h"
#import "UILabel+create.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXStockDealDeatailCell ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, assign) BOOL isBTDeal;

@end

@implementation YXStockDealDeatailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isBTDeal:(BOOL)isBTDeal {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isBTDeal = isBTDeal;
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = QMUITheme.foregroundColor;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.numLabel];
    [self.contentView addSubview:self.iconView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    if (self.isBTDeal) {
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        self.priceLabel.font = [UIFont systemFontOfSize:14];
        self.numLabel.font = [UIFont systemFontOfSize:14];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(16);
        }];

        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-168 * YXConstant.screenWidth / 375.0);
            make.centerY.equalTo(self.timeLabel);
        }];

        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-16);
            make.centerY.equalTo(self.timeLabel);
            make.width.height.mas_equalTo(16);
        }];
        
        [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.timeLabel);
            make.trailing.equalTo(self.iconView.mas_leading).offset(-2);
        }];
        
    } else {
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(5);
            make.width.mas_equalTo(30);
        }];

        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.timeLabel.mas_trailing).offset(10);
            make.centerY.equalTo(self.timeLabel);
        }];

        [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.timeLabel);
            make.trailing.equalTo(self.iconView.mas_leading).offset(-5);
        }];

        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-4);
            make.centerY.equalTo(self.contentView).offset(-3);
        }];
    }
    

    [self.contentView addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}


- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [UILabel labelWithText:@"--" textColor: [QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
    }
    return _timeLabel;
}


- (UILabel *)priceLabel {
    if (_priceLabel == nil) {
        _priceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
        _priceLabel.adjustsFontSizeToFitWidth = true;
        _priceLabel.minimumScaleFactor = 0.9;
    }
    return _priceLabel;
}


- (UILabel *)numLabel {
    if (_numLabel == nil) {
        _numLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel2] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]];
        _numLabel.adjustsFontSizeToFitWidth = true;
        _numLabel.minimumScaleFactor = 0.9;
    }
    return _numLabel;
}

- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [[UIImage imageNamed:@"tick_grey"] qmui_imageWithTintColor:QMUITheme.stockGrayColor];
    }
    return _iconView;
}

- (UIView *)animationView {
    if (!_animationView) {
        _animationView = [[UIView alloc] initWithFrame:CGRectZero];
        _animationView.alpha = 0;

        _animationView.backgroundColor = [[QMUITheme stockRedColor] colorWithAlphaComponent:0.2];
    }
    return _animationView;
}

#pragma mark - set model

- (void)reloadDataWithModel:(YXTick *)tickDetailModel pclose:(double)pclose priceBase:(double)priceBase isCryptos:(BOOL)isCryptos {
    NSInteger square = priceBase;
    //NSInteger priceBasic = pow(10.0, square);
    //时间
    YXDateModel *dateModel = [YXDateToolUtility dateTimeWithTimeString:[NSString stringWithFormat:@"%llu", tickDetailModel.time.value]];
    if (tickDetailModel.latestTime.value > 0) {
        dateModel = [YXDateToolUtility dateTimeWithTimeString:[NSString stringWithFormat:@"%llu", tickDetailModel.latestTime.value]];
    }
    _timeLabel.text = [NSString stringWithFormat:@"%@:%@", dateModel.hour, dateModel.minute];
    
    //价格
    double priceValue = tickDetailModel.price.value;
    if (isCryptos) {
        priceValue = tickDetailModel.price.stringValue.doubleValue;
        _priceLabel.text = [YXToolUtility btNumberString:tickDetailModel.price.stringValue decimalPoint:0 isVol:NO showPlus:NO]; //self.decimalCount
    } else {
        _priceLabel.text = [YXToolUtility stockPriceData:priceValue deciPoint:square priceBase:square];
    }
    _priceLabel.textColor = [YXToolUtility priceTextColor:priceValue comparedData:pclose];


    //成交量
    double volumeValue = tickDetailModel.volume.value;
    if (isCryptos) {
        volumeValue = tickDetailModel.volume.stringValue.doubleValue;
        _numLabel.text = [YXToolUtility btNumberString:tickDetailModel.volume.stringValue decimalPoint:0 isVol:YES showPlus:NO];;
    } else {
        _numLabel.text = [YXToolUtility stockVolumeUnit:volumeValue];
    }
}


- (void)setIsLastRow:(BOOL)isLastRow {
    _isLastRow = isLastRow;
    if (isLastRow) {
        [self refresBidAnimation];
    } else {
        self.animationView.alpha = 0;
    }
}

- (void)refresBidAnimation {

    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.animationView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.animationView.alpha = 0;
        } completion:^(BOOL finished)  {

        }];
    }];
}
@end

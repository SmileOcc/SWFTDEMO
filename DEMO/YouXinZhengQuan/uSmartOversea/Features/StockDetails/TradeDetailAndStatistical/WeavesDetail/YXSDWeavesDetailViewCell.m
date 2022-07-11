//
//  YXSDWeavesDetailViewCell.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSDWeavesDetailViewCell.h"
#import "YXDateModel.h"
#import "YXDateToolUtility.h"
#import "YXToolUtility.h"
#import <Masonry/Masonry.h>
#import "UILabel+create.h"
#import "uSmartOversea-Swift.h"
//#import <YXKit/YXKit.h>

@interface YXSDWeavesDetailViewCell ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UILabel *trdTypeLab;

@property (nonatomic, strong) UIView *animationView;

@property (nonatomic, strong) UILabel *exchangeLabel;


@end

@implementation YXSDWeavesDetailViewCell


#pragma mark - set model
- (void)refreshWith:(YXTick *)tickDetailModel pClose:(double)pClose priceBase:(NSInteger)priceBase {
//    tickDetailModel.time.value
//    tickDetailModel.price.doubleValue
    //时间
    YXDateModel *dateModel = [YXDateToolUtility dateTimeWithTimeString:@(tickDetailModel.time.value).stringValue];
    _timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", dateModel.hour, dateModel.minute,dateModel.second];
    
    self.trdTypeLab.text = tickDetailModel.trdTypeString;    
    //价格
    _priceLabel.text = tickDetailModel.price.value > 0 ? [YXToolUtility stockPriceData:tickDetailModel.price.value deciPoint:priceBase priceBase:priceBase] : @"--";
    //成交价 颜色
    _priceLabel.textColor = [YXToolUtility stockColorWithData:tickDetailModel.price.value compareData:pClose];
    
    _exchangeLabel.text = [YXToolUtility getQuoteExchangeEnName:tickDetailModel.exchange.value];
    //成交量
    _numLabel.text = [YXToolUtility stockVolumeUnit:tickDetailModel.volume.value];
}

- (void)setIsLastRow:(BOOL)isLastRow {
    _isLastRow = isLastRow;
    if (isLastRow) {
        [self refresBidAnimation];
    } else {
    }
}

- (void)refresBidAnimation {
    
    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.animationView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.animationView.alpha = 0;
        } completion:^(BOOL finished)  {
            
        }];
    }];
}

- (UIView *)animationView {
    if (!_animationView) {
        _animationView = [[UIView alloc] initWithFrame:CGRectZero];
        _animationView.alpha = 0;
        _animationView.backgroundColor = [QMUITheme.stockRedColor colorWithAlphaComponent:0.2];
    }
    return _animationView;
}


- (void)initialUI {
    
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.trdTypeLab];
    
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.numLabel];
    [self.contentView addSubview:self.directImgView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(12);
    }];
    
    [self.trdTypeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.timeLabel.mas_trailing).offset(12);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView.mas_centerX).offset(-70);
    }];

    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView.mas_centerX).offset(40);
    }];
    
    [self.directImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        //make.size.mas_equalTo(CGSizeMake(10, 14));
        make.trailing.equalTo(self.contentView).offset(-40);
    }];
    
    [self.contentView addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
}

//MARK: getter
- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        
        _timeLabel = [UILabel labelWithText:@"--" textColor: [QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14] ];
    }
    return _timeLabel;
}


- (UILabel *)priceLabel {
    if (_priceLabel == nil) {
        
        _priceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:14]];
        
    }
    return _priceLabel;
}


- (UILabel *)numLabel {
    if (_numLabel == nil) {
        
        _numLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14]];
        
    }
    return _numLabel;
}
- (UILabel *)trdTypeLab {
    if (_trdTypeLab == nil) {
        
        _trdTypeLab = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14]];
        
    }
    return _trdTypeLab;
}

- (UILabel *)exchangeLabel {
    if (_exchangeLabel == nil) {
        _exchangeLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:14]];
    }
    return _exchangeLabel;
}

- (UIImageView *)directImgView {
    if (!_directImgView) {
        _directImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weaves_detial_gray_rect"]];
    }
    return _directImgView;
}


@end

#pragma mark - 全美行情的cell

@implementation YXSDWeavesUsNationDetailViewCell

- (void)initialUI {
    
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.trdTypeLab];
    
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.numLabel];
    [self.contentView addSubview:self.directImgView];
    [self.contentView addSubview:self.exchangeLabel];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(12);
    }];
    
    [self.trdTypeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.timeLabel.mas_trailing).offset(12);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(105);
    }];

    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(195);
    }];
    
    [self.directImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-91);
    }];
    
    [self.exchangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-12);
    }];
    
    [self.contentView addSubview:self.animationView];
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
        
    
}

@end

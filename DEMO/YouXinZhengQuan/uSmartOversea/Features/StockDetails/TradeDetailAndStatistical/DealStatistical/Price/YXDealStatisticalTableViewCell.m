//
//  YXDealStatisticalTableViewCell.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXDealStatisticalTableViewCell.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXDealStatisticalTableViewCell ()

@property (nonatomic, strong)UILabel *tradePriceLab;    //成交价
@property (nonatomic, strong)UILabel *bidSizeLab;       //主买
@property (nonatomic, strong)UILabel *askSizeLab;       //主卖
@property (nonatomic, strong)UILabel *bothSizeLab;       //主卖
@property (nonatomic, strong)UILabel *volumeLab;        //成交量
@property (nonatomic, strong)UILabel *rateLab;          //占比


@property (nonatomic, strong)UIView *redView;
@property (nonatomic, strong)UIView *greenView;
@property (nonatomic, strong)UIView *grayView;

@property (nonatomic, assign)CGFloat colorBgWidth;

@end

@implementation YXDealStatisticalTableViewCell

- (void)refreshWith:(YXAnalysisStatisticPrice *)statisPrice priceBase:(int64_t)priceBase pClose:(NSString *)pClose maxVolume:(int32_t)maxVolume {
    if (statisPrice != nil) {
        //成交价
        self.tradePriceLab.text = [YXToolUtility stockPriceData:statisPrice.tradePrice.value deciPoint:priceBase priceBase:priceBase];
        
        //主买
        self.bidSizeLab.text = [YXToolUtility stockVolumeUnit:statisPrice.bidSize.value];

        //主卖
        self.askSizeLab.text = [YXToolUtility stockVolumeUnit:statisPrice.askSize.value];
        // 中性
        self.bothSizeLab.text = [YXToolUtility stockVolumeUnit:statisPrice.bothSize.value];
        
        //成交量
        self.volumeLab.text = [YXToolUtility stockVolumeUnit:statisPrice.volume.value];
        
        //占比
        NSString *rate = [YXToolUtility stockPercentData:statisPrice.rate.value priceBasic:2 deciPoint:2];
        self.rateLab.text = [rate stringByReplacingOccurrencesOfString:@"+" withString:@""];
        
        //成交价 颜色
        NSComparisonResult compare =[[NSString stringWithFormat:@"%d",statisPrice.tradePrice.value] compare:pClose];
        switch (compare) {
            case NSOrderedAscending: //self.tradePriceLab.text < pClose 升序
                self.tradePriceLab.textColor = QMUITheme.stockGreenColor;
                break;
            case NSOrderedDescending: //self.tradePriceLab.text > pClose 降序
                self.tradePriceLab.textColor = QMUITheme.stockRedColor;
                break;
            default:
                self.tradePriceLab.textColor = QMUITheme.stockGrayColor;
                break;
        }
        
        
        CGFloat ratioWidth = self.colorBgWidth;
        
        CGFloat modelRatioWidth = ratioWidth * statisPrice.volume.value / (CGFloat)maxVolume;
        
        CGFloat modelRedWidth = statisPrice.bidSize.value / (CGFloat)statisPrice.volume.value * modelRatioWidth;
        CGFloat modelGreenWidth = statisPrice.askSize.value / (CGFloat)statisPrice.volume.value * modelRatioWidth;
        CGFloat modelGrayWidth = statisPrice.bothSize.value / (CGFloat)statisPrice.volume.value * modelRatioWidth;
        
        if (isnan(modelRatioWidth) || statisPrice.volume.value == 0) {
            modelRedWidth = 0;
            modelGreenWidth = 0;
            modelGrayWidth = 0;
        }
        
        [self.redView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo( modelRedWidth );
        }];
        [self.greenView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo( modelGreenWidth );
        }];
        [self.grayView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo( modelGrayWidth );
        }];
                
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}


- (void)initialUI {

    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.width.mas_equalTo(YXConstant.screenWidth);
        make.height.mas_equalTo(40);
    }];
    self.scrollView.contentSize = CGSizeMake(460, 40);
    
    [self.scrollView addSubview:self.tradePriceLab];
    [self.tradePriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scrollView);
        make.leading.equalTo(self.scrollView).offset(12);
    }];
    
    [self.scrollView addSubview:self.bidSizeLab];
    [self.bidSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scrollView);
        make.trailing.equalTo(self.scrollView.mas_leading).offset(127);
//        make.width.equalTo(self.contentView).multipliedBy((33 - 9 + 39.0) / 375.0);
    }];
    
    [self.scrollView addSubview:self.askSizeLab];
    [self.askSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scrollView);
        make.trailing.equalTo(self.scrollView.mas_leading).offset(191);
//        make.width.equalTo(self.contentView).multipliedBy((20 + 39.0) / 375.0);
    }];
    
    [self.scrollView addSubview:self.bothSizeLab];
    [self.bothSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scrollView);
        make.trailing.equalTo(self.scrollView.mas_leading).offset(270);
//        make.width.equalTo(self.contentView).multipliedBy((20 + 39.0) / 375.0);
    }];
    
    [self.scrollView addSubview:self.volumeLab];
    [self.volumeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scrollView);
//        make.leading.equalTo(self.askSizeLab.mas_trailing);
        make.leading.equalTo(self.scrollView).offset(300);
//        make.width.equalTo(self.contentView).multipliedBy((20 + 36.0 + 15) / 375.0);
    }];
    

    //占比
    [self.scrollView addSubview:self.rateLab];
    [self.rateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scrollView);
        make.leading.equalTo(self.scrollView).offset(400);
        make.width.mas_equalTo(50);
    }];
    
    
    //MARK:颜色
    self.colorBgWidth = 95;
    UIView *colorBgView = [UIView new];
    colorBgView.layer.cornerRadius = 2;
    colorBgView.clipsToBounds = YES;
    [self.scrollView addSubview:colorBgView];
    [colorBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.leading.equalTo(self.volumeLab.mas_trailing).offset(20);
        make.centerY.equalTo(self.scrollView);
        make.height.mas_equalTo(10);
        make.width.mas_offset(self.colorBgWidth);
        make.trailing.equalTo(self.rateLab);
    }];
    
    
    [colorBgView addSubview:self.redView];
    [colorBgView addSubview:self.greenView];
    [colorBgView addSubview:self.grayView];
    
    [self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(colorBgView);
        make.width.mas_equalTo(0);
    }];
    [self.greenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(colorBgView);
        make.leading.equalTo(self.redView.mas_trailing);
        make.width.mas_equalTo(0);
    }];
    [self.grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(colorBgView);
        make.leading.equalTo(self.greenView.mas_trailing);
        make.width.mas_equalTo(0);
    }];
    
    [self.scrollView insertSubview:self.volumeLab aboveSubview:colorBgView];
    [self.scrollView insertSubview:self.rateLab aboveSubview:colorBgView];
}

//MARK: getter
-(UILabel *)tradePriceLab {
    if (!_tradePriceLab) {
        _tradePriceLab = [self buildLabelTextColor:QMUITheme.stockRedColor];
    }
    return _tradePriceLab;
}

-(UILabel *)bidSizeLab {
    if (!_bidSizeLab) {//红色
        _bidSizeLab = [self buildLabelTextColor:QMUITheme.stockRedColor];
    }
    return _bidSizeLab;
}

-(UILabel *)askSizeLab {
    if (!_askSizeLab) { //绿色
        _askSizeLab = [self buildLabelTextColor:QMUITheme.stockGreenColor];
    }
    return _askSizeLab;
}

-(UILabel *)bothSizeLab {
    if (!_bothSizeLab) { //灰色
        _bothSizeLab = [self buildLabelTextColor:QMUITheme.stockGrayColor];
        _bothSizeLab.text = @"--";
    }
    return _bothSizeLab;
}

-(UILabel *)volumeLab {
    if (!_volumeLab) {
        _volumeLab = [self buildLabelTextColor:[QMUITheme textColorLevel1]];
    }
    return _volumeLab;
}

-(UILabel *)rateLab {
    if (!_rateLab) {
        _rateLab = [self buildLabelTextColor:[QMUITheme textColorLevel1]];
    }
    return _rateLab;
}
- (UIView *)redView {
    if (!_redView) {
        _redView = [UIView new];
        _redView.backgroundColor = QMUITheme.stockRedColor;
    }
    return _redView;
}

- (UIView *)greenView {
    if (!_greenView) {
        _greenView = [UIView new];
        _greenView.backgroundColor = QMUITheme.stockGreenColor;
    }
    return _greenView;
}

- (UIView *)grayView {
    if (!_grayView) {
        _grayView = [UIView new];
        _grayView.backgroundColor = QMUITheme.separatorLineColor;
    }
    return _grayView;
}

//MARK: 构建Label
- (UILabel *)buildLabelTextColor:(UIColor *)tColor {
    UILabel * lab = [UILabel new];
    lab.textColor = tColor;
    lab.textAlignment = NSTextAlignmentRight;
    lab.font = [UIFont systemFontOfSize:14];
    return lab;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}


@end

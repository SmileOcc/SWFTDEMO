//
//  YXExchangeDistributionCell.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXExchangeDistributionCell.h"
#import "YXExchangeStatisticalModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXExchangeDistributionCell()
@property (nonatomic, strong)UILabel *nameLab;
@property (nonatomic, strong)UILabel *volumeLab;
@property (nonatomic, strong)UILabel *volumeRatoLab;

@property (nonatomic, strong)UILabel *amountLab;
@property (nonatomic, strong)UILabel *amountRatoLab;

@property (nonatomic, strong)UILabel *bidSizeLab;
@property (nonatomic, strong)UILabel *askSizeLab;
@property (nonatomic, strong)UILabel *bothSizeLab;

@property (nonatomic, strong) UIView *volumnView;

@end

@implementation YXExchangeDistributionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(82);
        make.width.mas_equalTo(YXConstant.screenWidth - 82);
        make.height.mas_equalTo(40);
    }];
    self.scrollView.contentSize = CGSizeMake(680, 40);
    
//    UIView *bottomLineView = [[UIView alloc] init];
//    bottomLineView.backgroundColor = QMUITheme.separatorLineColor;
//    [self.contentView addSubview:bottomLineView];
//
//    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(12);
//        make.right.equalTo(self.contentView).offset(-12);
//        make.bottom.equalTo(self.contentView);
//        make.height.mas_equalTo(1);
//    }];
    
    self.volumnView = [[UIView alloc] init];
    self.volumnView.layer.cornerRadius = 2;
    self.volumnView.clipsToBounds = YES;
    self.volumnView.backgroundColor = QMUITheme.themeTextColor;
            
    self.nameLab = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.centerY.equalTo(self.contentView);
    }];
    
    self.volumeLab = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    self.volumeRatoLab = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    self.amountLab = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    self.amountRatoLab = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    self.bidSizeLab = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    self.askSizeLab = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    self.bothSizeLab = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
        
    [self.scrollView addSubview:self.volumeLab];
    [self.scrollView addSubview:self.volumnView];
    [self.scrollView addSubview:self.volumeRatoLab];
    [self.scrollView addSubview:self.amountLab];
    [self.scrollView addSubview:self.amountRatoLab];
    [self.scrollView addSubview:self.bidSizeLab];
    [self.scrollView addSubview:self.askSizeLab];
    [self.scrollView addSubview:self.bothSizeLab];
    
    
    [self.volumeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.scrollView.mas_left).offset(80);
        make.centerY.equalTo(self.scrollView);
    }];
    [self.volumnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scrollView);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(0);
        make.left.equalTo(self.volumeLab.mas_right).offset(4);
    }];
    [self.volumeRatoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(190);
        make.centerY.equalTo(self.scrollView);
    }];
    [self.amountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(260);
        make.centerY.equalTo(self.scrollView);
    }];
    [self.amountRatoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(340);
        make.centerY.equalTo(self.scrollView);
    }];
    [self.bidSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(420);
        make.centerY.equalTo(self.scrollView);
    }];
    [self.askSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(500);
        make.centerY.equalTo(self.scrollView);
    }];
    [self.bothSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(624);
        make.centerY.equalTo(self.scrollView);
    }];
}

- (void)refreshWithModel: (YXExchangeStatisticalSubModel *)model andMaxVolumn: (uint64_t)maxVolume andPriceBase: (NSInteger)priceBase {
    self.nameLab.text = [YXToolUtility getQuoteExchangeEnName:model.exchange];
    self.volumeLab.text = [YXToolUtility stockVolumeUnit:model.volume];
    self.amountLab.text = [YXToolUtility stockData:model.amount deciPoint:2 stockUnit:@"" priceBase:priceBase];
    self.askSizeLab.text = [YXToolUtility stockVolumeUnit:model.askSize];
    self.bidSizeLab.text = [YXToolUtility stockVolumeUnit:model.bidSize];
    self.bothSizeLab.text = [YXToolUtility stockVolumeUnit:model.bothSize];
    self.amountRatoLab.text = [[YXToolUtility stockPercentData:model.amtRate priceBasic:2 deciPoint:2] stringByReplacingOccurrencesOfString:@"+" withString:@""];
    self.volumeRatoLab.text = [[YXToolUtility stockPercentData:model.volRate priceBasic:2 deciPoint:2] stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    CGFloat maxWidth = 100;
    CGFloat volumnWidth = 0;
    if (maxVolume > 0) {
        volumnWidth = model.volume / (CGFloat)maxVolume * maxWidth;
    }
    if (volumnWidth > 0 && volumnWidth < 3) {
        volumnWidth = 3;
    }
     
    [self.volumnView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(volumnWidth);
    }];
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

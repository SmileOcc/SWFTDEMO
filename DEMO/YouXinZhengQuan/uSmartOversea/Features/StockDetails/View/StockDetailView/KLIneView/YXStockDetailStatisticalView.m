//
//  YXStockDetailStatisticalView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailStatisticalView.h"
#import "YXDealStatisticalPieChartView.h"
#import "uSmartOversea-Swift.h"
#import <YXKit/YXKit.h>
#import <Masonry/Masonry.h>
#import "YXToolUtility.h"

@interface YXStockDetailStatisticalCell ()

@property (nonatomic, strong)UILabel *tradePriceLab;    //成交价
@property (nonatomic, strong)UILabel *volumeLab;        //成交量
@property (nonatomic, strong)UILabel *rateLab;          //占比


@property (nonatomic, strong)UIView *redView;
@property (nonatomic, strong)UIView *greenView;
@property (nonatomic, strong)UIView *grayView;

@property (nonatomic, assign)CGFloat colorBgWidth;


@end


@implementation YXStockDetailStatisticalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {

    self.colorBgWidth = 51;
    
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.tradePriceLab];
    [self.tradePriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(3);
//        make.width.equalTo(self.contentView).multipliedBy(1.4/(1.4+1+1.4));
    }];

    [self.contentView addSubview:self.volumeLab];
    [self.volumeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-self.colorBgWidth - 10);
//        make.width.equalTo(self.contentView).multipliedBy(1/(1.4+1+1.4));
    }];
    
    //占比
    [self.contentView addSubview:self.rateLab];
    [self.rateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-3);
        make.width.mas_equalTo(self.colorBgWidth);
    }];
    
    //MARK:颜色
    UIView *colorBgView = [UIView new];
    [self.contentView addSubview:colorBgView];
    colorBgView.layer.cornerRadius = 0.5;
    colorBgView.clipsToBounds = YES;
    [colorBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.leading.equalTo(self.volumeLab.mas_trailing).offset(20);
        make.centerY.equalTo(self.contentView);
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
    
    [self.contentView insertSubview:self.volumeLab aboveSubview:colorBgView];
    [self.contentView insertSubview:self.rateLab aboveSubview:colorBgView];
}

- (void)refreshWith:(YXAnalysisStatisticPrice *)statisPrice priceBase:(int64_t)priceBase pClose:(NSString *)pClose maxVolume:(int32_t)maxVolume {
    if (statisPrice != nil) {
        //成交价
        self.tradePriceLab.text = [YXToolUtility stockPriceData:statisPrice.tradePrice.value deciPoint:priceBase priceBase:priceBase];
    
        //成交量
        self.volumeLab.text = [YXToolUtility stockVolumeUnit:statisPrice.volume.value];
        
        //占比
        NSString *rate = [YXToolUtility stockPercentData:statisPrice.rate.value priceBasic:2 deciPoint:2];
        self.rateLab.text = [rate stringByReplacingOccurrencesOfString:@"+" withString:@""];
        
        //成交价 颜色
        NSComparisonResult compare =[[NSString stringWithFormat:@"%d",statisPrice.tradePrice.value] compare:pClose];
        switch (compare) {
            case NSOrderedAscending: //self.tradePriceLab.text < pClose 升序
                self.tradePriceLab.textColor = [QMUITheme stockGreenColor];
                break;
            case NSOrderedDescending: //self.tradePriceLab.text > pClose 降序
                self.tradePriceLab.textColor = [QMUITheme stockRedColor];
                break;
            default:
                self.tradePriceLab.textColor = [QMUITheme stockGrayColor];
                break;
        }
        
        
        CGFloat ratioWidth = self.colorBgWidth;
        
        CGFloat modelRatioWidth = ratioWidth * statisPrice.volume.value / (CGFloat)maxVolume;
        
        CGFloat modelRedWidth = statisPrice.bidSize.value / (CGFloat)statisPrice.volume.value * modelRatioWidth;
        CGFloat modelGreenWidth = statisPrice.askSize.value / (CGFloat)statisPrice.volume.value * modelRatioWidth;
        CGFloat modelGrayWidth = statisPrice.bothSize.value / (CGFloat)statisPrice.volume.value * modelRatioWidth;
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


//MARK: getter
-(UILabel *)tradePriceLab {
    if (!_tradePriceLab) {
        _tradePriceLab = [self buildLabelTextColor:[QMUITheme stockRedColor]];
    }
    return _tradePriceLab;
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
        _rateLab.textAlignment = NSTextAlignmentRight;
    }
    return _rateLab;
}
- (UIView *)redView {
    if (!_redView) {
        _redView = [UIView new];
        _redView.backgroundColor = [QMUITheme stockRedColor];
        _redView.layer.cornerRadius = 0.5;
        _redView.layer.masksToBounds = true;
    }
    return _redView;
}

- (UIView *)greenView {
    if (!_greenView) {
        _greenView = [UIView new];
        _greenView.backgroundColor = [QMUITheme stockGreenColor];
        _greenView.layer.cornerRadius = 0.5;
        _greenView.layer.masksToBounds = true;
    }
    return _greenView;
}

- (UIView *)grayView {
    if (!_grayView) {
        _grayView = [UIView new];
        _grayView.backgroundColor = [QMUITheme stockGrayColor];
        _grayView.layer.cornerRadius = 0.5;
        _grayView.layer.masksToBounds = true;
    }
    return _grayView;
}

//MARK: 构建Label
- (UILabel *)buildLabelTextColor:(UIColor *)tColor {
    UILabel * lab = [UILabel new];
    lab.textColor = tColor;
//    lab.textAlignment = NSTextAlignmentRight;
    lab.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    lab.text = @"--";
    return lab;
}



@end

@interface YXStockDetailStatisticalView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UILabel *totalAskCountLab;     // 主动卖出股数
@property (nonatomic, strong)UILabel *totalBidCountLab;     // 主动买入股数
@property (nonatomic, strong)UILabel *totalBothCountLab;    // 中性盘股数

@property (nonatomic, strong)UILabel *totalAskRateLab;     // 主动卖出率
@property (nonatomic, strong)UILabel *totalBidRateLab;     // 主动买入率
@property (nonatomic, strong)UILabel *totalBothRateLab;    // 中性盘率

@property (nonatomic, strong) YXDealStatisticalPieChartView *pieView; //饼状图
//@property (nonatomic, strong) UILabel *pieNoDataLab;

@property (nonatomic, strong) UIView *noDataView;

@property (nonatomic, copy) NSArray *pieColorArr; //饼状图颜色

@property (nonatomic, assign) uint32_t maxVolume;


@property (nonatomic, strong) YXTableView *tableView;

@end

@implementation YXStockDetailStatisticalView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI

- (void)setUI {
    self.backgroundColor = [QMUITheme foregroundColor];
    
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 139, 148)];
    
    self.pieView.frame = CGRectMake(0, 0, 57, 57);
    [headView addSubview:self.pieView];
    [self.pieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headView);
        make.width.height.mas_equalTo(57);
        make.top.equalTo(headView).offset(12);
    }];
    
//    [headView addSubview:self.pieNoDataLab];
//    [self.pieNoDataLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.pieView);
//    }];
    
    //3个颜色
    UIView *bidTip = [UIView new]; //
    bidTip.backgroundColor = self.pieColorArr[0];
    bidTip.layer.cornerRadius = 2;
    bidTip.layer.masksToBounds = true;
    [headView addSubview:bidTip];
    [bidTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headView).offset(3);
        make.top.equalTo(headView).offset(85);
        make.size.mas_equalTo(CGSizeMake(4, 4));
    }];
    UIView *askTip = [UIView new];
    askTip.backgroundColor = self.pieColorArr[1];
    askTip.layer.cornerRadius = 2;
    askTip.layer.masksToBounds = true;
    [headView addSubview:askTip];
    [askTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bidTip);
        make.top.equalTo(bidTip.mas_bottom).offset(19);
        make.size.mas_equalTo(CGSizeMake(4, 4));
    }];
    UIView *bothTip = [UIView new];
    bothTip.backgroundColor = self.pieColorArr[2];
    bothTip.layer.cornerRadius = 2;
    bothTip.layer.masksToBounds = true;
    [headView addSubview:bothTip];
    [bothTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bidTip);
        make.top.equalTo(askTip.mas_bottom).offset(19);
        make.size.mas_equalTo(CGSizeMake(4, 4));
    }];
    //文字提示
    UILabel *bidTipLab = [self buildGrayLabelWith:[YXLanguageUtility kLangWithKey:@"stock_deal_master_buy2"] color:QMUITheme.buyColor];//
    [headView addSubview:bidTipLab];
    [bidTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bidTip.mas_trailing).offset(7);
        make.centerY.equalTo(bidTip);
    }];
    
    UILabel *askTipLab = [self buildGrayLabelWith:[YXLanguageUtility kLangWithKey:@"stock_deal_master_sell2"] color:QMUITheme.sellColor];
    [headView addSubview:askTipLab];
    [askTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(askTip.mas_trailing).offset(7);
        make.centerY.equalTo(askTip);
    }];
    
    UILabel *bothTipLab = [self buildGrayLabelWith:[YXLanguageUtility kLangWithKey:@"stock_deal_neutral_disk2"] color:QMUITheme.stockGrayColor];
    bothTipLab.adjustsFontSizeToFitWidth = true;
    [headView addSubview:bothTipLab];
    [bothTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bothTip.mas_trailing).offset(7);
        make.centerY.equalTo(bothTip);
        if ([YXUserManager isENMode]) {
            make.width.mas_lessThanOrEqualTo(53 - 18);
        }
    }];
    
    
    //数字：xx亿股
    // 主动买入股数
    [headView addSubview:self.totalBidCountLab];
    [self.totalBidCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(bidTipLab.mas_trailing).offset(6);
        if ([YXUserManager isENMode]) {
            make.leading.equalTo(headView).offset(53);
        } else {
            make.leading.equalTo(headView).offset(41);
        }
        make.centerY.equalTo(bidTip);
    }];
    self.totalBidCountLab.adjustsFontSizeToFitWidth = YES;
    self.totalBidCountLab.minimumScaleFactor = 0.3;
    
    // 主动卖出股数
    [headView addSubview:self.totalAskCountLab];
    [self.totalAskCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(askTipLab.mas_trailing).offset(6);
        if ([YXUserManager isENMode]) {
            make.leading.equalTo(headView).offset(53);
        } else {
            make.leading.equalTo(headView).offset(41);
        }
        make.centerY.equalTo(askTip);
    }];
    self.totalAskCountLab.adjustsFontSizeToFitWidth = YES;
    self.totalAskCountLab.minimumScaleFactor = 0.3;
    
    [headView addSubview:self.totalBothCountLab];
    [self.totalBothCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(bothTipLab.mas_trailing).offset(6);

        if ([YXUserManager isENMode]) {
            make.leading.equalTo(headView).offset(53);
        } else {
            make.leading.equalTo(headView).offset(41);
        }
        make.centerY.equalTo(bothTip);
    }];
    self.totalBothCountLab.adjustsFontSizeToFitWidth = YES;
    self.totalBothCountLab.minimumScaleFactor = 0.3;
    
    [headView addSubview:self.totalBidRateLab];
    [self.totalBidRateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(headView).offset(-2);
        make.centerY.equalTo(bidTip);
        make.leading.equalTo(self.totalBidCountLab.mas_trailing).offset(2);
    }];
    
    [headView addSubview:self.totalAskRateLab];
    [self.totalAskRateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(headView).offset(-2);
        make.centerY.equalTo(askTip);
        make.leading.equalTo(self.totalAskCountLab.mas_trailing).offset(2);
    }];
    
    [headView addSubview:self.totalBothRateLab];
    [self.totalBothRateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(headView).offset(-2);
        make.centerY.equalTo(bothTip);
        make.leading.equalTo(self.totalBothCountLab.mas_trailing).offset(2);
    }];
    
//    UIView *lineView = [[UIView alloc] init];
//    lineView.backgroundColor = [QMUITheme separatorLineColor];
//    [headView addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(headView);
//        make.bottom.equalTo(headView);
//        make.height.mas_equalTo(1);
//    }];
//
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.tableView.tableHeaderView = headView;
    
    YXRefreshNormalHeader *header =  [YXRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [header setStateTextColor:[QMUITheme textColorLevel3]];
    self.tableView.mj_header = header;
    header.stateLabel.font = [UIFont systemFontOfSize:10];
    header.arrowView.alpha = 0.0;
    header.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    [self.tableView setContentOffset:CGPointMake(0, 1) animated:NO];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureEvent)];
    [self addGestureRecognizer:tap];
    
    [self addSubview:self.noDataView];
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.statisData.priceData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YXStockDetailStatisticalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXStockDetailStatisticalCell"];
    
    [cell refreshWith:self.statisData.priceData[indexPath.row] priceBase:self.statisData.priceBase.value pClose:[NSString stringWithFormat:@"%u", self.preClose] maxVolume:self.maxVolume];

    return cell;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    // 为了让scorllview不在顶部边界, 可以下拉刷新
    if (contentOffsetY == 0) {
        [scrollView setContentOffset:CGPointMake(0, 1) animated:NO];
    }
}

//MARK: 刷新数据
- (void)setStatisData:(YXAnalysisStatisticData *)statisData {
    _statisData = statisData;
    if (self.tableView.mj_header.isRefreshing) {
        [self.tableView.mj_header endRefreshing];
    }
    
    if (statisData != nil) {
        self.noDataView.hidden = true;
        //获取最大成交量
        for (YXAnalysisStatisticPrice *model in statisData.priceData) {
            if (self.maxVolume < model.volume.value) {
                self.maxVolume = model.volume.value;
            }
        }
        
        NSArray<NSNumber *> *countArr = @[
                @(statisData.totalBidCount.value),
                @(statisData.totalAskCount.value),
                @(statisData.totalBothCount.value),
        ];
        //饼图
        if (statisData.totalBidCount.value == 0 &&
            statisData.totalAskCount.value == 0 &&
            statisData.totalBothCount.value == 0) {
            self.noDataView.hidden = false;
            self.pieView.hidden = true;
        } else {
            self.noDataView.hidden = true;
            self.pieView.hidden = false;
            [self.pieView setForPieViewData:countArr andColor:self.pieColorArr];
        }
                        
        NSString *stockUnit = [YXLanguageUtility kLangWithKey:@"stock_unit_en"];

        UIFont *numberFont = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        UIFont *unitFont = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
        if (YXUserManager.isENMode) {
            // 主动买入股数
            self.totalBidCountLab.text = [YXToolUtility stockData:countArr[0].doubleValue deciPoint:2 stockUnit:stockUnit priceBase:0];

            // 主动卖出股数
            self.totalAskCountLab.text = [YXToolUtility stockData:countArr[1].doubleValue deciPoint:2 stockUnit:stockUnit priceBase:0];

            //中性盘
            self.totalBothCountLab.text = [YXToolUtility stockData:countArr[2].doubleValue deciPoint:2 stockUnit:stockUnit priceBase:0];
        } else {
            // 主动买入股数
            self.totalBidCountLab.attributedText = [YXToolUtility stocKNumberData:countArr[0].longLongValue deciPoint:2 stockUnit:stockUnit priceBase:0 numberFont:numberFont unitFont:unitFont];

            // 主动卖出股数
            self.totalAskCountLab.attributedText = [YXToolUtility stocKNumberData:countArr[1].longLongValue deciPoint:2 stockUnit:stockUnit priceBase:0 numberFont:numberFont unitFont:unitFont];

            //中性盘
            self.totalBothCountLab.attributedText = [YXToolUtility stocKNumberData:countArr[2].longLongValue deciPoint:2 stockUnit:stockUnit priceBase:0 numberFont:numberFont unitFont:unitFont];
        }
        
        // 总数
        float total = countArr[0].floatValue + countArr[1].floatValue + countArr[2].floatValue;
        if (total > 0) {
            
            
            float rato1 = [YXToolUtility yx_roundFloat:countArr[0].floatValue / total andDeciPoint:4];
            float rato2 = [YXToolUtility yx_roundFloat:countArr[1].floatValue / total andDeciPoint:4];
            float rato3 = (1 - rato1 - rato2);
            
            self.totalBidRateLab.text = [NSString stringWithFormat:@"%.2f%%", rato1 * 100];
            self.totalAskRateLab.text = [NSString stringWithFormat:@"%.2f%%", rato2 * 100];
            self.totalBothRateLab.text = [NSString stringWithFormat:@"%.2f%%", rato3 * 100];
        } else {
            self.totalBidRateLab.text = @"--";
            self.totalAskRateLab.text = @"--";
            self.totalBothRateLab.text = @"--";
        }
        
        [self.tableView reloadData];
        
    } else {
        self.noDataView.hidden = false;
        self.pieView.hidden = true;
    }
}


- (void)loadData {
    if (self.loadStactisticDataBlock ) {
        self.loadStactisticDataBlock();
    }
}

- (void)tapGestureEvent {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}


//MARK: getter

- (UILabel *)totalAskCountLab {
    if (!_totalAskCountLab) {
        _totalAskCountLab = [self buildBlackLabelWith:@"--"];
    }
    return _totalAskCountLab;
}
- (UILabel *)totalBidCountLab {
    if (!_totalBidCountLab) {
        _totalBidCountLab = [self buildBlackLabelWith:@"--"];
    }
    return _totalBidCountLab;
}
- (UILabel *)totalBothCountLab {
    if (!_totalBothCountLab) {
        _totalBothCountLab = [self buildBlackLabelWith:@"--"];
    }
    return _totalBothCountLab;
}

- (UILabel *)totalAskRateLab {
    if (!_totalAskRateLab) {
        _totalAskRateLab = [self buildBlackLabelWith:@"--"];
        _totalAskRateLab.textAlignment = NSTextAlignmentRight;
    }
    return _totalAskRateLab;
}
- (UILabel *)totalBidRateLab {
    if (!_totalBidRateLab) {
        _totalBidRateLab = [self buildBlackLabelWith:@"--"];
        _totalBidRateLab.textAlignment = NSTextAlignmentRight;
    }
    return _totalBidRateLab;
}
- (UILabel *)totalBothRateLab {
    if (!_totalBothRateLab) {
        _totalBothRateLab = [self buildBlackLabelWith:@"--"];
        _totalBothRateLab.textAlignment = NSTextAlignmentRight;
    }
    return _totalBothRateLab;
}

- (YXDealStatisticalPieChartView *)pieView {
    if (!_pieView) {
        _pieView = [[YXDealStatisticalPieChartView alloc] initWithFrame:CGRectZero];
        _pieView.sliceSpace = 1;
    }
    return _pieView;
}
//-(UILabel *)pieNoDataLab {
//    if (!_pieNoDataLab) {
//        _pieNoDataLab = [self buildGrayLabelWith:@"暂无数据" alpha:0.5];
//        _pieNoDataLab.textAlignment = NSTextAlignmentCenter;
//        _pieNoDataLab.hidden = true;
//    }
//    return _pieNoDataLab;
//}

- (UIView *)noDataView {
    if (_noDataView == nil) {
        _noDataView = [[UIView alloc] init];
        _noDataView.backgroundColor = [QMUITheme foregroundColor];
    }
    return _noDataView;
}

- (NSArray *)pieColorArr {
    if (!_pieColorArr) {
        _pieColorArr = @[
            [QMUITheme stockRedColor],
            [QMUITheme stockGreenColor],
            [QMUITheme stockGrayColor]
        ];
    }
    return _pieColorArr;
}

//MARK: 构建Label
- (UILabel *)buildBlackLabelWith:(NSString *)text {
    UILabel * lab = [UILabel new];
    lab.text = text;
    lab.textColor = [QMUITheme textColorLevel1];
    lab.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    return lab;
}

- (UILabel *)buildGrayLabelWith:(NSString *)text color: (UIColor *)color {
    UILabel * lab = [UILabel new];
    lab.text = text;
    lab.textColor = color;//0.6 0.65
    lab.font = [UIFont systemFontOfSize:10];
    return lab;
}

- (QMUIButton *)buildRightImgBtnWith:(NSString *)text type:(NSInteger)type {
    QMUIButton *btn = [QMUIButton buttonWithType:UIButtonTypeCustom];
    btn.imagePosition = QMUIButtonImagePositionRight;
    
    
    [btn setTitle:text forState:UIControlStateNormal];//@"总览"
    if (type > 10) {
        if (@available(iOS 11.0, *)) {
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentTrailing;
        } else {
            // Fallback on earlier versions
        }
        
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitleColor:[[QMUITheme textColorLevel3] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
        //[btn setImage:[UIImage imageNamed:@"sd_statistical_default_sort"] forState:UIControlStateNormal];
    } else {
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[QMUITheme textColorLevel3] forState:UIControlStateNormal];
        //[btn setImage:[UIImage imageNamed:@"weaves_detail_help"] forState:UIControlStateNormal];
    }

    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(__kindof UIControl * _Nullable x) {
        //响应
        switch (type) {
            case 1:
                //总览
                break;
            case 11://成交价
                break;
            case 12://主买
                break;
            case 13://主卖
                break;
            case 14://成交量
                break;
            case 15://占比
                break;
                
            default:
                break;
        }
    }];
    return btn;
}

- (YXTableView *)tableView {
    if (!_tableView) {
        _tableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[YXStockDetailStatisticalCell class] forCellReuseIdentifier:@"YXStockDetailStatisticalCell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 18;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

@end

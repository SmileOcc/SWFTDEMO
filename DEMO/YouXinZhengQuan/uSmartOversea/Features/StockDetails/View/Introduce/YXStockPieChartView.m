//
//  YXStockPieChartView.m
//  ChartsDemo-iOS
//
//  Created by JC_Mac on 2018/11/22.
//  Copyright © 2018 dcg. All rights reserved.
//

#import "YXStockPieChartView.h"
#import <Charts/Charts-Swift.h>


@interface YXStockPieChartView ()
 
@property (nonatomic, strong) PieChartView *chartView;


@end

@implementation YXStockPieChartView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
    
}

- (void)initUI{
    
    [self addSubview:self.chartView];
    self.chartView.userInteractionEnabled = NO;
    self.chartView.drawEntryLabelsEnabled = NO; //关闭显示pie分组名称
    self.chartView.drawHoleEnabled = YES;//不空心
    self.chartView.drawCenterTextEnabled = YES; //圆心不加描述
    self.chartView.usePercentValuesEnabled = YES; //使用百分比
    self.chartView.rotationAngle = 270.0; //起始角度
    self.chartView.legend.enabled = NO; //不显示legend
    self.chartView.holeRadiusPercent = 0.65f;
    self.chartView.transparentCircleRadiusPercent = 0.0f;
    [self.chartView setExtraOffsetsWithLeft:30.f top:0.f right:30.f bottom:0.f];
}

- (void)setCenterText:(NSString *)centerText {
    _centerText = centerText;
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:centerText attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14 weight:UIFontWeightRegular], NSForegroundColorAttributeName : QMUITheme.textColorLevel1}];
    self.chartView.centerAttributedText = attrStr;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.chartView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - lazy load
- (PieChartView *)chartView{
    
    if (!_chartView) {
        _chartView = [[PieChartView alloc] init];
    }
    return _chartView;
    
}

#pragma mark - 数据赋值
- (void)setForPieViewData:(NSArray *)dataArray andColor:(NSArray *)colorArr{
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    for (NSNumber *num in dataArray) {
        [entries addObject:[[PieChartDataEntry alloc] initWithValue:num.doubleValue]];
    }
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithEntries:entries];
    
    dataSet.colors = colorArr;
    dataSet.valueLinePart1OffsetPercentage = 1; //折线距离圆心长度
    dataSet.valueLinePart1Length = 0.5; //折线前半段长度
    dataSet.valueLinePart2Length = 0.6; //折线前后b半段长度
    dataSet.valueLineColor = [UIColor clearColor]; //线颜色，只能统一设置
    dataSet.yValuePosition = PieChartValuePositionOutsideSlice; //百分比是否在pie内部
    dataSet.sliceSpace = 2;
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f; //小数位位数
    pFormatter.percentSymbol = @"%";
    pFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]];
    [data setValueTextColor:[UIColor clearColor]]; //设置文字颜色
    self.chartView.data = data;
    [self.chartView highlightValues:nil];

}

- (void)deletePieView{
    
    [self.chartView removeFromSuperview];
    self.chartView = nil;
    
}

@end

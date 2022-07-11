//
//  YXDealStatisticalPieChartView.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXDealStatisticalPieChartView.h"

#import <Charts/Charts-Swift.h>

@interface YXDealStatisticalPieChartView ()

@property (nonatomic, strong) PieChartView *chartView;

@end

@implementation YXDealStatisticalPieChartView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
    
}

- (void)initUI{
    [self addSubview:self.chartView];
    
    self.sliceSpace = 2;
    self.chartView.userInteractionEnabled = NO;
    self.chartView.drawEntryLabelsEnabled = NO; //关闭显示pie分组名称
    self.chartView.drawHoleEnabled = YES;//不空心
    self.chartView.drawCenterTextEnabled = NO; //圆心不加描述
    self.chartView.usePercentValuesEnabled = YES; //使用百分比
    self.chartView.rotationAngle = 270.0; //起始角度
    self.chartView.legend.enabled = NO; //不显示legend
    self.chartView.transparentCircleColor = QMUITheme.foregroundColor;
    self.chartView.holeColor = QMUITheme.foregroundColor;
    self.chartView.holeRadiusPercent = 0.3;
    self.chartView.transparentCircleRadiusPercent = 0.3;
    [self.chartView setExtraOffsetsWithLeft:0.f top:0.f right:0.f bottom:0.f];
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
    dataSet.selectionShift = 0;
    dataSet.valueLinePart1OffsetPercentage = 1; //折线距离圆心长度
    dataSet.valueLinePart1Length = 0.5; //折线前半段长度
    dataSet.valueLinePart2Length = 0.6; //折线前后b半段长度
    dataSet.valueLineColor = [UIColor clearColor]; //线颜色，只能统一设置
    dataSet.yValuePosition = PieChartValuePositionOutsideSlice; //百分比是否在pie内部
    dataSet.sliceSpace = self.sliceSpace;
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f; //小数位位数
    pFormatter.percentSymbol = @"%";
    pFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont systemFontOfSize:12]];
    [data setValueTextColor:[UIColor clearColor]]; //设置文字颜色
    self.chartView.data = data;
    [self.chartView highlightValues:nil];

}

- (void)deletePieView{
    
    [self.chartView removeFromSuperview];
    self.chartView = nil;
    
}

@end

//
//  YXStockPieChartView.h
//  ChartsDemo-iOS
//
//  Created by JC_Mac on 2018/11/22.
//  Copyright © 2018 dcg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXStockPieChartView : UIView

@property (nonatomic, strong) NSString *centerText;

- (void)setForPieViewData:(NSArray *)dataArray andColor:(NSArray *)colorArr;

- (void)deletePieView;

@end



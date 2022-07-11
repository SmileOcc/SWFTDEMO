//
//  YXWarrantsStreetHeaderView.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXWarrantsStreetViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class YXStockTopView;

@interface YXWarrantsStreetHeaderView : UIView

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIView *searchBgView;

@property (nonatomic, strong) UIView *stockView;
@property (nonatomic, strong) UIView *sortView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *marketLab;
@property (nonatomic, strong) UILabel *nowLab;
@property (nonatomic, strong) UILabel *changeLab;
@property (nonatomic, strong) UILabel *rocLab;

@property (nonatomic, strong) QMUIButton *rangeBtn;
@property (nonatomic, strong) QMUIButton *dateBtn;
@property (nonatomic, strong) UIButton *stockBtn;

@property (nonatomic, strong) YXWarrantsStreetViewModel *viewModel;
@property (nonatomic, strong) NSArray *rangeArr;
@property (nonatomic, strong) NSArray *dateArr;

@property (nonatomic, strong) NSString *symbol;

@property (nonatomic, assign) NSInteger rangeIndex;
@property (nonatomic, assign) NSInteger dateIndex;
@property (nonatomic, copy) YXStockTopView *stockInfoView;
@property (nonatomic, strong) UIButton *searchButton;

- (void)cleanStock;

@end

NS_ASSUME_NONNULL_END

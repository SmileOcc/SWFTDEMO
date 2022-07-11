//
//  YXWarrantsHeaderView.h
//  uSmartOversea
//
//  Created by 井超 on 2019/7/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YXStockWarrantsType) {
    YXStockWarrantsTypeBullBear,            //涡轮牛熊
    YXStockWarrantsTypeInlineWarrants,      //界内证
    YXStockWarrantsTypeOptionChain,         //期权链
    YXStockWarrantsTypeCBBC                 //牛熊街货
};

@class YXWarrantBullBearView;
@class YXWarrantSignalView;
@class YXStockTopView;
@interface YXWarrantsHeaderView : UIStackView

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIView *searchBgView;

@property (nonatomic, strong) YXWarrantBullBearView *bullBearView;
@property (nonatomic, strong) YXWarrantSignalView *signalView;

@property (nonatomic, strong) UIView *stockView;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *marketLab;
@property (nonatomic, strong) UILabel *nowLab;
@property (nonatomic, strong) UILabel *changeLab;
@property (nonatomic, strong) UILabel *rocLab;

@property (nonatomic, strong) UIButton *stockBtn;

@property (nonatomic, assign) YXStockWarrantsType warrantType;
@property (nonatomic, copy) void (^lzButtonBlock)(void);

@property (nonatomic, copy) NSString *bullBearCode;
@property (nonatomic, copy) NSString *signalCode;
@property (nonatomic, copy) YXStockTopView *stockInfoView;
@property (nonatomic, strong) UIButton *searchButton;


@property (nonatomic, copy) void (^updateHeightBlock)(CGFloat height);

- (void)showBullBear;
- (void)hideBullBear;
- (void)showSignal;
- (void)hideSignal;

- (void)cleanStock;

- (void)hideLZBButton:(BOOL)ishide;
@end



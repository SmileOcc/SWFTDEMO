//
//  YXWarrantsSortTopView.h
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/6/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXWarrantsSortTopView : UIView

@property (nonatomic, strong) QMUIButton *typeBtn;
@property (nonatomic, strong) QMUIButton *dateBtn;
@property (nonatomic, strong) QMUIButton *moreBtn;
@property (nonatomic, strong) QMUIButton *issuerBtn;
@property (nonatomic, strong) NSArray *typeArr;
@property (nonatomic, strong) NSArray *dateArr;
@property (nonatomic, strong) NSArray *issuerArr;


@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger expireDate;
@property (nonatomic, assign) NSInteger moneyness;
@property (nonatomic, assign) NSInteger issuerIndex;
@property (nonatomic, assign) NSInteger leverageRatio;
@property (nonatomic, assign) NSInteger premium;
@property (nonatomic, assign) NSInteger outstandingRatio;
@property (nonatomic, copy) NSString *outstandingPctLow;
@property (nonatomic, copy) NSString *outstandingPctHeight;
@property (nonatomic, copy) NSString *exchangeRatioLow;
@property (nonatomic, copy) NSString *exchangeRatioHeight;
@property (nonatomic, copy) NSString *recoveryPriceLow; //回收价低
@property (nonatomic, copy) NSString *recoveryPriceHeight; //回收价高

@property (nonatomic, copy) NSString *extendedVolatilityLow; //引申波幅低
@property (nonatomic, copy) NSString *extendedVolatilityHeight; //引申波幅高

- (void)setSortBtnState;

- (void)setSelectedWithButton:(UIButton *)btn;


- (instancetype)initSgWarrantsWithFrame:(CGRect)frame;
@end

NS_ASSUME_NONNULL_END

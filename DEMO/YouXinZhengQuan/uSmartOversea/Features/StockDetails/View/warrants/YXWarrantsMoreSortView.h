//
//  YXWarrantsMoreSortView.h
//  uSmartOversea
//
//  Created by 井超 on 2019/7/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YXTextField;
@interface YXWarrantsMoreSortView : UIView

@property (nonatomic, copy) NSString *outstandingPctLow; //行使价低
@property (nonatomic, copy) NSString *outstandingPctHeight; //行使价高

@property (nonatomic, copy) NSString *exchangeRatioLow; //换股比率低
@property (nonatomic, copy) NSString *exchangeRatioHeight; //换股比率高

@property (nonatomic, copy) NSString *recoveryPriceLow; //回收价低
@property (nonatomic, copy) NSString *recoveryPriceHeight; //回收价高

@property (nonatomic, copy) NSString *extendedVolatilityLow; //引申波幅低
@property (nonatomic, copy) NSString *extendedVolatilityHeight; //引申波幅高


@property (nonatomic, assign) NSInteger moneyness; //价内/价外
@property (nonatomic, assign) NSInteger leverageRatio; //杠杆比率
@property (nonatomic, assign) NSInteger premium; //溢价
@property (nonatomic, assign) NSInteger outstandingRatio; //街货比

@property (nonatomic, strong) YXTextField *outstandingPctLowTextFld;
@property (nonatomic, strong) YXTextField *outstandingPctHeightTextFld;

@property (nonatomic, strong) YXTextField *exchangeRatioLowTextFld;
@property (nonatomic, strong) YXTextField *exchangeRatioHeightTextFld;

@property (nonatomic, strong) YXTextField *recoveryPriceLowTextFld;
@property (nonatomic, strong) YXTextField *recoveryPriceHeightTextFld;

@property (nonatomic, strong) YXTextField *extendedVolatilityLowTextFld;
@property (nonatomic, strong) YXTextField *extendedVolatilityHeightTextFld;

@property (nonatomic, copy) dispatch_block_t confirmBlock;

- (void)setAllBtnState;
- (void)resetBtnAction;

@end

NS_ASSUME_NONNULL_END

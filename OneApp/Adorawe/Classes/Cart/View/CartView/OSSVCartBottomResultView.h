//
//  OSSVOSSVCartBottomResultView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVPriceView.h"

@class OSSVCartBottomResultView;

@protocol OSSVCartBottomResultViewDelegate <NSObject>

@optional
- (void)cartBottomResultView:(OSSVCartBottomResultView *)cartResultView  selectAll:(BOOL)select;
- (void)cartBottomResultView:(OSSVCartBottomResultView *)cartResultView  eventBuy:(BOOL)buy;
@end

@interface OSSVCartBottomResultView : UIView

@property (nonatomic, weak) id<OSSVCartBottomResultViewDelegate>    delegate;
/** 选中按钮*/
@property (nonatomic, strong) UIButton                          *choiceBtn;
@property (nonatomic, strong) UILabel                           *allLabel;
/** 减金额*/
@property (nonatomic, strong) OSSVPriceView                       *deductionView;
/** 金额*/
@property (nonatomic, strong) OSSVPriceView                       *totalView;

/** buy按钮*/
@property (nonatomic, strong) UIButton                          *buyBtn;
@property (nonatomic, strong) UIView                            *lineView;
@property (nonatomic, assign) BOOL                              testFlag;
@property (nonatomic, strong) UILabel                           *taxLabel; //含税label
@property (nonatomic, strong) UILabel                           *tipMsgLabel;
@property (nonatomic, strong) UIImageView                       *tipCoinView;

/**
 * select: 全选
 * count: 商品数量
 */

- (void)updateSelect:(BOOL)select
           cartInfor:(CartInfoModel *)cartInfo
               count:(NSInteger)count;

@end

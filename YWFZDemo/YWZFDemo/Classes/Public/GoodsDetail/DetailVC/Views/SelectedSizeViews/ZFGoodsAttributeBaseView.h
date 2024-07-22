//
//  ZFGoodsAttributeBaseView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFGoodsAttributeBaseView : UIView

// 外部刷新数据源
@property (nonatomic, strong) GoodsDetailModel *model;

- (void)openSelectTypeView;

- (void)hideSelectTypeView;

- (void)changeCartNumberInfo;

- (void)bottomCartViewEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END

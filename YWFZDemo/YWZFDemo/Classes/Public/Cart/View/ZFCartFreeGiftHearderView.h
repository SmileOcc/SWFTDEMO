//
//  ZFCartFreeGiftHearderView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFCartGoodsListModel;

typedef void(^ZFCartFreeGiftActionCompltionHandler)(void);

@interface ZFCartFreeGiftHearderView : UITableViewHeaderFooterView

@property (nonatomic, strong) ZFCartGoodsListModel *model;

@property (nonatomic, copy) ZFCartFreeGiftActionCompltionHandler        cartFreeGiftActionCompltionHandler;

@end


NS_ASSUME_NONNULL_END

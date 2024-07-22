//
//  ZFCartNumberOptionView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CartGoodsCountChangeCompletionHandler)(NSInteger number);

@interface ZFCartNumberOptionView : UIView
@property (nonatomic, assign) NSInteger         goodsNumber;
@property (nonatomic, assign) NSInteger         maxGoodsNumber;
@property (nonatomic, copy) CartGoodsCountChangeCompletionHandler     cartGoodsCountChangeCompletionHandler;
@end


NS_ASSUME_NONNULL_END

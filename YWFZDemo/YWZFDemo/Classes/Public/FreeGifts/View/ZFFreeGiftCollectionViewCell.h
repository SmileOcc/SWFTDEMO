//
//  ZFFreeGiftCollectionViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/5/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFFreeGiftGoodsModel.h"

typedef void(^ZFFreeGiftCollectCompletionHandler)(BOOL isCollect);

@interface ZFFreeGiftCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView               *goodsImageView;
@property (nonatomic, strong) ZFFreeGiftGoodsModel                      *model;

@property (nonatomic, copy) ZFFreeGiftCollectCompletionHandler          freeGiftCollectCompletionHandler;
@end

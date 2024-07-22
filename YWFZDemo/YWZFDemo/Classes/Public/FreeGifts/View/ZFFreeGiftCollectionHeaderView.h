//
//  ZFFreeGiftCollectionHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2018/5/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFFreeGiftListModel.h"

#ifdef __IPHONE_11_0
@interface ZFFreeGiftCustomLayer : CALayer

@end
#endif

@interface ZFFreeGiftCollectionHeaderView : UICollectionReusableView
@property (nonatomic, strong) ZFFreeGiftListModel               *model;
@end

//
//  ZFSearchHistroyHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2017/12/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SearchHistoryClearCompletionHandler)(void);

@interface ZFSearchHistroyHeaderView : UICollectionReusableView
@property (nonatomic, copy) SearchHistoryClearCompletionHandler         searchHistoryClearCompletionHandler;
@end

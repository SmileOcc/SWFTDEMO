//
//  YXTopicStockListView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXHotTopicStockModel;
NS_ASSUME_NONNULL_BEGIN

@interface YXTopicStockListView : UIView

@property (nonatomic, strong) NSArray *list;

@property (nonatomic, copy) void (^stockClickCallBack)(YXHotTopicStockModel *model);

@end

NS_ASSUME_NONNULL_END

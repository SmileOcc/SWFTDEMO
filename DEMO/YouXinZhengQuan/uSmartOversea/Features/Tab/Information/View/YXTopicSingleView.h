//
//  YXTopicSingleView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXHotTopicModel;
@class YXHotTopicStockModel;
    
NS_ASSUME_NONNULL_BEGIN

@interface YXTopicSingleView : UIView

@property (nonatomic, strong) YXHotTopicModel *model;

@property (nonatomic, copy) void (^voteCallBack)(BOOL isFirst);

@property (nonatomic, copy) void (^clickCallBack)(void);

@property (nonatomic, copy) void (^stockClickCallBack)(YXHotTopicStockModel *model);

@end

NS_ASSUME_NONNULL_END

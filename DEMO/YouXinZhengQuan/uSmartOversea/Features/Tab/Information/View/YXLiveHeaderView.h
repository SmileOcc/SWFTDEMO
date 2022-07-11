//
//  YXLiveHeaderView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic, copy) void (^arrowCallBack)(void);

@end

NS_ASSUME_NONNULL_END

//
//  ZFCommunityOutfitBottomMenuView.h
//  ZZZZZ
//
//  Created by YW on 2019/2/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityOutfitBottomMenuView : UIView

@property (nonatomic, strong) NSArray<NSString *>       *datasArray;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, assign) BOOL          isHiddenUnderLineView;

///选择菜单
@property (nonatomic, copy) void (^selectBlock)(NSInteger index);


@end

NS_ASSUME_NONNULL_END

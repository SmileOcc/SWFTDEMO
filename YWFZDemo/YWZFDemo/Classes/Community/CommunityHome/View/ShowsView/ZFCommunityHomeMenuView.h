//
//  ZFCommunityHomeMenuView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityChannelModel.h"

@interface ZFCommunityHomeMenuView : UIView

@property (nonatomic, strong) NSArray       *datasArray;
@property (nonatomic, assign) NSInteger     selectIndex;
@property (nonatomic, assign) BOOL          isHiddenUnderLineView;

///选择菜单
@property (nonatomic, copy) void (^selectBlock)(NSInteger index);

@end


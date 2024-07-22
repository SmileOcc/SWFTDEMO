//
//  ZFCollectionPostsMenuView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityChannelModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCollectionPostsMenuView : UIView

@property (nonatomic, assign) NSInteger     selectIndex;

///选择菜单
@property (nonatomic, copy) void (^indexBlock)(NSInteger index);


@end

NS_ASSUME_NONNULL_END

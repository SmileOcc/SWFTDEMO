//
//  ZFCommunityPostCategoryItemsViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCommunityCategoryPostChannelModel.h"

@interface ZFCommunityPostCategoryItemsViewController : ZFBaseViewController

@property (nonatomic, strong) ZFCommunityCategoryPostChannelModel     *channelModel;
/**上移提示语位置*/
@property (nonatomic, assign) CGFloat                                 tipMoveHeight;

- (void)startRequestData;

@end

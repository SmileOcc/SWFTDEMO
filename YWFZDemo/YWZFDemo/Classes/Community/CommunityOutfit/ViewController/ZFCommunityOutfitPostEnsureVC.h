//
//  ZFCommunityOutfitPostEnsureVC.h
//  ZZZZZ
//
//  Created by YW on 2018/8/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCommunityHotTopicModel.h"
/**
 穿搭发帖 确认界面
 */
@interface ZFCommunityOutfitPostEnsureVC : ZFBaseViewController

@property (nonatomic, strong) UIImage            *postImage;

/// 选择的热门话题
@property (nonatomic, strong) ZFCommunityHotTopicModel    *selectHotTopicModel;

@property (nonatomic, copy) void (^successBlock)(NSDictionary *noteDict);

@end

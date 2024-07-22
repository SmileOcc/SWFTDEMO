//
//  ZFCommunityOutiftConfigurateBordersItemView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityOutfitGoodsCateModel.h"
#import "CategoryRefineSectionModel.h"
#import "ZFCommunityOutfitBorderCateModel.h"
#import "ZFCommunityOutfitBorderViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityOutiftConfigurateBordersItemView : UIView

/** 分类模型*/
@property (nonatomic, strong) ZFCommunityOutfitBorderCateModel     *cateModel;

@property (nonatomic, copy) void (^selectOutfitBorderBlock)(ZFCommunityOutfitBorderModel *borderModel);

- (void)zfViewWillAppear;

- (void)zfReloadView;

@end

NS_ASSUME_NONNULL_END

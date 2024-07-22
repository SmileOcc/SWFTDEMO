//
//  ZFCommunityOutiftConfigurateBorderView.h
//  ZZZZZ
//
//  Created by YW on 2019/2/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityOutfitGoodsCateModel.h"
#import "ZFCommunityOutfitBorderModel.h"
#import "ZFCommunityOutfitBorderCateModel.h"

@class ZFCommunityOutiftConfigurateBordersMenuView;


@interface ZFCommunityOutiftConfigurateBordersView : UIView

@property (nonatomic, strong) ZFCommunityOutiftConfigurateBordersMenuView *menuView;

@property (nonatomic, copy) void (^selectBlock)(ZFCommunityOutfitBorderModel *borderModel);

- (void)updateMenuViewDatas:(NSArray <ZFCommunityOutfitBorderCateModel*> *)menuDatas;
- (void)showMenuView:(BOOL)isShow;

@end


@interface ZFCommunityOutiftConfigurateBordersMenuView : UIView

@property (nonatomic, strong) NSArray<ZFCommunityOutfitBorderCateModel *>       *datasArray;
@property (nonatomic, assign) NSInteger                                         selectIndex;
@property (nonatomic, assign) BOOL                                              isHiddenUnderLineView;

///选择菜单
@property (nonatomic, copy) void (^selectBlock)(NSInteger index);


@end

//
//  ZFOutfitBuilderView.h
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOutfitsWorkSpaceView.h"
#import "ZFOutfitItemModel.h"
#import "ZFCommunityOutfitBorderModel.h"

typedef NS_ENUM(NSInteger, ZFOutfitsEditStatus) {
    ZFOutfitsEditStatusNormal = 0,  // 未编辑
    ZFOutfitsEditStatusEditing      // 正在编辑
};

/**
 穿搭操作视图
 */
@interface ZFOutfitBuilderView : UIView

@property (nonatomic, copy) void (^outfitRuleBlock)(NSString *name);

// 添加相册图片
@property (nonatomic, copy) void (^completionPhoneBlock)(BOOL isAdd);
// 编辑状态
@property (nonatomic, assign) ZFOutfitsEditStatus editStatus;


- (void)changeBorderItemModel:(ZFCommunityOutfitBorderModel *)borderModel;

/**
 将选项添加到画布
 */
- (void)addNewItemWithItemModel:(ZFOutfitItemModel *)itemModel;

/**
 画布截图
 */
- (UIImage *)imageOfOutfitsView;


/**
 底部操作视图高度
 */
+ (CGFloat)bottomOperateHeight;

/**
 初始化画布选择列表
 */
//- (void)initOutfitCanvasWithImageURLs:(NSArray *)urls;

@end

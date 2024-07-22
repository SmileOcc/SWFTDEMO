//
//  ZFOutfitsWorkSpaceView.h
//  ZZZZZ
//
//  Created by YW on 2018/5/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOutfitItemModel.h"
#import "ZFOutfitItemView.h"

/**
 穿搭作业区
 */
@interface ZFOutfitsWorkSpaceView : UIImageView

@property (nonatomic, copy) void(^deleteItem)(void);
@property (nonatomic, copy) void(^cancelAllSelectBlock)(BOOL flag);


- (void)setCanvasWithImage:(UIImage *)image;

- (void)resetAllItemStatus:(BOOL)resetAll;

/** 添加一个*/
- (void)addNewOutfitItemWithItemModel:(ZFOutfitItemModel *)itemModel;

/** 删除选择的*/
- (void)deleteSelectOutfitItemView;

- (ZFOutfitItemView *)currentSelectItemView;

// 当前操作对象向上移动一个位置
- (void)upOutfitItem;

// 当前操作对象向下移动一个位置
- (void)downOufitItem;

@end

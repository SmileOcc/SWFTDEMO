//
//  ZFOutfitItemView.h
//  ZZZZZ
//
//  Created by YW on 2018/5/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOutfitItemModel.h"
/**
 穿搭操作单元
 */
@interface ZFOutfitItemView : UIView

@property (nonatomic, strong) ZFOutfitItemModel   *itemModel;

@property (nonatomic, copy) void (^tapItemBlock)(ZFOutfitItemView *itemView);

- (instancetype)initWithItemModel:(ZFOutfitItemModel *)itemModel mainView:(UIView *)mainView;

- (void)itemStatus:(BOOL)isOperater;
- (void)changeContentImageSize;

@end

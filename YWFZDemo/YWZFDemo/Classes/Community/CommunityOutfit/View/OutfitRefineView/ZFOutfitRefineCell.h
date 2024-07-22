//
//  ZFOutfitRefineCell.h
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityOutfitRefineSectionModel.h"

NS_ASSUME_NONNULL_BEGIN
//typedef void(^RefineInfoChooseBlock)(ZFOutfitRefineCellModel   *model);

@interface ZFOutfitRefineCell : UITableViewCell

@property (nonatomic, assign) BOOL                        isSelect;

@property (nonatomic,strong, readonly)  UILabel           *titleLabel;

//@property (nonatomic, copy) RefineInfoChooseBlock         refineInfoChooseBlock;

@end

NS_ASSUME_NONNULL_END

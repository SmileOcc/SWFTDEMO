//
//  ZFSuperCateViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/11/21.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCategoryParentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFSuperCateViewCell : UITableViewCell

@property (nonatomic, strong) ZFCategoryTabNav *cateTabNav;

- (void)configData:(NSString *)cateName isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END

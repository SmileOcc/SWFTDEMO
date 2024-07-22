//
//  CategorySubCell.h
//  ListPageViewController
//
//  Created by YW on 6/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryNewModel.h"
#import "YYText.h"

typedef void(^CategorySubCellTouchHandler)(BOOL isChoose);

@interface CategorySubCell : UITableViewCell

@property (nonatomic, strong,readonly)  YYLabel          *titleLabel;
@property (nonatomic, assign) BOOL       isSelect;

@property (nonatomic, copy) CategorySubCellTouchHandler   categorySubCellTouchHandler;

+ (NSString *)setIdentifier;

@end

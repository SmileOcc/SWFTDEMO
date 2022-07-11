//
//  OSSVCartLikeTableCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STLCartLikeGoodsModel.h"

@class LikeItemView;

@interface OSSVCartLikeTableCell : UITableViewCell

+ (OSSVCartLikeTableCell *)cellCartLikeTableWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

+ (CGFloat)heightCellCartLike;

@property (nonatomic, strong) NSArray                *datasArray;
@property (nonatomic, strong) LikeItemView           *oneItemView;
@property (nonatomic, strong) LikeItemView           *twoItemView;

//统计来源
@property (nonatomic, assign) CartGroupModelType     sourceType;

@end


@interface LikeItemView : UIControl

@property (nonatomic, strong) YYAnimatedImageView      *imgView;
@property (nonatomic, strong) UILabel                  *priceLabel;

@end

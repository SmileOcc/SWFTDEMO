//
//  HotSearchCollectionCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVHotSearchCCCell : UICollectionViewCell

@property (nonatomic, strong) YYAnimatedImageView        *hotImageView;
@property (nonatomic, strong) UILabel            *titleLabel;
@property (nonatomic, strong) UIView             *lineView;
@property (nonatomic, assign) NSInteger          is_hot;// 是否是热搜词

@end

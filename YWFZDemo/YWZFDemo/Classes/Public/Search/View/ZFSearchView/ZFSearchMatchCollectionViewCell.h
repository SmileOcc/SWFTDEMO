//
//  ZFSearchMatchCollectionViewCell.h
//  ZZZZZ
//
//  Created by YW on 2017/12/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JumpModel;
@interface ZFSearchMatchCollectionViewCell : UICollectionViewCell
@property (nonatomic, copy) NSString *searchKey;
/// 是否显现热门图标
@property (nonatomic, assign) BOOL showHotImage;

@property (nonatomic, strong) JumpModel *model;

@end

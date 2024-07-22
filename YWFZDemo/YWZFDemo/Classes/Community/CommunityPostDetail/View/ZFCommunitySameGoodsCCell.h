//
//  ZFCommunitySameGoodsCCell.h
//  ZZZZZ
//
//  Created by YW on 2018/6/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYAnimatedImageView.h>

@interface ZFCommunitySameGoodsCCell : UICollectionViewCell

@property (nonatomic, strong) YYAnimatedImageView *imageView;
- (void)setGoodsTitle:(NSString *)title;
- (void)setGoodsImageURL:(NSString *)imageURL;
- (void)setGoodsPirce:(NSString *)price;
- (void)setGoodsIsSame:(BOOL)isSame;

@end

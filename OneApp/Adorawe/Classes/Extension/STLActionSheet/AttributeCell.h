//
//  AttributeCell.h
// XStarlinkProject
//
//  Created by 10010 on 2017/9/18.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttributeCell : UICollectionViewCell

+ (AttributeCell *)attributeCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
+ (CGSize)sizeAttributeContent:(NSString *)content;
- (void)setKeyword:(NSString *)keyword isSelect:(BOOL)isSelect isDisable:(BOOL)isDisable;
- (void)setBgImgStr:(NSString *)bgImgStr isSelect:(BOOL)isSelect isDisable:(BOOL)isDisable;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) YYAnimatedImageView *imgV;

@end

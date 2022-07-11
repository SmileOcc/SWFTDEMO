//
//  OSSVCheckOutOneProductCell.h
// XStarlinkProject
//
//  Created by fan wang on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface OSSVCheckOutOneProductCell : UICollectionViewCell
@property (nonatomic, strong) YYAnimatedImageView            *iconView;
@property (nonatomic, strong) UILabel                        *titleLabel;
@property (nonatomic, strong) UILabel                        *propertyLabel;
@property (nonatomic, strong) UILabel                        *priceLabel;
@property (nonatomic, strong) UILabel                        *countLabel;

@property (nonatomic, strong) UIView                         *markView;
@property (nonatomic, strong) UILabel                        *stateLabel;
@property (weak,nonatomic) UIImageView * stateImageView;
@end

NS_ASSUME_NONNULL_END

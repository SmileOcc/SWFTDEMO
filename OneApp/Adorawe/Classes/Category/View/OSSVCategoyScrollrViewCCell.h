//
//  OSSVCategoyScrollrViewCCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCategorysModel.h"
#import "OSSVAdvsEventsModel.h"

@class OSSVCategoyScrollrViewCCell;

@protocol STLCategoyScrollViewCellDelegate <NSObject>

@optional

- (void)categoriesCell:(OSSVCategoyScrollrViewCCell *)cell advModel:(OSSVAdvsEventsModel *)model isBanner:(BOOL)isBanner;

@end

@interface OSSVCategoyScrollrViewCCell : UICollectionViewCell

@property (nonatomic, strong) OSSVCategorysModel *model;

@property (nonatomic, weak) id <STLCategoyScrollViewCellDelegate> categoriesClickDelegate;

+ (CGFloat)scrollViewContentH:(OSSVCategorysModel *)model;

@end



@interface STLCateBannerGuidItemView : UIButton

@property (nonatomic, strong) STLProductImagePlaceholder *featuredImageView;
@property (nonatomic, strong) UILabel *featuredtitleLabel;

- (void)imageUrl:(NSString *)imageUrl name:(NSString *)name;
@end

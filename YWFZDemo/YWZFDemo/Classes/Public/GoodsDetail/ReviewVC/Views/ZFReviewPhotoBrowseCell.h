//
//  ZFReviewPhotoBrowseCell.h
//  ZZZZZ
//
//  Created by YW on 2019/7/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFReviewImageModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFReviewPhotoBrowseCell : UICollectionViewCell

@property (nonatomic, strong) NSString *imageurl;

@property (nonatomic, copy) void (^tapImageBlock)(void);

@end

NS_ASSUME_NONNULL_END

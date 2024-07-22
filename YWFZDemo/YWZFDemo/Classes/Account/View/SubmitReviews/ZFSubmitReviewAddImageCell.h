//
//  ZFSubmitReviewAddImageCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SubmitReviewAddImageType) {
    SubmitReviewAddImageTypeNormal = 0,
    SubmitReviewAddImageTypeAdd,
};

typedef void(^ZFSubmitReviewDeleteImageCompletionHandler)(void);

@interface ZFSubmitReviewAddImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImage                           *image;

@property (nonatomic, assign) SubmitReviewAddImageType          type;

@property (nonatomic, copy) ZFSubmitReviewDeleteImageCompletionHandler      submitReviewDeleteImageCompletionHandler;
@end

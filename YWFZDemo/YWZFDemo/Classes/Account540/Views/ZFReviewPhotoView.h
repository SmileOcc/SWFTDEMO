//
//  ZFReviewPhotoView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrderReviewModel.h"

@interface ZFReviewPhotoView : UIView

@property (nonatomic, strong) NSArray *photosArray;

@property (nonatomic, copy) void(^addImageActionBlock)(void);

@property (nonatomic, copy) void(^showAddImageActionBlock)(NSInteger index, NSArray *rectArray);

@property (nonatomic, copy) void(^deleteImageActionBlock)(NSInteger index);

@end

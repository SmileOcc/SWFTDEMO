//
//  GoodsDetailsReviewsSizeModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodsDetailsReviewsSizeModel : NSObject

@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *bust;
@property (nonatomic, copy) NSString *waist;
@property (nonatomic, copy) NSString *hips;
@property (nonatomic, copy) NSString *overall;
//是否展示
@property (nonatomic, assign) BOOL is_save;

- (NSString *)reviewsOverallContent;

- (BOOL)isShowOverall;

- (BOOL)isShowReviewsSize;

@end

NS_ASSUME_NONNULL_END

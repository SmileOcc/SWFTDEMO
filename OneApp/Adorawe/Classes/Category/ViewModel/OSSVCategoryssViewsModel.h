//
//  OSSVCategoryssViewsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVCategorysVC.h"

@interface OSSVCategoryssViewsModel : BaseViewModel

@property (nonatomic, weak) OSSVCategorysVC   *controller;
@property (nonatomic, strong) NSArray                   *dataArray;


- (void)requestCategoryMenu:(id)parmaters
            completion:(void (^)(id))completion
                           failure:(void (^)(id))failure;

- (void)requestCategory:(id)parmaters
            completion:(void (^)(id))completion
                failure:(void (^)(id))failure;

+ (CGFloat)listFirstRangeTableWidth;
+ (CGFloat)secondRangeCollectionWidth;
+ (CGSize)secondRangeItemSize;
+ (CGSize)cellRangeItemSize;
@end

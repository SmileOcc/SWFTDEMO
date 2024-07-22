//
//  ZFReviewPhotoBrowseView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFReviewImageModel;

@interface ZFReviewPhotoBrowseView : UIView

@property (nonatomic, copy) void (^hasShowLastPageBlock)(void);

@property (nonatomic, copy) void (^refreshStatusBarBlock)(BOOL show);

- (void)setReviewBrowseData:(NSArray<NSString *> *)imageUrlArray
                 reviewText:(NSArray<NSString *> *)reviewTextArray
                currentPage:(NSInteger)currentPage
               isAppendData:(BOOL)isAppendData;

@end

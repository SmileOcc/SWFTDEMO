//
//  ZFGoodsReviewFilterView.h
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ZFReviewFilterType) {
    ZFReviewFilterTypeAll = 0,
    ZFReviewFilterTypeLatest,
    ZFReviewFilterPicture
};

@interface ZFGoodsReviewFilterView : UITableViewHeaderFooterView
@property (nonatomic, strong) UIButton         *allButton;
@property (nonatomic, strong) UIButton         *latestButton;
@property (nonatomic, strong) UIButton         *pictureButton;
@property (nonatomic, strong) NSArray          *filterArray;
@property (nonatomic, copy) void (^filterBlock)(NSArray *filterArray);
@end


@interface ZFReviewFilterModel : NSObject
@property (nonatomic, assign) ZFReviewFilterType   type;
@property (nonatomic, assign) BOOL                 selectState;
@end

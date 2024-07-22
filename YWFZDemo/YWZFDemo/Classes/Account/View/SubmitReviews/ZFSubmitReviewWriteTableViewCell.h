//
//  ZFSubmitReviewWriteTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrderReviewModel.h"
#import "ZFOrderReviewSubmitModel.h"

typedef void(^ZFSubmitReviewWriteContentCompletionHandler)(NSString *content);
typedef void(^ZFSubmitReviewSelectOverallFitHandler)(NSInteger index);

@interface ZFSubmitReviewWriteTableViewCell : UITableViewCell

@property (nonatomic, strong) ZFOrderReviewModel                 *model;

@property (nonatomic, strong) ZFOrderReviewSubmitModel           *editInfo;

@property (nonatomic, copy) ZFSubmitReviewWriteContentCompletionHandler         submitReviewWriteContentCompletionHandler;

@property (nonatomic, copy) ZFSubmitReviewSelectOverallFitHandler submitReviewSelectOverallFitHandler;

@end

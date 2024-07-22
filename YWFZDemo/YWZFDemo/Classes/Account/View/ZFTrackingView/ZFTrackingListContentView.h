//
//  ZFTrackingListContentView.h
//  ZZZZZ
//
//  Created by YW on 6/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFTrackingListModel;
@interface ZFTrackingListContentView : UIView

@property (assign, nonatomic) BOOL hasUpLine;
@property (assign, nonatomic) BOOL hasDownLine;
@property (assign, nonatomic) BOOL currented;

- (void)reloadDataWithModel:(ZFTrackingListModel *)model;

@end

//
//  OSSVDetailTransportTimePopView.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OSSVDetailTransportTimePopView : UIView
/** 阴影层*/
@property (nonatomic, strong) UIView                       *shadeView;
/** 底层容器*/
@property (nonatomic, strong) UIView                       *sheetView;

@property (nonatomic, strong) UIView                       *headerView;
@property (nonatomic, strong) UILabel                      *headerTitleLabel;
@property (nonatomic, strong) UIView                       *headerLineView;
@property (nonatomic, assign) CGPoint                      panGestureBeginPoint;

@property (nonatomic, strong) UILabel                      *titleLabel;
@property (nonatomic, strong) UILabel                      *subTitleLabel;
@property (nonatomic, strong) UIView                       *lineView;
@property (nonatomic, strong) UIButton                     *confirmButton;
@property (nonatomic, strong) UITableView                  *transportTimeTable;

@property (nonatomic, copy) void (^closeViewBlock)();

- (void)updateTransportTimeList:(OSSVDetailsBaseInfoModel *)goodsInforModel;

- (void)dismiss;
-(void)show;

@end


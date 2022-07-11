//
//  OSSVCheckOutCodMsgAlertView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CodDetailView;

@interface OSSVCheckOutCodMsgAlertView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) void(^codAlertBlock)(NSString *resultId, NSString *resultStr);
@property (nonatomic, copy) void(^closeBlock)(void);

@property (nonatomic, strong) UIView            *contentView;
@property (nonatomic, strong) UIView            *headerView;
@property (nonatomic, strong) UILabel           *titleLabel;
//@property (nonatomic, strong) CodDetailView     *subTitleView;
//@property (nonatomic, strong) UILabel           *subTitleLabel;
@property (nonatomic, strong) UIView            *lineView;
@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) UIButton          *closeButton;
@property (nonatomic, strong) UIButton          *confirmButton;
@property (nonatomic, strong) NSArray           *datasArray;

@property (nonatomic, strong) NSIndexPath       *selectIndexPath;

@property (nonatomic, copy) NSString   *order_flow_switch;

@property (nonatomic, assign) CGFloat           detailHeight;

- (void)show;
@end


@interface CodDetailView : UIView

@property (nonatomic, strong) UIScrollView      *bgScroView;
@property (nonatomic, strong) UILabel           *subTitleLabel;

+ (CGFloat)fetchDetailTitleHeight;
@end

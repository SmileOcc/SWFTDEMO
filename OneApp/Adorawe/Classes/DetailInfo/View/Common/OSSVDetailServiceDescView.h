//
//  OSSVDetailServiceDescView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYText.h"
@class DetailServiceDescCell;

@interface OSSVDetailServiceDescView : UIView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray                      *serviceDatas;
/** 阴影层*/
@property (nonatomic, strong) UIView                       *shadeView;
/** 底层容器*/
@property (nonatomic, strong) UIView                       *sheetView;

@property (nonatomic, strong) UILabel                      *titleLabel;
@property (nonatomic, strong) UIButton                     *confirmButton;
@property (nonatomic, strong) UITableView                  *serviceTable;

@property (nonatomic, copy) void (^closeViewBlock)();
@property (nonatomic, copy) void (^gotoWebViewBlock)();

- (void)updateServices:(OSSVDetailsBaseInfoModel *)goodsInforModel;

- (void)dismiss;
-(void)show;

@end



@interface DetailServiceDescCell : UITableViewCell

@property (nonatomic, strong) UIImageView      *iconImageView;
@property (nonatomic, strong) UILabel          *descLabel;
@property (nonatomic, strong) YYLabel          *contentLabel;
@property (nonatomic, strong) NSDictionary     *contentDic;
@end

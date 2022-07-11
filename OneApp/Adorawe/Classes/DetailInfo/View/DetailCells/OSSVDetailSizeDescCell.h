//
//  OSSVDetailSizeDescCell.h
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "OSSVDetailArrView.h"
@import WebKit;

static CGFloat  kSizeDescHeight = APP_TYPE == 3 ? 60 : 50;
NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailSizeDescCell : OSSVDetailBaseCell

/** 描述*/
@property (nonatomic, strong) OSSVDetailArrView                      *descView;

@property (nonatomic, strong) UIView                             *lineView;

@property (nonatomic, strong) OSSVDetailsBaseInfoModel    *model;

@property (strong,nonatomic) WKWebView *webView;
@property (assign,nonatomic) CGFloat bodyH;


- (void)updateHeaderGoodsSelect:(OSSVDetailsBaseInfoModel *)goodsInforModel;


@end

NS_ASSUME_NONNULL_END

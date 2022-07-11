//
//  GoodsDetailHeaderGoodsServiceView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailsBaseInfoModel.h"

@class ServiceItemView;
@class TransportTimeView;
@class OSSVDetailsHeaderServiceView;

@protocol OSSVDetailsHeaderServiceViewDelegate<NSObject>

- (void)goodsDetailsHeaderGoodsServiceView:(OSSVDetailsHeaderServiceView *)goodsServiceView serviceDesc:(BOOL)flag;
- (void)goodsDetailsHeaderGoodsTransportTime:(OSSVDetailsHeaderServiceView *)goodsServiceView serviceDesc:(BOOL)flag;

@end

@interface OSSVDetailsHeaderServiceView : UIView

@property (nonatomic, weak) id<OSSVDetailsHeaderServiceViewDelegate> delegate;
@property (nonatomic, strong) UIView                             *separateLineView;
@property (nonatomic, strong) UIControl                          *serviceBgControl;
@property (nonatomic, strong) UIImageView                        *arrowImgeView;
@property (nonatomic, strong) ServiceItemView                    *firstLeftItem;
@property (nonatomic, strong) ServiceItemView                    *secondRightItem;
@property (nonatomic, strong) ServiceItemView                    *thirdLeftItem;
@property (nonatomic, strong) ServiceItemView                    *fourRightItem;
@property (nonatomic, strong) TransportTimeView                  *transportView; //运输时长View

- (void)updateHeaderGoodsService:(OSSVDetailsBaseInfoModel *)goodsInforModel;

+ (CGFloat)heightGoodsServiceView:(OSSVDetailsBaseInfoModel *)goodsInforModel;

@end

@interface ServiceItemView : UIView

@property (nonatomic, strong) UIImageView      *iconImageView;
@property (nonatomic, strong) UILabel          *descLabel;

@end

//运输时长View
@interface TransportTimeView : UIControl

@property (nonatomic, strong) UILabel *shipGlobal;
@property (nonatomic, strong) UILabel *shipTimeLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
 
@end

//
//  OSSVOrdereTrackeeView.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVOrdereTrackeeView : UIView

@property (nonatomic, strong) UIView  *carImgBg; //物流车背景
@property (nonatomic, strong) UIImageView *trackCarImgView; //物流小车
@property (nonatomic, strong) UILabel *transitLabel;//物流状态
@property (nonatomic, strong) UILabel *tradingStatusLabel;//状态描述
@property (nonatomic, strong) UILabel *trackCodeNum;//物流单号
@property (nonatomic, strong) YYAnimatedImageView *addressImg;//地址图标
@property (nonatomic, strong) UILabel *addressLabel;//地址
@property (nonatomic, strong) UILabel *timeLabel;   //时间
@property (nonatomic, strong) YYAnimatedImageView *arrowImg; //右箭头

@property (nonatomic, strong) UILabel *noOrderLabel;


@end

NS_ASSUME_NONNULL_END

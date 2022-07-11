//
//  OSSVTransporteSpliteView.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVTransporteSpliteView : UIView
@property (nonatomic, strong) UIView  *carImgBg; //物流车背景
@property (nonatomic, strong) UIImageView *trackCarImgView; //物流小车
@property (nonatomic, strong) UILabel *detail;//拆单描述
@property (nonatomic, strong) YYAnimatedImageView *arrowImg; //右箭头

@end

NS_ASSUME_NONNULL_END

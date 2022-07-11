//
//  OSSVDetaailheaderColorSizeView.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVSizeDidSelectProtoCol.h"

NS_ASSUME_NONNULL_BEGIN

@class ColorSizePickView;

@interface OSSVDetaailheaderColorSizeView : UIView <OSSVSizeDidSelectProtocol>

@property (nonatomic, strong)OSSVDetailsBaseInfoModel *baseModel;
@property (nonatomic, assign)BOOL                            isSelectedSize;//用于判断第一次进入不选中尺码 1.4.0

- (CGFloat)getTipViewHeight;
+ (CGFloat)getTipViewHeightWith:(OSSVDetailsBaseInfoModel *)baseModel;

@property (nonatomic,strong) ColorSizePickView *colorSizeViewVIV;


@end

NS_ASSUME_NONNULL_END

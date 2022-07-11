//
//  OSSVDetailsHeaderScrollverAdvView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OSSVDetailsHeaderScrollverAdvView : UIView

@property (nonatomic, strong) OSSVDetailsBaseInfoModel  *goodsInforModel;

@property (nonatomic, strong) NSArray<OSSVAdvsEventsModel*>  *advBanners;
@property (nonatomic, copy) void(^advBlock)(OSSVAdvsEventsModel *model);

//+ (CGFloat)heightGoodsScrollerAdvView:(NSArray<OSSVAdvsEventsModel *> *)advBanners;
@end




@interface GoodsHeaderScrollerItemCCell : UICollectionViewCell

@property (nonatomic, strong) YYAnimatedImageView *imgView;

@property (nonatomic, strong) OSSVAdvsEventsModel    *model;
@end

//
//  OSSVDetailsHeaderView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailHeaderReviewModel.h"

#import "OSSVDetailsListModel.h"
#import "OSSVDetailsHeaderInforView.h"


typedef NS_ENUM(NSInteger, GoodsDetailsHeaderEvent) {
    GoodsDetailsHeaderEventCollect = 0,
    GoodsDetailsHeaderEventShare,
    GoodsDetailsHeaderEventGoodsSimilar,
};

@protocol OSSVDetailsHeaderViewDelegate <NSObject>

-(void)OSSVDetailsHeaderViewDidClick:(GoodsDetailsHeaderEvent)event;
@end

@interface OSSVDetailsHeaderView : UICollectionReusableView

+ (OSSVDetailsHeaderView*)goodsDetailsHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath;
+ (CGFloat)headerViewHeight;

- (void)updateDetailInfoModel:(OSSVDetailsListModel *)model recommend:(BOOL)hasRecommend;
@property (nonatomic, weak) id<OSSVDetailsHeaderViewDelegate>delegate;

/**封面图片*/
@property (nonatomic, copy) NSString                      *coverImageUrl;

/** 收藏按钮*/
@property (nonatomic, strong) EmitterButton               *collectBtn;
@property (nonatomic, assign) BOOL                        isCollect;
@property (nonatomic, strong) UIButton                    *shareBtn;
@property (nonatomic, strong) UIImageView                 *shareImgV;
@property (nonatomic, strong) UIView                      *shareBgV;


-(void)clearMemory;
@end


//
//  ZFTopicDetailTileCollectionReusableView.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFTopicDetailTitleType) {
    ZFTopicDetailTitleTypeSimilar = 0,          // 同款商品
    ZFTopicDetailTitleTypeNomarlRelated,        // 相关普通帖子
    ZFTopicDetailTitleTypeOutfitRelated         // 相关穿搭帖子
};

@interface ZFPostDetailTileCollectionReusableView : UICollectionReusableView

@property (nonatomic, copy) void (^moreActionHandle)(void);
+ (ZFPostDetailTileCollectionReusableView *)titleHeaderViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath type:(ZFTopicDetailTitleType)type;

- (void)hideMoreView;
@end

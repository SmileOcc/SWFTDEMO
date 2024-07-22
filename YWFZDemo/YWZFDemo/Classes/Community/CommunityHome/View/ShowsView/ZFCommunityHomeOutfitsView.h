//
//  ZFCommunityHomeOutfitsView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeChannelBaseView.h"
#import "ZFCommunityChannelModel.h"

@interface ZFCommunityHomeOutfitsView : ZFCommunityHomeChannelBaseView

- (instancetype)initWithFrame:(CGRect)frame itemModel:(ZFCommunityChannelItemModel *)itemModel startRequest:(BOOL)start;

@property (nonatomic, strong) ZFCommunityChannelItemModel    *itemModel;

///开始请求
- (void)startFirstRequest;
///刷新内容
- (void)updateItemModel:(ZFCommunityChannelItemModel *)itemModel;

/**
 UICollectionView scrollsToTop state
 
 @return defaulte is NO
 */
- (BOOL)collectionViewScrollsTopState;
@end
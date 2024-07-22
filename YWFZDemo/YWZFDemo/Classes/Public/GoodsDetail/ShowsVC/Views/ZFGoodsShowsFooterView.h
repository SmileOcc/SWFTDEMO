//
//  ZFGoodsShowsFooterView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ZFGoodsShowsFooterView : UIView

@property (nonatomic, copy) void (^selectIndexCompletion)(NSInteger index);

- (void)showDataWithSku:(NSString *)goods_sn;

- (void)selectCustomIndex:(NSInteger)index;

- (BOOL)fetchRelatedCollectionStatuss;

@end

NS_ASSUME_NONNULL_END

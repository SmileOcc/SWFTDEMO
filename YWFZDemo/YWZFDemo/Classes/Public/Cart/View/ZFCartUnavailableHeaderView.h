//
//  ZFCartUnavailableHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CartUnavailableGoodsClearAllCompletionHandler)(void);

@interface ZFCartUnavailableHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) CartUnavailableGoodsClearAllCompletionHandler       cartUnavailableGoodsClearAllCompletionHandler;

@end


NS_ASSUME_NONNULL_END

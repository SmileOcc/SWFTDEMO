//
//  ZFCartUnavailableViewAllFooterView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CartUnavailableViewAllSelectCompletionHandler)(BOOL isShowMore);

@interface ZFCartUnavailableViewAllFooterView : UITableViewHeaderFooterView
@property (nonatomic, assign) BOOL          isShowMore;
@property (nonatomic, copy) CartUnavailableViewAllSelectCompletionHandler       cartUnavailableViewAllSelectCompletionHandler;
@end

NS_ASSUME_NONNULL_END

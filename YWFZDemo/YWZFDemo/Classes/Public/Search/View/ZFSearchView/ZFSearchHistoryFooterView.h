//
//  ZFSearchHistoryFooterView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SearchHistoryMoreCompletionHandler)(void);

@interface ZFSearchHistoryFooterView : UICollectionReusableView

@property (nonatomic, copy) SearchHistoryMoreCompletionHandler         searchHistoryMoreCompletionHandler;

@end



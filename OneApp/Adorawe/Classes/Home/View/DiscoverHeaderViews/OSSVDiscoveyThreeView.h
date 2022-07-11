//
//  DiscoveryThreeView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DiscoveryThreeViewDelegate <NSObject>

- (void)tapThreeViewItemActionAtIndex:(NSInteger)index;

@end


@interface OSSVDiscoveyThreeView : UIView

@property (nonatomic, weak) id <DiscoveryThreeViewDelegate> delegate;
@property (nonatomic, strong) NSArray <OSSVAdvsEventsModel *>         *modelArray;
@property (nonatomic, strong) UIButton                      *superDealsButton;
@property (nonatomic, strong) UIButton                      *newinButton;
@property (nonatomic, strong) UIButton                      *bestSellersButton;
@end

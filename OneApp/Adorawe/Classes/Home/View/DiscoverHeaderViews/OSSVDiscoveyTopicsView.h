//
//  DiscoveryTopicView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DiscoveryTopicViewDelegate <NSObject>

- (void)tapTopicViewItemActionAtIndex:(NSInteger)index;

@end

@interface OSSVDiscoveyTopicsView : UIView

@property (nonatomic, weak) id <DiscoveryTopicViewDelegate> delegate;

- (void)makeTopicViewsWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray;

@end



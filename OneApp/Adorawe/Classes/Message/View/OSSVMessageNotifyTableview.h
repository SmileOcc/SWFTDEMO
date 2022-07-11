//
//  OSSVMessageNotifyTableview.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STLMessageNotifyTableviewDelegate<NSObject>

@optional

- (void)didDeselectItem:(OSSVAdvsEventsModel*)OSSVAdvsEventsModel;

@end

@interface OSSVMessageNotifyTableview : UITableView

@property (nonatomic, weak) id <STLMessageNotifyTableviewDelegate> myDelegate;
@property (nonatomic, strong) NSArray *dataArray;

- (void)updateData;

@end

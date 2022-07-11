//
//  OSSVMessageActivityTableview.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol STLMessageActivityTableviewDelegate<NSObject>

@optional

- (void)didDeselectItem:(OSSVAdvsEventsModel*)OSSVAdvsEventsModel;

@end

@interface OSSVMessageActivityTableview : UITableView

@property (nonatomic, weak) id <STLMessageActivityTableviewDelegate> myDelegate;
@property (nonatomic, strong) NSArray *dataArray;

- (void)updateData;

@end

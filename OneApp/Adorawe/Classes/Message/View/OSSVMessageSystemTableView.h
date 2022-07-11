//
//  OSSVMessageSystemTableView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVMessageSystemCell.h"


@protocol STLMessageSystemTableViewDelegate<NSObject>

@optional

- (void)didDeselectItem:(OSSVAdvsEventsModel*)OSSVAdvsEventsModel;

@end

@interface OSSVMessageSystemTableView : UITableView

@property (nonatomic, weak) id <STLMessageSystemTableViewDelegate>  myDelegate;
@property (nonatomic, strong) NSArray                               *dataArray;

- (void)updateData;

@end

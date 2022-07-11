//
//  OSSVMessageTableView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVMessageListModel.h"
#import "OSSVMessageBriefCell.h"

@protocol STLMessageTableviewDelegate<NSObject>

@optional

- (void)didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)messageTableScrolling:(UIScrollView *)scrollView;

@end

@interface OSSVMessageTableView : UITableView

@property (nonatomic, strong) OSSVMessageListModel           *model;
@property (nonatomic,weak) id <STLMessageTableviewDelegate> myDelegate ;

@end

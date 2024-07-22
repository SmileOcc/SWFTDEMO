//
//  ZFSearchResultMatchTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2017/12/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFSearchResultMatchTableViewCell : UITableViewCell
@property (nonatomic, copy) NSString            *matchKey;
@property (nonatomic, copy) NSString            *searchKey;
@property (nonatomic, strong) UIImageView       *historySearchImageView;
@end

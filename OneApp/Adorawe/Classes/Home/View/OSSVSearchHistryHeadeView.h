//
//  SearchHistoryHeaderView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchHistoryHeaderViewDelegate <NSObject>

- (void)deleteSearchHistory;

@end

@interface OSSVSearchHistryHeadeView : UICollectionReusableView

@property (nonatomic, weak) id <SearchHistoryHeaderViewDelegate>  delegate;
@property (nonatomic, strong) UILabel                             *searchLab;
@property (nonatomic, strong) UIView                              *line;
@property (nonatomic, strong) UIButton                            *deleteBtn;
@end

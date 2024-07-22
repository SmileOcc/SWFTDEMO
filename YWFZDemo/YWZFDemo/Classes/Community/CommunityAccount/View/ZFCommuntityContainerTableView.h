//
//  ZFCommuntityContainerTableView.h
//  ZZZZZ
//
//  Created by YW on 2018/4/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kZFCommunityAccountShowViewIdentifier = @"kZFCommunityAccountShowViewIdentifier";
static NSString *const kZFCommunityAccountFavesViewIdentifier = @"kZFCommunityAccountFavesViewIdentifier";

@interface ZFCommuntityContainerTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UICollectionView              *collectionView;

- (instancetype)initWithFrame:(CGRect)frame
                        style:(UITableViewStyle)style
            containerDelagate:(id)containerDelagate
            sectionHeaderView:(UIView *)sectionHeaderView;

@end

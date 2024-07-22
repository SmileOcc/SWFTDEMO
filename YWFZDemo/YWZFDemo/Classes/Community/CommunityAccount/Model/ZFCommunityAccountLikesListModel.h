//
//  ZFCommunityAccountLikesListModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunityAccountLikesListModel : NSObject
@property (nonatomic,copy) NSString *type;
@property (nonatomic,assign) NSInteger curPage;
@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,strong) NSArray *list;
@end

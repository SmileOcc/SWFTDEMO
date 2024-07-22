//
//  ZFVideoCommentListView.m
//  Zaful
//
//  Created by occ on 2019/8/13.
//  Copyright © 2019 Zaful. All rights reserved.
//

#import "ZFVideoLiveCommentListView.h"

@interface ZFVideoLiveCommentListView()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ZFVideoLiveCommentListView

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFVideoLiveCommentListView *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZFVideoLiveCommentListView alloc] init];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.messageTable];
        
    }
    return self;
}

- (UITableView *)messageTable {
    if (!_messageTable) {
        _messageTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _messageTable.delegate = self;
        _messageTable.dataSource = self;
        
        [_messageTable registerClass:[ZFCommunityLiveChatMessageCell class] forCellReuseIdentifier:NSStringFromClass(ZFCommunityLiveChatMessageCell.class)];
    }
    return _messageTable;
}




@end

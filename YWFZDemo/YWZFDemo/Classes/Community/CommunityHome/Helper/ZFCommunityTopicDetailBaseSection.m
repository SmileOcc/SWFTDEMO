//
//  ZFCommunityTopicDetailBaseSection.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailBaseSection.h"
#import "ZFFrameDefiner.h"

@implementation ZFCommunityTopicDetailBaseSection

- (instancetype)init {
    if (self = [super init]) {
        self.rowCount                   = 0;
        self.columnCount                = 1;
        self.footerSize                 = CGSizeMake(0.0, 0.0);
        self.headerSize                 = CGSizeMake(0.0, 0.0);
        self.edgeInsets                 = UIEdgeInsetsMake(0, 0, 0, 0);
        self.minimumLineSpacing         = 0.0f;
        self.minimumInteritemSpacing    = 0.0f;
        self.itemSize                    = CGSizeMake(KScreenWidth, 0.0f);
    }
    return self;
}

#pragma mark getter/setter
- (void)setRowCount:(NSInteger)rowCount {
    _rowCount = rowCount;
}

@end

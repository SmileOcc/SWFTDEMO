//
//  OSSVMessageSystemTableView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageSystemTableView.h"

@interface OSSVMessageSystemTableView ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation OSSVMessageSystemTableView

#pragma mark - public methods

- (void)updateData {
    [self reloadData];
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        self.backgroundColor = [OSSVThemesColors col_F5F5F5];
        self.separatorStyle = NO;
        [self setShowsVerticalScrollIndicator:NO];
        self.estimatedRowHeight = UITableViewAutomaticDimension;
        self.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
        self.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
        [self registerClass:[OSSVMessageSystemCell class] forCellReuseIdentifier:NSStringFromClass(OSSVMessageSystemCell.class)];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(OSSVMessageSystemCell.class) cacheByIndexPath:indexPath configuration:^(OSSVMessageSystemCell *cell) {
        [cell setModel:_dataArray[indexPath.section]];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVMessageSystemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVMessageSystemCell.class)];
    [cell setModel:_dataArray[indexPath.section]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSSVMessageModel *model = _dataArray[indexPath.section];
    
    OSSVAdvsEventsModel *advEvent = [[OSSVAdvsEventsModel alloc] init];
    advEvent.actionType = AdvEventTypeInsertH5;
    advEvent.url  = STLToString(model.jump_url);
    advEvent.name = STLToString(model.title);
    advEvent.msgId = STLToString(model.message_id);
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(didDeselectItem:)]) {
        [self.myDelegate didDeselectItem:advEvent];
    }

}

@end

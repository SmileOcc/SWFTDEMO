//
//  OSSVMessageNotifyTableview.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageNotifyCell.h"
#import "OSSVMessageNotifyTableview.h"

@interface OSSVMessageNotifyTableview ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation OSSVMessageNotifyTableview

#pragma mark - public methods

- (void)updateData
{
    [self reloadData];
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        self.backgroundColor = OSSVThemesColors.col_F5F5F5;
        self.separatorStyle = NO;
        [self setShowsVerticalScrollIndicator:NO];
        self.estimatedRowHeight = UITableViewAutomaticDimension;
        self.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
        self.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
        [self registerClass:[OSSVMessageNotifyCell class] forCellReuseIdentifier:NSStringFromClass(OSSVMessageNotifyCell.class)];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(OSSVMessageNotifyCell.class) cacheByIndexPath:indexPath configuration:^(OSSVMessageNotifyCell *cell) {
        [cell setModel:_dataArray[indexPath.section]];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVMessageNotifyCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVMessageNotifyCell.class)];
    [cell setModel:_dataArray[indexPath.section]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSSVMessageModel *model = _dataArray[indexPath.section];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (model.jump_url)
    {
        NSArray *availableArr = [model.jump_url componentsSeparatedByString:@"?"];
        if (availableArr.count >= 2)
        {
            NSArray *arr = [availableArr[1] componentsSeparatedByString:@"&"];
            for (NSString *str in arr)
            {
                if ([str rangeOfString:@"="].location != NSNotFound)
                {
                    NSString *key   = [str componentsSeparatedByString:@"="][0];
                    NSString *value = [str componentsSeparatedByString:@"="][1];
                    value = REMOVE_URLENCODING(STLToString(value));
                    [params setObject:value forKey:key];
                }
            }
        }
    }
    
    OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
    advEventModel.actionType = AdvEventTypeDefault;
    advEventModel.url  = @"";
    advEventModel.name = @"";
    advEventModel.msgId = STLToString(model.message_id);
    if (params.count > 0)
    {
        advEventModel.actionType = [params[@"actiontype"] integerValue];
        advEventModel.url = STLToString(params[@"url"]);
        advEventModel.name = STLToString(params[@"name"]);
        [self.myDelegate didDeselectItem:advEventModel];
    }
}


@end

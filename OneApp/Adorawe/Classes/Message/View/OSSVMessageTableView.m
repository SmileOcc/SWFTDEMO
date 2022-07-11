//
//  OSSVMessageTableView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageCell.h"
#import "OSSVMessageTableView.h"

@interface OSSVMessageTableView()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>


@end

@implementation OSSVMessageTableView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.dataSource = self;
        self.delegate = self;
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        self.tableHeaderView = header;
//        [self registerClass:[OSSVMessageCell class] forCellReuseIdentifier:NSStringFromClass(OSSVMessageCell.class)];
        [self registerClass:[OSSVMessageBriefCell class] forCellReuseIdentifier:NSStringFromClass(OSSVMessageBriefCell.class)];

    }
    return self;
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.bubbles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(OSSVMessageBriefCell.class) cacheByIndexPath:indexPath configuration:^(OSSVMessageBriefCell *cell) {
        if (self.model.bubbles.count > indexPath.section) {
            [cell setModel:_model.bubbles[indexPath.section]];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVMessageBriefCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVMessageBriefCell.class) forIndexPath:indexPath];
//    if (indexPath.section == 0)
//    {
//        UIView *topLine = [UIView new];
//        topLine.backgroundColor = OSSVThemesColors.col_EFEFEF;
//        [cell.contentView addSubview:topLine];
//        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.trailing.top.mas_equalTo(0);
//            make.height.mas_equalTo(@(MIN_PIXEL));
//        }];
//        OSSVMessageModel *service = [[OSSVMessageModel alloc] init];
//        service.title = STLLocalizedString_(@"onlineCustomService",nil);
//        service.content = STLLocalizedString_(@"viewOnlineCustomServiceMessage",nil);
//        service.type = @"0";
//        [cell setModel:service];
//    }
//    else
//    {
//        if (indexPath.row == 0)
//        {
//            UIView *topLine = [UIView new];
//            topLine.backgroundColor = OSSVThemesColors.col_EFEFEF;
//            [cell.contentView addSubview:topLine];
//            [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.leading.trailing.top.mas_equalTo(0);
//                make.height.mas_equalTo(@(MIN_PIXEL));
//            }];
//        }
    if (self.model.bubbles.count > indexPath.section) {
        [cell setModel:_model.bubbles[indexPath.section]];
    }
//    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.myDelegate didDeselectRowAtIndexPath:indexPath];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(messageTableScrolling:)]) {
        [self.myDelegate messageTableScrolling:scrollView];
    }
}
#pragma mark - private methods


@end

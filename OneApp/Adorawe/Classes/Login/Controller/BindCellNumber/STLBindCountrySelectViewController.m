//
//  STLBindCountrySelectViewController.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBindCountrySelectViewController.h"
#import "STLBindCountryCell.h"
#import "OSSVAddresseCountryeHeaderView.h"

@interface STLBindCountrySelectViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak,nonatomic) UITableView *tableView;
@end

@implementation STLBindCountrySelectViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI{
    self.title = STLLocalizedString_(@"bind_seelct_country", nil);
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    tableView.tableHeaderView = [UIView new];
    tableView.separatorColor = OSSVThemesColors.col_F1F1F1;
    tableView.allowsSelection = YES;
    tableView.sectionIndexColor = [UIColor blackColor];
    [tableView registerClass:[STLBindCountryCell class] forCellReuseIdentifier:NSStringFromClass(STLBindCountryCell.class)];
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIS_IPHONEX) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, STL_TABBAR_IPHONEX_H, 0));
        } else {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }
    }];
    _tableView = tableView;
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keyArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *countrys = self.keyArr[section].countries;
    return countrys.count;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 28)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH-24, 28)];
    label.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    label.text = self.keyArr[section].key;
    headerView.backgroundColor = OSSVThemesColors.col_FAFAFA;
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = OSSVThemesColors.col_0D0D0D;
    [headerView addSubview:label];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 28; // wei 确认
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STLBindCountryCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(STLBindCountryCell.class)];
    STLBindCountryModel *model = self.keyArr[indexPath.section].countries[indexPath.row];
//    if ([self.countryName isEqualToString:model.countryName]) {
//        cell.textLabel.textColor = OSSVThemesColors.col_FF9522;
//    } else {
//        cell.textLabel.textColor = OSSVThemesColors.col_333333;
//    }
    
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STLBindCountryModel *model = self.keyArr[indexPath.section].countries[indexPath.row];
    if (self.countryBlock) {
        self.countryBlock(model);
    }
}
//添加索引列
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self sectionIndexs];
}

//索引列点击事件
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    return index;
}

-(NSArray *)sectionIndexs{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (STLBIndCountryGroup *gp in self.keyArr) {
        [arr addObject:gp.key];
    }
    return arr;
}
@end

//
//  ZFSelectShippingViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/9/11.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFSelectShippingViewController.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFGrowingIOAnalytics.h"
#import "CustomTextField.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFSelectShippingViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) CustomTextField *dniTextField;                ///税号输入框
@property (nonatomic, strong) NSMutableArray *datasourceList;
@end

@implementation ZFSelectShippingViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shippingList = [[NSArray alloc] init];
        self.datasourceList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"Title_ShippingMethod", nil);
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

-(void)setIsCod:(BOOL)isCod
{
    _isCod = isCod;
    
    if (!_isCod) {
        [self.shippingList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ShippingListModel *model = obj;
            if (!model.is_cod_ship.integerValue) {
                [self.datasourceList addObject:model];
            }
        }];
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasourceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFOrderShippingListCell *cell = [tableView dequeueReusableCellWithIdentifier:[ZFOrderShippingListCell queryReuseIdentifier]];
    ShippingListModel *model = self.datasourceList[indexPath.row];
    cell.isCod = self.isCod;
    cell.shippingListModel = model;
    cell.isChoose = NO;
    if ([model.iD isEqualToString:self.selectShippingModel.iD]) {
        cell.isChoose = YES;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectShippingComplation) {
        ShippingListModel *model = self.datasourceList[indexPath.row];
        if ([model isKindOfClass:[ShippingListModel class]]) {
            self.selectShippingComplation(self.datasourceList[indexPath.row]);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

#pragma mark - textField delegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.didEndEditDniBlock) {
        self.didEndEditDniBlock(textField.text);
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //限制32位输入
    if (textField.text.length > 31 && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

#pragma mark - setter and getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 112;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 96, 0);
        CGRect footFrame = CGRectZero;
        footFrame.size = [self.footerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.footerView.frame = footFrame;
        if (self.isShowTax) {
            _tableView.tableFooterView = self.footerView;
        }else{
            _tableView.tableFooterView = [UIView new];
        }
        [_tableView registerClass:[ZFOrderShippingListCell class] forCellReuseIdentifier:[ZFOrderShippingListCell queryReuseIdentifier]];
    }
    return _tableView;
}

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            if (YES) {
                UILabel *label = [[UILabel alloc] init];
                label.text = ZFLocalizedString(@"choose_tax_shipping", nil);
                label.textColor = [UIColor colorWithHexString:@"999999"];
                label.numberOfLines = 0;
                label.font = [UIFont systemFontOfSize:12];
                label.preferredMaxLayoutWidth = KScreenWidth - 24;
                [view addSubview:label];
                
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(view);
                    make.leading.mas_equalTo(view.mas_leading).mas_offset(12);
                    make.trailing.mas_equalTo(view.mas_trailing).mas_offset(-12);
                }];
                
                [view addSubview:self.dniTextField];
                
                [self.dniTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(label.mas_bottom).mas_offset(8);
                    make.leading.trailing.mas_equalTo(view);
                    make.height.mas_offset(48);
                    make.bottom.mas_equalTo(view.mas_bottom);
                }];
            }
            view;
        });
    }
    return _footerView;
}

- (CustomTextField *)dniTextField
{
    if (!_dniTextField) {
        _dniTextField = ({
            CustomTextField *textField = [[CustomTextField alloc] init];
            textField.backgroundColor = [UIColor whiteColor];
            textField.placeholder = ZFLocalizedString(@"DNI number", nil);
            textField.textAlignment = NSTextAlignmentLeft;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.font = [UIFont systemFontOfSize:16];
            textField.delegate = self;
            textField.placeholderPadding = 12;
            if (ZFToString(self.oldTaxString).length) {
                textField.text = self.oldTaxString;
            }
            textField;
        });
    }
    return _dniTextField;
}

@end

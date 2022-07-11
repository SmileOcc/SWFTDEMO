//
//  YXStockFilterMarketGroupVC.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockFilterMarketGroupVC.h"
#import "YXStockFilterMarketGroupViewModel.h"
#import "YXStockFilterGroupCell.h"
#import "uSmartOversea-Swift.h"
#import <MJRefresh/MJRefresh.h>
#import "UILabel+create.h"
#import <YYCategories/YYCGUtilities.h>
#import <Masonry/Masonry.h>
#import <IQKeyboardManagerSwift-Swift.h>

@interface YXStockFilterMarketGroupVC ()
@property (nonatomic, strong, readonly) YXStockFilterMarketGroupViewModel *viewModel;
@property (nonatomic, assign) BOOL isFirst;
@end


@implementation YXStockFilterMarketGroupVC
@dynamic viewModel;

- (void)viewDidLoad {
    // Do any additional setup after loading the view.

    [super viewDidLoad];

    self.view.backgroundColor = [QMUITheme backgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_isFirst) {
        [self loadFirstPage];
    }
    _isFirst = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)bindViewModel {
    [super bindViewModel];

}

- (void)configureCell:(YXStockFilterGroupCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {

    @weakify(self)
    cell.operateBlock = ^(YXStockFilterGroupOperateType type) {
        @strongify(self)
        if (type == YXStockFilterGroupOperateTypeModify) {
            [self modifyAction:object];
        } else if (type == YXStockFilterGroupOperateTypeRename) {
            [self renameAction:object];
        } else if (type == YXStockFilterGroupOperateTypeDelete) {
            [self deleteAction:object];
        }
    };

    [super configureCell:cell atIndexPath:indexPath withObject:object];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.dataSource.count > 0 && indexPath.row < self.viewModel.dataSource.firstObject.count) {
        YXStockFilterUserFilterList *model = self.viewModel.dataSource.firstObject[indexPath.row];
        return model.groups.count * 26 + 76;
    }
    return [self rowHeight];
}


- (void)deleteAction:(YXStockFilterUserFilterList *)model {


    NSString *title = [YXLanguageUtility kLangWithKey:@"filter_delete_message"];
    YXAlertView *alertView = [YXAlertView alertViewWithMessage:title];
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction *action) {}]];
    @weakify(self)
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm"] style:YXAlertActionStyleDefault handler:^(YXAlertAction *action) {
        @strongify(self)
        [self saveStockPicker:model optType:(YXStockFilterOperationTypeDelete) name:model.name];
    }]];

    YXAlertController *alertController = [YXAlertController alertControllerWithAlertView:alertView];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)renameAction:(YXStockFilterUserFilterList *)model {
    [self createStockPickerName: model];
}

- (void)modifyAction:(YXStockFilterUserFilterList *)model {

    YXStockFilterTabViewModel *vm = [[YXStockFilterTabViewModel alloc] initWithServices:self.viewModel.services params:@{@"market" : model.market, @"userGroup": model}];
    [self.viewModel.services pushViewModel:vm animated:YES];
}

- (CGFloat)rowHeight {
    return 180;
}

- (NSArray<Class> *)cellClasses {
    return @[[YXStockFilterGroupCell class]];
}


- (void)saveStockPicker:(YXStockFilterUserFilterList *)model optType:(YXStockFilterOperationType)type name:(NSString *)name {

    NSDictionary *dic = @{@"name" : name, @"idString" : @(model.Id), @"type" : @(type), @"market" : model.market};
    //@weakify(self)
    [[[self.viewModel.saveResultCommand execute:dic] deliverOnMainThread]
     subscribeNext:^(NSNumber *number) {
        //@strongify(self);
        if (number.integerValue == -1) {
            if (type == YXStockFilterOperationTypeDelete) {
                [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"delete_fail"]];
            } else {
                [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"user_saveFailed"]];
            }

        } else {
            if (type == YXStockFilterOperationTypeDelete) {
                [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"mine_del_success"]];

            } else {
                [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"user_saveSucceed"]];
            }
            [self loadFirstPage];
        }

    } error:^(NSError *error) {
    } completed:^{
    }];
}

- (void)createStockPickerName:(YXStockFilterUserFilterList *)model {
    YXAlertView *alertView = [YXAlertView alertViewWithTitle:[YXLanguageUtility kLangWithKey:@"stock_scanner"] message:nil];
    alertView.clickedAutoHide = NO;
    @weakify(alertView, self)
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction *action) {
        @strongify(alertView)
        [alertView hideView];
    }]];

    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm"] style:YXAlertActionStyleDefault handler:^(YXAlertAction *action) {
        @strongify(alertView, self)
        NSString *name = alertView.textField.text;
        if (name.length < 1 || [name stringByReplacingOccurrencesOfString:@" " withString:@""].length < 1) {
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"filter_name_emtpy_prompt"]];
        } else {
            [self saveStockPicker:model optType:(YXStockFilterOperationTypeEdit) name:name];
            [alertView hideView];
        }
    }]];

    [alertView addTextFieldWithMaxNum:12 handler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [YXLanguageUtility kLangWithKey:@"enter_name"];
        textField.keyboardDistanceFromTextField = 212;
        if ([UIScreen mainScreen].bounds.size.width < 375) {
            textField.keyboardDistanceFromTextField = CGFloatPixelRound([UIScreen mainScreen].bounds.size.height/667 * 212);
        }

    }];

    UILabel *propmtLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"enter_name_alert"] textColor:[QMUITheme.textColorLevel1 colorWithAlphaComponent:0.65] textFont:[UIFont systemFontOfSize:10]];
    propmtLabel.adjustsFontSizeToFitWidth = YES;
    propmtLabel.minimumScaleFactor = 0.3;
    [alertView addSubview:propmtLabel];
    [propmtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(alertView.textField).offset(-6);
        make.right.equalTo(alertView.textField).offset(-27);
        make.top.equalTo(alertView.textField.mas_bottom).offset(5);
    }];

    YXAlertController *alertController = [YXAlertController alertControllerWithAlertView:alertView];
    [UIViewController.currentViewController presentViewController:alertController animated:YES completion:nil];
}

- (CGFloat)tableViewTop {
    return 9;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.viewModel.dataSource == nil) {
        return [super titleForEmptyDataSet:scrollView];
    } else if (self.viewModel.dataSource.firstObject.count == 0) {
        UIColor *textColor = [QMUITheme textColorLevel3];
        if (self.whiteStyle) {
            textColor = QMUITheme.textColorLevel2;
        }
        return [[NSAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"common_no_data"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: textColor}];
    }
    return [self customTitleForEmptyDataSet];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {

    if (self.viewModel.dataSource == nil) {
        return [super imageForEmptyDataSet:scrollView];
    } else if (self.viewModel.dataSource.firstObject.count == 0) {
        return [UIImage imageNamed:@"empty_no_stock"];
    }
    return [self customImageForEmptyDataSet];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    if (self.viewModel.dataSource == nil) {
        return [super buttonTitleForEmptyDataSet:scrollView forState:state];
    }
    return nil;
}

@end

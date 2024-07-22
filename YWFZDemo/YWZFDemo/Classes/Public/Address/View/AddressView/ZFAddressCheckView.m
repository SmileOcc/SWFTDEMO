//
//  ZFAddressCheckView.m
//  ZZZZZ
//
//  Created by YW on 2018/12/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFAddressCheckView.h"
#import "ZFInitViewProtocol.h"
#import "ZFBottomToolView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

#import "UILabel+HTML.h"
#import "UIImage+ZFExtended.h"

static CGFloat kZFAddressCheckTitleViewHeight = 60;
static CGFloat kZFAddressCheckSaveViewHeight = 56;

@interface ZFAddressCheckView()<ZFInitViewProtocol,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) ZFCheckShippingAddressModel      *checkModel;

@property (nonatomic, strong) UIView                           *contentView;
@property (nonatomic, strong) UITableView                      *tableView;
@property (nonatomic, strong) ZFBottomToolView                 *saveButton;

@property (nonatomic, strong) UIView                           *topView;
@property (nonatomic, strong) UIView                           *headerView;
@property (nonatomic, strong) UILabel                          *titleLabel;
@property (nonatomic, strong) UILabel                          *tipLabel;
@property (nonatomic, strong) UIButton                         *closeButton;
@property (nonatomic, strong) UIButton                         *hideButton;

@property (nonatomic, strong) NSAttributedString               *highlightAddressAttribute;


@end
//地址纠错弹窗
@implementation ZFAddressCheckView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        self.backgroundColor = ColorHex_Alpha(0x000000, 0.4);
        
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    
    [self addSubview:self.hideButton];
    [self addSubview:self.contentView];

    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.saveButton];
    [self.contentView addSubview:self.tableView];
    
    [self.topView addSubview:self.titleLabel];
    [self.topView addSubview:self.closeButton];
    [self.headerView addSubview:self.tipLabel];

    self.tableView.tableHeaderView = self.headerView;
}

- (void)zfAutoLayoutView {
    
    [self.hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.contentView.mas_top);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(kZFAddressCheckTitleViewHeight);
    }];
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.tableView.mas_bottom);
        make.height.mas_equalTo(kZFAddressCheckSaveViewHeight);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topView.mas_leading).offset(60);
        make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-60);
        make.top.mas_equalTo(self.topView.mas_top).offset(19);
        make.bottom.mas_equalTo(self.topView.mas_bottom).offset(-19);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.topView.mas_top).offset(16);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.headerView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.headerView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.headerView.mas_top);
        make.bottom.mas_equalTo(self.headerView.mas_bottom).offset(-10);
        make.width.mas_equalTo(KScreenWidth - 32);
    }];
}

- (void)hideView {
    
    CGRect contentFrame = self.contentView.frame;
    contentFrame.origin.y = KScreenHeight;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = contentFrame;
        
    } completion:^(BOOL finished) {
        if (self.superview) {
            [self removeFromSuperview];
        }
        self.hidden = YES;
        self.contentView.hidden = YES;
        self.highlightAddressAttribute = nil;
    }];
}

- (void)showView:(ZFCheckShippingAddressModel *)addressCheckModel {
    
    if (addressCheckModel) {
        self.checkModel = addressCheckModel;
        self.checkModel.suggested_address.isMark = YES;
    } else {
        [self hideView];
        return;
    }
    self.contentView.hidden = YES;
    if (self.superview) {
        [self removeFromSuperview];
    }
    [WINDOW addSubview:self];
    
    UILabel *suggestLabel = [[UILabel alloc] init];
    suggestLabel.textColor = ColorHex_Alpha(0x666666, 1);
    suggestLabel.font = ZFFontSystemSize(14);
    
    //兼容数据异常
    if (!ZFIsEmptyString(self.checkModel.suggested_address.highlight_address)) {
        [suggestLabel zf_setHTMLFromString:self.checkModel.suggested_address.highlight_address  completion:^(NSAttributedString *stringAttributed) {
            
            self.highlightAddressAttribute = stringAttributed;
            [self showReloadView];
        }];
    } else {
        [self showReloadView];
    }
    
}

- (void)showReloadView {
    
    self.contentView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, KScreenHeight);
    self.contentView.hidden = NO;
    self.hidden = NO;
    
    
    //设置全屏来获取总cell,
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    [self.tableView reloadData];
    
    CGRect headRect = CGRectZero;
    headRect.size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.headerView.frame = headRect;
    self.tableView.tableHeaderView = self.headerView;
    
    
    CGFloat totalHeight = 0;
    totalHeight += CGRectGetHeight(headRect);
    
    NSInteger sections = self.tableView.numberOfSections;
    for (int section = 0; section < sections; section++) {
        NSInteger rows =  [self.tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            CGFloat height = [self.tableView rectForRowAtIndexPath:indexPath].size.height;
            totalHeight += height;
        }
    }
    
    self.contentView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, totalHeight + kZFAddressCheckTitleViewHeight + kZFAddressCheckSaveViewHeight + kiphoneXHomeBarHeight);
    self.tableView.frame = CGRectMake(0, kZFAddressCheckTitleViewHeight, KScreenWidth, totalHeight);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = CGRectMake(0, KScreenHeight - totalHeight - kZFAddressCheckTitleViewHeight - kZFAddressCheckSaveViewHeight - kiphoneXHomeBarHeight, KScreenWidth, totalHeight + kZFAddressCheckTitleViewHeight + kZFAddressCheckSaveViewHeight + kiphoneXHomeBarHeight);
    }];
}

- (void)actionClose {
    [self hideView];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFAddressCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZFAddressCheckCell"];
    cell.bottomLineView.hidden = NO;
    if (indexPath.row == 0) {
        cell.titleLabel.text = ZFLocalizedString(@"ModifyAddress_Check_Address_Original", nil);
        cell.contentLabel.text = [self addressContentDesc:self.checkModel.original_address];
        [cell isMark:self.checkModel.original_address.isMark];
        [cell isEdit:NO];

    } else {
        cell.titleLabel.text = ZFLocalizedString(@"ModifyAddress_Check_Address_Suggested", nil);
        cell.bottomLineView.hidden = YES;
        //默认显示高亮
        if (self.highlightAddressAttribute) {
            cell.contentLabel.attributedText = self.highlightAddressAttribute;

        } else {//只是异常处理
            cell.contentLabel.text = [self addressContentDesc:self.checkModel.suggested_address];
        }
        [cell isMark:self.checkModel.suggested_address.isMark];
        [cell isEdit:NO];
        if (self.checkModel.suggested_address.isMark) {
            [cell isEdit:YES];
        }
    }
    
    cell.operateBlock = ^(ZFAddressCheckEvent event) {
        if (self.editBlock) {
            self.editBlock(self.checkModel);
        }
        [self hideView];
    };
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        self.checkModel.original_address.isMark = YES;
        self.checkModel.suggested_address.isMark = NO;
    } else {
        self.checkModel.original_address.isMark = NO;
        self.checkModel.suggested_address.isMark = YES;
    }
    [tableView reloadData];
}

- (NSString *)addressContentDesc:(ZFCheckShippingAddressItemModel *)model {
    NSString *addressStr = @"";
    if (!ZFIsEmptyString(model.addressline1)) {
        addressStr = [addressStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.addressline1]];
    }
    if (!ZFIsEmptyString(model.addressline2)) {
        addressStr = [addressStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.addressline2]];
    }
    
    if (!ZFIsEmptyString(model.city)) {
        addressStr = [addressStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.city]];
    }
    
    if (!ZFIsEmptyString(model.country)) {
        addressStr = [addressStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.country]];
    }
    
    if (!ZFIsEmptyString(model.zipcode)) {
        addressStr = [addressStr stringByAppendingString:[NSString stringWithFormat:@"%@,",model.zipcode]];
    }
    if ([addressStr hasSuffix:@","]) {
        addressStr = [addressStr substringToIndex:addressStr.length-1];
    }
    return addressStr;
}


#pragma mark - setter/getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _contentView.backgroundColor = ZFCOLOR_WHITE;
        _contentView.hidden = YES;
    }
    return _contentView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 120;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ZFAddressCheckCell class] forCellReuseIdentifier:@"ZFAddressCheckCell"];
    }
    return _tableView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (ZFBottomToolView *)saveButton {
    if (!_saveButton) {
        _saveButton = [[ZFBottomToolView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 56)];
        _saveButton.backgroundColor = ColorHex_Alpha(0xFFFFFF, 1.0);
        _saveButton.bottomTitle = ZFLocalizedString(@"ModifyAddress_SAVE",nil);
        _saveButton.showTopShadowline = NO;
        @weakify(self);
        _saveButton.bottomButtonBlock = ^{
            @strongify(self);
            if (self.saveBlock && self.checkModel) {
                self.saveBlock(self.checkModel);
            }
            [self hideView];
        };
    }
    return _saveButton;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0)];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //_titleLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1);
        _titleLabel.font = ZFFontSystemSize(18);
        _titleLabel.text = ZFLocalizedString(@"ModifyAddress_Check_Address_Title", nil);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textColor = ColorHex_Alpha(0x666666, 1);
        _tipLabel.font = ZFFontSystemSize(14);
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = ZFLocalizedString(@"ModifyAddress_Check_Address_Tip", nil);
    }
    return _tipLabel;
}
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(actionClose) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)hideButton {
    if (!_hideButton) {
        _hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hideButton addTarget:self action:@selector(actionClose) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideButton;
}
@end








@implementation ZFAddressCheckCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.markButton];
        [self addSubview:self.titleLabel];
        [self addSubview:self.editButton];
        [self addSubview:self.contentLabel];
        [self addSubview:self.bottomLineView];
        
        [self.markButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(16);
            make.top.mas_equalTo(self.mas_top).offset(6);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
            make.centerY.mas_equalTo(self.markButton.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.markButton.mas_trailing).offset(6);
            make.centerY.mas_equalTo(self.markButton.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-16);
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (void)actionSelect:(UIButton *)sender {
    if (self.operateBlock) {
        self.operateBlock(ZFAddressCheckEventSelected);
    }
}

- (void)actionEdit:(UIButton *)sender {
    if (self.operateBlock) {
        self.operateBlock(ZFAddressCheckEventEdit);
    }
}

- (void)isMark:(BOOL)mark {
    if (mark) {
        [_markButton setImage:[[UIImage imageNamed:@"address_choose"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateNormal];

    } else {
        [_markButton setImage:[UIImage imageNamed:@"address_unchoose"] forState:UIControlStateNormal];
    }
}

- (void)isEdit:(BOOL)edit {
    self.editButton.hidden = !edit;
}
#pragma mark -
- (UIButton *)markButton {
    if (!_markButton) {
        _markButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_markButton setImage:[UIImage imageNamed:@"address_unchoose"] forState:UIControlStateNormal];
        [_markButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//        [_markButton addTarget:self action:@selector(actionSelect:) forControlEvents:UIControlEventTouchUpInside];
        _markButton.userInteractionEnabled = NO;

    }
    return _markButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"address_edit"] forState:UIControlStateNormal];
        [_editButton setImage:[UIImage imageNamed:@"address_edit"] forState:UIControlStateHighlighted];
        [_editButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [_editButton addTarget:self action:@selector(actionEdit:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _editButton;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        //_titleLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1);
        _titleLabel.font = ZFFontSystemSize(14);
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = ColorHex_Alpha(0x666666, 1);
        _contentLabel.font = ZFFontSystemSize(14);
    }
    return _contentLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ColorHex_Alpha(0xDDDDDD, 1);
    }
    return _bottomLineView;
}
@end

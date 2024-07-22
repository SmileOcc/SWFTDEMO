//
//  GJPickerView.m
//  YDGJ
//
//  Created by Luke on 16/7/28.
//  Copyright © 2016年 Galaxy360. All rights reserved.
//

#import "ZFPickerView.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "UIView+LayoutMethods.h"

#define contentViewHeight  (KScreenHeight*0.4)
#define topHeight  44
#define topButtonW  60

@interface ZFPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView   *contentView;
@property (nonatomic, copy) void(^sureBlock)(NSArray<ZFPickerViewSelectModel *> * selectContents);
@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, strong) NSArray<NSArray <NSString *> *> *pickDataArr;
@property (nonatomic, strong) UIPickerView     *pickView;
@property (nonatomic, strong) NSMutableArray <ZFPickerViewSelectModel *> *selectContents;;
@end

@implementation ZFPickerView


+ (instancetype)showPickerViewWithTitle:(id)title
                            pickDataArr:(ZFDataList)pickDataArr
                              sureBlock:(void(^)(NSArray<ZFPickerViewSelectModel *> * selectContents))sureBlock
                            cancelBlock:(void (^)(void))cancelBlock
{
    //按钮至少要有一个
    if(pickDataArr.count == 0) return nil;
    
    return [[self alloc] initWithFrame:[UIScreen mainScreen].bounds title:title pickDataArr:pickDataArr sureBlock:sureBlock cancelBlock:cancelBlock];
}


#pragma mark - 自定义PickerView

- (instancetype)initWithFrame:(CGRect)frame
                        title:(id)title
                  pickDataArr:(ZFDataList)pickDataArr
                    sureBlock:(void(^)(NSArray<ZFPickerViewSelectModel *> * selectContents))sureBlock
                  cancelBlock:(void (^)(void))cancelBlock
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.sureBlock = sureBlock;
        self.cancelBlock = cancelBlock;
        self.pickDataArr = pickDataArr;
        
        self.alpha = 1.0;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        
        //点击背景消失
        UIControl *control = [[UIControl alloc] initWithFrame:self.frame];
        [control addTarget:self action:@selector(dismissGJPickerView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        
        self.selectContents = [[NSMutableArray alloc] init];
        [pickDataArr enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFPickerViewSelectModel *selectModel = [[ZFPickerViewSelectModel alloc] init];
            selectModel.section = idx;
            selectModel.row = 0;
            selectModel.content = obj.firstObject;
            [self.selectContents addObject:selectModel];
        }];
        
        //显示UI
        [self initSquareActionSheetUI:title];
        
        //动画显示在窗口
        [self showGJPickView];
    }
    return self;
}

- (void)selectPickerRowArray:(NSArray <NSString *> *)selectRowArr {
    
    for (int i=0; i<selectRowArr.count; i++) {
        NSString *content = selectRowArr[i];
        
        if (self.pickDataArr.count > i) {
            NSArray *currentArr = self.pickDataArr[i];
            
            if ([currentArr containsObject:content]) {
                NSInteger index = [currentArr indexOfObject:content];
                [self.pickView selectRow:index inComponent:i animated:NO];
            }
        }
    }
}
#pragma mark - 初始化UI


/**
 *  创建直角的ActionSheet
 */
- (void)initSquareActionSheetUI:(id)title
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, contentViewHeight)];
    contentView.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    //取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, topButtonW, topHeight)];
    cancelBtn.backgroundColor = ZFCOLOR_WHITE;
    [cancelBtn setTitle:ZFLocalizedString(@"community_outfit_leave_cancel", nil) forState:0];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:ZFC0x2D2D2D() forState:0];
    cancelBtn.hidden = YES;
    [contentView addSubview:cancelBtn];
    //标题
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame), 0, KScreenWidth-topButtonW*2, topHeight)];
    [titleLab setTextColor:ZFC0x2D2D2D()];
    [titleLab setTextAlignment:NSTextAlignmentCenter];
    [titleLab setFont:[UIFont systemFontOfSize:16]];
    [titleLab setBackgroundColor:ZFCOLOR_WHITE];
    titleLab.numberOfLines = 0;
    [contentView addSubview:titleLab];
    //根据文字类型设置标题
    if ([title isKindOfClass:[NSString class]]) {
        titleLab.text = title;
    } else if([title isKindOfClass:[NSAttributedString class]]){
        titleLab.attributedText = title;
    }
    
    //确定
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLab.frame), 0, topButtonW, topHeight)];
    sureBtn.backgroundColor = ZFCOLOR_WHITE;
    [sureBtn setTitle:ZFLocalizedString(@"Address_VC_Done", nil) forState:0];
    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitleColor:ZFC0x2D2D2D() forState:0];
    [contentView addSubview:sureBtn];
    
    //线条
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sureBtn.frame), KScreenWidth, 0.5)];
    line.backgroundColor = ZFC0xDDDDDD();
    [contentView addSubview:line];
    
    //选择器
    UIPickerView *pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), KScreenWidth, contentViewHeight-topHeight)];
    pickView.delegate = self;
    pickView.dataSource = self;
    self.pickView = pickView;
    [contentView addSubview:pickView];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window endEditing:YES];
    [window addSubview:self];
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.pickDataArr.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *rows = self.pickDataArr[component];
    return rows.count;
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    id objStr = self.pickDataArr[component][row];
    if ([objStr isKindOfClass:[NSAttributedString class]]) {
        return objStr;
    } else if ([objStr isKindOfClass:[NSString class]]) {
        NSString *content = objStr;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
        [attr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} range:NSMakeRange(0, content.length)];
        return attr;
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"didSelectRow===%@",self.pickDataArr[component][row]);
    NSString *selectContent = self.pickDataArr[component][row];
    ZFPickerViewSelectModel *model = self.selectContents[component];
    model.row = row;
    model.section = component;
    model.content = selectContent;
    [self.selectContents replaceObjectAtIndex:component withObject:model];
}


#pragma mark - 确定和取消事件处理

- (void)cancelBtnAction:(UIButton *)button
{
    [self dismissGJPickerView:button];
}

- (void)sureBtnAction:(UIButton *)button
{
    if ( self.sureBlock) {
        self.sureBlock(self.selectContents);
    }
    [self dismissGJPickerView:button];
}

#pragma mark - 显示和影藏弹框

/**
 *  显示弹框
 */
- (void)showGJPickView
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setAlpha:1];
        self.contentView.y = KScreenHeight - self.contentView.height;
    } completion:nil];
}

/**
 *  退出弹框
 */
- (void)dismissGJPickerView:(id)sender
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.y = KScreenHeight;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
    } completion:^(BOOL finished) {
        if (sender) {
            NSLog(@"点击了ActionSheet灰色背景消失");
        }
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];
}

- (void)dismissView {
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.y = KScreenHeight;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
    } completion:^(BOOL finished) {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end


@implementation ZFPickerViewSelectModel

@end

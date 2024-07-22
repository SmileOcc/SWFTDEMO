//
//  ZFBaseEditAddressCell.m
//  ZZZZZ
//
//  Created by YW on 2018/9/6.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFBaseEditAddressCell.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

@implementation ZFBaseEditAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFC0xDDDDDD();
    }
    return _lineView;
}

- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel {
    
}

- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel hasUpperLevel:(BOOL)hasUpperLevel {
    
}


- (void)updateContentText:(NSString *)text {
    
}

#pragma mark - action

- (void)baseEditContent:(NSString *)content {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(editAddressCell:editContent:)]) {
        [self.myDelegate editAddressCell:self editContent:content];
    }
}

- (void)baseShowTips:(BOOL)showTips overMax:(BOOL)overMax content:(NSString *)content {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(editAddressCell:showTips:overMax:content:)]) {
        [self.myDelegate editAddressCell:self showTips:showTips overMax:overMax content:content];
    }
}

- (void)baseShowTips:(BOOL)showTips content:(NSString *)content resultTell:(NSString *)resultTel {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(editAddressCell:showTips:content:resultTell:)]) {
        [self.myDelegate editAddressCell:self showTips:showTips content:content resultTell:resultTel];
    }
}
- (void)baseIsEditEvent:(BOOL)isEdit {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(editAddressCell:isEditing:)]) {
        [self.myDelegate editAddressCell:self isEditing:isEdit];
    }
}

- (void)baseCancelContent:(NSString *)content {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(editAddressCell:cancelMaxContent:)]) {
        [self.myDelegate editAddressCell:self cancelMaxContent:content];
    }
}

- (void)baseSelectEvent:(BOOL)flag {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(editAddressCell:selectEvent:)]) {
        [self.myDelegate editAddressCell:self selectEvent:flag];
    }
}
- (void)baseSelectFirstTips:(BOOL)flag {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(editAddressCell:selectFirstTips:)]) {
        [self.myDelegate editAddressCell:self selectFirstTips:flag];
    }
}

- (void)baseShowPlaceholderTips:(BOOL)showTips {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(editAddressCell:showBottomPlaceholderTip:)]) {
        [self.myDelegate editAddressCell:self showBottomPlaceholderTip:showTips];
    }
}
@end

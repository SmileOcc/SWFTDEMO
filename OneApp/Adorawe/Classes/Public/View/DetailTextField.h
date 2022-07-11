//
//  DetailTextField.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/14.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


@class DetailTextField;
@protocol DetailTextFieldDelegate <NSObject>
-(void)textFieldDidEndEditing:(DetailTextField *)detailField filed:(UITextField *)field;
-(void)textFieldDidBeginEditing:(DetailTextField *)detailField filed:(UITextField *)field;
-(BOOL)textFieldShouldReturn:(DetailTextField *)detailField filed:(UITextField *)field;
-(BOOL)textField:(UITextField *)textField detailText:(DetailTextField *)detailField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end


///可配置errorInfo 的textfield 基于JVFloatLabeledTextField
@interface DetailTextField : UIStackView <UITextFieldDelegate>
@property (nonatomic,copy) NSString *placeholder;
/// 需要展示就设置值 不需要展示就设置空
@property (nonatomic,copy) NSString *details;

@property (nonatomic,strong) UIColor *placeholderColor;
///上方的placeholder
@property (nonatomic,strong) UIColor *floatPlaceholderColor;
///底部提示信息颜色
@property (nonatomic,strong) UIColor *detailsColor;

///devider color
@property (nonatomic,strong) UIColor *deviderColor;

@property (weak,nonatomic) id<DetailTextFieldDelegate> delegate;

@property (assign,nonatomic,readonly) BOOL isEditing;
@property (copy,nonatomic) NSString* text;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property (assign,nonatomic) BOOL isPassword;

@property (assign,nonatomic) UIKeyboardType keyboardType;

-(void)setError:(NSString *)msg color:(UIColor *)color;
-(void)clearError;

@property (weak,nonatomic) UILabel *detailLbl;
@property (weak,nonatomic) UITextField *inputField;
@property (weak,nonatomic) UIView *devider;

///自定义
-(void)setUpViews;
@end

NS_ASSUME_NONNULL_END

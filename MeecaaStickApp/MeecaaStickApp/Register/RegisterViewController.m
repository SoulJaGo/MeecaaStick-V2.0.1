//
//  RegisterViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/24.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "RegisterViewController.h"
@interface RegisterViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
/**
 *  计时器
 */
@property (nonatomic,strong) NSTimer *codeTimer;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@property (nonatomic,strong) MMDrawerController * drawerController;

- (IBAction)onClickGetCodeBtn;
- (IBAction)onClickGetNoCode;
- (IBAction)onClickSubmit;

@end
@implementation RegisterViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIVIEW_BACKGROUND_COLOR;
    
    self.getCodeBtn.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.submitBtn.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    
    //设置Nav
    [self setupNav];
    
    self.phoneTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.codeTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification) name:@"LoginSuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCodeSucceedDelegate:) name:@"GETCODE_SUCCEED" object:nil];
}

- (void)loginSuccessNotification {
    [self presentViewController:self.drawerController animated:NO completion:^{
        [SVProgressHUD showSuccessWithStatus:@"密码修改成功"];
    }];
}


- (void)getCodeSucceedDelegate:(id)sender{
    [SVProgressHUD showInfoWithStatus:@"获取验证码成功，请5分钟内注册！" ];
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GETCODE_SUCCEED" object:nil];
}


/**
 *  设置Nav
 */
- (void)setupNav {
    self.navigationItem.title = @"新用户注册";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"register_back_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
}

/**
 *  返回上一级
 */
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (IBAction)onClickGetCodeBtn {
    //未输入手机号码
    if ([self.phoneTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写手机号码!"];
        return;
    }
    
    //获取验证码
    [[HttpTool shared] getRegistVerifyCode:self.phoneTextField.text];
    
    self.getCodeBtn.enabled = NO;
    [self.getCodeBtn setBackgroundImage:[[GlobalTool shared] createImageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
    [self.getCodeBtn setTitle:@"60" forState:UIControlStateDisabled];
    self.codeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countCodeTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.codeTimer forMode:NSRunLoopCommonModes];
}

/**
 *  收不到验证码
 */
- (IBAction)onClickGetNoCode {
    [SVProgressHUD showInfoWithStatus:@"请拨打40009-365-12服务热线获取验证码，谢谢！"];
}

- (IBAction)onClickSubmit {
    [self.view endEditing:YES];
    
    if ([self.phoneTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写手机号码!"];
        return;
    }
    if (![[GlobalTool shared] isMobileNumberClassification:self.phoneTextField.text]) {
        [SVProgressHUD showErrorWithStatus:@"手机号码填写错误！"];
        return;
    }
    
    if ([self.pwdTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写密码！"];
        return;
    }
    if (self.pwdTextField.text.length < 6) {
        [SVProgressHUD showErrorWithStatus:@"请填写密码！"];
        return;
    }
    if ([self.codeTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写验证码!"];
        return;
    }
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [[HttpTool shared] registerAccountWithPhoneNumber:self.phoneTextField.text NickName:@"米开宝宝" Password:self.pwdTextField.text registerCode:self.codeTextField.text];

}

- (void)countCodeTimer {
    int count = [self.getCodeBtn.titleLabel.text intValue];
    if (count == 0) {
        if (self.codeTimer) {
            [self.codeTimer invalidate];
        }
        self.getCodeBtn.enabled = YES;
        [self.getCodeBtn setTitle:@"获取" forState:UIControlStateNormal];
    } else {
        count -= 1;
        self.getCodeBtn.titleLabel.text = [NSString stringWithFormat:@"%d",count];
        [self.getCodeBtn setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateDisabled];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end

//
//  ForgetPwdViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/23.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "MainTabBarController.h"
@interface ForgetPwdViewController () <UITextFieldDelegate>
/**
 *  手机输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
/**
 *  验证码按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
/**
 *  验证码
 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
/**
 *  计时器
 */
@property (nonatomic,strong) NSTimer *codeTimer;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (nonatomic,strong) MMDrawerController * drawerController;

/**
 *  获取验证码
 */
- (IBAction)onClickGetCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
- (IBAction)onClickSubmit;
- (IBAction)onClickGetNoCode;


@end
@implementation ForgetPwdViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIVIEW_BACKGROUND_COLOR;
    
    //按钮圆角
    self.getCodeBtn.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.submitBtn.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    
    [self setupNav];
    
    self.phoneTextField.delegate = self;
    self.codeTextField.delegate = self;
    self.pwdTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification) name:@"LoginSuccessNotification" object:nil];
}

- (MMDrawerController *)drawerController {
    if (_drawerController == nil) {
        MainTabBarController *mainTabBarC = [[MainTabBarController alloc] init];
        LeftMenuViewController *leftMenuVc = [[LeftMenuViewController alloc] init];
        RightMenuViewController *rightMenuVc = [[RightMenuViewController alloc] init];
        self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainTabBarC leftDrawerViewController:leftMenuVc rightDrawerViewController:rightMenuVc];
        [self.drawerController setShowsShadow:NO];
        [self.drawerController setMaximumRightDrawerWidth:200];
        [self.drawerController setMaximumLeftDrawerWidth:200];
    }
    return _drawerController;
}

- (void)loginSuccessNotification {
    [self presentViewController:self.drawerController animated:NO completion:^{
        [SVProgressHUD showSuccessWithStatus:@"密码修改成功"];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.codeTimer) {
        [self.codeTimer invalidate];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccessNotification" object:nil];
}

/**
 *  设置Nav
 */
- (void)setupNav {
    self.navigationItem.title = @"忘记密码";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forgetpwd_go_back_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
}

/**
 *  返回上一级
 */
- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  获取验证码
 */
- (IBAction)onClickGetCodeBtn {
    //未输入手机号码
    if ([self.phoneTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请填写手机号码!"];
        return;
    }
    
    //获取验证码
    [[HttpTool shared] getResetPwdVerifyCode:self.phoneTextField.text];
    
    self.getCodeBtn.enabled = NO;
    [self.getCodeBtn setBackgroundImage:[[GlobalTool shared] createImageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
    [self.getCodeBtn setTitle:@"60" forState:UIControlStateDisabled];
    self.codeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countCodeTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.codeTimer forMode:NSRunLoopCommonModes];
    
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
        [self.getCodeBtn setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateDisabled];
    }
}

/**
 *  退出键盘
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
/**
 *  提交
 */
- (IBAction)onClickSubmit {
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
        return;
    } else {
        if ([self.phoneTextField.text isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"此号码还没有注册!"];
            return;
        } else if (![[GlobalTool shared] isMobileNumberClassification:self.phoneTextField.text]) {
            [SVProgressHUD showErrorWithStatus:@"此号码还没有注册!"];
            return;
        } else if ([self.codeTextField.text isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"请填写验证码！"];
            return;
        } else if ([self.pwdTextField.text isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"请填写密码！"];
        } else if (self.pwdTextField.text.length <= 1) {
            [SVProgressHUD showErrorWithStatus:@"请填写不少于1位的密码！"];
            return;
        } else if (self.pwdTextField.text.length > 10) {
            [SVProgressHUD showErrorWithStatus:@"请填写少于10位的密码！"];
        } else {
            [SVProgressHUD show];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
            [[HttpTool shared] resetAccountPasswordByPhoneNumber:self.phoneTextField.text NewPwd:self.pwdTextField.text Code:self.codeTextField.text];
            
        }
    }
}

- (IBAction)onClickGetNoCode {
    [SVProgressHUD showInfoWithStatus:@"请拨打40009-365-12服务热线获取验证码，谢谢！"];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end

//
//  LoginViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/23.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "LoginViewController.h"
#import "LeftMenuViewController.h"
#import "MainTabBarController.h"
#import "Account.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/sdkdef.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
//开启QQ和Facebook网页授权需要
#import <QZoneConnection/ISSQZoneApp.h>
#import "SVProgressHUD.h"
#import "WXApi.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *QQBtn;
@property (weak, nonatomic) IBOutlet UIButton *WeixinBtn;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (nonatomic,strong) MMDrawerController * drawerController;
- (IBAction)goStroll;
/**
 *  普通登陆
 */
- (IBAction)normalLogin;
- (IBAction)onClickLoginQQ;
- (IBAction)onClickLoginWeiBo;
- (IBAction)onClickLoginWeiXin;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loginBtn.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.registerBtn.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.view.backgroundColor = UIVIEW_BACKGROUND_COLOR;
    
    //取得默认的手机号码
    [self initPhoneValue];
    
    //检测第三方登陆软件是否安装
    if (![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi]) {
        self.WeixinBtn.hidden = YES;
    }
    
    if (![TencentOAuth iphoneQQInstalled]) {
        self.QQBtn.hidden = YES;
    }
    
    self.phoneTextField.delegate = self;
    self.pwdTextField.delegate = self;
}

/**
 *  取得默认的手机号码
 */
- (void)initPhoneValue {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docDir stringByAppendingPathComponent:@"account.archive"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        Account *account = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (![account.telephone isEqualToString:@""] || account.telephone != nil) {
            self.phoneTextField.text = account.telephone;
        } else {
            return;
        }
    } else {
        return;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification) name:@"LoginSuccessNotification" object:nil];
}

/**
 *  登陆成功方法
 */
- (void)loginSuccessNotification {
    //主页面
    MainTabBarController *mainTabBarC = [[MainTabBarController alloc] init];
    LeftMenuViewController *leftMenuVc = [[LeftMenuViewController alloc] init];
    RightMenuViewController *rightMenuVc = [[RightMenuViewController alloc] init];
    
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainTabBarC leftDrawerViewController:leftMenuVc rightDrawerViewController:rightMenuVc];
    
    [self.drawerController setShowsShadow:NO];
    [self.drawerController setMaximumRightDrawerWidth:200];
    [self.drawerController setMaximumLeftDrawerWidth:200];
    
    [self presentViewController:self.drawerController animated:NO completion:nil];
}

/**
 *  取消所有通知
 */
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccessNotification" object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  随便逛逛
 */
- (IBAction)goStroll {
    //主页面
    MainTabBarController *mainTabBarC = [[MainTabBarController alloc] init];
    LeftMenuViewController *leftMenuVc = [[LeftMenuViewController alloc] init];
    RightMenuViewController *rightMenuVc = [[RightMenuViewController alloc] init];
    
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainTabBarC leftDrawerViewController:leftMenuVc rightDrawerViewController:rightMenuVc];
    
    [self.drawerController setShowsShadow:NO];
    [self.drawerController setMaximumRightDrawerWidth:200];
    [self.drawerController setMaximumLeftDrawerWidth:200];
    
    [self presentViewController:self.drawerController animated:NO completion:nil];
}


- (IBAction)normalLogin {
    //输入的电话号码不能为空
    if ([self.phoneTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"用户名或密码错误!"];
        return;
    }
    
    //输入的密码不能为空
    if ([self.pwdTextField.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"用户名或密码错误!"];
        return;
    }
    
    //检查网络状态
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
        return;
    } else {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [[HttpTool shared] LoginWithPhoneNumber:self.phoneTextField.text Password:self.pwdTextField.text];
    }

}

- (IBAction)onClickLoginQQ {
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    } else {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES allowCallback:YES authViewStyle:SSAuthViewStyleFullScreenPopup viewDelegate:nil authManagerViewDelegate:nil];
        [ShareSDK getUserInfoWithType:ShareTypeQQSpace authOptions:authOptions result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
            if (result) {
                [[HttpTool shared] loginThirdPartyWithOpenId:[userInfo uid] NickName:[userInfo nickname] PlatForm:@"2" Avatar:[userInfo profileImage]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"QQ授权失败!"];
            }
        }];
    }
}

- (IBAction)onClickLoginWeiBo {
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    } else {
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES allowCallback:YES authViewStyle:SSAuthViewStyleFullScreenPopup viewDelegate:nil authManagerViewDelegate:nil];
        [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo authOptions:authOptions result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
            if (result) {
                [[HttpTool shared] loginThirdPartyWithOpenId:[userInfo uid] NickName:[userInfo nickname] PlatForm:@"1" Avatar:[userInfo profileImage]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"新浪微博授权失败!"];
            }
        }];
    }
}

- (IBAction)onClickLoginWeiXin {
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }else{
        [SVProgressHUD show];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES allowCallback:YES authViewStyle:SSAuthViewStyleFullScreenPopup viewDelegate:nil authManagerViewDelegate:nil];
        [ShareSDK getUserInfoWithType:ShareTypeWeixiTimeline authOptions:authOptions result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
            if (result) {
                [[HttpTool shared] loginThirdPartyWithOpenId:[userInfo uid] NickName:[userInfo nickname] PlatForm:@"3" Avatar:[userInfo profileImage]];
            }else{
                [SVProgressHUD showErrorWithStatus:@"微信授权失败！"];
            }
        }];
    }
}


/**
 *  触摸关闭键盘
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end

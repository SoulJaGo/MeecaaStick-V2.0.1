//
//  UserUpdateViewController.m
//  MeecaaStickApp
//
//  Created by mciMac on 15/11/27.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "UserUpdateViewController.h"
#import "UserListTableViewController.h"

#define kScreen_Height      ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width       ([UIScreen mainScreen].bounds.size.width)
#define kScreen_Frame       (CGRectMake(0, 0 ,kScreen_Width,kScreen_Height))

#define COLOR_NAV_BACKGROUND [UIColor colorWithRed:80/255.0 green:205/255.0 blue:216/255.0 alpha:1.0]
#define COLOR_VIEW_BACKGROUND [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]
@interface UserUpdateViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate,UIScrollViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate>
/**昵称*/
@property (weak, nonatomic) IBOutlet UITextField *nickNameField;
/**男性头像按钮*/
@property (weak, nonatomic) IBOutlet UIButton *maleBtn;
/**女性头像按钮*/
@property (weak, nonatomic) IBOutlet UIButton *femaleBtn;
/**点击男性头像按钮*/
- (IBAction)clickMaleBtn:(id)sender;
/**点击女性头像按钮*/
- (IBAction)clickFemaleBtn:(id)sender;
/**出生日期*/
@property (weak, nonatomic) IBOutlet UILabel *birthLabel;
/**城市*/
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
/**添加按钮*/
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
/**UIImagePickerController*/
@property (nonatomic,strong) UIImagePickerController *ipc;
/**现在的iconImage*/
@property (nonatomic,weak) UIImage *currentIconImage;
/**头像的imageView*/
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
/**选择的性别按钮*/
@property (nonatomic,weak) UIButton *selectedBtn;
/**男性选择图像*/
@property (nonatomic,weak) UIImageView *maleImageView;
/**女性选择图像*/
@property (nonatomic,weak) UIImageView *femaleImageView;
/**生日*/
@property (nonatomic,strong) UIDatePicker *datePicker;
/**
 *  生日上方的选择按钮
 */
@property (nonatomic,strong) UIView *datePickerHeaderView;

- (IBAction)clickSaveBtn:(id)sender;

/**
 *	添加城市选择器pickerView
 */
@property (nonatomic,strong)UIPickerView *myPicker;
/**
 *	为城市选择器添加一个toolbar
 */
@property (nonatomic,strong)UIToolbar *toolbar;
/**
 *	全局的点击回收键盘
 */
@property (strong, nonatomic) UIView *maskView;
/**
 *	以下是城市选择器要用到的属性
 */
//data
@property (strong, nonatomic) NSDictionary *pickerDic;
@property (strong, nonatomic) NSArray *provinceArray;
@property (strong, nonatomic) NSArray *cityArray;
@property (strong, nonatomic) NSArray *townArray;
@property (strong, nonatomic) NSArray *selectedArray;

@end

@implementation UserUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cityLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside)];
    [self.cityLabel addGestureRecognizer:labelTapGestureRecognizer];
    
    self.nickNameField.delegate = self;
    self.nickNameField.returnKeyType = UIReturnKeyDone;

    [self setupNav];
    [self setupChooseBtn];
    [self setupInitUserInfo];
    
    [self getPickerData];
    [self initView];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    //监听更新用户成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateMemberSuccessNotification) name:@"UpdateMemberSuccessNotification" object:nil];
    
//    self.birthLabel.text = @"1990-1-1";
    self.birthLabel.text = [self.memberInfoDict objectForKey:@"birth"];
    self.birthLabel.textColor = [UIColor colorWithRed:212 / 255.0 green:212 / 255.0 blue:212 / 255.0 alpha:1.0];
    self.birthLabel.font = [UIFont boldSystemFontOfSize:17];
//    self.cityLabel.text = @"点击选择城市";
    self.cityLabel.text = [self.memberInfoDict objectForKey:@"city"];
    self.birthLabel.textColor = [UIColor colorWithRed:212 / 255.0 green:212 / 255.0 blue:212 / 255.0 alpha:1.0];
    self.birthLabel.font = [UIFont boldSystemFontOfSize:17];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateMemberSuccessNotification" object:nil];
}
- (void)UpdateMemberSuccessNotification{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Third" bundle:nil];
    UserListTableViewController *userListVc = [board instantiateViewControllerWithIdentifier:@"UserListTableViewController"];
    [self.navigationController pushViewController:userListVc animated:YES];
}



- (void)setupNav
{
    self.title = @"修改成员信息";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"login_back_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
}
- (void)setupChooseBtn
{
    //男性头像的tag
    self.maleBtn.tag = 0;
    //女性头像的tag
    self.femaleBtn.tag = 1;
    
    
    UIImageView *maleImageView = [[UIImageView alloc] init];
    maleImageView.image = [UIImage imageNamed:@"check_choose_icon"];
    maleImageView.frame = CGRectMake(self.maleBtn.frame.size.width - 20, self.maleBtn.frame.size.height - 20, 20, 20);
    maleImageView.hidden = YES;
    [self.maleBtn addSubview:maleImageView];
    self.maleImageView = maleImageView;
    
    UIImageView *femaleImageView = [[UIImageView alloc] init];
    femaleImageView.image = [UIImage imageNamed:@"check_choose_icon"];
    femaleImageView.frame = CGRectMake(self.femaleBtn.frame.size.width - 20, self.femaleBtn.frame.size.height - 20, 20, 20);
    femaleImageView.hidden = YES;
    [self.femaleBtn addSubview:femaleImageView];
    self.femaleImageView = femaleImageView;
    
    //初始化默认选择男性
    [self clickMaleBtn:self.maleBtn];
    
    //点击生日
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBirthLabel:)];
    self.birthLabel.userInteractionEnabled = YES;
    [self.birthLabel addGestureRecognizer:recognizer];
}
- (void)setupInitUserInfo
{
    self.nickNameField.text = self.memberInfoDict[@"name"];
    if ([self.memberInfoDict[@"sex"] isEqualToString:@"0"]) {
        [self clickMaleBtn:self.maleBtn];
    } else {
        [self clickFemaleBtn:self.femaleBtn];
    }
    self.birthLabel.text = self.memberInfoDict[@"birth"];
    self.cityLabel.text = self.memberInfoDict[@"city"];
    
    if (self.memberInfoDict[@"avatar"]) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.memberInfoDict[@"avatar"]] placeholderImage:[UIImage imageNamed:@"user_icon_button"]];
    } else {
        [self.iconImageView setImage:[UIImage imageNamed:@"user_icon_button"]];
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickIconImageView)];
    self.iconImageView.userInteractionEnabled = YES;
    [self.iconImageView.layer setMasksToBounds:YES];
    [self.iconImageView.layer setCornerRadius:22];
    [self.iconImageView addGestureRecognizer:gestureRecognizer];
}

#pragma mark -- 以下是城市选择器的方法和代理方法
- (void)getPickerData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
    self.pickerDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.provinceArray = [self.pickerDic allKeys];
    self.selectedArray = [self.pickerDic objectForKey:[[self.pickerDic allKeys] objectAtIndex:0]];
    
    if (self.selectedArray.count > 0) {
        self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
    }
    
    if (self.cityArray.count > 0) {
        //        self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:0]];
    }
    //    NSLog(@"%@",_provinceArray);
}
- (void)initView {
    self.toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, kScreen_Height - 324, kScreen_Width, 44)];
    self.toolbar.barTintColor = [UIColor  colorWithRed:80/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    self.toolbar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *lefttem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    lefttem.width = 50;
    
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *right=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];
    right.width = 50;
    self.toolbar.items=@[lefttem,centerSpace,right];
    
    self.myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 280, kScreen_Width, 280)];
    self.myPicker.backgroundColor = [UIColor whiteColor];
    self.myPicker.delegate = self;
    self.myPicker.dataSource = self;
    
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 324)];
    self.maskView.backgroundColor = [UIColor clearColor];
    self.maskView.alpha = 0.1;
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMyPicker)]];
}

#pragma mark -- 以下是城市选择器的代理方法
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view{
    UILabel *myLabel = nil;
    if (component == 0) {
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125,30)];
        myLabel.textAlignment = NSTextAlignmentCenter;
        myLabel.text = [self.provinceArray objectAtIndex:row];
        myLabel.font = [UIFont systemFontOfSize:17];
        myLabel.backgroundColor = [UIColor clearColor];
    }else if (component == 1){
        myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250,30)];
        myLabel.textAlignment = NSTextAlignmentCenter;
        myLabel.text = [self.cityArray objectAtIndex:row];
        myLabel.font = [UIFont systemFontOfSize:17];
        myLabel.backgroundColor = [UIColor clearColor];
    }
    return myLabel;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArray.count;
    } else if (component == 1) {
        return self.cityArray.count;
    }
    else {
        return self.townArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [self.provinceArray objectAtIndex:row];
    } else if (component == 1) {
        return [self.cityArray objectAtIndex:row];
    } else {
        return [self.townArray objectAtIndex:row];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return kScreen_Width / 3;
    } else if (component == 1) {
        return kScreen_Width / 3 * 2;
    } else {
        return 110;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.selectedArray = [self.pickerDic objectForKey:[self.provinceArray objectAtIndex:row]];
        if (self.selectedArray.count > 0) {
            self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
        } else {
            self.cityArray = nil;
        }
        if (self.cityArray.count > 0) {
            self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:0]];
        } else {
            self.townArray = nil;
        }
    }
    [pickerView selectedRowInComponent:1];
    [pickerView reloadComponent:1];
    //    [pickerView selectedRowInComponent:2];
    
    if (component == 1) {
        if (self.selectedArray.count > 0 && self.cityArray.count > 0) {
            self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:row]];
        } else {
            self.townArray = nil;
        }
        //[pickerView selectRow:0 inComponent:2 animated:YES];
    }
    
    [pickerView reloadComponent:0];
}

- (void)labelTouchUpInside{
    [self.view endEditing:YES];
    [self.datePicker removeFromSuperview];
    [self.datePickerHeaderView removeFromSuperview];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.myPicker];
    [self.view addSubview:self.maskView];
}
- (void)hideMyPicker{
    [self.myPicker removeFromSuperview];
    [self.maskView removeFromSuperview];
    //    [self.OKButton removeFromSuperview];
    //    [self.cancelButton removeFromSuperview];
    [self.toolbar removeFromSuperview];
}
- (void)remove{
    [self hideMyPicker];
}
- (void)doneClick{
    NSLog(@"%@%@",[self.provinceArray objectAtIndex:[self.myPicker selectedRowInComponent:0]],[self.cityArray objectAtIndex:[self.myPicker selectedRowInComponent:1]]);
    self.cityLabel.text = [NSString stringWithFormat:@"%@%@",[self.provinceArray objectAtIndex:[self.myPicker selectedRowInComponent:0]],[self.cityArray objectAtIndex:[self.myPicker selectedRowInComponent:1]]];
    [self hideMyPicker];
}

/**
 *  返回
 */
- (void)goBack{
    if (self.isFromMain) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        UserListTableViewController *userListVc = [[UserListTableViewController alloc] init];
        [self.navigationController pushViewController:userListVc animated:YES];
    }
}

- (UIDatePicker *)datePicker
{
    if (_datePicker == nil) {
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    }
    return _datePicker;
}

- (IBAction)clickSaveBtn:(UIButton *)sender
{
    //友盟统计
//    [MobClick event:@"saveuserinfo"];
    
    if ([self.nickNameField.text isEqualToString:@""]) {
//        [[TTToolsHelper shared] showNoticetMessage:@"请填写昵称" handler:^{}];
        [SVProgressHUD showErrorWithStatus:@"请填写昵称"];
        return;
    } else if (self.nickNameField.text.length > 10) {
//        [[TTToolsHelper shared] showNoticetMessage:@"昵称不能超过10个字符" handler:^{}];
        [SVProgressHUD showErrorWithStatus:@"昵称不能超过10个字符"];
        return;
    } else if ([self.birthLabel.text isEqualToString:@""]) {
//        [[TTToolsHelper shared] showNoticetMessage:@"请选择生日" handler:^{}];
        [SVProgressHUD showErrorWithStatus:@"请选择生日"];
        return;
    } else if ([self.cityLabel.text isEqualToString:@""]) {
//        [[TTToolsHelper shared] showNoticetMessage:@"请填写所在城市" handler:^{}];
        [SVProgressHUD showErrorWithStatus:@"请选择所在城市"];
        return;
    }
    
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    
    //获取用户的mid
    NSString *mid = self.memberInfoDict[@"id"];
    //是否更换了图片
    BOOL isChangeIconImage;
    
    NSData *currentData = UIImagePNGRepresentation(self.currentIconImage);
    
    if (currentData == nil) { //表示没有新的选择的图形
        isChangeIconImage = NO;
    } else { //选择过头像
        isChangeIconImage = YES;
    }
    
    
    if (isChangeIconImage) { //如果用户头像和以前的头像不同了
        [[HttpTool shared] updateMemberWithMid:mid Name:self.nickNameField.text Sex:[NSString stringWithFormat:@"%d",(int)self.selectedBtn.tag] Birth:self.birthLabel.text City:self.cityLabel.text IconImage:self.iconImageView.image];
    } else {
        [[HttpTool shared] updateMemberWithMid:mid Name:self.nickNameField.text Sex:[NSString stringWithFormat:@"%d",(int)self.selectedBtn.tag] Birth:self.birthLabel.text City:self.cityLabel.text];
    }
}

- (void)clickBirthLabel:(UILabel *)label
{
    //去除键盘
    [self.view endEditing:YES];
    
    [self.view addSubview:self.datePickerHeaderView];
    
    self.datePicker.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216);
    [self.view addSubview:self.datePicker];
}

/**
 *  懒加载datePickerHeaderView
 */
- (UIView *)datePickerHeaderView
{
    if (_datePickerHeaderView == nil) {
        _datePickerHeaderView = [[UIView alloc] init];
        _datePickerHeaderView.frame = CGRectMake(0, self.view.bounds.size.height - 260, self.view.bounds.size.width, 44);
        _datePickerHeaderView.backgroundColor = COLOR_NAV_BACKGROUND;
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 0, 100, 44);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:18];
        [cancelBtn addTarget:self action:@selector(cancelSelectBirth) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerHeaderView addSubview:cancelBtn];
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.frame = CGRectMake(_datePickerHeaderView.bounds.size.width-100, 0, 100, 44);
        [selectBtn setTitle:@"完成" forState:UIControlStateNormal];
        selectBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:18];
        [selectBtn addTarget:self action:@selector(dataChange) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerHeaderView addSubview:selectBtn];
    }
    return _datePickerHeaderView;
}

/**
 *  点击取消按钮
 */
- (void)cancelSelectBirth
{
    [_datePicker removeFromSuperview];
    [_datePickerHeaderView removeFromSuperview];
}

- (void)dataChange
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd";
    NSString *birthStr = [formatter stringFromDate:[self.datePicker date]];
    self.birthLabel.text = birthStr;
    [self.datePicker removeFromSuperview];
    [self.datePickerHeaderView removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    if (self.datePicker) {
        [self.datePicker removeFromSuperview];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/**
 *  点击头像按钮
 */
- (void)clickIconImageView
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"拍照", nil];
    [actionSheet showInView:self.view];
}
/**
 *  点击男性按钮
 */
- (IBAction)clickMaleBtn:(UIButton *)sender
{
    self.selectedBtn = sender;
    self.maleImageView.hidden = NO;
    self.femaleImageView.hidden = YES;
}

- (IBAction)clickFemaleBtn:(UIButton *)sender
{
    self.selectedBtn = sender;
    self.femaleImageView.hidden = NO;
    self.maleImageView.hidden = YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //相册
    if (buttonIndex == 0) {
        [self showPhoto];
    }
    //拍照
    if (buttonIndex == 1) {
        [self showCamera];
    }
}

/**
 *  从相册中选取
 */
- (void)showPhoto
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [ipc.navigationBar setTintColor:[UIColor blackColor]];
    ipc.delegate = self;
    self.ipc = ipc;
    [self presentViewController:self.ipc animated:YES completion:nil];
}

/**
 *  从照相机选取
 */
- (void)showCamera
{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.allowsEditing = YES;
    ipc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    ipc.delegate = self;
    self.ipc = ipc;
    [self presentViewController:self.ipc animated:YES completion:nil];
    
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.iconImageView setImage:info[UIImagePickerControllerOriginalImage]];
    self.currentIconImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark - 2015-10-12 新加代码
/**
 *  SoulJa 2015-10-12
 *  显示状态栏
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

@end

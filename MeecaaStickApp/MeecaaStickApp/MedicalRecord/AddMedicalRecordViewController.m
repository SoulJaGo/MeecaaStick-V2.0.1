//
//  AddMedicalRecordViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/30.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "AddMedicalRecordViewController.h"
#import "TimeLabelCell.h"
#import "TemperatureLabelCell.h"
#import "SymptomCell.h"
#import "DescriptionLabelCell.h"
#import "PhotosCell.h"
#import "CollectionViewCell.h"
#import "MainTabBarController.h"

@interface AddMedicalRecordViewController () <UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) TimeLabelCell *timeLabelCell;
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIView *datePickerHeaderView;
@property (nonatomic,strong) TemperatureLabelCell *temperatureLabelCell;
@property (nonatomic,strong) SymptomCell *symptomCell;
/**
 *  症状视图
 */
@property (nonatomic,strong) UIView *SymptomButtonsView;
@property (nonatomic,strong) UIView *SymptomButtonsHeaderView;
@property (nonatomic,strong) NSMutableArray *symptomButtonsArray;
/**
 *  添加描述TextView
 */
@property (nonatomic,strong) UITextView *descriptionTextView;
@property (nonatomic,strong) UIView *descriptionHeaderView;
/**
 *  添加照片View
 */
@property (nonatomic,strong) UIView *photosView;
@property (nonatomic,strong) UIView *photosHeaderView;
@property (nonatomic,strong) NSMutableArray *photosArray;

@property (nonatomic,strong) UIImagePickerController *ipc;
@property (nonatomic,strong)UICollectionView *collectionView;
@end

@implementation AddMedicalRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置Nav
    [self setupNav];
    
    
    self.photosArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDiarySuccessNotification) name:@"AddDiarySuccessNotification" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddDiarySuccessNotification" object:nil];
}

- (void)addDiarySuccessNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddNewDiarySuccessNotification" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 *  添加照片View
 */
- (UIView *)photosView {
    if (_photosView == nil) {
        self.photosView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 216, self.view.bounds.size.width, 216)];
        [self.photosView setBackgroundColor:[UIColor whiteColor]];
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(10, 78, 60, 60);
        [addBtn setBackgroundImage:[UIImage imageNamed:@"medical_add_icon"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(onClickAddPhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.photosView addSubview:addBtn];
        
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(80, 78, self.view.bounds.size.width - 10 - 60 - 10, 60) collectionViewLayout:flowLayout];
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];
        //设置代理
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.photosView addSubview:self.collectionView];
        
        [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _photosView;
}

#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell.imageView setImage:self.photosArray[indexPath.row]];
    [cell.delBtn setTag:indexPath.row];
    [cell.delBtn addTarget:self action:@selector(onClickDelPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [cell sizeToFit];
    if (!cell) {
        NSLog(@"无法创建CollectionViewCell时打印，自定义的cell就不可能进来了。");
    }
    
    return cell;
}

- (void)onClickDelPhoto:(UIButton *)btn {
    [self.photosArray removeObjectAtIndex:btn.tag];
    [self.collectionView reloadData];
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //边距占5*4=20 ，2个
    //图片为正方形，边长：(fDeviceWidth-20)/2-5-5 所以总高(fDeviceWidth-20)/2-5-5 +20+30+5+5 label高20 btn高30 边
    return CGSizeMake(60, 60);
}
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5, 5, 5);
}



- (void)onClickAddPhoto {
    if (self.photosArray.count >= 5) {
        [SVProgressHUD showErrorWithStatus:@"最多上传5张照片!"];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"拍照", nil];
    [actionSheet showInView:self.view];
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
    ipc.navigationBar.tintColor = [UIColor blackColor];
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
    ;
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
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self.photosArray addObject:info[UIImagePickerControllerOriginalImage]];
    [self.collectionView reloadData];

}




- (UIView *)photosHeaderView {
    if (_photosHeaderView == nil) {
        self.photosHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 260, self.view.bounds.size.width, 44)];
        [self.photosHeaderView setBackgroundColor:NAVIGATIONBAR_BACKGROUND_COLOR];
        UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        completeBtn.frame = CGRectMake(0, 0, 100, 44);
        [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        completeBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:18];
        [completeBtn addTarget:self action:@selector(completePhotos) forControlEvents:UIControlEventTouchUpInside];
        [self.photosHeaderView addSubview:completeBtn];

    }
    return _photosHeaderView;
}

- (void)completePhotos {
    [self.photosHeaderView removeFromSuperview];
    [self.photosView removeFromSuperview];
}

/**
 *  添加描述TextView
 */
- (UITextView *)descriptionTextView {
    if (_descriptionTextView == nil) {
        _descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 216, self.view.bounds.size.width, 216)];
    }
    return _descriptionTextView;
}

/**
 *  添加描述TextView的Header
*/
- (UIView *)descriptionHeaderView {
    if (_descriptionHeaderView == nil) {
        self.descriptionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 260, self.view.bounds.size.width, 44)];
        [self.descriptionHeaderView setBackgroundColor:NAVIGATIONBAR_BACKGROUND_COLOR];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 0, 100, 44);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:18];
        [cancelBtn addTarget:self action:@selector(cancelSelectDesc) forControlEvents:UIControlEventTouchUpInside];
        [self.descriptionHeaderView addSubview:cancelBtn];
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.frame = CGRectMake(self.descriptionHeaderView.bounds.size.width-100, 0, 100, 44);
        [selectBtn setTitle:@"完成" forState:UIControlStateNormal];
        selectBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:18];
        [selectBtn addTarget:self action:@selector(completeSelectDesc) forControlEvents:UIControlEventTouchUpInside];
        [self.descriptionHeaderView addSubview:selectBtn];
    }
    return _descriptionHeaderView;
}

/**
 *  取消描述
 */
- (void)cancelSelectDesc {
    [self.descriptionHeaderView removeFromSuperview];
    [self.descriptionTextView removeFromSuperview];
}

/**
 *  完成描述
 */
- (void)completeSelectDesc {
    [self.descriptionHeaderView removeFromSuperview];
    [self.descriptionTextView removeFromSuperview];
}



/**
 *  症状顶部视图
 */
- (UIView *)SymptomButtonsHeaderView {
    if (_SymptomButtonsHeaderView == nil) {
        self.SymptomButtonsHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 260, self.view.bounds.size.width, 44)];
        [self.SymptomButtonsHeaderView setBackgroundColor:NAVIGATIONBAR_BACKGROUND_COLOR];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(0, 0, 100, 44);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:18];
        [cancelBtn addTarget:self action:@selector(cancelSelectSymptom) forControlEvents:UIControlEventTouchUpInside];
        [self.SymptomButtonsHeaderView addSubview:cancelBtn];
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.frame = CGRectMake(self.SymptomButtonsHeaderView.bounds.size.width-100, 0, 100, 44);
        [selectBtn setTitle:@"完成" forState:UIControlStateNormal];
        selectBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:18];
        [selectBtn addTarget:self action:@selector(completeSelectSymptom) forControlEvents:UIControlEventTouchUpInside];
        [self.SymptomButtonsHeaderView addSubview:selectBtn];
    }
    return _SymptomButtonsHeaderView;
}

/**
 *  点击取消
 */
- (void)cancelSelectSymptom {
//    self.symptomButtonsArray = nil;
//    for (UIView *subview in self.SymptomButtonsView.subviews) {
//        if ([subview isKindOfClass:[UIButton class]]) {
//            for (UIView *nextSubview in subview.subviews) {
//                if ([nextSubview isKindOfClass:[UIImageView class]]) {
//                    [nextSubview setHidden:YES];
//                }
//            }
//        }
//    }
    
    [self.SymptomButtonsView removeFromSuperview];
    [self.SymptomButtonsHeaderView removeFromSuperview];
}

/**
 *  点击完成
 */
- (void)completeSelectSymptom {
    NSString *str = [NSString string];
    for (UIButton *btn in self.symptomButtonsArray) {
        str = [str stringByAppendingString:btn.titleLabel.text];
        str = [str stringByAppendingString:@" "];
    }
    self.symptomCell.symptomLabel.text = str;
    [self.SymptomButtonsView removeFromSuperview];
    [self.SymptomButtonsHeaderView removeFromSuperview];
}


/**
 *  症状视图
 */
- (UIView *)SymptomButtonsView {
    if (_SymptomButtonsView == nil) {
        self.SymptomButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 216, self.view.bounds.size.width, 216)];
        [self.SymptomButtonsView setBackgroundColor:[UIColor whiteColor]];
        NSArray *symtonTemplateList = [[GlobalTool shared] symptonTemplateList];
        for (int i = 0; i < symtonTemplateList.count; i++) {
            NSDictionary *btnDict = symtonTemplateList[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = [[btnDict objectForKey:@"tag"] intValue];
            [btn setTitle:[btnDict objectForKey:@"name"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            CGFloat btnW = (self.view.bounds.size.width - 5*5) / 4;
            CGFloat btnH = (216 - 5*5)/4;
            CGFloat btnX = 5 + (btnW + 5) * (i%4);
            CGFloat btnY = 5 + (btnH + 5) * (i/4);
            
            btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            //添加选中图标
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(btnW - 20, btnH - 20, 20, 20);
            imageView.image = [UIImage imageNamed:@"medical_choose_icon"];
            [imageView setHidden:YES];
            [btn addSubview:imageView];
            
            [btn addTarget:self action:@selector(onClickSymptonBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self.SymptomButtonsView addSubview:btn];
        }
    }
    return _SymptomButtonsView;
}

- (void)onClickSymptonBtn:(UIButton *)btn {
    for (UIView *subView in btn.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            if (subView.hidden == YES) {
                [self.symptomButtonsArray addObject:btn];
                [subView setHidden:NO];
            } else {
                [self.symptomButtonsArray removeObject:btn];
                [subView setHidden:YES];
            }
        }
    }
}


/**
 *  设置DatePicker
 */
- (UIDatePicker *)datePicker
{
    if (_datePicker == nil) {
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    }
    return _datePicker;
}

- (UIView *)datePickerHeaderView
{
    if (_datePickerHeaderView == nil) {
        _datePickerHeaderView = [[UIView alloc] init];
        _datePickerHeaderView.frame = CGRectMake(0, self.view.bounds.size.height - 260, self.view.bounds.size.width, 44);
        _datePickerHeaderView.backgroundColor = NAVIGATIONBAR_BACKGROUND_COLOR;
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
    formatter.dateFormat = @"YYYY-MM-dd HH:mm";
    NSString *birthStr = [formatter stringFromDate:[self.datePicker date]];
    self.timeLabelCell.timeLabel.text = birthStr;
    [self.datePicker removeFromSuperview];
    [self.datePickerHeaderView removeFromSuperview];    
}



/**
 *  设置Nav
 */
- (void)setupNav {
    self.navigationItem.title = @"添加记录";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"medical_back_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(onClickSave)];
}

/**
 *  保存
 */
- (void)onClickSave {
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
        return;
    }
    
    //取出默认用户
    NSDictionary *defaultMember = [[DatabaseTool shared]  getDefaultMember];
    if (defaultMember == nil) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"First" bundle:nil];
        UIViewController *vc = [board instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:vc animated:NO completion:^{
            [SVProgressHUD showErrorWithStatus:@"请您先登录"];
        }];

        return;
    }
    
    //取出默认用户的id
    NSString *defaultMemberId = [NSString stringWithFormat:@"%@",defaultMember[@"id"]];
    
    //获取填写的时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [formatter dateFromString:self.timeLabelCell.timeLabel.text];
    NSTimeInterval time = [date timeIntervalSince1970];
    
    NSString *timeStr = [NSString stringWithFormat:@"%d",(int)time];
    //描述
    NSString *desc = [NSString string];
    if ([self.descriptionTextView.text isEqualToString:@""]) {
        desc = @"未描述";
    } else {
        desc = self.descriptionTextView.text;
    }
    
    //温度值
    if ([self.temperatureLabelCell.temperatureTextField.text isEqualToString:@""] || self.temperatureLabelCell.temperatureTextField.text == nil) {
        [SVProgressHUD showErrorWithStatus:@"请填写温度！"];
        return;
    }
    
    float temperatureFloat = [self.temperatureLabelCell.temperatureTextField.text floatValue];
    if (temperatureFloat > 44.0 || temperatureFloat < 32.0) {
        [SVProgressHUD showErrorWithStatus:@"超出体温范围！（请填写32.0~44.0）"];
        return;
    }
    
    int symptomInt = 0;
    for (UIButton *btn in self.symptomButtonsArray) {
        symptomInt += [self count2N:(int)btn.tag];
    }
    
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [[HttpTool shared] addDiaryWithDate:timeStr Temperature:self.temperatureLabelCell.temperatureTextField.text Symptoms:[NSString stringWithFormat:@"%d",symptomInt] Photo_count:0 Description:desc Member_id:defaultMemberId Longitude:[NSString stringWithFormat:@"%f",[[GlobalTool shared] longitude]] Latitude:[NSString stringWithFormat:@"%f",[[GlobalTool shared] latitude]]];

    
}

/**
 *  计算2的N次方
 */
- (int)count2N:(int)n {
    int result = 2;
    for (int i=1; i<n; i++) {
        result = result * 2;
    }
    return result;
}

/**
 *  返回上级
 */
- (void)goBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TimeLabelCell *timeLabelcell = [tableView dequeueReusableCellWithIdentifier:@"TimeLabelCell"];
        timeLabelcell.addMedicalRecordVc = self;
        self.timeLabelCell = timeLabelcell;
        return timeLabelcell;
    } else if (indexPath.section == 1) {
        TemperatureLabelCell *temperatureLabelCell = [tableView dequeueReusableCellWithIdentifier:@"TemperatureLabelCell"];
        temperatureLabelCell.temperatureTextField.delegate = self;
        self.temperatureLabelCell = temperatureLabelCell;
        return temperatureLabelCell;
    } else if (indexPath.section == 2) {
        SymptomCell *symptomCell = [tableView dequeueReusableCellWithIdentifier:@"SymptomCell"];
        self.symptomButtonsArray = [NSMutableArray array];
        self.symptomCell = symptomCell;
        return symptomCell;
    } else if (indexPath.section == 3) {
        DescriptionLabelCell *descCell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionLabelCell"];
        return descCell;
    } else if (indexPath.section == 4) {
        PhotosCell *photosCell = [tableView dequeueReusableCellWithIdentifier:@"PhotosCell"];
        return photosCell;
    }
    
    TimeLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeLabelCell"];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        //去除键盘
        [self.view endEditing:YES];
        
        [self.view addSubview:self.datePickerHeaderView];
        
        self.datePicker.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216);
        [self.view addSubview:self.datePicker];
    } else if (indexPath.section == 2) {
        [self.view addSubview:self.SymptomButtonsView];
        [self.view addSubview:self.SymptomButtonsHeaderView];
    } else if (indexPath.section == 3) {
        [self.descriptionTextView becomeFirstResponder];
        [self.tableView setContentOffset:CGPointMake(0, 200) animated:NO];
        [self.view addSubview:self.descriptionTextView];
        [self.view addSubview:self.descriptionHeaderView];
    } else if (indexPath.section == 4) {
        [self.view addSubview:self.photosView];
        [self.view addSubview:self.photosHeaderView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSArray *points = [textField.text componentsSeparatedByString:@"."];
    if (points.count>=2&&[string isEqualToString:@"."]) {
        return NO;
    }
    // Check for total length
    NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
    //限制温度输入长度
    if (proposedNewLength > 5){
        return NO;//限制长度
    }
    return [self validateNumber:string];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i< number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

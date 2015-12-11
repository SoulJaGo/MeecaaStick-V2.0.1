//
//  MedicalRecordDetailViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/29.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "MedicalRecordDetailViewController.h"
#import "CollectionViewCell.h"


@interface MedicalRecordDetailViewController ()

@end

@implementation MedicalRecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.bounds.size.width, 200);
    self.view.backgroundColor = UIVIEW_BACKGROUND_COLOR;
    
    //添加描述Label
    [self setupDescLabel];
    
    //添加图片
    if (self.picsArray != nil) {
        [self setupPicsView];
    }
    
    //添加修改按钮
    [self setupUpdateBtn];
    
    //添加删除按钮
    [self setupDeleteBtn];
}

/**
 *  添加图片
 */
- (void)setupPicsView {
    UIView *picsView = [[UIView alloc] initWithFrame:CGRectMake(10, 80, self.view.bounds.size.width - 20, 80)];
    [self.view addSubview:picsView];
    
    for (int i = 0;i < self.picsArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        CGFloat imageViewX = i * (60 + 5);
        CGFloat imageViewY = 10;
        CGFloat imageViewW = 60;
        CGFloat imageViewH = 60;
        imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.picsArray[i]]];
        imageView.userInteractionEnabled = YES;
        [imageView setTag:i];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.medicalRecordVc action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:recognizer];
        [picsView addSubview:imageView];
    }
}

- (void)tapImageView:(UITapGestureRecognizer *)recognizer {
}

/**
 *  添加删除按钮
 */
- (void)setupDeleteBtn {
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setBackgroundColor:[UIColor redColor]];
    deleteBtn.frame = CGRectMake(self.view.bounds.size.width - 10 - 50, 200 - 30 - 10, 50, 30);
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn addTarget:self.medicalRecordVc action:@selector(onClickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
}

- (void)onClickDeleteBtn {
    
}

/**
 *  添加修改按钮
 */
- (void)setupUpdateBtn {
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateBtn setBackgroundColor:[UIColor redColor]];
    updateBtn.frame = CGRectMake(10, 200 - 30 - 10, 50, 30);
    [updateBtn setTitle:@"修改" forState:UIControlStateNormal];
    [updateBtn addTarget:self.medicalRecordVc action:@selector(onClickUpdateBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateBtn];
}

- (void)setupDescLabel {
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.frame =CGRectMake(10, 10, [UIApplication sharedApplication].keyWindow.bounds.size.width - 20, 60);
    
    //设置行数
    descLabel.numberOfLines = 0;
    [descLabel setTextColor:[UIColor lightGrayColor]];
    descLabel.text = self.desc;
    [self.view addSubview:descLabel];
}

- (void)onClickUpdateBtn {
    
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

@end

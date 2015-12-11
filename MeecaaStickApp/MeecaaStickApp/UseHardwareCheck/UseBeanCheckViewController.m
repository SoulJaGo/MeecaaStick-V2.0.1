//
//  UseBeanCheckViewController.m
//  MeecaaStickApp
//
//  Created by mciMac on 15/12/4.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "UseBeanCheckViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SVProgressHUD.h"
#import "ZX.h"
#import "ZHPickView.h"
#import "DACircularProgressView.h"
#import "AFNetworking.h"

#define GETColor(r, g, b,a)         [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define USERDEF_SERV_UUID       @"0xF4E0"       //温豆

#define CENTRAL_WRITE_UUID          @"0xF4E1"   //上位机
#define PERIPHERAL_NOTI_UUID        @"0xF4E2"   //下位机
#define PERIPHERAL_SYSCLOCK_UUID    @"0xF4E3"   //系统实时时钟
#define PERIPHERAL_RATE_UUID        @"0xF4E4"   //连续转换的速率，单位ms
#define PERIPHERAL_CACHE_UUID       @"0XF4E5"   //内部缓存的温度个数
#define PERIPHERAL_LASTCACHETEMPTIME_UUID       @"0XF4E6"   //最近一次温度缓存的时间
#define PERIPHERAL_CACHE_FIFO_UUID              @"0XF4E8"   //内部缓存的温度FIFO

@interface UseBeanCheckViewController ()<CBCentralManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate,ZHPickViewDelegate>{
    //系统蓝牙设备管理对象，可以把他理解为主设备，通过他，可以去扫描和链接外设
    CBCentralManager    *_cbCentralManager;
    
    //所有支持蓝牙4.0的蓝牙设备都能够作为beacon基站发射信号，这就需要创建一个CBPeripheralManager实例，然后发射beacon广播信号
    CBPeripheralManager *_testPeripheralManager;
    CBPeripheral        *_testPeripheral;
    CBCharacteristic    *_testCharacteristic;
    CBCharacteristic    *_centralCharacteristic;
    CBCharacteristic    *_peripheralCharacteristic;
    CBCharacteristic    *_sysClockCharacteristic;
    CBCharacteristic    *_rateCharacteristic;
    CBCharacteristic    *_cacheCharacteristic;
    CBCharacteristic    *_cacheFIFOCharacteristic;
    CBCharacteristic    *_LastTempCharacteristic;
    
    NSMutableArray *_peripheralArray;   //用来存放外围设备的UUID的数组
    
    NSTimer        *_timer; //蓝牙发送数据的时长
    
    /*复联*/
    NSTimer  *researchTimer;
    int      researchTime; //断连时长
    //获取温度
    NSString *TempStr;   //获取到的温度的字符串,用以在label上显示
    float     maxTemp;           //30分钟之内温度的最大值
    
    //圆环
    DACircularProgressView *progressView;
    
    ZX               *lineChart;
    NSMutableArray   *_pointArr;
    UIScrollView     *scrollView;    //显示可滑动折线图的scrollView
    ZHPickView       *pickview;      //选择器
    NSString         *peripheralIdStr;   //存储外围设备id的字符串，用于下次连接时判断
    NSString         *identifier;        //在搜索到外围设置以后存储
    
    //测温时间计数器
    int timercount;
    NSMutableString *mutStr;
    NSMutableString *maxStr;
    NSMutableString *minStr;
    int max;
    int min;
    BOOL flag;//用于区分高温低温按钮
    BOOL press;//用于标记开始按钮的状态
}
@property (weak, nonatomic) IBOutlet UILabel *_timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *maxTempBtn;
@property (weak, nonatomic) IBOutlet UIButton *minTempBtn;
@property (weak, nonatomic) IBOutlet UIImageView *start;
@property (weak, nonatomic) IBOutlet UIImageView *circular;
@property (weak, nonatomic) IBOutlet UIView *lineChartView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularLeftEdge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startTopEdge;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxTempBtnRightEdge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minTempBtnRightEdge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startRightEdge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineChartViewTopEdge;

@property (nonatomic, strong)UILabel *_temperatureLab;
@end

@implementation UseBeanCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置主设备 / 外围设备的代理方法
    _cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _testPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    _peripheralArray = [NSMutableArray array];//用于存放外围设备UUID的数组

    //总时长定时器
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateInteger) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];    //暂停计时器
    
    press = NO;
    
    //复联定时器
    researchTime = 0;
    //researchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startResearchTime) userInfo:nil repeats:YES];
    [researchTimer setFireDate:[NSDate distantFuture]];

    //显示高温报警
    max = 380;
    //显示低温报警
    min = 360;
    
    //初始化选择器
    pickview=[[ZHPickView alloc] initPickviewWithPlistName:@"多组数据" isHaveNavControler:NO];
    pickview.delegate=self;
    
    self._temperatureLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.circular.frame.size.width, self.circular.frame.size.height)];
    
    self._temperatureLab.backgroundColor = [UIColor clearColor];
    self._temperatureLab.text = @"--.-℃";
    self._temperatureLab.font = [UIFont systemFontOfSize:30];
    self._temperatureLab.textAlignment = NSTextAlignmentCenter;
    self._temperatureLab.textColor = NAVIGATIONBAR_BACKGROUND_COLOR;
    [self.circular addSubview:self._temperatureLab];
    
    [self.maxTempBtn addTarget:self action:@selector(tempWarning:) forControlEvents:UIControlEventTouchUpInside];
    [self.maxTempBtn setTag:1000];
    [self.minTempBtn addTarget:self action:@selector(tempWarning:) forControlEvents:UIControlEventTouchUpInside];
    [self.minTempBtn setTag:1001];
    
    progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(5, 5, self.circular.frame.size.width - 10, self.circular.frame.size.height - 10)];
    [self.circular addSubview:progressView];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressChange) userInfo:nil repeats:NO];
    
    //点击开始按钮
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startCheck)];
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    [self.start setUserInteractionEnabled:YES];
    [self.start addGestureRecognizer:gesture];
    
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 230)];
    scrollView.bounces=NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [scrollView setContentSize:CGSizeMake(2000, 230)];
    
    lineChart = [[ZX alloc]initWithFrame:CGRectMake(0, 0, scrollView.contentSize.width,230)];
//    [lineChart setBackgroundColor:GETColor(255, 111, 132, 1)];
    [lineChart setBackgroundColor:[UIColor clearColor]];
    _pointArr=[NSMutableArray array];
    
    [scrollView addSubview:lineChart];
    [self.lineChartView addSubview:scrollView];
    
    //读取本地保存的外围设备id以作比较
    [self readUserDefaults];
    
    
    
    if ([[[GlobalTool shared] deviceString] isEqualToString:@ "iPhone 6 Plus"] || [[[GlobalTool shared] deviceString] isEqualToString:@ "iPhone 6S Plus"]) {
        self.circularLeftEdge.constant = 30;
        self.maxTempBtnRightEdge.constant = 50;
        self.minTempBtnRightEdge.constant = 50;
        self.startTopEdge.constant = 100;
        self.startRightEdge.constant = 90;
        self.lineChartViewTopEdge.constant = 250;
    }else if ([[[GlobalTool shared] deviceString] isEqualToString:@ "iPhone 6"] || [[[GlobalTool shared] deviceString] isEqualToString:@ "iPhone 6S"]) {
        self.circularLeftEdge.constant = 20;
        self.maxTempBtnRightEdge.constant = 30;
        self.minTempBtnRightEdge.constant = 30;
        self.startTopEdge.constant = 90;
        self.startRightEdge.constant = 90;
        self.lineChartViewTopEdge.constant = 230;

    }
}

#pragma mark -- 本地读取外围设备id
- (void)readUserDefaults{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    peripheralIdStr = [userDefaultes stringForKey:@"identifier"];
    NSLog(@"idStr -- %@",peripheralIdStr);
}

- (void)startCheck{
    if (press == YES) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"是否确定停止为您的宝宝测温？" preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self finishTemp];
             press = NO;
         }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (press == NO || (_testPeripheral.state != CBPeripheralStateConnected)){
        [self SearchDevice];
        press = YES;
    }
    
//    if ((_testPeripheral.state != CBPeripheralStateConnected)) { //状态处于断开
//    }
}
//1秒的间隔，一秒钟有1个间隔，走完一圈为（1 / 0.0001） == 10000个间隔，即1000秒钟，半圈即为500秒
- (void)progressChange{
    progressView.progress += 0.0001;
    if (progressView.progress > 1.0f){
        progressView.progress = 0.0f;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
    [self finishTemp];
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelPheral) object:self];//取消延迟执行,重要！
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self breakUp];
//    [_timeLabel removeFromSuperview];
    [pickview removeFromSuperview];
}

- (void)tempWarning:(UIButton *)btn{
    [pickview show];
    
    if (btn.tag == 1000) {
        flag = YES;
    }else if (btn.tag == 1001){
        flag = NO;
    }
}
#pragma mark -- 选择器的代理方法
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    if (flag == YES) {
        if (min >= [resultString integerValue]) {
            [SVProgressHUD showErrorWithStatus:@"高温值需大于低温值"];
            return;
        }
        max = [resultString intValue];
        NSMutableString *string = [[NSMutableString alloc] initWithString:@"℃"];
        [string insertString:resultString atIndex:0];
        maxStr = [NSMutableString stringWithCapacity:1];
        [maxStr appendString:string];
        [maxStr insertString:@"." atIndex:2];
        [self.maxTempBtn setTitle:maxStr forState:UIControlStateNormal];
    }else if (flag == NO){
        if (max <= [resultString integerValue]) {
            [SVProgressHUD showErrorWithStatus:@"低温值需小于高温值"];
            return;
        }
        min = [resultString intValue];
        NSMutableString *string = [[NSMutableString alloc] initWithString:@"℃"];
        [string insertString:resultString atIndex:0];
        minStr = [NSMutableString stringWithCapacity:1];
        [minStr appendString:string];
        [minStr insertString:@"." atIndex:2];
        [self.minTempBtn setTitle:minStr forState:UIControlStateNormal];
    }
    NSLog(@"%@",resultString);
}



//外围设备的代理方法
//进来就搜索外围设备
#pragma  mark -- CBPeripheralManagerDelegate -- 外围设备管理者
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"外围设备关闭");
            break;
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"外围设备打开");
            break;
            
        default:
            break;
    }
}

//检测蓝牙开关  -- 主设备状态改变的代理方法，在初始化CBCentralManager的适合会打开设备，只有当设备正确打开后才能使用
#pragma mark -- CBCentralManagerDelegate -- 中心设备管理者
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"蓝牙已关闭");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已打开");
            break;
        default:
            break;
    }
}

//开始扫面外围设备
- (void)SearchDevice{
    [SVProgressHUD showWithStatus:@"正在搜索米开温豆"];
    if (_cbCentralManager.state == CBCentralManagerStatePoweredOff) {
//        [SVProgressHUD dismiss];
        [SVProgressHUD showInfoWithStatus:@"检测到蓝牙未开启，请开启蓝牙重试"];
    }else {
        
        //第一个参数:根据外设的UUID来扫描,若设置为nil就是扫描周围所有的外设
        //        NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        //        [_cbCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:USERDEF_SERV_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        [_cbCentralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:USERDEF_SERV_UUID]] options:nil];
        double delayInSeconds = 10.0;//扫描10秒钟
        [self performSelector:@selector(cancelPheral) withObject:self afterDelay:delayInSeconds];
        //        [researchTimer setFireDate:[NSDate distantPast]];
    }
    
}

//注销搜索外围设备服务的方法
-(void)cancelPheral{
    if (_peripheralArray.count == 0) {
        [_cbCentralManager stopScan];//关闭搜索,非常重要!
//        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"未检测到米开温豆!"];
        [_timer invalidate];
        _timer = nil;
        self._timeLabel.text = @"00.00.00";
        [researchTimer setFireDate:[NSDate distantFuture]];
        researchTimer = 0;
        //        [_timer setFireDate:[NSDate distantFuture]];
        //        [self finishTemp];
    }else if (_peripheralArray.count > 1 && _testPeripheral.state != CBPeripheralStateConnected){
        [SVProgressHUD dismiss];
        UIAlertController *alertView1 = [UIAlertController alertControllerWithTitle:@"提醒" message:@"请选择温豆来测温" preferredStyle:UIAlertControllerStyleAlert];
        for (int i = 0; i < _peripheralArray.count; i++) {
            NSLog(@"name : %@ %d",[[_peripheralArray objectAtIndex:i] name],i);
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",[[_peripheralArray objectAtIndex:i] name]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"正在连接设备");
                [SVProgressHUD showWithStatus:@"正在连接设备..."];
                [_cbCentralManager connectPeripheral:_testPeripheral options:nil];//连接外围设备
            }];
            [alertView1 addAction:okAction];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [_timer invalidate];
            _timer = nil;
            self._timeLabel.text = @"00.00.00";
            [researchTimer setFireDate:[NSDate distantFuture]];     //计时器暂停
            researchTime = 0;
        }];
        
        [alertView1 addAction:cancelAction];
        [self presentViewController:alertView1 animated:YES completion:nil];
    }else if (_peripheralArray.count == 1 && _testPeripheral.state != CBPeripheralStateConnected){
        [SVProgressHUD dismiss];
        if ([identifier isEqualToString:peripheralIdStr]) {
            NSLog(@"正在连接设备");
            [SVProgressHUD showWithStatus:@"正在连接设备..."];
            [_cbCentralManager connectPeripheral:_testPeripheral options:nil];//连接外围设备
        }else{
            UIAlertController *alertView1 = [UIAlertController alertControllerWithTitle:@"请选择温豆来测温" message:[NSString stringWithFormat:@"%@",_testPeripheral.name] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"正在连接设备");
                [SVProgressHUD showWithStatus:@"正在连接设备..."];
                [_cbCentralManager connectPeripheral:_testPeripheral options:nil];//连接外围设备
                
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [_timer invalidate];
                _timer = nil;
                self._timeLabel.text = @"00.00.00";
                [researchTimer setFireDate:[NSDate distantFuture]];     //计时器暂停
                researchTime = 0;
            }];
            
            [alertView1 addAction:okAction];
            [alertView1 addAction:cancelAction];
            [self presentViewController:alertView1 animated:YES completion:nil];
        }
        
    }
    
}


/*
 找到外设的代理方法
 一个周边设备（peripheral）可以有多个服务（service）
 一个服务又可以有多个特性（cheracteristic）
 特性包含了值，比如电池的电量百分数
 特性的值可以是只读的，也可以是通过中央设备编辑的
 
 */

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@">>>>扫描周边设备 .. 及信号强度: rssi: %@",RSSI);
    NSLog(@"name:%@  identifier:%@",peripheral.name,peripheral.identifier);
    //    if (_peripheralArray != nil) {  //先判断之前存放UUID的数组是否为空,不是的话清空
    //        [_peripheralArray removeAllObjects];
    //    }
    if (![_peripheralArray containsObject:peripheral])
    {
        [_peripheralArray addObject:peripheral];
        
    }
    //    [self removeHUD];
    
    
    if (_testPeripheral != peripheral) {
        _testPeripheral = peripheral;
    }
    
    identifier = [NSString stringWithFormat:@"%@",peripheral.identifier];
    identifier = [identifier substringFromIndex:30];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:identifier forKey:@"identifier"];
    [userDefaults synchronize];
}

- (void)handleTimer:(NSTimer *)timer{
    timercount++;//时间计数自增
    int m = timercount / 60;
    int h = m / 60;
    int s = timercount % 60;
    self._timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@",[self getTimeStr:h],[self getTimeStr:m % 60], [self getTimeStr:s % 60]];
    NSLog(@"timecount %d",timercount % 20);
    if (timercount == 7 || (timercount % 20 == 0)) {    //若为三十秒的整数倍就绘制
        [self draw];
    }
    
    //每一秒绘制一次圆环
    [self progressChange];
}
- (NSString *)getTimeStr:(int)value{
    if (value<10) {
        return [NSString stringWithFormat:@"0%i",value];
    }
    return [NSString stringWithFormat:@"%i",value];
}

//成功连接上外围设备后的代理，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"和周边设备连接成功");
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"正在获取温度..."];
    [_cbCentralManager stopScan];//关闭搜索,非常重要!
    
    _timer = [NSTimer scheduledTimerWithTimeInterval: 1
                                              target: self
                                            selector: @selector(handleTimer:)  //这个方法就是每秒一次获取体温数据
                                            userInfo: nil
                                             repeats: YES];
    [peripheral setDelegate:self];
    [peripheral discoverServices: @[[CBUUID UUIDWithString:USERDEF_SERV_UUID]]];
}

//连接外围设备失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外围设备失败 %@.(%@)",peripheral,[error description]);
    [self cleanup];
    [_cbCentralManager stopScan];
    [_timer setFireDate:[NSDate distantFuture]];
    
    press = NO;
}
-(void)cleanup{
    if (_testPeripheral.state != CBPeripheralStateConnected) {
        return;
    }
    // See if we are subscribed to a characteristic on the peripheral
    //先判断外围服务是否打开
    if (_testPeripheral.services != nil) {
        //已经打开的话,遍历寻找外围设备服务
        for (CBService *service in _testPeripheral.services) {
            //判断是否获取到了外围设备特征
            if (service.characteristics != nil) {
                //遍历寻找设备特征
                for (CBCharacteristic *characteristic in service.characteristics) {
                    //如果设备特征符合温豆特征
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:USERDEF_SERV_UUID]]) {
                        //判断它是不是在发送通知消息
                        if (characteristic.isNotifying) {
                            //如果是则注销
                            [_testPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:@"连接设备失败"];
    NSLog(@"连接设备失败");
    
    // cancelPeripheralConnection -- 取消一个活跃的或者等待连接的peripheral的连接的方法
    [_cbCentralManager cancelPeripheralConnection:_testPeripheral];
}

//断开蓝牙设备的代理方法
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"外围设备已断开");
    [_cbCentralManager stopScan];
    [SVProgressHUD dismiss];
    press = NO;
    [_cbCentralManager cancelPeripheralConnection:peripheral];
    
    [_timer setFireDate:[NSDate distantFuture]];
    
    //判断是否重连
    if (_timer) {   //自动测温完成和手动完成_timer是注销掉的,如果是意外断开的就开启重新搜索的方法
        //每次中断就设置为0
        researchTime = 0;
        [researchTimer setFireDate:[NSDate distantPast]];//计时开始
        [self SearchDevice];//失败再重试
        [_cbCentralManager connectPeripheral:peripheral options:nil];
        
    }
}

#pragma mark - UIAlerVIew
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        [self finishTemp];
    }
}

//设备自动断开网络后判断重连时间
-(void)startResearchTime{
    NSLog(@"researchTime = %d",researchTime);
    if (researchTime < 30) {
        //[self setupService];//失败再重试
        if (researchTime == 20) {
            [SVProgressHUD showInfoWithStatus:@"信号不稳定哦~请检查温豆距离是否太远"];
        }
        researchTime++;
    }else{
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"无法连接到设备"];
        [self finishTemp];
        [_timer setFireDate:[NSDate distantFuture]];
        [researchTimer setFireDate:[NSDate distantFuture]];     //计时器暂停
        researchTime = 0;
        [_cbCentralManager cancelPeripheralConnection:_testPeripheral];
        [_cbCentralManager stopScan];
    }
}

/*
 设备连接成功后，就可以扫描设备的服务了，同样是通过委托形式，扫描到结果后会进入委托方法。但是这个委托已经不再是主设备的委托（CBCentralManagerDelegate），而是外设的委托（CBPeripheralDelegate）,这个委托包含了主设备与外设交互的许多回调方法，包括获取services，获取characteristics，获取characteristics的值，获取characteristics的Descriptor，和Descriptor的值，写数据，读rssi，用通知的方式订阅数据等等。
 
 */

//发现服务后，开始查找特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"获取特征");
    
    if (error){
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    for (CBService *service in peripheral.services){
        NSLog(@"Service found with UUID: %@",service.UUID);
        if ([service.UUID isEqual:[CBUUID  UUIDWithString:USERDEF_SERV_UUID]]){
            [peripheral discoverCharacteristics: nil forService:service];
        }
    }
}
//发现特征，并根据特征值设置监听通道
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"charatetistics:%@",[service characteristics]);
    if (error){
        NSLog(@"发现外围设备特征值错误: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString: USERDEF_SERV_UUID]]){
        for (CBCharacteristic *characteristic in service.characteristics){
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:PERIPHERAL_NOTI_UUID]]){
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];   //0xF4E2 对该特征进行订阅
                _peripheralCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:PERIPHERAL_SYSCLOCK_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                _sysClockCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CENTRAL_WRITE_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                _centralCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:PERIPHERAL_RATE_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                _rateCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:PERIPHERAL_CACHE_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                _cacheCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:PERIPHERAL_CACHE_FIFO_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                _cacheFIFOCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:PERIPHERAL_LASTCACHETEMPTIME_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                _LastTempCharacteristic = characteristic;
            }
        }
        [self UpdateFromDate];  //同步时间
        [self sendOldData];     //在此时发送连续温度转换指令,这两个方法不可分开且只能发送一次
        [researchTimer setFireDate:[NSDate distantFuture]];//将计时器暂停
        researchTime = 0;
    }
}

//发送触发函数
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error){
        NSLog(@"写入失败:%@,%@,%@",peripheral,characteristic,[error description]);
    }else{
        NSLog(@"写入成功:%@,%@",peripheral,characteristic);
    }
}

//处理蓝牙回调函数
//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //此处是实时读取RSSI
    [_testPeripheral readRSSI];
    
    //此处是处理连续温度转换,先要保证其value的值存在,其次UUID要等于0xF4E1
    if (characteristic.value && [characteristic.UUID isEqual:[CBUUID UUIDWithString:PERIPHERAL_NOTI_UUID]]) {
        Byte *by=(Byte*)[characteristic.value bytes];
        if ((by[0] == 2) && (by[1] == 1)) {   //此处是连续温度转换,返回4个字节
            
            float a = (by[2] + by[3] * 256 ) / 100.0f;
            TempStr =[NSString stringWithFormat:@"%.1f",a];//
            [SVProgressHUD dismiss];
            
            [self updateTemperture];
            /**
             *	11/24新增了折线图
             *
             */
            //5秒一次接收最大值
            maxTemp = a > maxTemp ? a : maxTemp;
            
//            NSString *totalStr = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%.1f\n",a]];
//            textView.text = totalStr;
//            NSLog(@"text.text  %@",textView.text);
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"member_id"] = @1;
            dic[@"temperature"] = [NSString stringWithFormat:@"%f",a];
            dic[@"date"] = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
            dic[@"type"] = @"bluetooth";
            [manager POST:@"http://120.24.174.207/api.php?m=open&c=bluetooth&a=addTemperature" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"success");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error);
            }];
        }
    }
}

- (void)draw{
    if (maxTemp == 0) {
        return;
    }
    [_pointArr addObject:[NSNumber numberWithDouble:maxTemp]];
    maxTemp = 0;
    [lineChart setArray:_pointArr];
    [lineChart setNeedsDisplay];
}

//如果一个特征的值被更新，然后周边代理接收
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [peripheral readValueForCharacteristic:characteristic];
    NSLog(@"ueriiewrio");
}


- (void)updateTemperture{
    NSLog(@"---temp-%@",TempStr);
    if (TempStr) {
        self._temperatureLab.text=[NSString stringWithFormat:@"%@℃",TempStr];
    }
}

//这个是获取系统时间的方法
- (NSInteger)getCurrentDate:(NSInteger)myflg{
    NSDate *date=[NSDate date];//获取当前时间
    NSDateFormatter *format1=[[NSDateFormatter alloc]init];
    
    if (myflg==0) //second
    {
        [format1 setDateFormat:@"ss"];
        return  [  [format1 stringFromDate:date] intValue];
    }
    else if (myflg==1) //minute
    {
        [format1 setDateFormat:@"mm"];
        return  [  [format1 stringFromDate:date] intValue];
    }
    else if (myflg==2) //hour
    {
        [format1 setDateFormat:@"HH"];
        return  [  [format1 stringFromDate:date] intValue];
    }
    else if (myflg==3) //day
    {
        [format1 setDateFormat:@"dd"];
        return  [  [format1 stringFromDate:date] intValue];
    }
    else if (myflg==4) //month
    {
        [format1 setDateFormat:@"MM"];
        return  [  [format1 stringFromDate:date] intValue];
    }
    else if (myflg==5) //year
    {
        [format1 setDateFormat:@"yyyy"];
        return  [  [format1 stringFromDate:date] intValue]-2000;
    }
    else
    {
        return 0;
    }
    
}
//系统日期同步
-(void)UpdateFromDate{
    //日期同步的命令码长度是六个字节,B0~B5:秒,分,时,日,月,年
    Byte datebyte[6];
    for (int i=0; i<6; i++) {
        datebyte[i] = [self getCurrentDate:i];
    }
    
    NSData *data=[[NSData alloc] initWithBytes:datebyte length:sizeof(datebyte)];
    [_testPeripheral writeValue:data forCharacteristic:_sysClockCharacteristic type:CBCharacteristicWriteWithResponse];//写数据
    
}

//发送温度转换指令
-(void)sendOldData{
    
    /*连接断开之后，重新建立连接，先批量上报记忆数据，然后进入正常的数据采样-上报流程*/
    //先设置一个连续转换温度的速率,单位ms,短整型,此处设置的是一万毫秒,先转换成16进制,by[0]低位,by[1]高位 {0x10,0x27} = 10000
    /**
     *	11/11号修改为了一秒一次，不再使用单次温度转换
     *  11/24修改为了五秒一次
     */
    Byte by[] = {0x88,0x13};
    NSData *rateData=[[NSData alloc] initWithBytes:by length:sizeof(by)];
    [_testPeripheral writeValue:rateData forCharacteristic:_rateCharacteristic type:CBCharacteristicWriteWithResponse];
    
    //开始连续转换温度的命令码:0x02 0x01    1
    Byte byte[] = {2,1};
    NSData *data=[[NSData alloc] initWithBytes:byte length:sizeof(byte)];
    [_testPeripheral writeValue:data forCharacteristic:_centralCharacteristic type:CBCharacteristicWriteWithResponse];
}



-(void)finishTemp{
    if (_testPeripheral.state == CBPeripheralStateConnected) {
        //此时发送清除下位机缓存温度的指令，全部清除缓存数据
        Byte byte[] = {7,0};
        NSData *data1=[[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        [_testPeripheral writeValue:data1 forCharacteristic:_centralCharacteristic type:CBCharacteristicWriteWithResponse];
        //然后发送停止连续温度转换的命令
        Byte bt[] = {2,0};
        NSData *data=[[NSData alloc] initWithBytes:bt length:sizeof(bt)];
        [_testPeripheral writeValue:data forCharacteristic:_centralCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    [researchTimer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
    [self performSelector:@selector(breakUp) withObject:self afterDelay:2];
    
}
- (void)breakUp{
    //然后判断是不是已经在连接
    if (_testPeripheral.state == CBPeripheralStateConnected || _testPeripheral.state == CBPeripheralStateConnecting) {
        [_cbCentralManager cancelPeripheralConnection:_testPeripheral];
        [_cbCentralManager stopScan];
    }
    
}
-(void)powerOff:(UIButton *)sender{
    [self finishTemp];
    
    //关机命令
    Byte bt[] = {0xff,0x00};
    NSData *data=[[NSData alloc] initWithBytes:bt length:sizeof(bt)];
    [_testPeripheral writeValue:data forCharacteristic:_centralCharacteristic type:CBCharacteristicWriteWithResponse];
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

//
//  MapViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/25.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"

@interface MapViewController () <CLLocationManagerDelegate,MKMapViewDelegate>
@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic,strong) CLLocationManager *locationManager;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置Nav
    [self setupNav];
    
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    }
    
    if (![CLLocationManager locationServicesEnabled]) { //不允许地理定位
        [SVProgressHUD showErrorWithStatus:@"请开启地理位置!"];
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse) {
        //设置代理
        _locationManager.delegate=self;
        //设置定位精度
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance=10.0;//十米定位一次
        _locationManager.distanceFilter=distance;
    }
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
    [self.view addSubview:self.mapView];

}

/**
 *  设置Nav
 */
- (void)setupNav {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo"]];
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocationCoordinate2D loc = [userLocation coordinate];
    //放大地图到自身的经纬度位置。
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    [self.mapView setRegion:region animated:YES];
    
    //判断是否登陆
    NSString *subTitleStr = @"";
    if ([[DatabaseTool shared] getDefaultMember] == nil) {
        subTitleStr = @"您还未登陆";
    } else {
        NSMutableDictionary *tempDict = [[DatabaseTool shared] getDefaultMemberLastDiary];
        if (tempDict != nil) {
            NSString *temperature = [tempDict objectForKey:@"temperature"];
            subTitleStr = [NSString stringWithFormat:@"最近的测温记录:%@",temperature];
        }
        
        
    }
    MyAnnotation *anno = [[MyAnnotation alloc] initWithCoordinates:loc title:@"您的位置" subTitle:subTitleStr];
    
    [self.mapView addAnnotation:anno];
    [self.mapView selectAnnotation:anno animated:YES];
    [self.mapView setShowsUserLocation:NO];
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

//
//  ViewController.h
//  BeaconReceiver
//
//  Created by Christopher Ching on 2013-11-28.
//  Copyright (c) 2013 AppCoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import UserNotifications;

@interface ViewController : UIViewController<CLLocationManagerDelegate, UNUserNotificationCenterDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelThree;
@property (strong, nonatomic) NSString *currentMinorVersion;
@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UNUserNotificationCenter *center;

@end

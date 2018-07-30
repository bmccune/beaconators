//
//  ViewController.m
//  BeaconReceiver
//
//  Created by Christopher Ching on 2013-11-28.
//  Copyright (c) 2013 AppCoda. All rights reserved.
//

#import "ViewController.h"
@import UserNotifications;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initialize location manager and set ourselves as the delegate
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
    //Create user notify
    self.center = [UNUserNotificationCenter currentNotificationCenter];
    self.center.delegate = self;
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    // Objective-C
    [self.center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!granted) {
                                  NSLog(@"Something went wrong");
                              }
                          }];
    //self.center = center;
    
    // Create a NSUUID with the same UUID as the broadcasting beacon
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"];
    
    // Setup a new region with that UUID and same identifier as the broadcasting beacon
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                             identifier:@"com.bmccune.myRegion"];
    // Tell location manager to start monitoring for the beacon region
    [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
    //[self.locationManager requestStateForRegion:self.myBeaconRegion];
    //[self.locationManager performSelector:@selector(requestStateForRegion:) withObject:self.myBeaconRegion afterDelay:1];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.myBeaconRegion];
    // Check if beacon monitoring is available for this device
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring not available" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]; [alert show]; return;
    }
    //self.statusLabel.text = @"Finding beacons.";
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManger:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion*)region{
    self.labelThree.text = @"DeterminedState";
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region
{
    // We entered a region, now start looking for our target beacons!
    self.statusLabel.text = @"Finding beacons.";
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion *)region
{
    // Exited the region
    self.statusLabel.text = @"None found.";
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center
        willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    // Beacon found!
    self.statusLabel.text = @"Beacon found!";
    
    CLBeacon *foundBeacon = [beacons firstObject];
    
    // You can retrieve the beacon data from its properties
    //NSString *uuid = foundBeacon.proximityUUID.UUIDString;
    //NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
    NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
    if ([self.currentMinorVersion isEqual: minor]) { return; }
    self.currentMinorVersion = minor;
    self.labelThree.text = [NSString stringWithFormat:@"%@", foundBeacon.minor];
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    if([minor isEqual:@"64001"]){
        content.title = @"Welcome to Chase!";
        content.body = @"Have you tried QuickPay with Zelle?";
    }else if([minor isEqual:@"64002"]){
        content.title = @"Waiting for help?";
        content.body = @"You're pre-qualified for Chase Sapphire Preferred.";
    }else{
        return;
    }
    content.sound = [UNNotificationSound defaultSound];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1
                                                                                                    repeats:NO];
    NSString *identifier = @"UYLLocalNotification";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:trigger];
    
    [self.center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        }
    }];
}

@end

//
//  ViewController.m
//  iBeaconEmitter
//
//  Created by David Cortés Fulla on 24/12/13.
//  Copyright (c) 2013 Lafosca. All rights reserved.
//

#import "ViewController.h"
#import "BNMBeaconRegion.h"
@import CoreLocation;

@interface ViewController ()

@property (weak) IBOutlet UITextField *uuid;
@property (weak) IBOutlet UITextField *identifier;
@property (weak) IBOutlet UITextField *major;
@property (weak) IBOutlet UITextField *minor;
@property (weak) IBOutlet UITextField *power;
@property (weak) IBOutlet UIButton *startBeaconButton;
@property (weak) IBOutlet UILabel *bluetoothStatusLbl;
@property (strong, nonatomic) CBPeripheralManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

    NSUUID *proximityUUID = [NSUUID UUID];
    [self.uuid setText:[proximityUUID UUIDString]];
    
    self.identifier.text = @"Pangea Beacon";
    self.major.text = @"1";
    self.minor.text = @"1";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
            [self.bluetoothStatusLbl setText:@"The current state of the peripheral manager is unknown; an update is imminent."];
            [self.startBeaconButton setEnabled:NO];
            break;
        case CBPeripheralManagerStateUnauthorized:
            [self.bluetoothStatusLbl setText:@"The app is not authorized to use the Bluetooth low energy peripheral/server role."];
            [self.startBeaconButton setEnabled:NO];
            break;
        case CBPeripheralManagerStateResetting:
            [self.bluetoothStatusLbl setText:@"The connection with the system service was momentarily lost; an update is imminent."];
            [self.startBeaconButton setEnabled:NO];
            break;
        case CBPeripheralManagerStatePoweredOff:
            [self.bluetoothStatusLbl setText:@"Bluetooth is currently powered off"];
            [self.startBeaconButton setEnabled:NO];
            break;
        case CBPeripheralManagerStateUnsupported:
            [self.bluetoothStatusLbl setText:@"The platform doesn't support the Bluetooth low energy peripheral/server role."];
            [self.startBeaconButton setEnabled:NO];
            break;
        case CBPeripheralManagerStatePoweredOn:
            [self.bluetoothStatusLbl setText:@"Bluetooth is currently powered on and is available to use."];
            [self.startBeaconButton setEnabled:YES];
            break;
    }
    
    
}

#pragma mark - Actions

- (IBAction)changeBeaconState:(UIButton *)sender {
    
    NSArray *textFields = @[self.uuid, self.identifier, self.major, self.minor, self.power];
    for (UITextField *textField in textFields) {
        [textField resignFirstResponder];
    }
    
    if ([self.manager isAdvertising]) {
        [self.manager stopAdvertising];
        [sender setTitle:@"Turn iBeacon on" forState:UIControlStateNormal];
    } else {
        
        NSUUID *proximityUUID  = [[NSUUID alloc] initWithUUIDString:self.uuid.text];
        if (proximityUUID) {
            CLBeaconRegion *beacon = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                               major:[self.major.text intValue]
                                                                               minor:[self.minor.text intValue]
                                                                          identifier:self.identifier.text];
            
            NSDictionary *proximityData = [beacon peripheralDataWithMeasuredPower:nil];
            [self.manager startAdvertising:proximityData];
            
            [sender setTitle:@"Turn iBeacon off" forState:UIControlStateNormal];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The UUID format is invalid" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (IBAction)handleClickRefreshButton:(id)sender {
    if ([self.manager isAdvertising]) {
        [self.manager stopAdvertising];
        [self.startBeaconButton setTitle:@"Turn iBeacon on" forState:UIControlStateNormal];
    }
    
    NSUUID *proximityUUID = [NSUUID UUID];
    [self.uuid setText:[proximityUUID UUIDString]];
}

@end

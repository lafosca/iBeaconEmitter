//
//  ViewController.m
//  iBeaconEmitter
//
//  Created by David Cortés Fulla on 24/12/13.
//  Copyright (c) 2013 Lafosca. All rights reserved.
//

#import "ViewController.h"

#define BEACON_UUID @"8B1026A2-3F02-4074-BBA6-626FE3BD73F6"
#define IDENTIFIER @"cat.lafosca.beaconnect.pangea"

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

    [self.uuid setText:BEACON_UUID];
    [self.identifier setText:IDENTIFIER];
    
    self.major.text = @"1";
    self.minor.text = @"1";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self layoutTextFields];
    [self.startBeaconButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.startBeaconButton.layer setBorderWidth:1.0];
    [self.startBeaconButton.layer setCornerRadius:2.0];
}
- (void)layoutTextFields {
    for (UITextField *textField in [self allTextFields]) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        textField.leftView = paddingView;
        textField.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (NSArray *)allTextFields {
   return @[self.uuid, self.identifier, self.major, self.minor, self.power];
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
    
    for (UITextField *textField in [self allTextFields]) {
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
            NSNumber *measuredPower = nil;
            if ([self.power.text intValue] != 0) {
                measuredPower = [NSNumber numberWithInt:[self.power.text intValue]];
            }
            
            NSDictionary *proximityData = [beacon peripheralDataWithMeasuredPower:measuredPower];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (UITextField *textField in [self allTextFields]) {
        [textField resignFirstResponder];
    }
}

@end

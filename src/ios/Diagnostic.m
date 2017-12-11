/*
 *  Diagnostic.h
 *  Plugin diagnostic
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import "Diagnostic.h"

@interface Diagnostic()

@property (nonatomic, retain) CMPedometer* cmPedometer;
@property (nonatomic, retain) NSUserDefaults* settings;

@end


@implementation Diagnostic

- (void)pluginInitialize {

    [super pluginInitialize];

    self.locationRequestCallbackId = nil;
    self.currentLocationAuthorizationStatus = nil;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    self.motionManager = [[CMMotionActivityManager alloc] init];
    self.motionActivityQueue = [[NSOperationQueue alloc] init];
    self.cmPedometer = [[CMPedometer alloc] init];
    self.settings = [NSUserDefaults standardUserDefaults];
}

/********************************/
#pragma mark - Plugin API
/********************************/

#pragma mark - Location
- (void) isLocationAvailable: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[CLLocationManager locationServicesEnabled] && [self isLocationAuthorized] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[CLLocationManager locationServicesEnabled] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}


- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[self isLocationAuthorized] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    @try {
        NSString* status = [self getLocationAuthorizationStatusAsString:[CLLocationManager authorizationStatus]];
        NSLog(@"%@",[NSString stringWithFormat:@"Location authorization status is: %@", status]);
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) requestLocationAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)])
        {
            BOOL always = [[command argumentAtIndex:0] boolValue];
            if(always){
                NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationAlwaysUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationAlwaysUsageDescription in its Info.plist");
                [self.locationManager requestAlwaysAuthorization];
                NSLog(@"Requesting location authorization: always");
            }else{
                NSAssert([[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSLocationWhenInUseUsageDescription"], @"For iOS 8 and above, your app must have a value for NSLocationWhenInUseUsageDescription in its Info.plist");
                [self.locationManager requestWhenInUseAuthorization];
                NSLog(@"Requesting location authorization: when in use");
            }
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
    self.locationRequestCallbackId = command.callbackId;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self sendPluginResult:pluginResult :command];
}

#pragma mark - Camera
- (void) isCameraAvailable: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[self isCameraPresent] && [self isCameraAuthorized] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isCameraPresent: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[self isCameraPresent] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command
{    @try {
    [self sendPluginResultBool:[self isCameraAuthorized] :command];
}
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    @try {
        NSString* status;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

        if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
            status = @"denied";
        }else if(authStatus == AVAuthorizationStatusNotDetermined){
            status = @"not_determined";
        }else if(authStatus == AVAuthorizationStatusAuthorized){
            status = @"authorized";
        }
        NSLog(@"%@",[NSString stringWithFormat:@"Camera authorization status is: %@", status]);
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self sendPluginResultBool:granted :command];
        }];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command
{
    @try {
        [self sendPluginResultBool:[[self getCameraRollAuthorizationStatus]  isEqual: @"authorized"] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    @try {
        NSString* status = [self getCameraRollAuthorizationStatus];
        NSLog(@"%@",[NSString stringWithFormat:@"Camera Roll authorization status is: %@", status]);
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) requestCameraRollAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authStatus) {
            NSString* status = [self getCameraRollAuthorizationStatusAsString:authStatus];
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
        }];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

#pragma mark -  Settings
- (void) switchToSettings: (CDVInvokedUrlCommand*)command
{
    @try {
        if (UIApplicationOpenSettingsURLString != nil ){
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] :command];
                    }else{
                        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] :command];
                    }
                }];
#endif
            }else{
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
                [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] :command];
            }
        }else{
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not supported below iOS 8"]:command];
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) switchToLocationSettings: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    @try {
        if (UIApplicationOpenSettingsURLString != nil){
            NSURL *url;

#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_8_0
            url = [NSURL URLWithString: @"prefs:root=LOCATION_SERVICES"];
#else
            url = [NSURL URLWithString: @"App-Prefs:root=Privacy&path=LOCATION"];
#endif

            if (![[UIApplication sharedApplication] canOpenURL:url]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot open phone settings, check the URL schema for iOS 11"];
            }else{
				[[UIApplication sharedApplication] openURL:url];
            	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }else{
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not supported below iOS 8"];
        }
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Motion methods

- (void) isMotionAvailable:(CDVInvokedUrlCommand *)command
{
    @try {

        [self sendPluginResultBool:[self isMotionAvailable] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) isMotionRequestOutcomeAvailable:(CDVInvokedUrlCommand *)command
{
    @try {

        [self sendPluginResultBool:[self isMotionRequestOutcomeAvailable] :command];
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}

- (void) getMotionAuthorizationStatus: (CDVInvokedUrlCommand*)command
{
    if([self getSetting:@"motion_permission_requested"] == nil){
        // Permission not yet requested
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"not_requested"] :command];
    }else{
       // Permission has been requested so determine the outcome
        [self _requestMotionAuthorization:command];
    }
}

- (void) requestMotionAuthorization: (CDVInvokedUrlCommand*)command{
    if([self getSetting:@"motion_permission_requested"] != nil){
        [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"requestMotionAuthorization() has already been called and can only be called once after app installation"]:command];
    }else{
        [self _requestMotionAuthorization:command];
    }
}

- (void) _requestMotionAuthorization: (CDVInvokedUrlCommand*)command
{
    @try {
        if([self isMotionAvailable]){
                @try {
                    [self.cmPedometer queryPedometerDataFromDate:[NSDate date]
                         toDate:[NSDate date]
                    withHandler:^(CMPedometerData* data, NSError *error) {
                        @try {
                            [self setSetting:@"motion_permission_requested" forValue:(id)kCFBooleanTrue];
                            NSString* status = @"unknown";
                            if (error != nil) {
                                if (error.code == CMErrorMotionActivityNotAuthorized) {
                                    status = @"denied";
                                }else if (error.code == CMErrorMotionActivityNotEntitled) {
                                    status = @"restricted";
                                }else if (error.code == CMErrorMotionActivityNotAvailable) {
                                    // Motion request outcome cannot be determined on this device
                                    status = @"not_determined";
                                }
                            }
                            else{
                                status = @"authorized";
                            }

                            NSLog(@"Motion tracking authorization status is %@", status);
                            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status] :command];
                        }@catch (NSException *exception) {
                            [self handlePluginException:exception :command];
                        }
                    }];
                }@catch (NSException *exception) {
                    [self handlePluginException:exception :command];
                }
        }else{
            // Activity tracking not available on this device
            [self sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"not_available"] :command];
        }
    }@catch (NSException *exception) {
        [self handlePluginException:exception :command];
    }
}


/********************************/
#pragma mark - Send results
/********************************/

- (void) sendPluginResult: (CDVPluginResult*)result :(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) sendPluginResultBool: (BOOL)result :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult;
    if(result) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) handlePluginException: (NSException*) exception :(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)jsCallback: (NSString*)jsString
{
    [self.commandDelegate evalJs:jsString];
}

/********************************/
#pragma mark - utility functions
/********************************/

- (void) setSetting: (NSString*)key forValue:(id)value{

    [self.settings setObject:value forKey:key];
    [self.settings synchronize];
}

- (id) getSetting: (NSString*) key{
    return [self.settings objectForKey:key];
}

- (BOOL) isMotionAvailable
{
    return [CMMotionActivityManager isActivityAvailable];
}

- (BOOL) isMotionRequestOutcomeAvailable
{
    return [CMPedometer respondsToSelector:@selector(isPedometerEventTrackingAvailable)] && [CMPedometer isPedometerEventTrackingAvailable];
}


- (NSString*) getLocationAuthorizationStatusAsString: (CLAuthorizationStatus)authStatus
{
    NSString* status;
    if(authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == kCLAuthorizationStatusNotDetermined){
        status = @"not_determined";
    }else if(authStatus == kCLAuthorizationStatusAuthorizedAlways){
        status = @"authorized";
    }else if(authStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
        status = @"authorized_when_in_use";
    }
    return status;
}

- (BOOL) isLocationAuthorized
{
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    if([status  isEqual: @"authorized"] || [status  isEqual: @"authorized_when_in_use"]) {
        return true;
    } else {
        return false;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)authStatus {
    NSString* status = [self getLocationAuthorizationStatusAsString:authStatus];
    BOOL statusChanged = false;
    if(self.currentLocationAuthorizationStatus != nil && ![status isEqual: self.currentLocationAuthorizationStatus]){
        statusChanged = true;
    }
    self.currentLocationAuthorizationStatus = status;

    if(!statusChanged) return;


    NSLog(@"%@",[NSString stringWithFormat:@"Location authorization status changed to: %@", status]);

    if(self.locationRequestCallbackId != nil){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.locationRequestCallbackId];
        self.locationRequestCallbackId = nil;
    }

    [self jsCallback:[NSString stringWithFormat:@"cordova.plugins.diagnostic._onLocationStateChange(\"%@\");", status]];
}

- (BOOL) isCameraPresent
{
    BOOL cameraAvailable =
    [UIImagePickerController
     isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if(cameraAvailable) {
        NSLog(@"Camera available");
        return true;
    }
    else {
        NSLog(@"Camera unavailable");
        return false;
    }
}

- (BOOL) isCameraAuthorized
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        return true;
    } else {
        return false;
    }
}

- (NSString*) getCameraRollAuthorizationStatus
{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    return [self getCameraRollAuthorizationStatusAsString:authStatus];

}

- (NSString*) getCameraRollAuthorizationStatusAsString: (PHAuthorizationStatus)authStatus
{
    NSString* status;
    if(authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted){
        status = @"denied";
    }else if(authStatus == PHAuthorizationStatusNotDetermined ){
        status = @"not_determined";
    }else if(authStatus == PHAuthorizationStatusAuthorized){
        status = @"authorized";
    }
    return status;
}

- (NSString*) arrayToJsonString:(NSArray*)inputArray
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString*) objectToJsonString:(NSDictionary*)inputObject
{
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inputObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end

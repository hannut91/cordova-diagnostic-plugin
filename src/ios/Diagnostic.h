/*
 *  Diagnostic.h
 *  Plugin diagnostic
 *
 *  Copyright (c) 2015 Working Edge Ltd.
 *  Copyright (c) 2012 AVANTIC ESTUDIO DE INGENIEROS
 */

#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <Photos/Photos.h>

@interface Diagnostic : CDVPlugin <CLLocationManagerDelegate>

    @property (strong, nonatomic) CLLocationManager* locationManager;
    @property (strong, nonatomic) CMMotionActivityManager* motionManager;
    @property (strong, nonatomic) NSOperationQueue* motionActivityQueue;
    @property (nonatomic, retain) NSString* locationRequestCallbackId;
    @property (nonatomic, retain) NSString* currentLocationAuthorizationStatus;

- (void) isLocationAvailable: (CDVInvokedUrlCommand*)command;
- (void) isLocationEnabled: (CDVInvokedUrlCommand*)command;
- (void) isLocationAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getLocationAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestLocationAuthorization: (CDVInvokedUrlCommand*)command;

- (void) isCameraAvailable: (CDVInvokedUrlCommand*)command;
- (void) isCameraPresent: (CDVInvokedUrlCommand*)command;
- (void) isCameraAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestCameraAuthorization: (CDVInvokedUrlCommand*)command;
- (void) isCameraRollAuthorized: (CDVInvokedUrlCommand*)command;
- (void) getCameraRollAuthorizationStatus: (CDVInvokedUrlCommand*)command;

- (void) switchToSettings: (CDVInvokedUrlCommand*)command;
- (void) switchToLocationSettings: (CDVInvokedUrlCommand*)command;

- (void) isMotionAvailable: (CDVInvokedUrlCommand*)command;
- (void) isMotionRequestOutcomeAvailable: (CDVInvokedUrlCommand*)command;
- (void) getMotionAuthorizationStatus: (CDVInvokedUrlCommand*)command;
- (void) requestMotionAuthorization: (CDVInvokedUrlCommand*)command;

@end
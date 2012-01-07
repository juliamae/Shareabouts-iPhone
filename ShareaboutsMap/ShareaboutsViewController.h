//
//  ShareaboutsViewController.h
//  ShareaboutsMap
//
//  Created by Evan Carter on 1/6/12.
//  Copyright (c) 2012 OpenPlans. All rights reserved.
//

#define kTextURL    @"http://shareabouts.dev.openplans.org/locations"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ShareaboutsViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView  *activityIndicator;

- (void) setUIState:(int)uiState;

@end

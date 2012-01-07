//
//  ShareaboutsViewController.m
//  ShareaboutsMap
//
//  Created by Evan Carter on 1/6/12.
//  Copyright (c) 2012 OpenPlans. All rights reserved.
//

#import "ShareaboutsViewController.h"

@implementation ShareaboutsViewController
@synthesize mapView;
@synthesize locationManager;
@synthesize urlConnection;
@synthesize receivedData;
@synthesize activityIndicator;


// State is loading data. Used to set view.
static const int LOADING_STATE = 1;
// State is active. Used to set view.
static const int ACTIVE_STATE = 0;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // locationManager setup
    locationManager = [[CLLocationManager alloc] init];
//    [locationManager setDelegate:self]; ?? gave me error
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.mapView setShowsUserLocation:YES];
    self.mapView.delegate = self;
    
    // Fetch server data
    // Change UI to loading state
    [self setUIState:LOADING_STATE];
    

}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.activityIndicator = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - state things
-(void) setUIState:(int)uiState;
{
    // Set view state to animating.
    if (uiState == LOADING_STATE)
    {
        [activityIndicator startAnimating];
    }
    // Set view state to not animating.
    else if (uiState == ACTIVE_STATE)
    {
        [activityIndicator stopAnimating];
    }
}

#pragma mark - mapView things

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id<MKAnnotation> mp = [annotationView annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 250, 250);
    
    [mv setRegion:region animated:YES];
}

#pragma mark - data stuff

-(IBAction)loadPoints:(id)sender
{
    NSLog(@"loadPoints");
    // Change UI to loading state
    [self setUIState:LOADING_STATE];
    NSString *urlAsString = [NSString stringWithFormat:@"%@", kTextURL ];
    
    NSLog(@"urlAsString: %@",urlAsString );
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlAsString]];
    
    // Create the NSURLConnection con object with the NSURLRequest req object
    // and make this MountainsEx01ViewController the delegate.
    urlConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    // Connection successful
    if (urlConnection) {
        NSMutableData *data = [[NSMutableData alloc] init];
        self.receivedData   = data;
        // [data release];
    }
    // Connection failed.
    else
    {
        UIAlertView *alert = [
                              [UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Error", @"Error")
                              message:NSLocalizedString(@"Error connecting to remote server", @"Error connecting to remote server")
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Bummer", @"Bummer")
                              otherButtonTitles:nil
                              ];
        [alert show];
        // [alert release];
    }
    // [req release];

}

@end

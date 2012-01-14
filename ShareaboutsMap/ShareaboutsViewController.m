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

-(IBAction)loadPoints
{
    [self setUIState:LOADING_STATE];
    NSString *urlAsString = [NSString stringWithFormat:@"%@", kTextURL ];
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlAsString]];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    // Connection successful
    if (urlConnection) {
        NSMutableData *data = [[NSMutableData alloc] init];
        self.receivedData   = data;
    }
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
    }    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CLLocationCoordinate2D openPlansCoord = {40.719991, -73.999530};
    
	MKCoordinateSpan span = {0.2, 0.2};
    MKCoordinateRegion region = { openPlansCoord, span};
    
    [mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
    
    [self loadPoints];
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



#pragma mark - NSURLConnection Callbacks
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.receivedData = nil; 
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error"
                          message:[NSString stringWithFormat:@"Connection failed! Error - %@ (URL: %@)", [error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]]
                          delegate:self
                          cancelButtonTitle:@"Bummer"
                          otherButtonTitles:nil];
    [alert show];
    [self setUIState:ACTIVE_STATE];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    NSDictionary *parsedData = [NSJSONSerialization 
                                JSONObjectWithData:receivedData
                                options:kNilOptions 
                                error:&error];
        
    NSArray *features = [parsedData valueForKey:@"features"];

    for (int i=0; i < [features count]; i++) {
        NSDictionary *feature = [features objectAtIndex:i];
        NSArray *coordinates  = [[feature valueForKey:@"geometry"] valueForKey:@"coordinates"];
        NSString *properties  = [feature valueForKey:@"properties"];
                
        CLLocationCoordinate2D latLng = { 
            [[coordinates objectAtIndex:1] doubleValue], 
            [[coordinates objectAtIndex:0] doubleValue] 
        };
        
        MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
        annotationPoint.coordinate = latLng;
        
        NSString *title = [properties valueForKey:@"name"];
        NSString *subTitle = [properties valueForKey:@"description"];
        
        if (title == (id)[NSNull null] || title.length == 0 ) 
            title = [NSString stringWithFormat:@"Shareabouts Point %@", [properties valueForKey:@"id"]];
        annotationPoint.title = title;

        if (subTitle != (id)[NSNull null] && subTitle.length > 0 ) 
            annotationPoint.subtitle = subTitle;
        
        [mapView addAnnotation:annotationPoint]; 
    }
}


@end

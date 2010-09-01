//
//  LocationSelectorViewController.m
//  MGOV
//
//  Created by Shou on 2010/8/30.
//  Copyright 2010 NTU Mobile HCI Lab. All rights reserved.
//

#import "LocationSelectorViewController.h"
#import "GlobalVariable.h"
#import "AppMKAnnotation.h"
#import "AppMKAnnotationView.h"

@implementation LocationSelectorViewController

@synthesize delegate;
@synthesize titleBar, searchBar, mapView;
@synthesize selectedAddress;

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)MapView viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [MapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) {
		draggablePinView.annotation = annotation;
	} else {		
		draggablePinView = [[[AppMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
		if ([draggablePinView isKindOfClass:[AppMKAnnotationView class]]) {
			((AppMKAnnotationView *)draggablePinView).AmapView = MapView;
		}
	}
	return draggablePinView;
}

- (void)mapView:(MKMapView *)MapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {

	if ( oldState == MKAnnotationViewDragStateDragging && newState == MKAnnotationViewDragStateEnding ) {
		CLLocationCoordinate2D coord;
		coord.latitude = annotationView.annotation.coordinate.latitude;
		coord.longitude = annotationView.annotation.coordinate.longitude;
		[self updatingAddress:coord ForAnnotation:annotationView.annotation];
	}
}


#pragma mark -
#pragma mark Location Selector method

- (void) updatingAddress:(CLLocationCoordinate2D)coordinate ForAnnotation:(AppMKAnnotation *)annotation{
	// Use Google API to transform Latitude & Longitude to the corresponding address  
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?latlng=%f,%f&sensor=true&language=zh-TW", coordinate.latitude, coordinate.longitude]];
	NSString *str = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	NSDictionary *dict = [str JSONValue];
	NSString *address = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@", [[[dict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"formatted_address"]]];
	selectedAddress.text = address;
	[annotation setSubtitle:address];
	[url release];
	[str release];	
	[address release];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	GlobalVariable *shared = [GlobalVariable sharedVariable];
	[mapView setCenterCoordinate:shared.locationManager.location.coordinate animated:YES];
	MKCoordinateRegion region;
	region.center = shared.locationManager.location.coordinate;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.004;
	span.longitudeDelta = 0.004;
	region.span = span;
	[mapView setRegion:region];
	
	AppMKAnnotation *casePlace = [[AppMKAnnotation alloc] initWithCoordinate:region.center andTitle:@"Title test" andSubtitle:@"科科"];
	[mapView addAnnotation:casePlace];
	[self updatingAddress:shared.locationManager.location.coordinate ForAnnotation:casePlace];
	[casePlace release];
	
	UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 420, 159.5, 45)];
	UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 420, 160, 45)];
	doneButton.backgroundColor = [UIColor blackColor];
	cancelButton.backgroundColor = [UIColor blackColor];
	doneButton.alpha = 0.8;
	cancelButton.alpha = 0.8;
	doneButton.showsTouchWhenHighlighted = YES;
	cancelButton.showsTouchWhenHighlighted = YES;
	doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
	cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
	[doneButton setTitle:@"確定" forState:UIControlStateNormal];
	[cancelButton setTitle:@"取消" forState:UIControlStateNormal];
	[doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneButton addTarget:delegate action:@selector(userDidSelectDone) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton addTarget:delegate action:@selector(userDidSelectCancel) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	[self.view addSubview:cancelButton];
	[doneButton release];
	[cancelButton release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
	// MapView could not release
	[titleBar release];
	[searchBar release];
	[selectedAddress release];
    [super dealloc];
}


@end

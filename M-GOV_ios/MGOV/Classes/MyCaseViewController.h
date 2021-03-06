/*
 * 
 * MyCaseViewController.h
 * 2010/9/9
 * sodas
 * 
 * The Main View Controller of My Case
 *
 * Copyright 2010 NTU CSIE Mobile & HCI Lab
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import <UIKit/UIKit.h>
#import "CaseSelectorViewController.h"
#import "CaseAddViewController.h"
#import "QueryGoogleAppEngine.h"
#import "CaseSelectorCell.h"
#import "CaseViewerViewController.h"
#import "AppMKAnnotation.h"
#import "GoogleAnalytics.h"

@interface MyCaseViewController : CaseSelectorViewController <MKMapViewDelegate> {
	UISegmentedControl *filter;
	int currentSegmentIndex;
	BOOL caseSourceDidLoaded;
	CaseAddViewController *caseAdder;
}

- (BOOL)myCaseDataAvailability;
- (void)addCase;
- (void)setCaseFilter:(UISegmentedControl *)segmentedControl;
- (NSDictionary *)setConditionWithEmailAndFilter:(UISegmentedControl *)statusFilter;
- (void)showInformationBar;

@end

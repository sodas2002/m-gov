/*
 * 
 * CaseSelectorViewController.h
 * 2010/9/9
 * sodas
 * 
 * Use this Class to merge the common section between MyCase and Query views.
 * HybridViewController sets most part of common UI section, but contains no Data Source section.
 * The common Data Source section is set here.
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
#import "QueryGoogleAppEngine.h"
#import "HybridViewController.h"
#import "CaseSelectorCell.h"
#import "EGORefreshTableHeaderView.h"

@interface CaseSelectorViewController : HybridViewController <QueryGAEReciever, HybridViewDelegate, HybridViewDataSource> {
	NSMutableArray *caseSource;
	// Data Range
	NSRange queryRange;
	// Case Viewer
	NSString *caseID;
	CaseViewerViewController *childViewController;
	UIView *informationBar;
	// Current condition
	id currentCondition;
	DataSourceGAEQueryTypes currentConditionType;
	// Reload Bar
	EGORefreshTableHeaderView *refreshHeader;
	
	BOOL firstQuery;
}

@property (nonatomic, retain) NSArray *caseSource;
@property (nonatomic, retain) id currentCondition;
@property (nonatomic) DataSourceGAEQueryTypes currentConditionType;

- (void)queryGAEwithConditonType:(DataSourceGAEQueryTypes)conditionType andCondition:(id)condition;
- (void)refreshDataSource;
- (NSUInteger)convertStatusStringToStatusCode:(NSString *)status;

@end

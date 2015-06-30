//
//  ViewController.m
//  MapKitDrawing
//
//  Created by Evernet on 17/05/2014.
//  Copyright (c) 2014 COULON Florian. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "CanvasView.h"

static NSString* token = @"sessiontoken=0cee771192b6be1827ceed8b52cda998deb23abaf96b30abd668aafe7f74a840";

@interface ViewController () <MKMapViewDelegate>
{
    UITouch *endTouch;
    WildcardGestureRecognizer * tapInterceptor;
    Zone    *selectedZone;
    UITableView *autocompleteTableView;
    UITableView *allZone;
    NSMutableArray *matchingZone;
    UIButton *search;
    UITextField *textField;
    NSString* nameToSearch;
    
}
@property (weak, nonatomic) IBOutlet UIView *top_view;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *coordinates;
@property (nonatomic, strong) NSMutableArray *polygonPoints;
@property (weak, nonatomic) IBOutlet UIButton *drawPolygonButton;
@property (nonatomic) BOOL isDrawingPolygon;
@property (nonatomic, strong) CanvasView *canvasView;
@end

@implementation ViewController
@synthesize coordinates = _coordinates;
@synthesize canvasView = _canvasView;

- (NSMutableArray*)coordinates
{
    if(_coordinates == nil) _coordinates = [[NSMutableArray alloc] init];
    return _coordinates;
}


- (CanvasView*)canvasView
{
    if(_canvasView == nil) {
        _canvasView = [[CanvasView alloc] initWithFrame:self.mapView.frame];
        _canvasView.userInteractionEnabled = YES;
        _canvasView.delegate = self;
    }
    return _canvasView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    matchingZone = [[NSMutableArray alloc] init];
    [self loadExistingArea];
    
    tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
    };
    [self.mapView addGestureRecognizer:tapInterceptor];
    tapInterceptor->map = self.mapView;
    tapInterceptor.delegate=self;
    
    CGRect frame = CGRectMake(10, 25, 200, 30);
    textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:14.0];
    textField.backgroundColor = [UIColor clearColor];
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.delegate=self;
    [textField setReturnKeyType:UIReturnKeyDone];
    [self.view addSubview:textField];
    
    if ( IDIOM == IPAD ) {
        autocompleteTableView = [[UITableView alloc] initWithFrame:
                                 CGRectMake(0, 80, 250, self.view.frame.size.height-450) style:UITableViewStylePlain];
    } else {
        autocompleteTableView = [[UITableView alloc] initWithFrame:
                                 CGRectMake(320, 0, 250, 80) style:UITableViewStylePlain];
    }
    autocompleteTableView.delegate = self;
    autocompleteTableView.dataSource = self;
    autocompleteTableView.scrollEnabled = YES;
    autocompleteTableView.hidden=YES;
    [self.view addSubview:autocompleteTableView];
    
    search = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [search addTarget:self
               action:@selector(rechercheZone:)
     forControlEvents:UIControlEventTouchUpInside];
    [search setTitle:@"Search" forState:UIControlStateNormal];
    search.frame = CGRectMake(230, 30, 50, 30.0);
    search.hidden=YES;
    [self.view addSubview:search];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)loadExistingArea{
    
    NSURL *url = [NSURL URLWithString:@"http://188.165.251.201:8064/admin/zones?sessiontoken=0cee771192b6be1827ceed8b52cda998deb23abaf96b30abd668aafe7f74a840"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@",responseObject);
        for (int i=0; i<(int)[[responseObject objectForKey:@"zones"] count]; i++) {
            Zone *newZone = [[Zone alloc]init];
            newZone->identifiant=[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"id"];
            newZone->name=[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"name"];
            
            CLLocationCoordinate2D points[(int)[[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"polygon"] count]+1];
            for (int k=0; k<(int)[[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"polygon"] count]; k++) {
                float latitude  = [[[[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"polygon"]objectAtIndex:k]objectAtIndex:0] floatValue];
                float longitude = [[[[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"polygon"]objectAtIndex:k]objectAtIndex:1] floatValue];
                MyPoint *unPoint = [[MyPoint alloc]init];
                unPoint->latitude = latitude;
                unPoint->longitude = longitude;
                [newZone->polyPoint addObject:unPoint];
                points[k].latitude = latitude;
                points[k].longitude = longitude;
                
                //NSLog(@"%@,%@",[[[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"polygon"]objectAtIndex:k]objectAtIndex:0]
                //          ,[[[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"polygon"]objectAtIndex:k]objectAtIndex:1]);
            }
            [tapInterceptor->zoneList addObject:newZone];
            [self.mapView addOverlay:[MKPolygon polygonWithCoordinates:points count:(int)[[[[responseObject objectForKey:@"zones"]objectAtIndex:i]objectForKey:@"polygon"] count]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    [operation start];
}
- (void) viewDidAppear:(BOOL)animated {}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)didTouchUpInsideDrawButton:(UIButton*)sender
{
    if(self.isDrawingPolygon == NO) {
        
        self.isDrawingPolygon = YES;
        [self.drawPolygonButton setTitle:@"done" forState:UIControlStateNormal];
        [self.coordinates removeAllObjects];
        [self.view addSubview:self.canvasView];
        
    } else {
        
        NSInteger numberOfPoints = [self.coordinates count];
        
        if (numberOfPoints > 2)
        {
            CLLocationCoordinate2D points[numberOfPoints];
            for (NSInteger i = 0; i < numberOfPoints; i++) {
                points[i] = [self.coordinates[i] MKCoordinateValue];
            }
            [self.mapView addOverlay:[MKPolygon polygonWithCoordinates:points count:numberOfPoints]];
        }
        
        self.isDrawingPolygon = NO;
        [self.drawPolygonButton setTitle:@"draw" forState:UIControlStateNormal];
        self.canvasView.image = nil;
        [self.canvasView removeFromSuperview];
        
    }
}

- (void)touchesBegan:(UITouch*)touch
{
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    [self.coordinates addObject:[NSValue valueWithMKCoordinate:coordinate]];
}

- (void)touchesMoved:(UITouch*)touch
{
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    [self.coordinates addObject:[NSValue valueWithMKCoordinate:coordinate]];
}

- (void)touchesEnded:(UITouch*)touch
{
    endTouch=touch;
    /*
    CGPoint location = [touch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    [self.coordinates addObject:[NSValue valueWithMKCoordinate:coordinate]];
    
    
    NSLog(@"CoordTab : {\ncount : %lu\n}", (unsigned long)self.coordinates.count);
    NSString *concatCoord = @"";
    for (NSValue *coord in self.coordinates) {
        CLLocationCoordinate2D value = [coord MKCoordinateValue];
        concatCoord = [NSString stringWithFormat:@"%@[%f,%f],", concatCoord, value.latitude, value.longitude];
    }
    if ([concatCoord length] > 0)
        concatCoord = [concatCoord substringToIndex:[concatCoord length] - 1];
    
    NSLog(@"%@", concatCoord);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", @"http://188.165.251.201:8064/admin/zone?sessiontoken=0cee771192b6be1827ceed8b52cda998deb23abaf96b30abd668aafe7f74a840"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postBody = [NSMutableData data];
    */
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nom" message:@"Entrer le nom de la zone" delegate:nil cancelButtonTitle:@"Valider" otherButtonTitles:@"Annuler", nil];
        alert.delegate = self;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    });

    
    //[postBody appendData:[[NSString stringWithFormat:@"{ \"name\" : \"%@\", \"polygon\" : [%@]}",[alert textFieldAtIndex:0].text, concatCoord] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        return;
    }
    CGPoint location = [endTouch locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    [self.coordinates addObject:[NSValue valueWithMKCoordinate:coordinate]];
    
    
    NSLog(@"CoordTab : {\ncount : %lu\n}", (unsigned long)self.coordinates.count);
    NSString *concatCoord = @"";
    for (NSValue *coord in self.coordinates) {
        CLLocationCoordinate2D value = [coord MKCoordinateValue];
        concatCoord = [NSString stringWithFormat:@"%@[%f,%f],", concatCoord, value.latitude, value.longitude];
    }
    if ([concatCoord length] > 0)
        concatCoord = [concatCoord substringToIndex:[concatCoord length] - 1];
    
    NSLog(@"%@", concatCoord);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", @"http://188.165.251.201:8064/admin/zone?sessiontoken=0cee771192b6be1827ceed8b52cda998deb23abaf96b30abd668aafe7f74a840"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postBody = [NSMutableData data];
    
    [postBody appendData:[[NSString stringWithFormat:@"{ \"name\" : \"%@\", \"polygon\" : [%@]}",[alertView textFieldAtIndex:0].text, concatCoord] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    //post
    [request setHTTPBody:postBody];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if([responseObject objectForKey:@"error"]!=nil){
            [_mapView removeOverlays:[_mapView overlays]];
            [self reloadMap];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oups" message:@"La zone n'a pas été créée" delegate:nil cancelButtonTitle:@"Je suis conscient d'avoir fait de la merde" otherButtonTitles:nil, nil];
                alert.delegate = self;
                alert.tag=1;
                [alert setAlertViewStyle:UIAlertViewStyleDefault];
                [alert show];
            });
        }
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error TROLOLO: %@", error);
    }];
    
    [operation start];
    
    [self performSelector:@selector(reloadMap) withObject:nil afterDelay:1];
    
    [self didTouchUpInsideDrawButton:nil];
}
#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayPathView *overlayPathView;
    
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        overlayPathView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay];
        
        overlayPathView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        overlayPathView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        overlayPathView.lineWidth = 3;
        
        return overlayPathView;
    }
    
    else if ([overlay isKindOfClass:[MKPolyline class]])
    {
        overlayPathView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
        
        overlayPathView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        overlayPathView.lineWidth = 3;
        
        return overlayPathView;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString * const annotationIdentifier = @"CustomAnnotation";
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (annotationView)
    {
        annotationView.annotation = annotation;
    }
    else
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        annotationView.image = [UIImage imageNamed:@"annotation.png"];
        annotationView.alpha = 0.5;
    }
    
    annotationView.canShowCallout = NO; 
    
    return annotationView;
}

-(void)zoneTouched:(Zone*)laZone : (MyPoint*)unPoint{
    
    selectedZone = laZone;
    SMCalloutView *pop = [[SMCalloutView alloc]init];
    pop.contentView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 100)];
    UILabel *labName = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 250, 15)];
    labName.text=laZone->name;
    
    UILabel *labId = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 250, 15)];
    labId.text=laZone->identifiant;
    
    UIButton *b_ok = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b_ok.frame=CGRectMake(100, 50, 50, 35);
    [b_ok setTitle:@"Ok" forState:UIControlStateNormal];
    [b_ok addTarget:self action:@selector(dismissPopUp) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *b_del = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b_del.frame=CGRectMake(170, 50, 50, 35);
    [b_del setTitle:@"Delete" forState:UIControlStateNormal];
    [b_del addTarget:self action:@selector(deleteZone) forControlEvents:UIControlEventTouchUpInside];
    [pop presentCalloutFromRect:CGRectMake(unPoint->latitude,unPoint->longitude+70,0,0) inView:self.view constrainedToView:self.view animated:YES];
    [[pop contentView]addSubview:labName];
    [[pop contentView]addSubview:labId];
    [[pop contentView]addSubview:b_del];
    [[pop contentView]addSubview:b_ok];

}
-(void)dismissPopUp{
    tapInterceptor.view.userInteractionEnabled=YES;
    [[[self.view subviews] lastObject] removeFromSuperview];
}

-(void)deleteZone{
    NSLog(@"Delete");
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@?id=%@&%@",@"http://188.165.251.201:8064/admin/zone",selectedZone->identifiant,token]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        
        [_mapView removeOverlays:[_mapView overlays]];
        [self reloadMap];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    [request setHTTPMethod:@"DELETE"];
    [operation start];
    
    [self dismissPopUp];
}

-(void)reloadMap{
    tapInterceptor->zoneList = [[NSMutableArray alloc]init];
    [self loadExistingArea];
}

-(void)rechercheZone:(id)sender{
    [textField resignFirstResponder];
    textField.text=@"";
    search.hidden=YES;
    autocompleteTableView.hidden=YES;
    
    Zone *z;
    for (Zone* zone in tapInterceptor->zoneList) {
        if([zone->name isEqualToString:nameToSearch])
            z=zone;
    }
    CLLocationCoordinate2D midCoord;
    midCoord.latitude=((MyPoint*)[z->polyPoint objectAtIndex:0])->latitude;
    midCoord.longitude=((MyPoint*)[z->polyPoint objectAtIndex:0])->longitude;
    MKCoordinateRegion theRegion = _mapView.region;
    // Zoom out
    theRegion.center = midCoord;
    theRegion.span.longitudeDelta = 0.002;
    theRegion.span.latitudeDelta = 0.002;
    [_mapView setRegion:theRegion animated:YES];
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    search.hidden=YES;
    [matchingZone removeAllObjects];
    for(Zone* z in tapInterceptor->zoneList) {
        NSString *curString = z->name;
        NSRange substringRange = [[curString lowercaseString] rangeOfString:[substring lowercaseString]];
        if (substringRange.location == 0) {
            NSLog(@"%@",curString);
            [matchingZone addObject:curString];
        }
    }
    if ([matchingZone count]>0){
        autocompleteTableView.hidden=NO;
    }
    else{
        autocompleteTableView.hidden=YES;
    }
    [autocompleteTableView reloadData];
}

#pragma mark TextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}


#pragma mark TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [matchingZone count];    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    
    // Here we use the provided setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    if (indexPath.row<[matchingZone count]) {
        cell.textLabel.text = [matchingZone objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 30;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    search.hidden=NO;
    nameToSearch=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
}

@end

//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Youwen Yi on 1/5/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "HudView.h"
#import "Location.h"

@interface LocationDetailsViewController ()<UITextViewDelegate>

@property(nonatomic,weak)IBOutlet UITextView *descriptionTextView;
@property(nonatomic,weak)IBOutlet UILabel *categoryLabel;
@property(nonatomic,weak)IBOutlet UILabel *latitudeLabel;
@property(nonatomic,weak)IBOutlet UILabel *longitudeLabel;
@property(nonatomic,weak)IBOutlet UILabel *addressLabel;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;

@end

@implementation LocationDetailsViewController
{
    NSString *_descriptionText;
    NSString *_categoryName;
    NSDate *_date;
    UIImage *_image;
    
    UIActionSheet *_actionSheet;
    UIImagePickerController *_imagePicker;
    
}

@synthesize locationToEdit;
@synthesize imageView, photoLabel;


//initialize the _descriptionText
-(id)initWithCoder:(NSCoder*)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        _descriptionText = @"";
        _categoryName = @"No Category";
        _date = [NSDate date];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];

}

-(void)applicationDidEnterBackground{

    if (_imagePicker != nil) {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
    
    if (_actionSheet != nil) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
        _actionSheet = nil;
    }
    
    [self.descriptionTextView resignFirstResponder];

}

-(int)nextPhotoId{

    int _photoId = [[NSUserDefaults standardUserDefaults] integerForKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults]  setInteger:_photoId+1 forKey:@"PhotoID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return _photoId;

}


-(IBAction)done:(id)sender{
    
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    
    //1
    Location *location = nil;
    
    if (self.locationToEdit != nil) {
        hudView.text = @"Updated";
        location = self.locationToEdit;
        
    } else {
        hudView.text = @"Tagged";
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        location.photoId = [NSNumber numberWithInt:-1];
    }
    
    
    //2
    location.locationDescription = _descriptionText;
    location.category = _categoryName;
    location.latitude = @(self.coordinate.latitude);
    location.longitude = @(self.coordinate.longitude);
    location.date = _date;
    location.placemark = self.placemark;
    
    if (_image != nil) {
        if (![location hasPhoto]) {
            location.photoId = [NSNumber numberWithInt:[self nextPhotoId]];
        }
        
        NSData *data = UIImagePNGRepresentation(_image);
        NSError *error;
        if (![data writeToFile:[location photoPath] options:NSDataWritingAtomic error:&error]) {
            NSLog(@"Error writing file: %@", error);
        }
    }
    
    //3
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Save error: %@", error);
        //abort();
        
    }
    
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
    
    /*
    //chapter 17
    NSLog(@"Desccription '%@' ", _descriptionText); 
    [self closeScreen];
    */
}

-(IBAction)cancel:(id)sender{
    [self closeScreen];
    
}

-(void)closeScreen{
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

//set the name of the selectedCategoryName
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"PickCategory"]) {
        CategoryPickViewController *controller = segue.destinationViewController;
        controller.selectedCategoryName = _categoryName;
    }

}

-(IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue{

    CategoryPickViewController *viewController = segue.sourceViewController;
    _categoryName = viewController.selectedCategoryName;
    self.categoryLabel.text = _categoryName;

}

-(void)showImage:(UIImage *)theImage{

    self.imageView.image = theImage;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    self.photoLabel.hidden = YES;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.locationToEdit != nil) {
        self.title = @"Edit Location";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(done:)];
    }
    
    if ([self.locationToEdit hasPhoto] && _image == nil) {
        UIImage *existingImage = [self.locationToEdit photoImage];
        if (existingImage != nil) {
            [self showImage:existingImage];
            
        }
    }
    
    if (_image != nil) {
        [self showImage:_image];
    }
    
    self.descriptionTextView.text = _descriptionText;
    self.categoryLabel.text = _categoryName;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.longitude];
    
    if (self.placemark!=nil) {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
        
    } else {
        self.addressLabel.text = @"No Address Found ...";
    }
    self.dateLabel.text = [self formatDate:_date];
    
    
    UITapGestureRecognizer *getureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    getureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:getureRecognizer];
    
    [self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer{

    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }

    [self.descriptionTextView resignFirstResponder];
}


-(NSString*)stringFromPlacemark:(CLPlacemark*)placemark{
    
    if (placemark.subThoroughfare == nil) {
        return [NSString stringWithFormat:@"%@, %@, %@, %@, %@", placemark.thoroughfare, placemark.subLocality,placemark.locality, placemark.administrativeArea, placemark.country];
        
    }else {
    
        return [NSString stringWithFormat:@"%@, %@, %@, %@, %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.subLocality,placemark.locality, placemark.administrativeArea, placemark.country];
    }
    
    //return [NSString stringWithFormat:@"%@, %@, %@, %@, %@", placemark.thoroughfare, placemark.subLocality,placemark.locality, placemark.administrativeArea, placemark.country];

}

-(NSString*)formatDate:(NSDate*)theDate{
    static NSDateFormatter *formatter = nil;
    
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return [formatter stringFromDate:theDate];

}

-(void)setLocationToEdit:(Location *)newLocationToEdit{
    if (locationToEdit != newLocationToEdit) {
        locationToEdit = newLocationToEdit;
        
        _descriptionText = locationToEdit.locationDescription;
        _categoryName = locationToEdit.category;
        
        self.coordinate = CLLocationCoordinate2DMake([locationToEdit.latitude doubleValue], [locationToEdit.longitude doubleValue]);
        self.placemark = locationToEdit.placemark;
        _date = locationToEdit.date;
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
    }
    
    if (![self isViewLoaded]) {
        self.descriptionTextView = nil;
        self.categoryLabel = nil;
        self.latitudeLabel = nil;
        self.longitudeLabel = nil;
        self.addressLabel = nil;
        self.dateLabel = nil;
        self.imageView = nil;
        self.photoLabel = nil;
    }
}


-(void)takePhoto{

    _imagePicker = [[UIImagePickerController alloc]init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:_imagePicker animated:YES completion:nil];

}

-(void)choosePhotoFromLibrary{
    _imagePicker = [[UIImagePickerController alloc]init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:_imagePicker animated:YES completion:nil];

}

-(void)showPhotoMenu{

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        [_actionSheet showInView:self.view];
        
    } else {
        [self choosePhotoFromLibrary];
    }

}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 88;
        
    }else if(indexPath.section == 1){
    
        if (self.imageView.hidden) {
            return 44;
        } else {
            return 280;
        }
        

    } else if(indexPath.section == 2 && indexPath.row == 2){
        CGRect rect = CGRectMake(100, 10, 205, 10000);
        self.addressLabel.frame = rect;
        [self.addressLabel sizeToFit];
        
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        
        return self.addressLabel.frame.size.height +20;
    }else{
        return 44;
    
    }

}

#pragma mark -UITextViewDelegate
-(BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    _descriptionText=[textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;

}

-(void)textViewDidEndEditing:(UITextView*)textView{
    _descriptionText = textView.text;

}

//the user can only touch the first two cells for action
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    } else {
        return nil;
    }
}

//to avoid no keyboard if touch the corner of the cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
        
    }else if (indexPath.section == 1 && indexPath.row == 0){
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        [self showPhotoMenu];
    
    }
    
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    _image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if ([self isViewLoaded]) {
        [self showImage:_image];
        [self.tableView reloadData];
    }
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    _imagePicker = nil;

}

#pragma mark - UIACtionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0) {
        [self takePhoto];
    } else if(buttonIndex == 1){
        [self choosePhotoFromLibrary];
        
    }

    actionSheet = nil;
}


@end

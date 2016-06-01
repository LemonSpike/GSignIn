//
//  ContentViewController.swift
//  GSignIn
//
//  Created by Gabriel Theodoropoulos on 8/7/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblContent: UITableView!
    
    var peopleDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        tblContent.delegate = self
        tblContent.dataSource = self
        
        getPeopleList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: IBAction method implementation
    
    @IBAction func signOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func disconnect(sender: AnyObject) {
            GIDSignIn.sharedInstance().disconnect()
    }

    
    @IBAction func VideoController(sender: AnyObject) {
    }
    // MARK: UITableView method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else {
            return peopleDataArray.count
        }
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Personal Info"
        }
        else {
            return "People in Circles"
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("idCellPersonalInfo", forIndexPath: indexPath) as! UITableViewCell
            
            if indexPath.row == 0 {
                cell.textLabel?.text = GIDSignIn.sharedInstance().currentUser.profile.name
                cell.detailTextLabel?.text = "Name"
            }
            else {
                cell.textLabel?.text = GIDSignIn.sharedInstance().currentUser.profile.email
                cell.detailTextLabel?.text = "Email"
            }
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("idCellPeople", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = peopleDataArray[indexPath.row]["displayName"] as? String
            cell.imageView?.image = UIImage(data: peopleDataArray[indexPath.row]["imageData"] as! NSData)
        }
        
        return cell
    }
    
    func getPeopleList() {
        let urlString = ("https://www.googleapis.com/plus/v1/people/me/people/visible?access_token=\(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)")
        let url = NSURL(string: urlString)
        
        performGetRequest(url, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                var resultsDictionary : Dictionary<NSObject, AnyObject>
                
                do {
                    
                    // Convert the JSON data to a dictionary.
                    resultsDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                
                // Get the array with people data dictionaries.
                let peopleArray = resultsDictionary["items"] as! Array<Dictionary<NSObject, AnyObject>>
                
                // For each item get the display name and download the picture.
                // Store these values in a new dictionary, and then in the peopleDataArray array.
                for item in peopleArray {
                    var dictionary = Dictionary<NSObject, AnyObject>()
                    dictionary["displayName"] = item["displayName"] as! String
                    
                    let imageURLString = (item["image"] as! Dictionary<NSObject, AnyObject>)["url"] as! String
                    dictionary["imageData"] = NSData(contentsOfURL: NSURL(string: imageURLString)!)
                    
                    self.peopleDataArray.append(dictionary)
                }
                } catch let error as NSError {
                    print(error)
                }

                // Reload the tableview data.
                dispatch_async(dispatch_get_main_queue()) {
                    self.tblContent.reloadData()
                }
            }
            else {
                print(HTTPStatusCode)
                print(error)
            }
        })
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    
    // MARK: Custom method implementation
    
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            }
        })
        task.resume()
    }
    
    
    
}

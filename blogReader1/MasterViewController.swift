//
//  MasterViewController.swift
//  blogReader1
//
//  Created by Scott Yoshimura on 5/29/15.
//  Copyright (c) 2015 west coast dev. All rights reserved.
//  we took the code and changed alot of it and simplified it.


//right now initial results come back empty

import UIKit
import CoreData
import Foundation

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    //the above allows us to work with the core data elements and extracts it easily.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var apiKey = "AIzaSyCWHQIxPFhF5hG-UIppwBB1zl2BBeRO4zg"
        var blogId = "10861780"
        
        //we are setting up a an AppDelegate to deal with core data.
        var appDelegate0:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //lets create a context that we can refer to
        var context:NSManagedObjectContext = appDelegate0.managedObjectContext!
        //this context gives us a framework within which we can access our database that we force unwrap
        

        //lets set up the get request
        var urlPathRequestBlogPosts = "https://www.googleapis.com/blogger/v3/blogs/" + blogId + "/posts?key=" + apiKey
        let url0 = NSURL(string: urlPathRequestBlogPosts)
        //println(urlPathRequestBlogPosts)
        var session0 = NSURLSession.sharedSession()
        
        //lets set up a task
        var task0 = session0.dataTaskWithURL(url0!, completionHandler: { (data, response, error) -> Void in if error != nil{
                println(error)
        } else { dispatch_async(dispatch_get_main_queue()) {
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            let jsonResponse0 = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
            //println(jsonResponse0)
            //println(jsonResponse0.count)
            if jsonResponse0.count > 0 {
                if let items = jsonResponse0["items"] as? NSArray {
                    //why are the below results not coming through at startup?
                    //lets set up a request to fetch the data from Posts
                    var initialRequest = NSFetchRequest(entityName: "Posts")
                    //initialRequest.returnsObjectsAsFaults = false
                    var initialResults : NSArray! = context.executeFetchRequest(initialRequest, error: nil)!
                    //println(initialResults)
                    //println(initialResults.count)
                    //if initialResults.count > 0 {
                    //    println(initialResults?.count)
                    //println(initialResults?.description)
                    //initialResults?.removeAll(keepCapacity: true)
                    //   println(initialResults?.count)
                    for initialResult in initialResults {
                        context.deleteObject(initialResult as! NSManagedObject)
                        context.save(nil)
                                                        }
                    for item in items {
                        //println(item)
                        if let title = item["title"] as? String{
                            //note, that string things in an array are not allowing gthe content string to be long enough
                            if let content = item["content"] as? String{
                                //println(content)
                                var newPost = NSEntityDescription.insertNewObjectForEntityForName("Posts", inManagedObjectContext: context) as! NSManagedObject
                                newPost.setValue(title, forKey: "title")
                                newPost.setValue(content, forKey: "content")
                                context.save(nil)
                                                                        }
                                                                }
                                        }
                                                                        }
                                }
            //lets set up a request to fetch the data from Posts
            var request = NSFetchRequest(entityName: "Posts")
            request.returnsObjectsAsFaults = false
            var results = context.executeFetchRequest(request, error: nil)!
            //println(results)
            //println(results.count)
            for result in results{
                self.fetchedResultsController.performFetch(nil)
                                }
                }//dispatch asynch closure
            }//else closure
            
        })//dataTaskWithURL completion handler and and URL
    
        task0.resume()
        
    }//viewDidLoad
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {

            //we want to pass the content for the blog content to the DetailViewController. so that the detail controller can display it.
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                (segue.destinationViewController as! DetailViewController).detailItem = object
            }
            //the above establishes the index path of the item that has been tapped on so we know where in the table we are, and also takes an object from the fetchedREsultscontroller at that index path. it gets all the information of that core data item that has been tapped on. 
                //and then it finds the destination view controler, the detailViewController in this case, and sets a value called detailitem to be equeal to the ojbect we just extracted from core data. we are getting a variable called detailitem, in a detailviewcontroller that is equal to the object in core data that we want to display.

        }
        
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo

        return sectionInfo.numberOfObjects
        //the above creates a variable sectionInfo from the fetchedResultsContrller (the section that is returned). it is looking at the entity and seeing how many objec5ts are in that entity.

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    //the configure cell creates a new cell for each row index path. it creates an object that gets a particular item from our resultsFetchedController, and allows us to do things with it. and  in this situation we want to set the text label text for that particular row in that table to the title
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        cell.textLabel!.text = object.valueForKey("title")!.description
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return false
    }

    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Posts", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptors = [sortDescriptor]
        //the above is the sort key. in this instance we will sort on title
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    }



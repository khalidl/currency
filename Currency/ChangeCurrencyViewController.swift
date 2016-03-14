//
//  TableViewController.swift
//  Currency
//
//  Created by Nuno Coelho Santos on 28/02/2016.
//  Copyright © 2016 Nuno Coelho Santos. All rights reserved.
//

import UIKit
import CoreData

protocol ChangeCurrencyViewControllerDelegate {
    func didChangeCurrency(currencyCode: String, targetCurrency: String)
}

class ChangeCurrencyViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var delegate: ChangeCurrencyViewControllerDelegate?
    var targetCurrency: String!
    var selectedCurrency: String!
    var currencies:Array<Currency>!
    var searchResults:Array<Currency>?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext as NSManagedObjectContext
        
        currencies = fetchCurrencies()
    }
    
    func fetchCurrencies() -> [Currency]{
        let fetch = NSFetchRequest(entityName: "Currency")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetch.sortDescriptors = sortDescriptors
        var result = [AnyObject]()
        do {
            result = try managedObjectContext!.executeFetchRequest(fetch)
        } catch let error as NSError {
            print("Error fetching currencies error: %@", error)
        }
        return result as! [Currency]
    }
    
}

// MARK: - Table View

extension ChangeCurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return searchResults?.count ?? 0
        } else {
            return currencies.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CurrencyCell")
        let index = indexPath.row
        let currency: Currency
        if tableView == self.searchDisplayController!.searchResultsTableView {
            currency = searchResults![index]
        } else {
            currency = currencies[index]
        }
        cell!.textLabel!.text = currency.name!
        cell!.detailTextLabel!.text = currency.code!
        cell!.accessoryType = UITableViewCellAccessoryType.None
        
        if currency.code! == selectedCurrency {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let currency: Currency
        if tableView == self.searchDisplayController!.searchResultsTableView {
            currency = searchResults![index]
        } else {
            currency = currencies[index]
        }
        let currencyCode = currency.code!
        
        delegate?.didChangeCurrency(currencyCode, targetCurrency: targetCurrency)
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
}

// MARK: - Search

extension ChangeCurrencyViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    
    func filterContentForSearchText(searchText: String) {

        var filteredContent:Array<Currency> = []
        let searchText = searchText.lowercaseString
        
        for currency in currencies {
            let matchesName = currency.name!.lowercaseString.rangeOfString(searchText) != nil
            let matchesCode = currency.code!.lowercaseString.rangeOfString(searchText) != nil
            
            if (matchesName || matchesCode) {
                filteredContent += [currency]
            }
        }
        
        self.searchResults = filteredContent
        
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        self.filterContentForSearchText(searchString!)
        return true
    }
    
}

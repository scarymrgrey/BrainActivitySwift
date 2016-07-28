//
//  StatOverallController.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 28/07/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//


class CategoryController : NSObject, UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return 0
    }
    
}
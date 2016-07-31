//
//  SessionsVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 04/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class SessionsVC : BatteryBarVC ,UITableViewDataSource,UITableViewDelegate {
    var arrayForBool : [Bool]! = []
    let sectionHeight : CGFloat = 100.0
    var sessionList = [String]()
    var context : Context!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        arrayForBool = [Bool](count :4,repeatedValue : false)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        context = Context(idToken: userDefaults.valueForKey(UserDefaultsKeys.idToken)! as! String, accessToken: userDefaults.valueForKey(UserDefaultsKeys.accessToken)! as!  String,URL : "http://cloudin.incoding.biz/Dispatcher/Query")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let req = GetSessionsQuery<GetSessionsQueryResponse>(context: context)
        req.On(success: { (resp : Array<GetSessionsQueryResponse>) in
            for r in resp {
                self.sessionList.append(r.StartDate)
            }
            self.arrayForBool = [Bool](count :resp.count,repeatedValue : false)
            self.tableView.reloadData()
            }, error: {})
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sessionList.count
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(arrayForBool[section])
        {
            return 5
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if arrayForBool[indexPath.section]{
            return sectionHeight
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = SessionHeaderView(dateText: sessionList[section],moodText: sessionList[section],frame: CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height))
        //print(tableView.frame.size.width)
        headerView.tag = section
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.grayColor().CGColor
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(SessionsVC.sectionHeaderTapped(_:)))
        headerView.addGestureRecognizer(headerTapped)
        
        return headerView
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        let indexPath  = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            var collapsed = arrayForBool[indexPath.section]
            collapsed       = !collapsed
            arrayForBool[indexPath.section] = collapsed
            //reload specific section animated
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = NSIndexSet(indexesInRange: range)
            self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let CellIdentifier = "Cell"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier)!
        cell.addSubview(SessionsContainerView(containerFrame: CGRectMake(0, 0, tableView.frame.width ,sectionHeight ),timeString : String(indexPath.section)))
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 1
        return cell
    }
}

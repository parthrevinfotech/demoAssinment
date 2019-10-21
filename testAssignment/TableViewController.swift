//
//  TableViewController.swift
//  testAssignment
//
//  Created by Hiteshi on 21/10/19.
//  Copyright © 2019 demo. All rights reserved.
//

import UIKit
import Alamofire

class TableViewController: UITableViewController {

    private var reachability: NetworkReachabilityManager!
    
    var arrData : [model] = [model]()
    var pageCount : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorReachability()

        self.pageCount = 1
        self.fetchDatafromAPI(page: pageCount)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        self.showDisplayCellCount()
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 50
        return arrData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.row == self.arrData.count - 5){
            self.fetchDatafromAPI(page: self.pageCount + 1)
        }
        
        if let cell : CustomCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCellTableViewCell", for: indexPath) as? CustomCellTableViewCell{
            
            let obj = arrData[indexPath.row]
            
            // Configure the cell...
            cell.lblTitle.text = obj.strTitle
            cell.lblSubTitle.text = obj.strSubTitle
            
            return cell
            
        }else{
           return UITableViewCell()
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension TableViewController {
    
    // MARK: - Private - Reachability
    private func monitorReachability() {
    
//        NetworkReachabilityManager.init()?.startListening(){ status in
//             print("Reachability Status Changed: \(status)")
//        }
       
    }

    func fetchDatafromAPI(page : Int = 1) {
        
        let strUrl = "https://hn.algolia.com/api/v1/search_by_date?tags=story&page=\(page)"
        
        if (page == 1){
           self.arrData.removeAll()
        }
        
        Alamofire.request(strUrl, method: .get, parameters: nil ,encoding: JSONEncoding.default).responseJSON {
            response in
            
            switch response.result {
            case .success:
                print(response)
                do{
                    
                    if let dict = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]{
                        self.parseAPIResponce(dict: dict, page: page)
                    }
                    
                }catch let err {
                   print(err)
                }
                break
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func parseAPIResponce(dict : [String : Any], page : Int) {
        
        if let arr = dict["hits"] as? [[String:Any]]{
            self.pageCount = page
            for dataDict in arr {
                let obj : model = model.init(dict: dataDict)
                self.arrData.append(obj)
            }
        }
        
        self.tableView.reloadData()
        self.showDisplayCellCount()
        if self.arrData.count > 0 {
            print("\n data count = \(self.arrData.count)")
        }else{
            print("\n no data found")
        }
    }
    
    func showDisplayCellCount() {
        let array = self.tableView.indexPathsForVisibleRows
        self.navigationItem.title = "Table \(array?.count ?? 0) / \(self.arrData.count))"
    }
}

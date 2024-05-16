//
//  TableData.swift
//  dancereality
//
//  Created by Saad Khalid on 28.03.22.
//

import Foundation
import UIKit

class MyData: NSObject, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        cell.textLabel!.text = self.classes[indexPath.row].name
        return cell
    }
    
    var classes :[DanceTypeModel]
    let completion :(Int) -> Void
    
    init(classes :[DanceTypeModel], completion:@escaping (Int) -> Void){
        self.classes = classes
        for danceClass in classes {
            if(danceClass.name == AppModel.ENGLISH_VALSE){
                self.classes[0] = danceClass
            } else if (danceClass.name == AppModel.TANGE){
                self.classes[1] = danceClass
            } else if (danceClass.name == AppModel.WIENER_VALSE){
                self.classes[2] = danceClass
            } else if (danceClass.name == AppModel.SLOWFOX){
                self.classes[3] = danceClass
            } else if (danceClass.name == AppModel.QUICKSTEP){
                self.classes[4] = danceClass
            }
        }
        self.completion = completion
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.completion(self.classes[indexPath.row].id)
    }
}

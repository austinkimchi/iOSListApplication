//
//  StateController.swift
//  CIS38Lab2_AustinKim
//
//  Created by Austin Kim on 2/8/24.
//

import UIKit
import MapKit
import CoreLocation

class TaskVC: ViewController, MKMapViewDelegate {
    
    @IBOutlet weak var nav: UINavigationItem!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var createdOn: UILabel!
    
    var strHeader: String!;
    var strDesc: String!;
    var imgImage: UIImage!;
    var strDate: String!;
    var strNavTitle: String!;
    var strCreatedOn: String!;
    var lon: Double!;
    var lat: Double!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.header.text = self.strHeader;
        self.desc.text = self.strDesc;
        self.img.image = self.imgImage;
        self.dueDate.text = self.strDate;
        self.nav.title = self.strNavTitle;
        self.createdOn.text = self.strCreatedOn;
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "MapSeg":
            let vc = segue.destination as! MapVC;
            
            vc.lon = self.lon;
            vc.lat = self.lat;
            break;
        default:
            break;
        }
        
     }


}

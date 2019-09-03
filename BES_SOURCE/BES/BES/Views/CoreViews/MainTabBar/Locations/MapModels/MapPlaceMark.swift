
import UIKit
import MapKit

class MapPlaceMark: NSObject, MKAnnotation {
    
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var address: String!
    var image: UIImage!
    var location: Location!
    
    init(coordinate c: CLLocationCoordinate2D, title markTitle: String, subtitle markSubtitle: String, image img: UIImage,location loc: Location ) {
        coordinate = c
        title = markTitle
        address = markSubtitle
        location = loc
        image = img
    }

}

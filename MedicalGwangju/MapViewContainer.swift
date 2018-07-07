import UIKit
import GoogleMaps

struct MyLoc {
    var latitude = 0.0
    var longitude = 0.0
}
class MapViewContainer: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var mapView: GMSMapView!
    var marker = GMSMarker()
    var myLocation = MyLoc()
    let locationManager = CLLocationManager()
    let geocoder = GMSGeocoder()
    var checkInit: Bool = true
    var hospitalData: Array<Hospital>? = nil
    var hospitalParser: HospitalParser!
    var mylocality: String = "" //현재 내가 속한 구
    var clicklocality: String = "" //클릭한 지역
    var beforelocality: String = "" //이전 지역
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //위치의 정확도를 표시하는 옵션 Best가 가장 배터리 소모량이 많다.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // 사용할때만 위치정보를 사용한다는 팝업이 발생
        locationManager.requestWhenInUseAuthorization()
        
        // 항상 위치정보를 사용한다는 판업이 발생
        //locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        
    
    }
    
    override func viewDidLoad() {
        
      
        super.viewDidLoad()
        
        //현재위치 가져오기
        if let coor = locationManager.location?.coordinate {
            myLocation.latitude = coor.latitude
            myLocation.longitude = coor.longitude
        }else{
              print("위치정보를 가져올 수 없습니다.")
            
        }
        
        print("내 위치 \(myLocation.latitude), \(myLocation.longitude)")
        
        
        mapView = GMSMapView()
        let camera = GMSCameraPosition.camera(withLatitude: myLocation.latitude, longitude: myLocation.longitude, zoom: 13.8)
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
       
        self.mapView.delegate = self
        
        self.view = mapView
        
        
    }
    
    //맵을 계속 움직일 때 호출
    /*func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
     print("이동2")
     }*/
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.clear()
    }
    
    
    //맵이 이동을 끝낸 후 호출 나는 이걸 사용할것이다.
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //중심점 위도 경도 구하기. position.target.latitude position.target.longitude
        
        print("이동 \(position.target.latitude)")
        
        //지오코딩으로 주소 구하기
        geocoder.reverseGeocodeCoordinate(position.target) { (response, error) in
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult() {
                let marker = GMSMarker()
                marker.position = position.target
                marker.title = result.lines?[0]
                self.hospitalData = nil
                
                //각각의 구(북구,남구,서구,광산구,동구) 로컬화
                self.clicklocality =  NSLocalizedString(result.locality!, comment: "")
                
                //처음 병원정보 얻어오기
                if(self.checkInit){
                    self.mylocality = NSLocalizedString(result.locality!, comment: "")
                    self.hospitalParser = HospitalParser(current_location: self.mylocality)
                    self.hospitalParser.get_hospitalData()
                    self.beforelocality = self.mylocality
                    self.checkInit = false
                }
                
                //지도에서 구 변경시
                else if(self.clicklocality != self.beforelocality){
                    
                    print("구가 변경되었습니다. 현위치: \(self.mylocality) 전 위치: \(self.beforelocality) 클릭위치: \(self.clicklocality)")
                    //인스턴스 초기화
                    self.hospitalParser = nil
                    self.hospitalData = nil
                    
                    //각각의 구 데이터 재 생성
                    self.hospitalParser = HospitalParser(current_location: self.mylocality)
                    self.hospitalParser.get_hospitalData()
                }
                
                self.hospitalData = self.hospitalParser.get_close_hospitalData(latitude: position.target.latitude, longitude: position.target.longitude)
                self.beforelocality  = NSLocalizedString(result.locality!, comment: "")
                marker.map = mapView
                
                
                guard let displayHospitals = self.hospitalData else {
                    print("나타낼 병원이 없습니다.")
                    return
                }
                
                var hospital_marker = Array<GMSMarker>()
               
                for hospital_item in displayHospitals{
                    
                        let hospital_marker_item = GMSMarker()
                        let hospitalLocation = CLLocationCoordinate2D(latitude: hospital_item.h_latitude, longitude: hospital_item.h_longitude)
                        hospital_marker_item.position = hospitalLocation
                    
                        var hospitalName: String?
                        hospitalName = hospital_item.h_name
                        hospital_marker_item.title = hospitalName
                    
                        hospital_marker.append(hospital_marker_item)
                    }
                
                for marker_item in hospital_marker{
                    marker_item.map = mapView
                }
 
            }else{
                print("정보를 불러올 수 없습니다.")
            }
        }
    }
    
}



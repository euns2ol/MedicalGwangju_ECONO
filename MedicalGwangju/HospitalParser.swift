//
//  HospitalParser.swift
//  MedicalGwangju
//
//  Created by 조은솔 on 2018. 7. 6..
//  Copyright © 2018년 sol. All rights reserved.
//

import UIKit
import CoreLocation

class HospitalParser: NSObject, XMLParserDelegate{
    
    var hospital_list = [Hospital]()
    var hospital_data = [String:String]()
    var parseTemp:String = ""
    var blank:Bool=true
    var i: Int = 1
    var current_location: String
    
    
    
    init(current_location: String) {
        self.current_location = current_location
    }
    
    func get_hospitalData() -> [Hospital]? {
        
        guard let url = Bundle.main.url(forResource: current_location, withExtension: "xml")else{
            print("URL error")
            return nil
        }
        
        
        
        guard let parser = XMLParser(contentsOf: url) else{
            print("Can't read data")
            return nil
        }
        
        parser.delegate = self //자신을 델리게이트에 연결
        
        let success:Bool = parser.parse()
        
        if success {
            print("\(current_location) 파싱 성공  병원 수: \(hospital_list.count)")
            var dicTemp = hospital_list[0]
            
            
        }else{
            print("파싱 실패")
        }
        
      
        return hospital_list
    }
   
    //현위치로부터 가까운 병원 30개의 데이터를 구한다.
    func get_close_hospitalData(latitude: Double, longitude: Double ) -> [Hospital]?{
        
        var rank_hospital_data = [Hospital]()
        let startLocation = CLLocation(latitude: latitude,longitude: longitude)
        var cnt: Int = 0
        
        for hospitalData in hospital_list{
            
            let destinationLocation = CLLocation(latitude: hospitalData.h_latitude,longitude: hospitalData.h_longitude)
            let distance_temp: CLLocationDistance = destinationLocation.distance(from: startLocation)
            hospitalData.h_distance = Int(distance_temp)
            
        }
        
        //거리 순(현재위치에 가까운 순서)에 따라 병원데이터 정렬
        hospital_list = hospital_list.sorted(by: {$0.h_distance < $1.h_distance})
        
        for close_hospital in hospital_list{
            
            if(close_hospital.h_distance != -1){
                rank_hospital_data.append(close_hospital)
                cnt = cnt + 1
            }
            
            if(cnt >= 15){
                break
                
            }
        }
        
        print("가까운 병원 수: \(rank_hospital_data.count)")
        /*for hospitalData in rank_hospital_data{
            print("병원이름: \(hospitalData.h_name) , 거리:  \(hospitalData.h_distance) ")
        }*/
        
        return rank_hospital_data
    }
    
    //element시작 잡는다 (element는 xml데이터)
    //<country>    한국        </country>
    // 시작.    중간(string)       끝(EndElement)에서 잡힌다.
    //시작태그를 만나면 호출
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
        parseTemp = elementName
        blank = true //블랭크를 쓰는 이유는 xml에서 <ㅁ><ㅁ/>뒤에 \n까지 캐릭터로 잡아버려서 detaildata의 키 값을 \n으로 바꾸게 된다. 이를 잡아주기 위해
        
    }
    
    //중간의 아이템 값을 만나면 호출
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        //딕셔너리에 스트링값 깔끔히 trim해서 넣어주기
        if blank == true {
            hospital_data[parseTemp] = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
        }
    }
    
    //끝 태그를 만나면 호출
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //각각의 병원객체를 생성해줌
        if elementName == "item"{
            
            guard let hpid = (hospital_data["hpid"]), let h_name = (hospital_data["dutyName"]), let h_div = (hospital_data["dutyDiv"]),
                let h_div_name = (hospital_data["dutyDivNam"]), let h_pnumber = (hospital_data["dutyTel1"]), let h_latitude = Double((hospital_data["wgs84Lat"])!),
                let h_longitude = Double((hospital_data["wgs84Lon"])!), let is_emergentcy = Int((hospital_data["dutyEryn"])!)
                else{
                    print("Tag 오류")
                    return }
            
            
            var dutytime_s = ["-1","-1","-1","-1","-1","-1","-1","-1"]
            var dutytime_c = ["-1","-1","-1","-1","-1","-1","-1","-1"]
            
            if let mon_dutytime_s = hospital_data["dutyTime1s"]{
                dutytime_s[0] = mon_dutytime_s
                dutytime_c[0] = hospital_data["dutyTime1c"]!
            }
            if let tues_dutytime_s = hospital_data["dutyTime2s"]{
                dutytime_s[1] = tues_dutytime_s
                dutytime_c[1] = hospital_data["dutyTime2c"]!
            }
            if let wed_dutytime_s = hospital_data["dutyTime3s"]{
                dutytime_s[2] = wed_dutytime_s
                dutytime_c[2] = hospital_data["dutyTime3c"]!
            }
            if let thur_dutytime_s = hospital_data["dutyTime4s"]{
                dutytime_s[3] = thur_dutytime_s
                dutytime_c[3] = hospital_data["dutyTime4c"]!
            }
            if let fri_dutytime_s = hospital_data["dutyTime5s"]{
                dutytime_s[4] = fri_dutytime_s
                dutytime_c[4] = hospital_data["dutyTime5c"]!
            }
            if let sat_dutytime_s = hospital_data["dutyTime6s"]{
                dutytime_s[5] = sat_dutytime_s
                dutytime_c[5] = hospital_data["dutyTime6c"]!
            }
            if let sun_dutytime_s = hospital_data["dutyTime7s"]{
                dutytime_s[6] = sun_dutytime_s
                dutytime_c[6] = hospital_data["dutyTime7c"]!
            }
            if let holi_dutytime_s = hospital_data["dutyTime8s"]{
                dutytime_s[7] = holi_dutytime_s
                dutytime_c[7] = hospital_data["dutyTime8c"]!
            }
            
            
            let h_item: Hospital = Hospital(h_pid: hpid, h_name: h_name, h_div: h_div, h_div_name: h_div_name, h_pnumber: h_pnumber,
                                            h_latitude: h_latitude, h_longitude: h_longitude, is_emergency: is_emergentcy, mon_dutytime_s: dutytime_s[0],
                                            tues_dutytime_s: dutytime_s[1], wed_dutytime_s: dutytime_s[2], thur_dutytime_s: dutytime_s[3],
                                            fri_dutytime_s: dutytime_s[4], sat_dutytime_s: dutytime_s[5], sun_dutytime_s: dutytime_s[6],
                                            holi_dutytime_s: dutytime_s[7], mon_dutytime_c: dutytime_c[0], tues_dutytime_c: dutytime_c[1],
                                            wed_dutytime_c: dutytime_c[2], thur_dutytime_c: dutytime_c[3], fri_dutytime_c: dutytime_c[4],
                                            sat_dutytime_c: dutytime_c[5], sun_dutytime_c: dutytime_c[6] , holi_dutytime_c: dutytime_c[7])
            
            //print("병원정보 \(i), \(h_item.h_pid), \(h_item.h_name), \(h_item.sun_dutytime_c)")
            i=i+1
            
            hospital_list.append(h_item)
            init_Date()
        }
        
        blank = false
        
    }
    
    func init_Date() -> Void {
        
        var k: Int = 0
        for _ in 1..<9 {
            
            let duty_c_string = "dutyTime"+String(k)+"s"
            let duty_s_string = "dutyTime"+String(k)+"c"
            hospital_data[duty_c_string] = "-1"
            hospital_data[duty_s_string] = "-1"
            k = k+1
        }
    }
    
    
}

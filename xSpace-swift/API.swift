import Alamofire
import SwiftyJSON
import RxSwift
import RxAlamofire

class API {

    static let shared = API()
    
    static let getLevelColorUrl = "http://sss.qingting.fm/pms/config/priv/lv.json"
    func getLevelColor() -> Observable<(HTTPURLResponse, Any)> {
        
        return SessionManager.default.rx.request(urlRequest: GetRequestConvertible(url:API.getLevelColorUrl)).flatMap {
            $0
                .validate(statusCode: 200 ..< 300)
                .validate(contentType: ["application/json"])
                .rx
                .responseData()
        }.map { (response, data) in
            let json = JSON(data)
            return (response, json)
        }.observeOn(MainScheduler.instance)
    }
}

class GetRequestConvertible: NSObject,URLRequestConvertible{
    
    var url:String!
    
    init(url:String){
        super.init()
        self.url = url
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: URL(string:url)!)
        urlRequest.httpMethod = "GET"
        return urlRequest
    }
}

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
    
    let onlineAppInfoUrl = "http://itunes.apple.com/lookup?id=1187159061"
    func getOnlineAppInfo() -> Observable<(HTTPURLResponse, Any)> {
        return SessionManager.default.rx.request(urlRequest: GetRequestConvertible(url:onlineAppInfoUrl)).flatMap {
            $0
                .validate(statusCode: 200 ..< 300)
                .rx
                .responseData()
            }.map { (response, data) in
                let json = JSON(data)
                return (response, json)
            }.observeOn(ConcurrentDispatchQueueScheduler(queue:DispatchQueue.global()))
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

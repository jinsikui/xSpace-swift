//
//  QtFile.swift
//  LiveAssistant
//
//  Created by JSK on 2017/10/31.
//  Copyright © 2017年 Shanghai MarkPhone Culture Media Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class QtFile: NSObject {
    
    static var shared = QtFile()
    
    static let levelColorsFileName = "levelColors"
    static let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    
    
    func hasDocumentFile(filename:String) -> Bool{
        let documentURL = URL(string:NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])!
        let appURL = documentURL.appendingPathComponent(QtFile.appName)
        let fileURL = appURL.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: fileURL.absoluteString)
    }
    
    func getFromDocument(filename:String) -> JSON? {
        let documentURL = URL(string:NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])!
        let appURL = documentURL.appendingPathComponent(QtFile.appName)
        let fileURL = appURL.appendingPathComponent(filename)
        let prefixFileURL = URL(fileURLWithPath:fileURL.absoluteString)
        if FileManager.default.fileExists(atPath: fileURL.absoluteString) {
            do{
                let data = try Data(contentsOf: prefixFileURL, options: .alwaysMapped)
                let json = JSON(data: data)
                return json
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func saveToDocument(filename:String, json:JSON){
        let documentURL = URL(string:NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])!
        let appURL = documentURL.appendingPathComponent(QtFile.appName)
        let fileURL = appURL.appendingPathComponent(filename)
        let prefixFileURL = URL(fileURLWithPath:fileURL.absoluteString)
        do {
            let dirExists = FileManager.default.fileExists(atPath: appURL.absoluteString)
            if !dirExists {
                try FileManager.default.createDirectory(atPath: appURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
            }
            let data = try json.rawData()
            try data.write(to: prefixFileURL, options: .atomic)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}


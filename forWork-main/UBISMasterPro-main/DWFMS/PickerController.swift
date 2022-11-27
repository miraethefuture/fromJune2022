//
//  test.swift
//  DWFMS
//
//  Created by dwi on 2022/11/03.
//  Copyright © 2022 DWFMS. All rights reserved.
//


import PhotosUI
import Alamofire
import WebKit

@available(iOS 14, *) // PHPickerConfiguration은 iOS 14 이상에서만 사용 가능하여 추가
@objc
class PickerController: UIViewController, PHPickerViewControllerDelegate {

    let cameraVC = CameraViewController()
    //var selectedImage : [UIImage?] = [] // 사용하는지 확인
    
    // 파일 이름 저장하는 배열
    var fileName: [String] = []
    
    // 이미지 개수
    @objc var imgCnt = 0
    
    var imgCntFromCV = GlobalDataManager.getgData().cameraData["num"]
    var totalImgCnt = GlobalDataManager.getgData().cameraData["totalImgCnt"]
    
    //포트까지 있는 서버 주소를 가져옴
    var serverIp = GlobalData.getServerIp()

    //사업소 코드와 메뉴 타입 가져오기
    var compCD = GlobalDataManager.getgData().compCd
    var menuType = GlobalDataManager.getgData().cameraData["type"]
    var type = "" // ?
    
    var imageParamKey = "file"
    
    var num = 0
    
    var imgCntToStr = ""
    var imgCntToInt = 0
    
    var totalImgCntToStr = ""
    var totalImgCntToInt = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ImgCntFromCV를 Int 형태로 변환하기 (Any->Int)
        imgCntToStr = (imgCntFromCV as? String)!
        imgCntToInt = Int(imgCntToStr)!
        
        totalImgCntToStr = (totalImgCnt as? String) ?? "5"
        totalImgCntToInt = Int(totalImgCntToStr)!
        
        print("imgCnt : \(imgCntFromCV)")
        print("imgCnt : \(totalImgCnt)")
        
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        //var configuration = PHPickerConfiguration()
    
        
        switch totalImgCntToInt {
        case 5 :
            configuration.selectionLimit = 1
        case 4 :
            configuration.selectionLimit = 2
        case 3 :
            configuration.selectionLimit = 3
        case 2 :
            configuration.selectionLimit = 4
        case 1 :
            configuration.selectionLimit = 5
        case 0 :
            configuration.selectionLimit = 6
        default:
            configuration.selectionLimit = 1 // 뭘로 주지?
        }

        // 이미지만 가져오기
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .current
        
        //let readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        // Request read-write access to the user's photo library.
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .notDetermined:
                // The user hasn't determined this app's access.
                print("notDetermined")
            case .restricted:
                // The system restricted this app's access.
                print("restricted")
            case .denied:
                // The user explicitly denied this app's access.
                print("denied")
            case .authorized:
                // The user authorized this app to access Photos data.
                print("authorized")
            case .limited:
                // The user authorized this app for limited Photos access.
                print("limited")
            @unknown default:
                fatalError()
            }
        }
        
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self
        
        DispatchQueue.main.async { [weak self] in
            self?.present(picker, animated: true, completion: nil)
        }
        
       
//        parent?.dismiss(animated: true, completion: nil)
        
        // 둘 다 하얀 화면만 남음
//        self.dismiss(animated: true, completion: nil)
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    // S: 이미지 다중 선택 - Upload 함수 작성 (2022.11.17)
    func UploadImages(imagesData: [UIImage?], urlString: String, imageParamName: String) {
        
        print("imgCntToInt 가져오는지 확인 ==> \(imgCntToInt)")
        
        print("menuType 가져오는지 확인 ==> \(type)")
        
        // body 내용은 임의로 설정 -> 수정하기
        let parameters = [
            "station_id" : "1000", // ?
            "title": "UBIS Master",
            "body": "images from UBIS Master"
        ]
        
        var ImageAsData : [Data] = []
        var strFilePath = "" //파일 경로 취합
        var strFileNum = ""  //파일 번호 취합
        
        
        // UIImage 타입 데이터를 jpegData로 변경하여 ImageAsData 배열에 저장
        for img in imagesData {
            
            // 만약 img가 nil 이라면...기본으로 들어갈 이미지를 만들까나
            // compressionQuality 몇으로 해야하는지..?
            ImageAsData.append(img!.jpegData(compressionQuality: 1)!)
        }
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            // import image to request
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }

            // filename 사용해서 순서대로 가져오기 (이미지 순서와 맞는지 확인) -> 가장 최근 사진이 1 ...
            for imageData in ImageAsData {
                
                multipartFormData.append(imageData, withName: "\(imageParamName)[]", fileName: "\(self.fileName[self.num])_\(self.imgCntToInt + 1).jpg", mimeType: "image/jpg")
                
                let filePath = "resources/App_Company/" + self.compCD! + "/" + self.type + "/"
                var path = filePath + "\(self.fileName[self.num])_\(self.imgCntToInt).jpg"
                var number = self.imgCntToInt
                
                strFilePath = strFilePath + path + "|"
                strFileNum = strFileNum + String(number) + "|"
                
                print("strFilePath : \(strFilePath)")
                
                self.imgCntToInt += 1
            }
        }, to: urlString,
            encodingCompletion: { encodingResult in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseString { [self] response in
                    print(response)
                    
                    
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    
                    
                    DispatchQueue.main.async {
                        
                        print("success Dispatch")

                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.main.webView.stringByEvaluatingJavaScript(from: "setMultiImge('\(strFilePath)','\(strFileNum)');")
                        
                        print("end Dispatch")
                    }
                    
                    
                }
            case .failure(let error):
                print(error)
            }
            
        })
    }
}



@available(iOS 14, *)
extension PickerController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // 취소
        if results.isEmpty {
            picker.dismiss(animated: true, completion: nil)
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            return
        }
        
//        print(results.count)
        
        let imageItems = results
            .map { $0.itemProvider }
            .filter { $0.canLoadObject(ofClass: UIImage.self) } // filter for possible UIImages
        
        let dispatchGroup = DispatchGroup()
        var images = [UIImage]()
        
        for imageItem in imageItems {
            dispatchGroup.enter() // signal IN
            
            imageItem.loadObject(ofClass: UIImage.self) { image, _ in
                if let image = image as? UIImage {
                    images.append(image)
                }
                dispatchGroup.leave() // signal OUT
            }
        }
        
        // This is called at the end; after all signals are matched (IN/OUT)
        dispatchGroup.notify(queue: .main) { [self] in
            print("dispatchGroup 안 images : \(images)")
            
            // 가져온 타입을 String 형식으로 입력
            type = String(describing: menuType!)
            
            // compCD 없을리 없으니까 ! 처리..
            let urlString = serverIp! + "/resources/filedown.jsp?path=resources/App_Company/" + compCD! + "/" + type + "/"
            print("최종 url 주소 ===> \(urlString)")
            
            UploadImages(imagesData: images, urlString: urlString, imageParamName: imageParamKey)
        }
        
        // 파일 이름 설정 - 이미지 생성일 이용
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMddHHmmssSSSS" // 2210241608
        
        // 이미지 생성 날짜 사용하여 fileName 짓기
        for i in 0..<results.count {
            let imageResult = results[i]
            
            if let assetId = imageResult.assetIdentifier {
                let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                
                var creationDate = assetResults.firstObject?.creationDate ?? Date()
                var formattedDate = formatter.string(from: creationDate)
//                print(assetResults.firstObject?.creationDate ?? "\(Date().timeIntervalSince1970)")
                
                // 20221121_1 형식의 String 데이터를 fileName 배열에 저장
                fileName.append(formattedDate)
                
                print(formattedDate)
            }
        }
        
        var options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true

        picker.dismiss(animated: true)
    }
}

//
//  KaKaoSTT.swift
//  DWFMS
//
//  Created by dwi on 2022/11/07.
//  Copyright © 2022 DWFMS. All rights reserved.
//

import UIKit
import AVFoundation

@objcMembers
class KakaoSTT : UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var numberOfRecords = 0 // uuid 사용 이름으로 변경하기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            self.setupView()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 10.0, *)
    func setupView() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            if #available(iOS 10.0, *) {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
            } else {
                // Fallback on earlier versions
            }
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record
                    }
                }
            }
        } catch {
            // failed to record
        }
    }
    
    func loadRecordingUI() {
        recordButton.isEnabled = true
        playButton.isEnabled = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.addTarget(self, action: #selector(recordAudioButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    @objc func recordAudioButtonTapped(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func startRecording() {
        
        self.numberOfRecords += 1 // 새로운 녹음이 있을 때마다 +1
        
        let audioFilename = getFileURL()
        print(audioFilename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: .normal)
            playButton.isEnabled = false
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
        
        playButton.isEnabled = true
        recordButton.isEnabled = true
    }
    
    @IBAction func playAudioButtonTapped(_ sender: UIButton) {
        if (sender.titleLabel?.text == "Play"){
            recordButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            preparePlayer()
            audioPlayer.play()
        } else {
            audioPlayer.stop()
            sender.setTitle("Play", for: .normal)
        }
    }
    
    func preparePlayer() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("\(numberOfRecords).m4a")
        return path as URL
    }
    
    //MARK: Delegates
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
    
    //MARK: To upload video on server
    
    func uploadAudioToServer() {
        /*Alamofire.upload(
         multipartFormData: { multipartFormData in
         multipartFormData.append(getFileURL(), withName: "audio.m4a")
         },
         to: "https://yourServerLink",
         encodingCompletion: { encodingResult in
         switch encodingResult {
         case .success(let upload, _, _):
         upload.responseJSON { response in
         Print(response)
         }
         case .failure(let encodingError):
         print(encodingError)
         }
         })*/
    }
    
//    var recordingSession: AVAudioSession!
//    var audioRecorder: AVAudioRecorder!
//    var audioPlayer: AVAudioPlayer! // 플레이어 필요 없음
//    var numberOfRecords = 0         // 서버로 전송하고 바로 삭제할 것이므로 필요 없을 듯
//
//    @IBOutlet weak var recordButton: UIButton! // 버튼 만들기. 이 프로젝트에 스토리보드 생성 or 새 프로젝트 만들기
//    @IBOutlet weak var playButton: UIButton!
//    let E_401 = "E_401" // 뭔가요
//    let DATABASE_PATH = "http://www.ubismaster.com:8445/DWFMS/"  // 경로보다 일단 로컬로 떨어트리기
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 버튼 액션 인식
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(record))
//        longPressRecognizer.minimumPressDuration = 0
//        recordButton.addGestureRecognizer(longPressRecognizer)
//
//        // 세션 설정
//        recordingSession = AVAudioSession.sharedInstance()
//
//        // 마이크 사용 권한 요청
//        AVAudioSession.sharedInstance().requestRecordPermission{ (hasPermission) in
//            if hasPermission
//            {print ("ACCEPTED 권한 확인")}
//        }
//    }
//
//    @IBAction func record(_ gestureRecognizer: UILongPressGestureRecognizer) {
//
//        // 작동중인 recorder 있는지 확인
//        if (gestureRecognizer.state == .began) && (audioRecorder == nil) {
//
//            // 새로운 녹음 있을 때마다 +1 추가
//            self.numberOfRecords += 1
//
//            // 파일 설정 및 이름 설정 - 1.m4a 와 같은 형식으로 이름 저장됨
//            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
//            let settings = [
//                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//                AVSampleRateKey: 12000,
//                AVNumberOfChannelsKey: 1,
//                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
//            ]
//
//            do
//            {
//                // 오디오 녹화 시작
//                recordButton.setTitle("Recording...", for: .normal)
//                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
//                audioRecorder.delegate = self
//                audioRecorder.record()
//            }
//            catch
//            {
//                // Catch for errors
//                displayAlert(title: "Oops!", message: "Recording failed")
//
//            }
//
//        } else if gestureRecognizer.state == .ended && (audioRecorder != nil)
//
//        {
//            // Stopping audio recording
//            recordButton.setTitle("Start Recording", for: .normal)
//            audioRecorder.stop()
//            audioRecorder = nil
//
//            do {
//                let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
//                let recording: NSData = try NSData(contentsOf: filename)
////                self.uploadFile(fileData: recording as Data, fileName: "\(numberOfRecords).m4a"){
////                    (fileURL, e) in
////                    if e == nil {
////                        print("FILE URL: " + fileURL!)
////                    }
////                }
//
//            } catch {
//                print("Unexpected <<<<<<<<<<<<<<>>>>>>>>>>>>>> error: \(error)")
//            }
//        }
//    }
//
//    @IBAction func playSound(_ sender: Any) {
//
//        recordButton.isEnabled = false
//        audioPlayer.prepareToPlay()
//        audioPlayer.play()
//    }
//
//    // 디렉토리 경로를 얻는 함수
//    func getDirectory () -> URL
//    {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        let documentDirectory = paths[0]
//
//        return documentDirectory
//    }
//
//    // Function that displays an alert
//    func displayAlert(title:String, message:String)
//    {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
    
    
//    func uploadFile(fileData:Data, fileName:String , completion: @escaping (_ fileURL:String?, _ error:String?) -> Void) {
//        let recId = "\(numberOfRecords)"
//        print("FILENAME: \(fileName)")
//        let request = NSMutableURLRequest()
//
//        let boundary = "--------14737809831466499882746641449----"
//        let beginningBoundary = "--\(boundary)"
//        let endingBoundary = "--\(boundary)--"
//        let contentType = "multipart/form-data;boundary=\(boundary)"
//
//
//
//        request.url = URL(string: DATABASE_PATH + "catch.php")
//        //        catch.php is php script on server
//        request.httpShouldHandleCookies = false
//        request.timeoutInterval = 60
//        request.httpMethod = "POST"
//        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
//        let body = NSMutableData()
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition: form-data; name=\"fileName\"\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append("\(fileName)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n".data(using: String.Encoding.utf8)!)
//
//        body.append(("\(beginningBoundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
//        body.append(("Content-Type: application/octet-stream\r\n\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
//
//        body.append(fileData)
//        body.append("\r\n".data(using: String.Encoding.utf8)!)
//
//
//        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
//        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
//        //        request.addValue(recId, forHTTPHeaderField: "REC-ID")
//        request.httpBody = body as Data
//
//
//        let session = URLSession.shared
//        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
//            guard let _:Data = data as Data?, let _:URLResponse = response, error == nil else {
//                DispatchQueue.main.async { completion(nil, error!.localizedDescription) }
//                return
//            }
//            if let response = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
//                print("XSUploadFile -> RESPONSE: " + self.DATABASE_PATH + response)
//                DispatchQueue.main.async { completion(self.DATABASE_PATH + response, nil) }
//
//                // NO response
//            } else { DispatchQueue.main.async { completion(nil, self.E_401) } }// ./ If response
//        }; task.resume()
//    }
}


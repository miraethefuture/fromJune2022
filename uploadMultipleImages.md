# Nov 17 
  
  사진을 첨부하여 업로드하는 기능을 가진 메뉴가 있는데, 현재 iOS 앱은 이미지를 하나씩 선택하고 추가할 수 있다.  
  3장을 추가하고 싶다면 3번을 선택하고 추가하는 일을 반복해야 한다.  
  사용중인 곳에서 여러 장을 한꺼번에 선택해서 올릴 수 있도록 기능 개선을 요청했다.  
  
## UIImagePickerController and PHPickerViewController
  
  소스를 보니 UIImagePickerController를 사용하여 라이브러리에서 이미지를 가져오고 있었다. 기존 소스를 이용할까 싶어 구글링을 해보니 UIImagePickerController로 여러장의 이미지를  
  선택하고 추가하려면 커스텀한 image picker를 사용해야 했다. third party를 사용하고 싶지 않아서 조금 더 구글링을 해보니 iOS 14 부터 애플 API PHPickerViewController를 사용하여  
  다중 이미지 선택/추가를 구현할 수 있다는 것을 발견했다.  
  
## Swift and Objective-C  
  
  현재 회사 앱의 코드는 Objective-C 로 작성되어 있다. 그런데 검색을 해보니 Objective-C 로 작성한 PHPickerViewController 관련 자료가 아주 적었다. 그에 비해 Swift 자료는 꽤 있어서  
  기존 Objective-C 프로젝트에 Swift 파일을 추가해 보기로 했다. 입사 초반에 한 번 시도해보고 싶었는데 당시에는 다른 일정으로 iOS 개발에 대한 시간이 주어지지 않아서 접었었다.  
  현재는 Swift - Objective-C 양쪽에서 다른 쪽의 클래스를 사용할 수 있도록 설정해 두었다. (오늘 이슈가 있었는데 잘 빌드되던 앱이 갑자기 import 부분에서 브릿징 헤더를 찾을 수 없다며 빌드 되지 않았다.)  
  급한 불을 꺼보자 싶어서 import한 부분을 주석처리했는데 Obejective-C 클래스 안에 사용된 Swift 클래스가 에러를 발생시키지 않고 잘 빌드 되었다. 이건 계속해서 확인해보려고 한다.)

## 서버에 사진 업로드 성공!
  
  서버에 사진이 올라갔지만 개수가 맞지 않는 문제가 있어 해결하던 중
  

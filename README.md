# 박스 오피스 리팩토링 ver 🎥

## 프로젝트 소개
> 서버와 통신하여 영화정보를 화면에 출력하는 앱
> 
> 프로젝트 기간: 2023.08.25 - 2023.09.23


## ⚙️ 개발환경 및 라이브러리
[![iOS](https://img.shields.io/badge/iOS-16.0-yellow)]() [![swift](https://img.shields.io/badge/swift-5.0-orange)]() [![xcode](https://img.shields.io/badge/Xcode-14.3.1-blue)]() [![rxswift](https://img.shields.io/badge/RxSwift-6.5.0-green)]() [![rxDataSource](https://img.shields.io/badge/RxDataSource-5.0-red)]()

## 핵심 기술스택 💎

`MVVM`, `RxSwift`, `RxDataSource`, `UserDefaults`, `CollectionView`, `UICalendarView`

## 설계 📍

### Layer 🗺

<Img src = "https://github.com/juun97/ios-diary/assets/59365211/aafca41c-11e6-4ec1-bce0-e6c7aa0bcb4a" width="700">

#### Presentaion Layer
- 사용자 인터페이스(UI)를 담당합니다. 이 레이어는 화면의 구성 요소를 표시하고 사용자 입력을 처리합니다.
- View: 사용자 인터페이스를 그리고, 사용자와의 상호작용을 처리합니다. View는 주로 화면 표시와 사용자 입력 처리에 집중합니다.
- ViewModel: UI와 상호작용하고 데이터를 관리합니다. ViewModel은 Presentation Logic을 제어하고, 비즈니스 로직이나 도메인 로직을 호출하며, 데이터를 노출합니다.

#### Domain Layer
- 비즈니스 로직 또는 도메인 로직을 처리합니다. 비즈니스 규칙과 데이터 처리 로직을 담당합니다.
- ViewModel과 상호작용하여 데이터를 처리하고 변환합니다.
- Use Case (Interactor): 비즈니스 로직을 캡슐화하고, 데이터의 흐름을 조작합니다. Use Case는 ViewModel에 필요한 데이터를 제공하고, 데이터를 도메인 객체로 변환합니다.


#### Data Layer
- 데이터에 접근하고 관리하는 역할을 합니다.


### Architectural Pattern

`MVC` 아키텍처는 간단하고 직관적인 설계 패턴으로, Controller가 View와 Model을 연결하여 사용하기 쉽습니다. 그러나 이러한 연결은 Controller가 View와 Model 양쪽에 의존해야 함을 의미하며, 이로 인해 결합도가 높아집니다.

MVC 아키텍처는 규모가 작은 어플리케이션을 개발할 때 간편하게 사용할 수 있지만, 어플리케이션 규모가 커질수록 유지 보수 측면에서 취약점이 발생할 수 있습니다. 이로 인해 코드 변경이 필요한 경우 해당 변경 사항이 전체 코드에 미치는 파급 효과가 증가하며, 코드의 복잡성과 결합도가 증가할 수 있습니다. 이는 비용과 리스크의 증가로 이어질 수 있습니다.


<Img src = "https://blogs.sap.com/wp-content/uploads/2017/04/pic1.png" width="500">

</br>
</br>

`MVVM` 아키텍처는 이러한 `MVC` 의 한계를 극복하기 위해 개발되었습니다. `MVVM` 은 View와 Model 사이에 ViewModel을 도입함으로써 Controller의 역할을 분리하고, 데이터와 UI 간의 바인딩을 더 효과적으로 다룰 수 있게 합니다.

<Img src = "https://blogs.sap.com/wp-content/uploads/2017/04/pic3.png" width="500">

</br>
</br>

MVVM의 핵심 아이디어는 `데이터와 뷰 간의 결합도`를 낮추는 데 있습니다. 결합도가 낮아진다면 다음과 같은 이점은 챙길 수 있습니다.

- 유지 보수성 향상: MVVM은 데이터와 비즈니스 로직을 뷰에서 분리함으로써 뷰의 변경이나 업데이트에 더 유연하게 대응할 수 있습니다. 이로 인해 애플리케이션의 유지 보수가 용이해지며 새로운 기능을 추가하거나 변경할 때 예기치 않은 부작용을 줄일 수 있습니다.

- 확장성: MVVM은 뷰모델을 통해 뷰와 모델 간의 중간 계층을 제공합니다. 이로써 새로운 뷰를 쉽게 추가하거나 기존 뷰를 변경할 수 있습니다. 뷰모델은 다양한 뷰와 함께 재사용할 수 있으며, 다른 플랫폼 또는 디바이스에서 동일한 뷰모델을 활용할 수 있습니다.

- 테스트 용이성: MVVM은 뷰와 모델을 분리하고 뷰모델을 중심으로 데이터 흐름을 관리하므로 단위 테스트가 쉽게 수행됩니다. 뷰와 뷰모델 간의 인터페이스가 명확하게 정의되어 있으므로 테스트 케이스를 작성하고 각 구성 요소를 독립적으로 테스트하는 데 용이합니다.

- 재사용성: 뷰모델은 뷰와 독립적으로 존재하며 뷰와 결합되지 않습니다. 따라서 동일한 뷰모델을 여러 뷰에서 재사용할 수 있습니다. 이는 코드의 재사용성을 증가시키며 개발 시간을 단축시킵니다.

</br>

## File Tree 🌲

<details>
<summary>File Tree 펼치기/접기</summary>
<div markdown="1">


```typescript
BoxOffice
│
├── AppDelegate.swift
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Model
│   ├── CellMode.swift
│   └── DTO
│       ├── DailyBoxOffice
│       ├── DetailMovieInformation
│       └── MoviePoster
│           ├── Document.swift
│           ├── Meta.swift
│           └── MoviePoster.swift
├── Network
│   ├── NetworkManager.swift
│   └── URLRequestMaker.swift
├── Presentation
│   ├── Common
│   │   └── ViewModelType.swift
│   ├── MovieRankingView
│   │   ├── MovieRankingViewController.swift
│   │   └── ViewModel
│   │       ├── MovieRankingUseCase.swift
│   │       └── MovieRankingViewModel.swift
│   ├── DetailMovieView
│   │   ├── DetailMovieViewController.swift
│   │   └── ViewModel
│   │       ├── DetailMovieUseCase.swift
│   │       └── DetailMovieViewModel.swift
│   ├── CalendarView
│   │   ├── CalendarViewController.swift
│   │   └── ViewModel
│   │       ├── CalendarViewUseCase.swift
│   │       └── CalendarViewViewModel.swift
│   └── UIComponents
│       ├── CustomCollectionViewIconCell.swift
│       ├── CustomCollectionViewListCell.swift
│       └── CustomStackView.swift
└── Util
    ├── AlertBuilder.swift
    ├── DateFormat.swift
    ├── DecodeManager.swift
    ├── StringConvertible.swift
    └── Extension
```
</div>
</details>


</br>



## 실행 화면 🎬


| <center> 처음 실행시 데이터 로딩</center> | <center>내부 데이터 새로고침</center>  | <center>항목들 List로 화면에 표시</center> |
| --- | --- | --- |
| <img src="https://i.imgur.com/LASoeY8.gif" width =400> | <img src="https://i.imgur.com/j2ZXMe0.gif" width =400> | <img src="https://i.imgur.com/MdMpHpH.gif" width =400> |


| <center> 날짜 선택뷰로 이동</center> | <center>특정 날짜 선택시 업데이트</center>  | <center>새로고침시 최근날짜로 업데이트</center> |
| --- | --- | --- |
| <img src="https://i.imgur.com/XYhmxpx.gif" width =400> | <img src="https://i.imgur.com/B8OcCZV.gif" width =400> | <img src="https://i.imgur.com/5K65eev.gif" width =400> |


</br>

## 트러블 슈팅 🚀

### 1️⃣ View Model 이 담당해야 할 기능

#### Problem

디미터 법칙은 객체 간의 결합도를 낮추고 느슨한 결합(Loose Coupling)을 유지하기 위한 객체 지향 설계 원칙 중 하나입니다. 디미터 법칙은 다음과 같이 요약됩니다
> "객체는 자신이 직접 관련된 객체와만 상호 작용해야 하며, 낯선 객체에게는 직접 접근하지 않아야 한다."

하지만 기존의 코드는 디미터 법칙을 지키지 않고 View Model의 프로퍼티가 외부로 노출되어 있었고 해당 모델을 뷰모델에서 직접 수정까지 진행을 하고 있었습니다. 또한 사용자의 Input 과 Output 사이에 일관적인 흐름이 맞지 않았습니다.

```swift
//ViewController의 기존 바인딩 코드
    viewModel.boxOffice
        .bind(to: collectionView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
```

#### Solution

이를 해결하기 위해 뷰모델 내부의 Input 과 Ouput 타입을 만들어 View 에서 Event 라는 Input 이 들어오면 해당 인풋을 transform 하여 필요한 요소만 내뱉어주는 Output 을 내뱉어 주었습니다.

위 방식을 사용하게 되면서 기존에 노출되어 있는 프로퍼티가 필요가 없어지게 되어 삭제하였고, View Model 은 필요한 최소한의 정보만을 노출 해 디미터 법칙은 준수하게 되었습니다. 또한 Input과 Output이 하나의 흐름으로 묶여 일관적인 흐름을 가지게 되었습니다.


```swift
// 변경된 바인딩 된 코드
    let input = MovieRankingViewModel.Input(
            didModelSelected: collectionView.rx.modelSelected(DailyBoxOffice.self).asObservable(),
            didTapSelectDateButton: selectDateButton.rx.tap.asObservable(),
            didTapSelectModeButton: selectModeButton.rx.tap.asObservable(),
            didCalendarViewDismiss: NotificationCenter.default.rx.notification(.calendarViewDismiss)
        )
    let output = viewModel.transform(input)

// transform된 output 으로 바인딩
```

### 2️⃣ Builder Pattern For Declarative Programming

#### Problem

RxSwift는 리액티브 프로그래밍 패러다임의 구현체로서, 데이터 스트림의 변화에 반응(react)하는 방식으로 프로그램을 작성합니다. rxSwift에서 데이터 스트림은 `"무엇"`을 표현하고, `"어떻게"` 값을 변환하거나 처리하는 것은 내부적으로 처리됩니다.

선언형 프로그래밍은 `"무엇"`을 수행해야 하는지를 설명하는 방식으로 코드를 작성하는 프로그래밍 패러다임입니다. 명령형 프로그래밍과 대조되며, 코드에서 `"어떻게"` 작업을 수행하는지에 대한 세부 사항을 최소화하려고 합니다.
    
따라서 RxSwift는 "무엇"을 표현하고 데이터 스트림을 조작하는 데 중점을 두며, 이로써 선언형 프로그래밍의 원칙을 자연스럽게 따르게 됩니다.

그럼에도 불구하고, Alert을 띄우는 과정에서 기존의 방식으로는 Alert과 Action을 생성하는 과정에서 불가피하게 명령형 프로그래밍으로 작성해야 하는 경우가 있습니다. 

```swift
private func presentCellChangeActionSheet() {
        let actionSheet = UIAlertController(title: "화면모드변경", message: nil, preferredStyle: .actionSheet)
        let actionDefault = UIAlertAction(title: viewModel.cellMode.value.alertText, style: .default) { [weak self] _ in
            self?.viewModel.changeCellMode()
            self?.collectionView.reloadData()
        }
        let actionCancel = UIAlertAction(title: "취소", style: .cancel)
        
        
        actionSheet.addAction(actionDefault)
        actionSheet.addAction(actionCancel)
        
        self.present(actionSheet, animated: true)
    }
```

이를 해결하기 위해, 명령형 프로그래밍과 선언형 프로그래밍 사이에서 일관성을 유지하고 가독성을 높일 수 있는 빌더 패턴을 적용했습니다.

빌더 패턴을 사용하면 Alert 및 Action 객체를 구성하는 과정을 선언적으로 작성할 수 있으며, 이로써 명령형 코드를 최소화하고 코드의 일관성을 유지할 수 있습니다. 이것은 RxSwift와 선언형 프로그래밍의 원칙을 적용한 코드와 어우러져 더 나은 코드 구조를 형성하는 데 도움이 됩니다.


```swift
AlertBuilder()
        .preferredStyle(.actionSheet)
        .withTitle("화면모드 변경")
        .addAction(self.viewModel.cellMode.value.alertText,style: .default, handler: ({ _ in
                   self.viewModel.changeCellMode()
                   self.collectionView.reloadData()
                    }))
        .addAction("취소", style: .cancel)
        .show(in: self)
```

<details>
<summary>AlertBuilder 구현부</summary>
<div markdown="2">

```swift
final class AlertBuilder {
    private var preferredStyle: UIAlertController.Style = .alert
    private var title: String? = nil
    private var message: String? = nil
    private var actions: [UIAlertAction] = [UIAlertAction]()

    
    func preferredStyle(_ style: UIAlertController.Style) -> AlertBuilder {
        self.preferredStyle = style
        return self
    }
    
    func withTitle(_ title: String?) -> AlertBuilder {
        self.title = title
        return self
    }
    
    func withMessage(_ message: String?) -> AlertBuilder {
        self.message = message
        return self
    }
    
    func addAction(_ title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> AlertBuilder {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        actions.append(action)
        
        return self
    }
    
    func show(in viewController: UIViewController, animated: Bool = true) {
        viewController.present(build(), animated: animated)
    }
    
    private func build() -> UIAlertController {
        let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: self.preferredStyle)
        actions.forEach { action in
            alert.addAction(action)
        }
        
        return alert
    }
}
```

</div>
</details>


### 3️⃣ RxDataSource

#### Problem

초기에는 사용에 익숙한 `DiffableDataSource` 를 적용하고자 했습니다. `DiffableDataSource` 각 요소를 고유하게 식별하기 위해 `Hashable` 한 요소들을 배열로 관리를 합니다. 특정요소를 접근하기 위해선 `IndexPath` 가 필수적으로 필요합니다.

![](https://hackmd.io/_uploads/rkaX6jAy6.png)

`DiffableDataSource`의 `CellProvider` 의 파라미터를 살펴보면 특정요소에 접근할 수 있도록 IndexPath 를 제공하고 있습니다. 하지만 현재 제 상황에선 Cell에 들어가는 Data 들을 ViewModel에서 따로 저장해 관리하지 않고 Input에 대한 결과인 Output으로 보내주고 있엇기에 IndexPath 로 특정 요소에 접근하는 것이 불가능했습니다.

#### Solution

이를 해결하기 위해 `RxDataSource` 를 도입했습니다. `RxDataSource` 는 `DiffableDataSource` 와 사용법과 모양이 굉장히 유사하지만 `CellProvider` 의 파라미터에서 차이점이 존재합니다.

```swift
open class CollectionViewSectionedDataSource<Section: SectionModelType> {

public typealias ConfigureCell = (CollectionViewSectionedDataSource<Section>, UICollectionView, IndexPath, Item) -> UICollectionViewCell

public init(
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: ConfigureSupplementaryView? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
    ) {
        self.configureCell = configureCell
        self.configureSupplementaryView = configureSupplementaryView
        self.moveItem = moveItem
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
    }
}
```

RxDataSource 의 CellProvider 의 파라미터로는 다음과 같은것이 있습니다.

- DataSource
- TableView or CollectionView
- IndexPath
- Item

RxDataSource는 DiffableDataSource와는 다르게 데이터를 직접 파라미터로 받아오며, 이를 통해 IndexPath를 사용하여 필요한 특정 요소에 직접 접근할 수 있습니다. 이로 인해 데이터를 별도로 보관하거나 관리하지 않아도 되며, DataSource를 구성하고 업데이트하는 작업을 더 간편하게 수행할 수 있게 됩니다.

```swift
  dataSource = RxCollectionViewSectionedReloadDataSource<MovieRankingViewDataSection> { _, _, indexPath, item in
            switch self.viewModel.cellMode {
            case .list:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewListCell.identifier, for: indexPath) as? CustomCollectionViewListCell else { return CustomCollectionViewListCell() }
                cell.configureCell(dailyBoxOffice: item)
                
                return cell
            case .icon:
                guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewIconCell.identifier, for: indexPath) as? CustomCollectionViewIconCell else { return CustomCollectionViewIconCell() }
                cell.configureCell(dailyBoxOffice: item)
                
                return cell
            }
        }
```

### 4️⃣ 두개의 Input 하나의 Output

#### Problem

어플리케이션을 초기에 실행할때와 CalendarView 가 Dismiss 되는 시점의 Event Input이 발생되었을 때 ViewModel 에서 View 에서 Binding 되어야할 모델과 날짜를 Output 을 보내주고 있습니다. 

하지만 각각의 Output 이 별개의 Observable 로 반환이 되고 있었기에 Binding에 어려움을 겪었습니다. 초기에는 각각의 Observable 을 직접 Binding 을 진행을 하려했으나 한번 Binding 되어있는 데이터소스에 다시 Binding을 진행하니 App Crash 를 경험했습니다.

#### Solution

RxSwift의 Combining Operator 중 하나인 Merge를 활용하여 이 문제를 해결하였습니다. ViewModel에서 데이터를 처리하는 단계에서 두 개의 입력에 대한 결과를 병합하여 하나의 Output으로 출력함으로써, 단 한 번의 Binding으로 문제를 해결할 수 있게 되었습니다.

```swift
let defaultDate = Observable.just(currentDate)
        
let updatedDate = input.didCalendarViewDismiss
        .compactMap { notification in
            notification.userInfo?["currentDate"] as? Date
            }
        .withUnretained(self)
        .map { owner, date in
            owner.currentDate = date
            }
        .withUnretained(self)
        .map { owner, _ in
            owner.currentDate
            }
   
let currentDate = Observable.of(defaultDate, updatedDate).merge()
        
let boxOffice = currentDate
        .withUnretained(self)
        .flatMap { owner, date in
            owner.useCase.fetchBoxOfficeData(date: date)
            }
        .map { boxOfficeList in
            [MovieRankingViewDataSection(header: "main", items: boxOfficeList)]
            }
```



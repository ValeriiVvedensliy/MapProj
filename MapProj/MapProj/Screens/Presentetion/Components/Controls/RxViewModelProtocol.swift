import Foundation

protocol RxViewModelProtocol {
  associatedtype Input
  associatedtype Output

  var input: Input! { get }
  var output: Output! { get }
}

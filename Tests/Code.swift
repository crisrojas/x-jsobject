import JavaScriptCore
import XCTest
import JSObject


final class Tests: XCTestCase {
    func test_increment_callsOnUpdateCallbackWithUpdatedValue() {
        var count = 0
        let vm = JSObject(js: jsSource, key: "ViewModel")
        let e = expectation(description: "Wait for callback")
        vm.onUpdate = { count = $0 ; e.fulfill() }
        vm.increment()
        wait(for: [e], timeout: 1)
        XCTAssertEqual(count, 1)
    }

    let jsSource = """
        function ViewModel() {
            this.counter = 0;
            this.onUpdate = null;
        }

        ViewModel.prototype.increment = function () {
            this.counter += 1;
            this.onUpdate(this.counter);
        };
        """
}

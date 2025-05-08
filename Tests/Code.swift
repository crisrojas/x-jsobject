import JavaScriptCore
import XCTest

@dynamicMemberLookup
final class JSObject {
    private let context: JSContext
    private let jsValue: JSValue
    private var callbacks = [String: Any]()

    init(js: String, key: String) {
        self.context = JSContext()!
        context.evaluateScript(js)
        let constructor = context.objectForKeyedSubscript(key)!
        self.jsValue = constructor.construct(withArguments: [])!
    }

    subscript(dynamicMember member: String) -> (() -> Void) {
        guard jsValue.hasProperty(member) else { return {} }
        return {
            _ = self.jsValue.invokeMethod(member, withArguments: [])
        }
    }

    subscript(dynamicMember member: String) -> ((Any) -> Void)? {
            get { nil }
            set {
                guard let newValue = newValue else { return }
                let block: @convention(block) (JSValue) -> Void = { jsVal in
                    newValue(jsVal.toObject()!)
                }
                callbacks[member] = block
                jsValue.setObject(block, forKeyedSubscript: member as NSString)
            }
        }

    func set(_ name: String, callback: @escaping (Any) -> Void) {
        let block: @convention(block) (JSValue) -> Void = { value in
            callback(value.toObject()!)
        }
        callbacks[name] = block
        jsValue.setObject(block, forKeyedSubscript: name as NSString)
    }
}

final class Tests: XCTestCase {
    func test_increment_callsOnUpdateCallbackWithUpdatedValue() {
        var count = 0
        let vm = JSObject(js: jsSource, key: "ViewModel")
        let e = expectation(description: "Wait for callback")
        vm.onUpdate = { count = $0 as! Int ; e.fulfill() }
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

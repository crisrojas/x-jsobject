import JavaScriptCore
import XCTest

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

    func set(_ callbackName: String, callback: @escaping (Any) -> Void) {
        let block: @convention(block) (JSValue) -> Void = { value in
            callback(value.toObject()!)
        }
        
        callbacks[callbackName] = block
        jsValue.setObject(block, forKeyedSubscript: callbackName as NSString)
    }

    func invoke(_ methodKey: String, args: [Any] = []) {
        _ = jsValue.invokeMethod(methodKey, withArguments: args)
    }
}

final class Tests: XCTestCase {
    func test_increment_callsOnUpdateCallbackWithUpdatedValue() {
        var count = 0
        let object = JSObject(js: jsSource, key: "ViewModel")
        let e = expectation(description: "Wait for callback")
        object.set("onUpdate") { count = $0 as! Int ; e.fulfill() }
        object.invoke("increment")
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

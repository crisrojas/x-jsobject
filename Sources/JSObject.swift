// © 2025  Cristian Felipe Patiño Rojas. Created on 8/5/25.


import JavaScriptCore
import XCTest

@dynamicMemberLookup
public final class JSObject {
    private let context: JSContext
    private let jsValue: JSValue
    private var callbacks = [String: Any]()

   public init(js: String, key: String) {
        self.context = JSContext()!
        context.evaluateScript(js)
        let constructor = context.objectForKeyedSubscript(key)!
        self.jsValue = constructor.construct(withArguments: [])!
    }

    public subscript(dynamicMember member: String) -> (() -> Void) {
        guard jsValue.hasProperty(member) else { return {} }
        return {
            _ = self.jsValue.invokeMethod(member, withArguments: [])
        }
    }

    public subscript<T>(dynamicMember member: String) -> ((T) -> Void)? {
            get { nil }
            set {
                guard let newValue = newValue else { return }
                let block: @convention(block) (JSValue) -> Void = { jsVal in
                    if let jsVal = jsVal.toObject(), let asT = jsVal as? T {
                        newValue(asT)
                    }
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

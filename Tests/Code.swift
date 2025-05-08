import JavaScriptCore
import XCTest


class Tests: XCTestCase {
    struct ViewModel {
        let onUpdate: (Int) -> Void
        
        private let jsContext: JSContext
        private let viewModel: JSValue

        func increment() {
            viewModel.invokeMethod("increment", withArguments: [])
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
        
        init(onUpdate: @escaping (Int) -> Void) {
            self.onUpdate = onUpdate

            let context = JSContext()!
            context.evaluateScript(jsSource)

            let vmConstructor = context.objectForKeyedSubscript("ViewModel")!
            let viewModel = vmConstructor.construct(withArguments: [])!

            let onUpdateBlock: @convention(block) (Int) -> Void = { value in
                onUpdate(value)
            }

            viewModel.setObject(onUpdateBlock, forKeyedSubscript: "onUpdate" as NSString)

            self.jsContext = context
            self.viewModel = viewModel
        }
    }
    
    func test_init_mapsViewModelOnUpateAndIncrementMethod() {
        var count = 0
        
        let e = expectation(description: "Callback triggered")
        let viewModel = ViewModel(
            onUpdate: { count = $0 ; e.fulfill() }
        )
        
        viewModel.increment()
        wait(for: [e], timeout: 1)
        XCTAssertEqual(count, 1)
    }
}

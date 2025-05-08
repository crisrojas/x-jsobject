# JSObject

> Dynamically interact with JavaScript objects from Swift using `JavaScriptCore`.

This was a small exploration into bridging Swift and Javascript through dynamic objects instantiable with js code.

## ✅ What it supports

- Construct JS objects from source code
- Call JS methods as Swift functions
- Assign typed Swift closures to JS object properties (e.g. callbacks)
- Avoid boilerplate with dynamic member lookup

## ✨ Example

### JavaScript

```js
function ViewModel() {
  this.counter = 0;
  this.onUpdate = null;
}

ViewModel.prototype.increment = function () {
  this.counter += 1;
  if (this.onUpdate) this.onUpdate(this.counter);
};
```

### Swift

```swift
let vm = JSObject(js: jsSource, key: "ViewModel")

vm.onUpdate = { (count: Int) in
  print("Updated count:", count)
}

vm.increment() // "Updated count: 1"
```

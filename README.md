# UZImageCollection
Image collection view controller to display images that are specified by URL like Photo.app.

![uzimagecollection](https://cloud.githubusercontent.com/assets/33768/8720260/9977a5b8-2bec-11e5-9560-a296eb2ed12c.gif)

1. Supported animated GIF.
2. Easy to use.
3. Written in Swift.

#### How to use

```
let URLList = [....]
let vc = ImageCollectionViewController.controllerInNavigationController(URLList)
self.presentViewController(vc, animated: true, completion: { () -> Void in })
```

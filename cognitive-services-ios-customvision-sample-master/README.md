---
services: cognitive-services,custom-vision
platforms: swift, iOS
author: Henry Lai, Ng Jin, Qing Hui Yi, Benjamin, Chun Yat
---

# Sample iOS application for models exported from Custom Vision Service
This code is a modified version of the MS vision ML code

## Getting Started

### Prerequisites
- [XCode 9 beta](https://developer.apple.com/support/beta-software/)
- iOS device running [iOS 11 beta](https://support.apple.com/en-us/HT203282#archive)
- An account at [Custom Vision Service](https://www.customvision.ai) 
### Quickstart
1. clone the repository and open the project in XCode
2. [launch your application to your iOS device](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/LaunchingYourApponDevices/LaunchingYourApponDevices.html#//apple_ref/doc/uid/TP40012582-CH27)
### Replacing the sample model with your own classifier 
The model provided with the sample recognizes flowers (Using oxford 120 dataset). to replace it with your own model exported from the [Custom Vision Service](https://www.customvision.ai) do the following, and then build and launch the application:
  1. [Create and train](https://docs.microsoft.com/en-us/azure/cognitive-services/custom-vision-service/getting-started-build-a-classifier) a classifer with the Custom Vision Service. You must choose a "compact" domain such as **General (compact)** to be able to export your classifier. If you have an existing classifier you want to export instead, convert the domain in "settings" by clicking on the gear icon at the top right. In setting, choose a "compact" model, Save, and Train your project.  
  2. Export your model by going to the Performance tab. Select an iteration trained with a compact domain, an "Export" button will appear. Click on *Export* then *iOS* then *Export.* Click the *Download* button when it appears. A *.mlmodel* file will download (you can also do all of this programatically with the [Custom Vision Service Training API](https://southcentralus.dev.cognitive.microsoft.com/docs/services/d9a10a4a5f8549599f1ecafc435119fa/operations/58d5835bc8cb231380095be3).
  3. Drop your *.mlmodel* file into your XCode Project. 
  4. Replace *Fruit.mlmodel* with the name of your model in *ViewController.swift.*

## Resources
- Link to [CoreML documentation](https://developer.apple.com/documentation/coreml)
- Link Apple WWDC videos, samples, and materials for information on [CoreML](https://developer.apple.com/videos/play/wwdc2017/710) and [Vision Framework](https://developer.apple.com/videos/play/wwdc2017/506/)
- Link to [Custom Vision Service Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/custom-vision-service/home)

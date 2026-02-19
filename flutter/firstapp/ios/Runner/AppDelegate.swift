import UIKit
import Flutter
import mesibo
import MesiboCall

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MesiboInitListener, MesiboCallIncomingListener {
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // OPTIONAL - to invoke Mesibo_onInit after initialization to perform additional custom
        // initialization, if requires. For example, call customization, UI customization listener, etc
	// Uncomment, if requires
        // Mesibo.getInstance().addListener(self)
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /* The code below is OPTIONAL for any additional mesibo initialization */
    /* Mesibo_onInit will be called before and after mesibo starts */
    func Mesibo_onInit(started: Bool) {
        if(!started) {
            return;
        }
        MesiboCall.start(with: self, name: nil, icon: nil, callKit: true)
    }
    
    // https://docs.mesibo.com/api/calls/listeners/
    func MesiboCall_OnIncoming(profile: MesiboProfile, video: Bool, waiting: Bool) -> MesiboCallProperties? {
        var cp: MesiboCallProperties = MesiboCall.getInstance().createCallProperties(video);
        // customize callproperties here and return
        cp.user = profile
        
        // OR, return null to reject an incoming call
        return cp;
    }
    
    func MesiboCall_OnShowUserInterface(call: Any?, properties cp: MesiboCallProperties?) -> Bool {
        return false;
    }
    
    func MesiboCall_OnNotify(type: Int32, profile: MesiboProfile, video: Bool) -> Bool {
        return false;
    }
    
    func MesiboCall_OnError(cp: MesiboCallProperties, error: Int32) {
        
    }
}

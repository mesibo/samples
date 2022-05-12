using System;
using mesibo;
using firstapp.iOS;
using Xamarin.Essentials;
using Photos;

[assembly: Xamarin.Forms.Dependency(typeof(mesiboDemo))]
namespace firstapp.iOS
{
    public class mesiboDemo : MesiboDelegate, MesiboInterface
    {
        MesiboCallbacks mCallbacks;
        public mesiboDemo()
        {
        }

        override
        public void Mesibo_OnConnectionStatus(int status)
        {
            mCallbacks.Mesibo_onConnectionStatus(status);

        }

        

        public void sendMessage(string destination, string message)
        {
            MesiboProfile profile = mesibo.Mesibo.getInstance().GetProfile(destination, 0);
            profile.SendMessage(Mesibo.getInstance().Random(), "Hello, from Xamarin");

        }

        public void showMainWindow()
        {
            MesiboUI.LaunchMesiboUIViewController(Platform.GetCurrentUIViewController(), null, true);
            
        }

        public void showMessageWindow(string destination)
        {
            MesiboProfile profile = mesibo.Mesibo.getInstance().GetProfile(destination, 0);

            MesiboUI.LaunchMessageViewControllerWithNavigation(Platform.GetCurrentUIViewController(), profile, null);

        }

        public void start(string token, MesiboCallbacks callbacks)
        {
            mCallbacks = callbacks;
            Mesibo.getInstance().SetAccessToken(token);
            Mesibo.getInstance().SetDatabase("mesibo", 0);
            Mesibo.getInstance().AddListener(this);
            Mesibo.getInstance().Start();
            MesiboCall.StartWith(null, "mesibo", null, true);
        }

        public void audioCall(string destination)
        {
            MesiboProfile profile = mesibo.Mesibo.getInstance().GetProfile(destination, 0);
            mesibo.MesiboCall.getInstance().CallUi(Platform.GetCurrentUIViewController(), destination, false);
        }

        public void videoCall(string destination)
        {
            MesiboProfile profile = mesibo.Mesibo.getInstance().GetProfile(destination, 0);
            mesibo.MesiboCall.getInstance().CallUi(Platform.GetCurrentUIViewController(), destination, true);
        }
    }
}

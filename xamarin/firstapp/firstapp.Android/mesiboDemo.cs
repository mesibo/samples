using System;
using Com.Mesibo.Api;

using Com.Mesibo.Messaging;
using Com.Mesibo.Calls.Api;


using firstapp.Droid;
using Xamarin.Essentials;

[assembly: Xamarin.Forms.Dependency(typeof(mesibo))]
namespace firstapp.Droid
{
    public class mesibo : Java.Lang.Object, MesiboInterface, Mesibo.IConnectionListener, Mesibo.IMessageListener
    {
        MesiboCallbacks mCallbacks;
        public mesibo()
        {
        }

        public void Mesibo_onActivity(Mesibo.MessageParams p0, int p1)
        {
        }

        public void Mesibo_onConnectionStatus(int status)
        {
            mCallbacks.Mesibo_onConnectionStatus(status);
        }

        public void Mesibo_onFile(Mesibo.MessageParams p0, Mesibo.FileInfo p1)
        {
        }

        public void Mesibo_onLocation(Mesibo.MessageParams p0, Mesibo.Location p1)
        {
        }

        public bool Mesibo_onMessage(Mesibo.MessageParams p0, byte[] p1)
        {
            return true;
        }

        public void Mesibo_onMessageStatus(Mesibo.MessageParams p0)
        {
            
        }

        public void start(String token, MesiboCallbacks callbacks)
        {
            mCallbacks = callbacks;

            Mesibo.InitEx(Android.App.Application.Context);
            Mesibo.SetAccessToken(token);
            Mesibo.SetDatabase("mesibo", 0);
            Mesibo.Start();

            Mesibo.AddListener(this);

            MesiboCall.Instance.Init(Android.App.Application.Context);
            
        }

        public void sendMessage(String destination, String message)
        {
            MesiboProfile profile = Mesibo.GetProfile(destination);
            profile.SendMessage(Mesibo.Random(), message);
        }

        public void showMainWindow()
        {
            MesiboUI.Launch(Platform.CurrentActivity, 0, false, false);
        }

        public void showMessageWindow(String destination)
        {
            MesiboUI.LaunchMessageView(Platform.CurrentActivity, destination, 0);
        }

        public void audioCall(String destination)
        {
            MesiboProfile profile = Mesibo.GetProfile(destination);
            MesiboCall.Instance.CallUi(Platform.CurrentActivity, destination, false);

        }

        public void videoCall(String destination)
        {
            MesiboProfile profile = Mesibo.GetProfile(destination);
            MesiboCall.Instance.CallUi(Platform.CurrentActivity, destination, true);

        }

    }
}

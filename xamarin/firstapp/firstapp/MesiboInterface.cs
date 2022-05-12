using System;

// https://www.codemag.com/article/1707071/Accessing-Platform-Specific-Functionalities-Using-DependencyService-in-Xamarin.Forms
namespace firstapp
{
    public interface MesiboCallbacks
    {
        void Mesibo_onConnectionStatus(int status);
    }

    public interface MesiboInterface
    {
        void start(String token, MesiboCallbacks callbacks);
        void sendMessage(String destination, String message);
        void showMainWindow();
        void showMessageWindow(String destination);
        void audioCall(String destination);
        void videoCall(String destination);
    }

    
}

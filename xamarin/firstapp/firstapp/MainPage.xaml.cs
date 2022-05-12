using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;

namespace firstapp
{
    public partial class MainPage : ContentPage, MesiboCallbacks
    {
        private string connStatusString = "Login to start";
        private String destination = "";
        private Boolean online = false;


        /* Refer to the tutorial to learn about users and token
         * https://mesibo.com/documentation/tutorials/get-started/
         * 
         * Create token for com.mesibo.firstapp using above tutorial and us here
         */
        private String user1 = "abc";
        private String token1 = "<Refer to the tuorial to learn how to generate tokens>";

        private String user2 = "xyz";
        private String token2 = "<Refer to the tuorial to learn how to generate tokens>";


        public string connStatusProperty
        {
            get {
                return connStatusString;
            }
            set
            {
                connStatusString = value;
                OnPropertyChanged(nameof(connStatusProperty)); 
            }
        }

        public MainPage()
        {
            InitializeComponent();
            BindingContext = this;

            enableButtons(false);


            //audioCallBut
        }

        void enableButtons(bool enabled)
        {
            //audioCallButton.IsEnabled = enabled;
            //videoCallButton.IsEnabled = enabled;
        }

        public void Mesibo_onConnectionStatus(int status)
        {
            //connStatusString = 
            statusLabel.Text = "Connection Status: " + status; ;
            if (1 == status) {
                online = true;
                //enableButtons(true);
            }
        }

        bool isOnline()
        {
            if (online) return true;
            DisplayAlert("Not Logged-In", "You should login first. If you have logged in but not online, check the token and the app id", "OK");
            return false;

        }

        void login(String token, String dest)
        {
            destination = dest;
            DependencyService.Get<MesiboInterface>().start(token, this);
            loginButton1.IsEnabled = false;
            loginButton2.IsEnabled = false;
        }
        

        void OnLoginUser1(System.Object sender, System.EventArgs e)
        {

            // for user1, the user2 is destination and vise versa
            login(token1, user2);
        }

        void OnLoginUser2(System.Object sender, System.EventArgs e)
        {
            login(token2, user1);
        }

        void OnMessage(System.Object sender, System.EventArgs e)
        {
            if (!isOnline()) return;
            DependencyService.Get<MesiboInterface>().showMessageWindow(destination);
        }


        void OnUserList(System.Object sender, System.EventArgs e)
        {
            if (!isOnline()) return;
            DependencyService.Get<MesiboInterface>().showMainWindow();
        }

        void OnAudioCall(System.Object sender, System.EventArgs e)
        {
            if (!isOnline()) return;
            DependencyService.Get<MesiboInterface>().audioCall(destination);
        }


        void OnVideoCall(System.Object sender, System.EventArgs e)
        {
            if (!isOnline()) return;
            DependencyService.Get<MesiboInterface>().videoCall(destination);
        }

       
    }
}

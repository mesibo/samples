import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  TextInput,
  NativeAppEventEmitter
} from 'react-native';


import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';


const Stack = createStackNavigator();

import { NativeModules, Button } from 'react-native';
const {MesiboModule} = NativeModules;

console.log(MesiboModule);

//See https://mesibo.com/documentation/tutorials/get-started/ to learn about creating users for your app
var mUser1 = {
  token: "xxx",
  name: "User-1",
  address: "react_user_1",
};
var mUser2 = {
  token: "xxx",
  name: "User-2",
  address: "react_user_2",
};


MesiboModule.setUser1(mUser1.token, mUser1.name, mUser1.address);
MesiboModule.setUser2(mUser2.token, mUser2.name, mUser2.address);

class HomeScreen extends React.Component{
	  constructor(props) {
		  super(props);
		  this.state = {cState: "", mState: "", mText:"", loggedIn: false};
		  NativeAppEventEmitter.addListener("mesiboListener", (p)=>{
			  console.log("==>MesiboListner: ", p);
			  if(p.event == "onConnectionStatus"){
				      this.setState({
					      cState: p.value 
				      });

			  }
			  if(p.event == "onMessageStatus"){
				      this.setState({
					      mState: p.value 
				      });

			  }

			  console.log(this.state);
		  });

	  }
	render(){
		return (<>
			<View style={{ flexDirection: "row" }}>
			<View style={styles.buttonStyle}>
			<Button
			color="#00868b"
			onPress={() => {
				console.log("Connect User1");
				MesiboModule.onLoginUser1();
				this.setState({
					loggedIn: true 
				});
			}}
			title="LOGIN AS USER1"
			/>
			</View>
			<View style={styles.buttonStyle}>
			<Button
			color="#00868b"
			onPress={() => {
				console.log("Connect User2");
				MesiboModule.onLoginUser2();
				this.setState({
					loggedIn: true 
				});
			}}
			title="LOGIN AS USER2"
			/>
			</View>
			</View>

			<View style={{alignItems: 'center', marginBottom: 10}}>
			<Text>Connection Status: {this.state.cState}</Text>
			</View>
			
			<View style={{ padding: 15 ,flexDirection: "row", justifyContent: 'center'}}>
			<TextInput
			style = {{ flex: 1 }}
			underlineColorAndroid={'rgb(0,0,0)'} 
			ref={input => { this.textInput = input }}
			placeholder="Type a message!"
			onChangeText={text => this.setState({ mText: text})}
			/>
			<View>
			<Button
			color="#00868b"
			disabled={!this.state.loggedIn}
			onPress={() => {
				console.log(this.state.mText);
				if(!this.state.mText)
					return;
				this.setState({
					mState: 0 
				});
				MesiboModule.onSendMessage(this.state.mText);
				this.textInput.clear();
			}}
			title="Send"
			/>
			</View>
			</View>

			<View style={{alignItems: 'center', marginBottom: 10}}>
			<Text>Message Status: {this.state.mState}</Text>
			</View>
			<View style={styles.buttonContainer}>
			<Button
			color="#00868b"
			disabled={!this.state.loggedIn}
			onPress={() => {
				MesiboModule.onLaunchMessagingUi();
			}}
			title="Launch MESSAGE UI"
			/>
			</View>
			
			<View style={styles.buttonContainer}>
			<Button
			color="#00868b"
			disabled={!this.state.loggedIn}
			onPress={() => {
				MesiboModule.onAudioCall();
			}}
			title="AUDIO CALL"
			/>
			</View>

			<View style={styles.buttonContainer}>
			<Button
			color="#00868b"
			onPress={() => {
				MesiboModule.onVideoCall();
			}}
			disabled={!this.state.loggedIn}
			title="VIDEO CALL"
			/>
			</View>
			
			
			</>
		);
	}
}

function App() {
  return (
	  <NavigationContainer>
	  <Stack.Navigator>
	  <Stack.Screen
	  name="Home"
	  component={HomeScreen}
	  options={{
		  title: 'First Mesibo App',
			  //headerTintColor: 'white',
			  //headerStyle: { backgroundColor: '#6200EE' },
	  }}
	  />
	  </Stack.Navigator>
	  </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  buttonContainer: {
    alignItems: 'baseline', 
    marginTop: 5,
    marginBottom: 5,
    marginLeft: 10
  },
  
  buttonStyle: {
    flex: 1, 
    marginLeft: 10,
    marginRight: 10,
    marginTop: 10,
    marginBottom: 10,
  },
  
  actionButton: {
	  backgroundColor:'#1E6738'
  } 
}
);

export default App;

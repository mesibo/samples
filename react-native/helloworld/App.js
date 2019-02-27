/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 * @lint-ignore-every XPLATJSCOPYRIGHT1
 */

import React, {Component} from 'react';
import {Alert, Button, AppRegistry, Platform, StyleSheet, Text, View} from 'react-native';
import MesiboModule from './MesiboModule';

// Refer to https://mesibo.com/documentation/ to generate token
const mesiboToken = "Mesibo Token - Generate Your Own";
const mesiboDestination = "Destination User";

MesiboModule.init(mesiboToken);

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};
export default class App extends Component<Props> {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to Mesibo!</Text>
        <Text style={styles.instructions}>Ensure that the Storage permission is granted</Text>
	
	<View style={styles.buttonContainer}>
	<Button
  		onPress={() => {
			MesiboModule.sendMessage(mesiboDestination, "Hello From React Native");
	        }}
  	   	title="Send a Message" 
	/>
	</View>
	

	<Button
  		onPress={() => {
		MesiboModule.launchUi(mesiboDestination);
	        }}
  	   	title="Launch UI" 
	/>

      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  buttonContainer: {
    margin: 20
  },

  alternativeLayoutButtonContainer: {
    margin: 20,
    flexDirection: 'row',
    justifyContent: 'space-between'
  }
});

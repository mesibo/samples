/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
	// Application Constructor
	initialize: function() {
		this.bindEvents();
	},
	// Bind Event Listeners
	//
	// Bind any events that are required on startup. Common events are:
	// 'load', 'deviceready', 'offline', and 'online'.
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	// deviceready Event Handler
	//
	// The scope of 'this' is the event. In order to call the 'receivedEvent'
	// function, we must explicitly call 'app.receivedEvent(...);'
	onDeviceReady: function() {
		//app.receivedEvent('deviceready');
		app.permissions = cordova.plugins.permissions;
		console.log(app.permissions);
		app.camPerm();
		app.micPerm();
		app.audioPerm();
	},

	// Update DOM on a Received Event
	receivedEvent: function(id) {
		var parentElement = document.getElementById(id);
		var listeningElement = parentElement.querySelector('.listening');
		var receivedElement = parentElement.querySelector('.received');

		listeningElement.setAttribute('style', 'display:none;');
		receivedElement.setAttribute('style', 'display:block;');

		console.log('Received Event: ' + id);
	},
	camPerm: function () {
		cordova.plugins.permissions.checkPermission("android.permission.CAMERA", function (status) {
			console.log('success checking permission');
			console.log('Has CAMERA:', status.hasPermission);
			if (!status.hasPermission) {
				app.permissions.requestPermission("android.permission.CAMERA", function (status) {
					console.log('success requesting CAMERA permission');
				}, function (err) {
					console.log('failed to set permission');
				});
			}
		}, function (err) {
			console.log(err);
		});
	},
	micPerm: function () {
		cordova.plugins.permissions.checkPermission("android.permission.RECORD_AUDIO", function (status) {
			console.log('success checking permission');
			console.log('Has RECORD_AUDIO:', status.hasPermission);
			if (!status.hasPermission) {
				app.permissions.requestPermission("android.permission.RECORD_AUDIO", function (status) {
					console.log('success requesting MIC permission');
				}, function (err) {
					console.log('failed to set permission');
				});
			}
		}, function (err) {
			console.log(err);
		});
	},

	audioPerm: function () {
		cordova.plugins.permissions.checkPermission("android.permission.MODIFY_AUDIO_SETTINGS", function (status) {
			console.log('success checking permission');
			console.log('Has MODIFY_AUDIO_SETTINGS:', status.hasPermission);
			if (!status.hasPermission) {
				app.permissions.requestPermission("android.permission.MODIFY_AUDIO_SETTINGS", function (status) {
					console.log('success requesting permission');
				}, function (err) {
					console.log('failed to set permission');
				});
			}
		}, function (err) {
			console.log(err);
		});
	}

};

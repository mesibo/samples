import { Component } from '@angular/core';
import { mesibo_init } from '../assets/js/mesibo.js';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
  })

  
export class AppComponent {
title = 'first mesibo app';
constructor() { }

ngOnInit() {
	mesibo_init('<token>', "<appid>", this);
}

ngOnDestroy() {
}

Mesibo_onConnectionStatus(status, value) {
	console.log("Mesibo_onConnectionStatus: "  + status);
}

Mesibo_onMessageStatus = function(m) {
        console.log("Mesibo_onMessageStatus: from "  + m.peer + " status: " + m.status + " id: " + m.mid);
}

Mesibo_onMessage = function(m) {
        console.log("Mesibo_onMessage: from "  + m.peer + " id: " + m.mid + " msg: " + m.message);
}


}

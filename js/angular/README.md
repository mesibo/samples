# mesibo first app using Angular 13

## Prerequisites
Please run the [basic javascript demo](https://mesibo.com/documentation/tutorials/get-started/javascript/) before using mesibo in Angular code. 

## Code Description 

### index.html
Add following to the `<head>` section of the `index.html` 

```
<script src="https://api.mesibo.com/mesibo-v2.js"></script>
```

You may also want to add the following line to the `index.html` if you are getting errors related to `exports`

```
 <script> var exports = {}; </script>
```

### assets/js/mesibo.js
mesibo specific javascript code is in `assets/js/mesibo.js`. 

### angular.json
Edit `angular.json` and add the reference to `mesibo.js` as shown below

```
"scripts": [
              "src/assets/js/mesibo.js"
            ]

```

### src/app/app.component.ts
Now edit 'src/app/app.component.ts' and add following imports

```
import { mesibo_init } from '../assets/js/mesibo.js';
```

You need to also implement mesibo listener functions and then call `mesibo_init` from `ngOnInit`

That's it!

## Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The application will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via a platform of your choice. To use this command, you need to first add a package that implements end-to-end testing capabilities.

## Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI Overview and Command Reference](https://angular.io/cli) page.

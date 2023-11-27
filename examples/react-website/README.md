# React website example

This is a [ReactApp](https://www.winglang.io/docs/standard-library/ex/react-app) example. 

Notice that `./website` is a basic react website, the only file we changed is `/src/app.js` (to include `wing.js`) 

## Dev mode

`wing run examples/react-website/main.w`

The command above will open both the simulator and react dev app on the browser.

Try to make some changes to the wing file and watch the react file changes!

## Run on simulator when react is in dev mode

`wing test examples/react-website/main.w`

Done developing, let's build the website, still on the simulator:

## Run on simulator when react is in build mode

1. Add `useBuildCommand: true` to line 18
2. run:
`wing run examples/react-website/main.w`

## Build on tf-aws

Now, let's test it on tf-aws platform:

`wing test -t tf-aws examples/react-website/main.w`

Great! Everything is working, now let's deploy to AWS:

`wing compile -t tf-aws examples/react-website/main.w`

then go to the `examples/react-website/target/main.tfaws` folder, and run:
`terraform init`

and
`terraform apply`

### welcome to the react website example

Inside of the `./website` folder you can find a basic react website.
The only file we changed is `/src/app.js` - to demonstrate how the information created in wing can be used in the website.

To start developing:
`wing run examples/react-website/main.w`
The command above will open both the simulator and react dev app on the browser.

- Try to make some changes to the wing file and watch the react file changes!

Now, let's test on the sim platform:

`wing test examples/react-website/main.w`

Done developing, let's build the website, still on the simulator:

Add `useBuildCommand: true` to line 18

and run:
`wing run examples/react-website/main.w`
or
`wing test examples/react-website/main.w`

Now, let's test it on tf-aws platform:

`wing test -t tf-aws examples/react-website/main.w`

Great! Everything is working, now let's deploy to AWS:

`wing compile -t tf-aws examples/react-website/main.w`

then go to the `examples/react-website/target/main.tfaws` folder, and run:
`terraform init`

and
`terraform apply`

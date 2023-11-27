import logo from "./logo.svg";
import "./App.css";

function App() {
  console.log(window.wingEnv);
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>Hey! the api url is {window.wingEnv["REACT_APP_SERVER_URL"]}</p>
        <p>And the wing env is {JSON.stringify(window.wingEnv, null, 2)}</p>
      </header>
    </div>
  );
}

export default App;

import axios from "../helpers/axios-instance";
import { Fragment, useState, useRef, useContext } from "react";

import style from "../UI/Login.module.css";
import styleInp from "../UI/Input.module.css";
import Logo from "../assets/img/logo.png";

import AuthContext from "../store/auth-context";

const isIE = /*@cc_on!@*/ false || !!document.documentMode;

const Login = (props) => {
  const usernameRef = useRef();
  const passwordRef = useRef();

  const authCtx = useContext(AuthContext);

  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  const loginHandler = (event) => {
    event.preventDefault();

    const username = usernameRef.current.value;
    const password = passwordRef.current.value;
      console.log(process.env.PUBLIC_URL + "/api")
    if (username === "" || password === "") {
      setError("Please enter username and password");
    } else {
      setError(null);
      setIsLoading(true);
      axios
      // .post("/account/login ", {
        .post("/account/login-ldap", {
      //  .post("/account/login", { 
          username,
          password,
        })
        .then(function (response) {
          setIsLoading(false);
         
          authCtx.login(response.data);
          axios.defaults.headers.common[
            "Authorization"
          ] = `Bearer ${response.data}`;
        })
        .catch(function (error) {
          setIsLoading(false);
          setError(error.response.data);
        });
    }
  };

  return (
    <Fragment>
      {isIE && (
        <div className={style["login-bg"]}>
          <img src={Logo} alt="MAAG GALA" />
          <p>
            This application uses features that{" "}
            <strong>Internet Explorer</strong> does not support.
          </p>
          <p>
            Please use a modern browser such as:
            <br />
            Google Chrome, <br />
            MS Edge or <br />
            Firefox.
          </p>
        </div>
      )}
      {!isIE && (
        <main className={style["login-bg"]}>
          <img src={Logo} className={style["dd-logo"]} alt="MAAG GALA" />
          <p className={style["dd-title"]}>Digital Documentation</p>
          <form onSubmit={loginHandler}>
            <input
              className={`${styleInp.inp} ${styleInp.inline}`}
              placeholder="Username"
              autoComplete="username"
              style={{ textAlign: "center", marginBottom: "10px" }}
              ref={usernameRef}
            />
            <br />
            <input
              className={`${styleInp.inp} ${styleInp.inline}`}
              placeholder="Password"
              type="password"
              autoComplete="current-password"
              style={{ textAlign: "center", marginBottom: "10px" }}
              ref={passwordRef}
            />
            <br />
            <button className={styleInp.btn}>
              {!isLoading && <span className="icon-login"> Login</span>}
              {isLoading && <span>Logging in...</span>}
            </button>
            {error && <p className={style.error}>{error}</p>}
          </form>
        </main>
      )}
    </Fragment>
  );
};

export default Login;

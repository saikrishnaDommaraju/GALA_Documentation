import styles from "./Help.module.css";

const Login = () => {
  return (
    <div className={styles.docdiv}>
      <h3>Login Documentation</h3>
      <p>
        <strong>Introduction</strong>
      </p>
      <p>
        The Technical Document Viewer is an easy to use web application to view
        the Technical documentation items such as report and drawings. <br />
        It is also integrated with other features such as checking of the
        completed items as well as filling out CheckSheets.
      </p>
      <br />
      <p>
        <strong>Logging in</strong>
      </p>
      <p>
        On the Login page enter your email and password and click the Login
        button. This will log you into the main page of the application. The
        login is the same as that of the Dover account credentials.
      </p>
      <p>
        The Administrator will be able to provide access to you. Clicking on the
        Contact link in the footer will provide information about who to
        contact, to get your login details.
      </p>
    </div>
  );
};

export default Login;

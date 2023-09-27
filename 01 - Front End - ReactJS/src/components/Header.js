import { Fragment, useContext, useState, useEffect, useCallback } from "react";

import { Link, useNavigate } from "react-router-dom";
import fs from "fscreen";
import SelectSearch from "react-select";

import styles from "./Header.module.css";
import logo from "../assets/img/logo_s.png";

import AuthContext from "../store/auth-context";
import axios from "../helpers/axios-instance";
import AlertBar from "../UI/AlertBar";

import { pgMap } from "../pages/Admin/Admin";

const Header = (props) => {
  const navigate = useNavigate();
  const authCtx = useContext(AuthContext);
  const { setProj, onFSHandler, isFS, rendered, setRendered } = props;
  const [projList, setProjList] = useState([]);
  const [alertBar, setAlertBar] = useState("");

  //Decide the Admin page to route to if the user is an admin
  let adminPage = "";
  if (authCtx.userData.Admin) {
    let adminPageI = 1001;
    if (authCtx.userData.role !== "Admin") {
      adminPageI = authCtx.userData.Admin.split(",").map(Number)[0];
    }
    adminPage = pgMap[adminPageI][0];
  }

  const submitProjHandler = (proj) => {
    setProj(proj.value);
    navigate("/", { replace: true });

    //Get the notes from the server.
    axios.get("/projects/notes/" + proj.value).then((response) => {
      if (response.data !== "" && response.data !== null) {
        setAlertBar(response.data);
        document.querySelector(":root").style.setProperty("--bottom", "30px");
      } else {
        setAlertBar("");
        document.querySelector(":root").style.setProperty("--bottom", "0px");
      }
    });
  };

  const logoutHandler = useCallback(() => {
    setProj("");
    onFSHandler(true);
    authCtx.logout();
    navigate("/", { replace: true });
    window.location.reload();
  }, [setProj, onFSHandler, authCtx, navigate]);

  useEffect(() => {
    if (rendered) {
      return;
    }

    axios
      .get("/account/validate")
      .then(() => {
        axios
          .get("/projects/list")
          .then((response) => {
            const pList = response.data;
            let options = [];
            for (let i = 0; i < pList.length; i++) {
              options.push({
                label: pList[i].projectNo + " - " + pList[i].projectName,
                value: pList[i].projectNo,
              });
            }
            setProjList(options);
            setRendered(true);
          })
          .catch((error) => alert(error.message.data));
      })
      .catch(() => {
        logoutHandler();
      });
  }, [logoutHandler, rendered, setRendered]);

  const dismissAlertHandler = () => {
    setAlertBar("");
    document.querySelector(":root").style.setProperty("--bottom", "0px");
  };

  return (
    <Fragment>
      <header className={styles.header}>
        <img src={logo} className={styles.header_img} alt="MAAG GALA" /> &nbsp;
        <div className={styles["nav-left"]}>
          <SelectSearch
            options={projList}
            name="language"
            placeholder="Select Project"
            onChange={submitProjHandler}
          />
        </div>
        <div className={styles["nav-right"]}>
          {fs.fullscreenEnabled && (
            <span
              className={styles["nav-item"]}
              onClick={() => onFSHandler(false)}
            >
              <span
                className={isFS ? "icon-resize-normal" : "icon-resize-full"}
                title="Full Screen"
              ></span>
            </span>
          )}
          {authCtx.userData && authCtx.userData.Admin && (
            <Fragment>
              <Link to="/" className={styles["nav-item"]} title="Home">
                <span className="icon-home"></span>
              </Link>
              <Link
                to={"/admin/" + adminPage}
                className={styles["nav-item"]}
                title="Admin"
              >
                <span className="icon-admin"></span>
              </Link>
            </Fragment>
          )}
          <span
            style={{ cursor: "pointer" }}
            className={`${styles["nav-item"]} icon-logout`}
            title="Logout"
            onClick={logoutHandler}
          ></span>
        </div>
        <div className="clear"></div>
      </header>
      {alertBar !== "" && (
        <AlertBar dismissAlert={dismissAlertHandler}>{alertBar}</AlertBar>
      )}
    </Fragment>
  );
};

export default Header;

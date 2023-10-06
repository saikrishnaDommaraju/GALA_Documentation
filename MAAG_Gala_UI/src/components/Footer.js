import React, { Fragment, useEffect, useState, useContext } from "react";
import { useLocation } from "react-router-dom";
import styles from "./Footer.module.css";
import Modal from "../UI/Modal";
import axios from "../helpers/axios-instance";
import AuthContext from "../store/auth-context";

const Footer = () => {
  const authCtx = useContext(AuthContext);
  const [contactModal, setContactModal] = useState(false);
  const [contact, setContact] = useState({ __html: "" });

  const location = useLocation();

  const contactToggleHandler = () => setContactModal((prev) => !prev);

  const helpClickHandler = () => {
    console.log(location.pathname);
    if (location.pathname === "/") {
      if (authCtx.isLoggedIn) {
        window.open(process.env.PUBLIC_URL + "/help/main", "_blank", "noopener,noreferrer");
      } else {
        window.open(process.env.PUBLIC_URL + "/help/login", "_blank", "noopener,noreferrer");
      }
    } else if (location.pathname.indexOf("admin") > -1) {
      window.open(process.env.PUBLIC_URL + "/help/admin", "_blank", "noopener,noreferrer");
    }
  };

  useEffect(() => {
    axios.get("/users/contact").then((response) => {
      setContact({ __html: response.data });
    });
  }, []);

  return (
    <Fragment>
      <footer className={styles.footer}>
        <div className={styles["footer-left"]}>
          <span onClick={helpClickHandler} style={{ cursor: "pointer" }}>
            Help
          </span>{" "}
          |{" "}
          <span onClick={contactToggleHandler} style={{ cursor: "pointer" }}>
            Contact Us
          </span>
        </div>
        <div className={styles["footer-right"]}>
          Built by <strong>Dover India Innovation Center</strong>
        </div>
        <div className="clear"></div>
      </footer>
      {contactModal && (
        <Modal onClose={contactToggleHandler}>
          <strong style={{ fontSize: "15px" }}>Contact Us</strong>
          <p>For information, help or feature requests, please contact:</p>
          <p dangerouslySetInnerHTML={contact}></p>
        </Modal>
      )}
    </Fragment>
  );
};

export default React.memo(Footer);

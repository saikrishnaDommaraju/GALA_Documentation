import { Fragment } from "react";
import { Route, Routes } from "react-router-dom";

import LoginHelp from "./help/Login";
import MainHelp from "./help/Main";
import AdminHelp from "./help/Admin";

import styleHead from "./components/Header.module.css";
import styleFoot from "./components/Footer.module.css";
import logo from "./assets/img/logo_s.png";

function Help() {
  return (
    <Fragment>
      <header className={styleHead.header}>
        <img src={logo} className={styleHead.header_img} alt="MAAG GALA" />{" "}
        &nbsp;
        <div
          className={styleHead["nav-left"]}
          style={{ fontSize: "20px", fontWeight: "bold", marginTop: "12px" }}
        >
          Documentation
        </div>
        <div className="clear"></div>
      </header>
      <main style={{ padding: "15px" }}>
        <Routes>
          <Route path="/login" element={<LoginHelp />} />
          <Route path="/main" element={<MainHelp />} />
          <Route path="/admin" element={<AdminHelp />} />
        </Routes>
      </main>
      <footer className={styleFoot.footer}>
        <div className={styleFoot["footer-right"]}>
          Built by <strong>Dover India Innovation Center</strong>
        </div>
        <div className="clear"></div>
      </footer>
    </Fragment>
  );
}

export default Help;

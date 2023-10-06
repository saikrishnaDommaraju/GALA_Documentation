import React, { useState, useContext } from "react";
import { Link } from "react-router-dom";
import { Route, Routes } from "react-router-dom";

import SideBar from "../../components/SideBar";
import styleSB from "../../components/SideBar.module.css";

import Users from "./Users";
import Projects from "./Projects";
import ProjectArchive from "./ProjectArchive";
import WorkCenters from "./WorkCenters";
import Roles from "./Roles";
import Checklist from "./Checklist";
import Contact from "./Contact";

import AuthContext from "../../store/auth-context";

export const pgMap = {
  1001: ["users", "Users"],
  1002: ["roles", "Roles"],
  1003: ["projects", "Projects"],
  1004: ["project_archive", "Project Archive"],
  1005: ["workcenters", "Work Centers"],
  1006: ["checksheets", "CheckSheets"],
  1007: ["contact", "Contact Us"],
};

const Admin = () => {
  const [sidebar1Open, setSidebar1Open] = useState("-open");

  const authCtx = useContext(AuthContext);
  let pageAccess = Object.keys(pgMap);
  if (authCtx.userData.role !== "Admin") {
    pageAccess = authCtx.userData.Admin.split(",").map(Number);
  }

  const toggleSideBar1Handler = () => {
    setSidebar1Open((prevState) => {
      if (prevState === "-open") {
        return "-closed";
      } else if (prevState === "-closed") {
        return "-open";
      }
    });
    return false;
  };

  return (
    <main style={{ display: "flex" }}>
      <SideBar
        sbType="sidebar1"
        sbState={sidebar1Open}
        sideBarHandler={toggleSideBar1Handler}
      >
        {authCtx.userData &&
          pageAccess.map((k) => (
            <Link
              key={"ad-" + k}
              className={`${styleSB["nav-link"]} ${styleSB["nav-link-drw"]}`}
              to={`/admin/${pgMap[k][0]}`}
            >
              {pgMap[k][1]}
            </Link>
          ))}
      </SideBar>
      <div
        style={{
          float: "left",
          height: "84vh",
          flexGrow: 1,
        }}
      >
        {authCtx.userData && (
          <Routes>
            {(authCtx.userData.role === "Admin" ||
              pageAccess.includes(1001)) && (
              <Route path="users" element={<Users />} />
            )}
            {(authCtx.userData.role === "Admin" ||
              pageAccess.includes(1002)) && (
              <Route path="roles" element={<Roles />} />
            )}
            {(authCtx.userData.role === "Admin" ||
              pageAccess.includes(1003)) && (
              <Route path="projects" element={<Projects />} />
            )}
            {(authCtx.userData.role === "Admin" ||
              pageAccess.includes(1004)) && (
              <Route path="project_archive" element={<ProjectArchive />} />
            )}
            {(authCtx.userData.role === "Admin" ||
              pageAccess.includes(1005)) && (
              <Route path="workcenters" element={<WorkCenters />} />
            )}
            {(authCtx.userData.role === "Admin" ||
              pageAccess.includes(1006)) && (
              <Route path="checksheets" element={<Checklist />} />
            )}
            {(authCtx.userData.role === "Admin" ||
              pageAccess.includes(1007)) && (
              <Route path="contact" element={<Contact />} />
            )}
          </Routes>
        )}
      </div>
    </main>
  );
};

export default Admin;

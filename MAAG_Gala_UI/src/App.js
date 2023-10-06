import React, { Fragment, useContext, useState, Suspense } from "react";
import { Route, Routes } from "react-router-dom";
import fs from "fscreen";

import "./assets/fonts/fontello.css";

import Login from "./pages/Login";
import Home from "./pages/Home";

import Footer from "./components/Footer";

import AuthContext from "./store/auth-context";

const Admin = React.lazy(() => import("./pages/Admin/Admin"));
const Header = React.lazy(() => import("./components/Header"));

function App() {
  const authCtx = useContext(AuthContext);
  const [projNo, setProjNo] = useState("");
  const [isFS, setFS] = useState(false);

  //This state is to ensure that the header effect runs only once
  const [hRendered, setHRendered] = useState(false); 

  const setProjectHandler = (projNo) => {
    setProjNo(projNo);
  };

  const onFSHandler = (logout) => {
    if (logout) {
      if (fs.fullscreenElement === document.body) {
        setFS(false);
        fs.exitFullscreen();
      }
      return;
    }

    if (fs.fullscreenElement === document.body) {
      setFS(false);
      fs.exitFullscreen();
    } else {
      setFS(true);
      fs.requestFullscreen(document.body);
    }
  };

  return (
    <div>
      {!authCtx.isLoggedIn && <Login />}
      {authCtx.isLoggedIn && (
        <Fragment>
          <Header
            setProj={setProjectHandler}
            onFSHandler={onFSHandler}
            isFS={isFS}
            rendered={hRendered}
            setRendered={setHRendered}
          />
          <Suspense
            fallback={
              <p>
                <span className="icon-wait"></span>Loading ...
              </p>
            }
          >
            <Routes>
              <Route
                path="/"
                element={<Home projNo={projNo} setProj={setProjectHandler} />}
              />
              <Route path="/admin/*" element={<Admin />} />
            </Routes>
          </Suspense>
        </Fragment>
      )}
      <Footer />
    </div>
  );
}

export default App;

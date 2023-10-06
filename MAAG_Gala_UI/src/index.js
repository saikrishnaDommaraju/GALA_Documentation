import React from "react";
import ReactDOM from "react-dom/client";
import { Route, Routes, BrowserRouter } from "react-router-dom";
import { AuthContextProvider } from "./store/auth-context";

import "./index.css";
import App from "./App";

const Help = React.lazy(() => import("./Help"));

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <AuthContextProvider>
    <BrowserRouter basename={process.env.PUBLIC_URL}>
      <Routes>
        <Route path="/*" element={<App />} />
        <Route path="/help/*" element={<Help />} />
      </Routes>
    </BrowserRouter>
  </AuthContextProvider>
);

//</React.StrictMode>

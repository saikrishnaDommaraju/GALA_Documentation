import React, { Fragment } from "react";
import styleSB from "../components/SideBar.module.css";

const SideBar1 = (props) => {

  return (
    <Fragment>
      {!props.list && (
        <div className={styleSB.noProj}>
          Please select the <br />
          <br />
          <strong>Project Number</strong>
        </div>
      )}
      {props.list && (
        <Fragment>
          {props.list
            .filter((item) => item.type !== "CHECK" && item.type !== "FILES")
            .map((lItem) => (
              <Fragment key={"list-" + lItem.type}>
                <div className={styleSB["nav-section"]}>{lItem.name}</div>
                {lItem.pdfList.map((item) => (
                  <span
                    className={`${styleSB["nav-link"]} 
                  ${props.active === item.id ? styleSB.active : ""} 
                  ${item.jobState === "F" ? styleSB.disabled : ""} 
                  ${item.jobState === "C" ? styleSB.complete : ""}`}
                    key={"job-" + item.id}
                    onClick={
                      item.jobState !== "F"
                        ? () => {
                            props.loadList(lItem.type, item.id);
                          }
                        : undefined
                    }
                  >
                    {lItem.type === "CUT" ? (
                      item.name
                    ) : (
                      <Fragment>
                        {item.name}
                        <br />
                        <span className={styleSB.jobName}>{item.jobName}</span>
                      </Fragment>
                    )}
                    {item.isComplete && <span className="icon-ok"></span>}
                  </span>
                ))}
              </Fragment>
            ))}
          {props.list
            .filter((item) => item.type === "CHECK")
            .map((lItem) => (
              <div
                className={`${styleSB["nav-section"]} ${
                  props.active === -99 ? styleSB.active : ""
                }`}
                style={{ cursor: "pointer" }}
                onClick={()=>props.loadCFList("check")}
                key={"list-" + lItem.type}
              >
                {lItem.name}
              </div>
            ))}
          {props.list
            .filter((item) => item.type === "FILES")
            .map((lItem) => (
              <div
                className={`${styleSB["nav-section"]} ${
                  props.active === -100 ? styleSB.active : ""
                }`}
                style={{ cursor: "pointer" }}
                onClick={()=>props.loadCFList("docs")}
                key={"list-" + lItem.type}
              >
                {lItem.name}
              </div>
            ))}
        </Fragment>
      )}
    </Fragment>
  );
};

export default React.memo(SideBar1);

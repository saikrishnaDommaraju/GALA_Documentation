import { Fragment } from "react";
import styleSB from "../components/SideBar.module.css";

const DrawingNo = (props) => {
  return (
    <div
      className={`${styleSB["nav-link"]} ${styleSB["nav-link-drw"]}
    ${props.activeChain[1] === props.drawing.id ? styleSB.active : ""}`}
      onClick={() => props.loadDraw(props.drawing.id)}
      id={"draw-" + props.drawing.id}
    >
      <span>
        {props.drawing.suffix >= 0 &&
          ("0000" + props.drawing.suffix).slice(-3) +
            " - " +
            props.drawing.drawNo}
        {props.drawing.suffix < 0 && props.drawing.drawNo}
        {props.drawing.isComplete ? <span className="icon-ok"></span> : ""}
      </span>
      {props.drawing.drawTitle && (
        <Fragment>
          <br />
          <span className={`${styleSB.jobName} ${styleSB.singleLine}`}>
            {props.drawing.drawTitle}
          </span>
        </Fragment>
      )}
    </div>
  );
};

export default DrawingNo;

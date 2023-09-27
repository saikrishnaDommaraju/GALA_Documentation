import { Fragment } from "react";
import ReactDOM from "react-dom";

import style from "./Modal.module.css";

const Backdrop = (props) => {
  return <div className={style.backdrop} />;
};

const ModalOverlay = (props) => {
  return (
    <div className={style.modal}>
      <div className={style.content}>{props.children}</div>
    </div>
  );
};

const portalElement = document.getElementById("overlays");

const Modal = (props) => {
  return (
    <Fragment>
      {ReactDOM.createPortal(<Backdrop />, portalElement)}
      {ReactDOM.createPortal(
        <ModalOverlay type={props.type}>
          <div className={style.modalTitle}>{props.title}</div>
          <button className={style.close} onClick={props.onClose}>
            ×
          </button>
          <div className="clear"><br /></div>
          {props.children}
        </ModalOverlay>,
        portalElement
      )}
    </Fragment>
  );
};

export default Modal;

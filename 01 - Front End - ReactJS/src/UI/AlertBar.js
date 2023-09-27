import style from "./AlertBar.module.css";

const AlertBar = (props) => {
  return (
    <div className={style.alertbar}>
      <div className={style.alertLeft}>{props.children}</div>
      <div className={style.alertRight} onClick={props.dismissAlert}>&#10006;</div>
    </div>
  );
};

export default AlertBar;

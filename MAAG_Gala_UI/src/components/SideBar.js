import styles from "./SideBar.module.css";

const SideBar = (props) => {
  let showChildren = true;
  let showIcon = "icon-close-menu";
  let floatDir = { float: "left" };
  if (props.sbType === "sidebar3") {
    floatDir = { float: "right", marginRight: "10px" };
  }

  if (props.sbState === "-closed") {
    showChildren = false;
    showIcon = "icon-open-menu";
  }

  if (props.sbType === "sidebar3") {
    floatDir = { float: "right", marginRight: "10px" };
    showIcon = "icon-open-menu";
    if (props.sbState === "-closed") {
      showIcon = "icon-close-menu";
    }
  }

  return (
    <nav
      className={`${styles[props.sbType]} ${
        styles[props.sbType + props.sbState]
      }`}
    >
      <div onClick={props.sideBarHandler}>
        <div
          style={floatDir}
          className={`${showIcon} ${styles["close-icon"]}`}
        ></div>
        {showChildren && (
          <div className={styles["sb-title"]}>{props.title}</div>
        )}
        <div style={{ clear: "both" }}></div>
      </div>
      {showChildren && props.children}
    </nav>
  );
};

export default SideBar;

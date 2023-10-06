import style from "./ScrollDiv.module.css";

const ScrollDiv = (props) => {
  return (
    <div
      className={style["scrolldiv"]}
      style={{ height: "calc(100vh - (" + props.scrollheight + " + var(--bottom)))" }}
    >
      {props.children}
    </div>
  );
};

export default ScrollDiv;

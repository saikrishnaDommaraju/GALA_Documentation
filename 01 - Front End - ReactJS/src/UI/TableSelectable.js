import { Fragment } from "react";
import style from "./Table.module.css";

const Table = (props) => {
  return (
    <table className={style.rTable} style={{ textAlign: "center" }}>
      <thead>
        <tr style={{ textAlign: "center" }}>
          <th>Item</th>
          <th>Drawing No</th>
          <th>Qty</th>
          <th>WC</th>
          <th>View</th>
        </tr>
      </thead>
      <tbody>
        {props.children &&
          props.children.map((rows) => (
            <Fragment key={rows.id}>
              <tr
                key={`${rows.id}-r1`}
                onClick={() => props.selectHandler(rows.id)}
                className={`${!props.readOnly ? style["selectable"] : ""} ${
                  props.selList.includes(rows.id) ? style.active : ""
                } ${rows.childDesc !== "" ? style.noBorder: ""}`}
              >
                <td key={`${rows.id}-seq`}>
                  {rows.child === "Complete" ? (
                    <span className="icon-compproj"></span>
                  ) : (
                    rows.seqNo
                  )}
                </td>
                <td key={`${rows.id}-child`}>{rows.child}</td>
                <td key={`${rows.id}-qty`} style={{ whiteSpace: "nowrap" }}>
                  {rows.child !== "Complete" && (
                    <span>
                      {rows.qty}{" "}
                      <small>
                        <em>{rows.um}</em>
                      </small>
                    </span>
                  )}
                </td>
                <td key={`${rows.id}-wc`}>{rows.wc}</td>
                {rows.drwExists && (
                  <td
                    key={`${rows.id}-view`}
                    onClick={(e) => props.viewHandler(e, rows.child)}
                  >
                    <span className="icon-eye"></span>
                  </td>
                )}
                {!rows.drwExists && <td key={`${rows.id}-view`}></td>}
              </tr>
              {rows.childDesc !== "" && (
                <tr
                  key={`${rows.id}-r2`}
                  onClick={() => props.selectHandler(rows.id)}
                  className={`${!props.readOnly ? style["selectable"] : ""} ${
                    props.selList.includes(rows.id) ? style.active : ""
                  }`}
                >
                  <td
                    colSpan="5"
                    style={{ textAlign: "left" }}
                    key={`${rows.id}-childdesc`}
                  >
                    <span className={style.childDesc}>{rows.childDesc}</span>
                  </td>
                </tr>
              )}
            </Fragment>
          ))}
      </tbody>
    </table>
  );
};

export default Table;

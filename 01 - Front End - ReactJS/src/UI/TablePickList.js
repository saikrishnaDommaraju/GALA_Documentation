import { useRef, Fragment } from "react";

import axios from "../helpers/axios-instance";

import style from "./Table.module.css";
import styleInp from "./Input.module.css";

const Table = (props) => {
  const pLVal = useRef(0);

  const pickFocusHandler = (e) => (pLVal.current = e.target.value);

  const pickChangeHandler = (e, id) => {
    if (pLVal.current !== e.target.value) {
      axios.put("/drw/pickitemupdate", { Id: id, notes: e.target.value });
    }
  };

  return (
    <table className={style.rTable} style={{ textAlign: "center" }}>
      <thead>
        <tr style={{ textAlign: "center" }}>
          <th>Item</th>
          <th>Draw No</th>
          <th>Req.</th>
          <th>Pick</th>
          <th>Picked</th>
        </tr>
      </thead>
      <tbody>
        {props.children &&
          props.children.map((rows) => (
            <Fragment key={rows.id}>
              <tr key={`${rows.id}-r1`} className={style.noBorder}>
                <td key={`${rows.id}-seq`}>{rows.seqNo}</td>
                <td key={`${rows.id}-child`}>{rows.child}</td>
                <td key={`${rows.id}-rqty`}>
                  <span>
                    {rows.qty}{" "}
                    <small>
                      <em>{rows.um}</em>
                    </small>
                  </span>
                </td>
                <td key={`${rows.id}-pqty`}>
                  <span>
                    {rows.pQty}{" "}
                    <small>
                      <em>{rows.um}</em>
                    </small>
                  </span>
                </td>
                <td key={`${rows.id}-picked`}>
                  {props.readOnly && rows.picked}
                  {!props.readOnly && (
                    <input
                      type="number"
                      min="0"
                      defaultValue={rows.picked}
                      className={styleInp.inp}
                      style={{
                        width: "45px",
                        textAlign: "center",
                        padding: "3px",
                        height: "inherit",
                      }}
                      onBlur={(e) => pickChangeHandler(e, rows.id)}
                      onFocus={(e) => pickFocusHandler(e)}
                    />
                  )}
                </td>
              </tr>
              <tr key={`${rows.id}-r2`}>
                <td></td>
                <td
                  colspan="4"
                  style={{ textAlign: "left" }}
                  key={`${rows.id}-loc`}
                >
                  <span className={style.childDesc}><strong>Loc:</strong> {rows.pLoc}</span>
                </td>
              </tr>
            </Fragment>
          ))}
      </tbody>
    </table>
  );
};

export default Table;

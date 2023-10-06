import { useState, useEffect, useRef, useContext, Fragment } from "react";
import axios from "../helpers/axios-instance";

import styleInp from "../UI/Input.module.css";
import Table from "../UI/TableSelectable";
import TablePL from "../UI/TablePickList";
import Modal from "../UI/Modal";

import "../assets/fonts/animation.css";

import AuthContext from "../store/auth-context";

const SideBar3 = (props) => {
  const [bomSelList, setBomSelList] = useState([]);
  const [notesModal, setNotesModal] = useState(false);
  const [notesList, setNotesList] = useState([]);
  const noteTextRef = useRef();
  const authCtx = useContext(AuthContext);

  useEffect(() => {
    let bomSelFromDB = [];
    if (props.notesPaneChildren) {
      props.notesPaneChildren.forEach((r) => {
        if (r.isComplete === true) {
          bomSelFromDB.push(r.id);
        }
      });
    }
    setBomSelList(bomSelFromDB);
  }, [props.notesPaneChildren]);

  const bomTableSelHandler = (id) => {
    //Check if readonly
    if (authCtx.userData.readOnly) {
      return;
    }

    const nSel = !bomSelList.includes(id);
    axios
      .put("/drw/select", {
        BomId: id,
        DrawId: props.notesPaneParent.id,
        selected: nSel,
      })
      .then((response) => {
        setBomSelList((prevList) => {
          let newList = [...prevList];
          if (nSel) {
            newList.push(id);
          } else {
            for (var i = 0; i < newList.length; i++) {
              if (newList[i] === id) {
                newList.splice(i, 1);
              }
            }
          }
          return newList;
        });
        props.selUpdateHandler(response.data);
      })
      .catch((error) => console.log(error));
  };

  const notesEditHandler = () => {
    let item = "pdf";
    if (props.notesPaneParent.type === "Drawing") {
      item = "drw";
    } else if (props.notesPaneParent.type === "Checklist") {
      item = "check-" + props.notesPaneParent.projNo;
    }
    const item_id = props.notesPaneParent.id;
    axios
      .get("notes/" + item + "/" + item_id)
      .then((response) => {
        setNotesList(response.data);
        setNotesModal(true);
      })
      .catch((error) => console.log(error));
  };

  const notesDeleteHandler = (id) => {
    if (window.confirm("Are you sure you want to delete this note ?")) {
      setNotesList((prevNotes) => prevNotes.filter((note) => note.id !== id));
      props.noteCountUpdateHandler(notesList.length - 1);
      axios.delete("notes/" + id).catch((error) => {
        alert(error.response.data);
      });
    }
  };

  const notesCloseHandler = () => {
    setNotesModal(false);
  };

  const notesSubmitHandler = (e) => {
    e.preventDefault();
    let item = "pdf";
    if (props.notesPaneParent.type === "Drawing") {
      item = "drw";
    } else if (props.notesPaneParent.type === "Checklist") {
      item = "check-" + props.notesPaneParent.projNo;
    }
    const item_id = props.notesPaneParent.id;
    axios
      .post("notes", {
        item: item,
        item_id: item_id,
        note: noteTextRef.current.value,
      })
      .then((response) => {
        setNotesList((prevNotesList) => {
          const newNotesList = [...prevNotesList];
          newNotesList.push(response.data);
          return newNotesList;
        });
        noteTextRef.current.value = "";
        props.noteCountUpdateHandler(notesList.length + 1);
      });
  };

  return (
    <Fragment>
      <div style={{ margin: "10px" }}>
        {props.notesPaneParent && props.notesPaneParent.type === "Drawing" && (
          <Fragment>
            <span
              onClick={(e) =>
                props.viewHandler(e, props.notesPaneParent.drawNo)
              }
            >
              <strong>Drawing: </strong>
              {props.notesPaneParent.drawNo}
              {props.notesPaneParent.drwExists && (
                <span className="icon-eye"></span>
              )}
            </span>
            <br />
            <br />
          </Fragment>
        )}
        {props.notesPaneParent &&
          props.notesPaneParent.type === "Drawing" &&
          props.notesPaneParent.parent !== "" && (
            <Fragment>
              <span
                onClick={(e) => {
                  if (props.notesPaneParent.parentExists) {
                    props.viewHandler(e, props.notesPaneParent.parent);
                  }
                }}
              >
                <strong>Parent: </strong>
                {props.notesPaneParent.parent}
                {props.notesPaneParent.parentExists && (
                  <span className="icon-eye"></span>
                )}
              </span>
              {props.notesPaneParent.parentType === "CUT" && (
                <Fragment>
                  &nbsp;&nbsp;&nbsp;
                  <span
                    className="icon-send"
                    style={{ fontSize: "20px", cursor: "pointer" }}
                    onClick={() => props.gotoParentOf(props.notesPaneParent.id)}
                  ></span>
                </Fragment>
              )}
              <br />
              <br />
            </Fragment>
          )}
        {props.notesPaneParent &&
          props.notesPaneParent.parentType !== "PICK" &&
          props.notesPaneChildren && (
            <Fragment>
              <Table
                selectHandler={bomTableSelHandler}
                viewHandler={props.viewHandler}
                selList={bomSelList}
                readOnly={authCtx.userData.readOnly}
              >
                {props.notesPaneChildren}
              </Table>
              <br />
              <br />
            </Fragment>
          )}
        {props.notesPaneParent &&
          props.notesPaneParent.parentType === "PICK" &&
          props.notesPaneChildren && (
            <Fragment>
              <TablePL readOnly={authCtx.userData.readOnly}>
                {props.notesPaneChildren}
              </TablePL>
              <br />
              <br />
            </Fragment>
          )}
        {props.notesPaneParent &&
          props.notesPaneParent.type === "Checklist" && (
            <Fragment>
              <br />
              <strong>Print Checksheets</strong>
              <br />
              <br />
              <button
                className={styleInp.btn}
                onClick={() => props.printCheckSheetHandler(1)}
                style={{ width: "180px", textAlign: "left" }}
              >
                <span className="icon-print"> with User Names</span>
              </button>
              <br />
              <br />
              <button
                className={styleInp.btn}
                onClick={() => props.printCheckSheetHandler(2)}
                style={{ width: "180px", textAlign: "left" }}
              >
                <span className="icon-print"> with User Codes</span>
              </button>
              <br />
              <br />
              <button
                className={styleInp.btn}
                onClick={() => props.printCheckSheetHandler(0)}
                style={{ width: "180px", textAlign: "left" }}
              >
                <span className="icon-print"> without Identity</span>
              </button>
              <br />
              <br />
              <br />
            </Fragment>
          )}
        {props.notesPaneParent && (
          <button onClick={notesEditHandler} className={styleInp.btn}>
            Manage Notes
            {props.notesPaneParent.noteCount > 0 && (
              <div className={styleInp.notifBadge}>
                {props.notesPaneParent.noteCount}
              </div>
            )}
          </button>
        )}
        {props.notesPaneParent &&
          props.notesPaneParent.parentType !== "PICK" &&
          typeof authCtx.userData.Admin !== "undefined" &&
          typeof props.notesPaneParent.toUpdate !== "undefined" && (
            <div style={{ borderTop: "1px solid #000", marginTop: "20px" }}>
              <br />
              <strong>Admin Functions:</strong>
              <br />
              <br />
              {props.notesPaneParent.toUpdate === 0 && (
                <Fragment>
                  <span
                    className="icon-waitproj"
                    style={{ cursor: "pointer" }}
                    onClick={props.markUpdateHandler}
                  >
                    Update
                  </span>
                  <br />
                  <br />
                  <span>
                    <strong>Last Update:</strong>{" "}
                    {new Date(
                      props.notesPaneParent.updateDateTime
                    ).toLocaleString()}
                  </span>
                </Fragment>
              )}
              {props.notesPaneParent.toUpdate === 1 && (
                <span
                  className="icon-ok"
                  style={{ cursor: "pointer" }}
                  onClick={props.markUpdateHandler}
                >
                  Marked for Update
                </span>
              )}
              {props.notesPaneParent.toUpdate === 2 && (
                <Fragment>
                  <span className="icon-wait animate-spin"></span> Updating...
                </Fragment>
              )}
              {props.notesPaneParent.toUpdate === 3 && (
                <Fragment>
                  <span className="icon-noproj">Drawing Not Found.</span>
                  <br />
                  <br />
                  <span
                    className="icon-waitproj"
                    style={{ cursor: "pointer" }}
                    onClick={props.markUpdateHandler}
                  >
                    Try Again
                  </span>
                </Fragment>
              )}
            </div>
          )}
      </div>
      {notesModal && (
        <Modal onClose={notesCloseHandler} title="Manage Notes">
          <form onSubmit={notesSubmitHandler}>
            <div>
              {notesList.map((note) => {
                return (
                  <div key={"note_" + note.id}>
                    {authCtx.userData.unique_name === note.user && (
                      <span
                        className="icon-trash"
                        style={{ color: "red", cursor: "pointer" }}
                        onClick={() => notesDeleteHandler(note.id)}
                      ></span>
                    )}
                    {authCtx.userData.unique_name !== note.user && (
                      <span
                        style={{ display: "inline-block", width: "20px" }}
                      ></span>
                    )}
                    <span>
                      <strong>{note.user}</strong>{" "}
                      <small>
                        [
                        <em>
                          {new Date(note.createdDateTime).toLocaleString()}
                        </em>
                        ]
                      </small>
                      :{" "}
                    </span>
                    <span>{note.note}</span>
                    <hr />
                  </div>
                );
              })}
            </div>
            <br />
            {!authCtx.userData.readOnly && (
              <Fragment>
                <textarea
                  className={styleInp.inp}
                  style={{ width: "100%", height: "40px" }}
                  ref={noteTextRef}
                ></textarea>
                <button
                  type="submit"
                  className={styleInp.btn}
                  style={{ float: "right" }}
                >
                  + Add Note
                </button>
              </Fragment>
            )}
          </form>
        </Modal>
      )}
    </Fragment>
  );
};

export default SideBar3;

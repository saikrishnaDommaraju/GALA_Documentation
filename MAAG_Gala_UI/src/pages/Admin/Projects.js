import { useEffect, useState, useRef, Fragment } from "react";
import TextareaAutosize from "react-textarea-autosize";
import axios from "../../helpers/axios-instance";

import stylesInp from "../../UI/Input.module.css";
import ScrollDiv from "../../UI/ScrollDiv";
import Container from "../../UI/Container";
import Table from "../../UI/Table";
import Modal from "../../UI/Modal";

import stylesList from "./Roles.module.css";

const tHead = [
  "Project No",
  "Project Name",
  "State",
  "Submitted",
  "Updated On",
  "Actions",
];

const Projects = () => {
  const projectRef = useRef();
  const [projects, setProjects] = useState([]);
  const [qActive, setQActive] = useState(true);
  const [clActive, setClActive] = useState(-1);
  const [piActive, setPiActive] = useState(-1);
  const [checkList, setCheckList] = useState([]);
  const [projInfo, setProjInfo] = useState({
    Name: "",
    Email: "",
    MechEng: "",
    ElecEng: "",
  });
  const cbRef = useRef([]);
  const projNoteRef = useRef();
  const projEmailRef = useRef();
  const projElecEngRef = useRef();
  const projMechEngRef = useRef();

  //Run the first time and only once to hydrate
  useEffect(() => {
    axios.get("/projects/adminlist/all").then((resp) => setProjects(resp.data));
    axios.get("/projects/queue_active").then((resp) => setQActive(resp.data));
  }, []);

  //Set a timer to run on a interval to fetch the data
  useEffect(() => {
    const intervalId = setInterval(() => {
      axios
        .get("/projects/adminlist/all")
        .then((resp) => setProjects(resp.data));
      axios.get("/projects/queue_active").then((resp) => setQActive(resp.data));
    }, 30000);

    return () => clearInterval(intervalId); //Clear the interval for cleanup
  });

  const projAddHandler = () => {
    let projNo = projectRef.current.value;

    //Validate the Project
    if (projNo === "") {
      alert("Please Enter the project number");
      return false;
    }

    projNo = projNo.replace(new RegExp("[\\r\\n]", "gm"), ",");

    //Add in the new Project
    const newProj = {
      projectNo: projNo,
      state: "new",
    };

    axios
      .post("/projects", newProj)
      .then((response) => {
        setProjects((prevProj) => {
          return prevProj.concat(response.data);
        });
        projectRef.current.value = "";
      })
      .catch((error) => {
        alert("Could not add Project : " + error.response.data);
      });
  };

  const projDeleteHandler = (projId) => {
    if (window.confirm("Are you sure you want to delete this project ?")) {
      setProjects((prevProjects) =>
        prevProjects.filter((proj) => proj.id !== projId)
      );

      axios.delete("/projects/" + projId).catch((error) => {
        alert(error.response.data);
      });
    }
  };

  const stateChangeHandler = (projId, projNo, state) => {
    if (
      window.confirm(
        "Are you sure you want to move this project to " + state + "?"
      )
    ) {
      const qs = require("qs");
      axios
        .post(
          "/projects/changestate",
          qs.stringify({ ProjectNo: projNo, state: state })
        )
        .then(() => {
          setProjects((pProj) => {
            var newProj = [...pProj];
            const objInd = newProj.findIndex((o) => o.id === projId);
            if (objInd > -1) {
              newProj[objInd].state = state;
            }
            return newProj;
          });
        })
        .catch((error) => alert(error.response.data));
    }
  };

  const projArchiveHandler = (projId, projNo) => {
    const mTxt =
      "Archiving the project will move the project to archive, keep the data BUT DELETE all the reports and drawing files from the server, which can be pulled back on demand.\n\nAre you sure you want to archive?";
    if (window.confirm(mTxt)) {
      setProjects((pProj) => {
        var newProj = [...pProj];
        const objInd = newProj.findIndex((o) => o.id === projId);
        if (objInd > -1) {
          newProj[objInd].state = "archiving";
        }
        return newProj;
      });

      axios
        .post("/projects/archive", { ProjectNo: projNo })
        .then(() => {
          setProjects((pProj) => {
            var newProj = [...pProj];
            const objInd = newProj.findIndex((o) => o.id === projId);
            if (objInd > -1) {
              newProj.splice(objInd, 1);
            }
            return newProj;
          });
        })
        .catch((error) => alert(error.response.data));
    }
  };

  const selectCLHandler = (id) => {
    axios.get("/checklist/" + id).then((response) => {
      setCheckList(response.data);
      setClActive(id);
    });
  };

  const selectPIHandler = (id) => {
    const aR = projects.filter((p) => p.id === id)[0];
    setProjInfo({
      Notes: aR.notes,
      Email: aR.notify,
      MechEng: aR.mechEng,
      ElecEng: aR.elecEng,
    });
    setPiActive(id);
  };

  const infoModalHandler = () => {
    setClActive(-1);
    setPiActive(-1);
  };

  const clSubmitHandler = (e) => {
    e.preventDefault();
    let strSel = "";
    for (let i = 0; i < cbRef.current.length; i++) {
      if (cbRef.current[i].checked) {
        if (strSel === "") {
          strSel = cbRef.current[i].value;
        } else {
          strSel += "," + cbRef.current[i].value;
        }
      }
    }

    axios
      .put("/projects/checklist", {
        Id: clActive,
        CheckList: strSel,
      })
      .then(() => {
        setProjects((pProj) => {
          var newProj = [...pProj];
          const objInd = newProj.findIndex((o) => o.id === clActive);
          if (objInd > -1) {
            newProj[objInd].checklist = strSel;
          }
          return newProj;
        });
        setClActive(-1);
      })
      .catch((error) => alert(error.response.message));
  };

  const infoSubmitHandler = (e) => {
    e.preventDefault();

    axios
      .put("/projects/projinfo", {
        Id: piActive,
        Notes: projNoteRef.current.value,
        Email: projEmailRef.current.value,
        MechEng: projMechEngRef.current.value,
        ElecEng: projElecEngRef.current.value,
      })
      .then(() => {
        setProjects((pProj) => {
          var newProj = [...pProj];
          const objInd = newProj.findIndex((o) => o.id === piActive);
          if (objInd > -1) {
            newProj[objInd].notes = projNoteRef.current.value;
            newProj[objInd].notify = projEmailRef.current.value;
            newProj[objInd].mechEng = projMechEngRef.current.value;
            newProj[objInd].elecEng = projElecEngRef.current.value;
          }
          return newProj;
        });
        setPiActive(-1);
      })
      .catch((error) => {
        alert(error.response.message);
      });
  };

  //Side Effect of opening the dialog box
  useEffect(() => {
    if (clActive > 0) {
      var aR = projects.filter((p) => p.id === clActive)[0];
      if (aR.checklist !== "" && aR.checklist !== null) {
        const toCheck = aR.checklist.split(",");
        for (let i = 0; i < cbRef.current.length; i++) {
          if (toCheck.includes(cbRef.current[i].value)) {
            cbRef.current[i].checked = true;
          } else {
            cbRef.current[i].checked = false;
          }
        }
      } else {
        for (let i = 0; i < cbRef.current.length; i++) {
          cbRef.current[i].checked = false;
        }
      }
    }
  }, [projects, clActive]);

  const tFoot = [
    <TextareaAutosize
      minRows={1}
      maxRows={6}
      ref={projectRef}
      className={stylesInp.inp}
      style={{ width: "200px" }}
      placeholder="Project No"
    />,
    <span></span>,
    <span className="icon-newproj" style={{ color: "blue" }}>
      New
    </span>,
    <span></span>,
    <span></span>,
    <button onClick={projAddHandler} className={stylesInp.btn}>
      <span className="icon-ok"></span>
    </button>,
  ];

  let tableContent = [["No Projects found", "", "", "", "", ""]];
  if (projects.length > 0) {
    tableContent = projects.map((rows) => {
      let pState = (
        <span
          className="icon-newproj"
          style={{ color: "blue", whiteSpace: "nowrap" }}
        >
          New
        </span>
      );
      let pActions = "";
      if (rows.state === "new") {
        pActions = (
          <Fragment>
            <span
              onClick={() => projDeleteHandler(rows.id)}
              className="icon-trash"
              title="Delete Project"
              style={{ fontSize: "18px", color: "red", cursor: "pointer" }}
            ></span>{" "}
            <span
              className="icon-checklist link"
              title="Select Checksheets"
              style={{ fontSize: "22px" }}
              onClick={() => selectCLHandler(rows.id)}
            ></span>
            <span
              className="icon-projinfo"
              title="Update Project Info"
              style={{ fontSize: "20px", color: "green", cursor: "pointer" }}
              onClick={() => selectPIHandler(rows.id)}
            ></span>
          </Fragment>
        );
      } else if (rows.state === "update") {
        pState = (
          <span
            className="icon-waitproj"
            style={{ color: "orange", whiteSpace: "nowrap" }}
          >
            Update
          </span>
        );
        pActions = (
          <Fragment>
            <span
              className="icon-noproj"
              style={{ color: "red", cursor: "pointer", fontSize: "18px" }}
              title="Cancel Update"
              onClick={() =>
                stateChangeHandler(rows.id, rows.projectNo, "ready")
              }
            ></span>{" "}
            <span
              className="icon-checklist link"
              title="Select Checksheets"
              style={{ fontSize: "22px" }}
              onClick={() => selectCLHandler(rows.id)}
            ></span>
            <span
              className="icon-projinfo"
              title="Update Project Info"
              style={{ fontSize: "20px", color: "green", cursor: "pointer" }}
              onClick={() => selectPIHandler(rows.id)}
            ></span>
          </Fragment>
        );
      } else if (rows.state === "inprogress") {
        pState = (
          <span style={{ color: "orange", whiteSpace: "nowrap" }}>
            <span className="icon-wait animate-spin"></span> In-Progress
          </span>
        );
        pActions = (
          <Fragment>
            <span
              className="icon-checklist link"
              title="Select Checksheets"
              style={{ fontSize: "22px" }}
              onClick={() => selectCLHandler(rows.id)}
            ></span>{" "}
            <span
              className="icon-projinfo"
              title="Update Project Info"
              style={{ fontSize: "20px", color: "green", cursor: "pointer" }}
              onClick={() => selectPIHandler(rows.id)}
            ></span>
          </Fragment>
        );
      } else if (rows.state === "ready") {
        pState = (
          <span
            className="icon-compproj"
            style={{ color: "green", whiteSpace: "nowrap" }}
          >
            Ready
          </span>
        );
        pActions = (
          <Fragment>
            <span
              className="icon-noproj"
              style={{ color: "blue", cursor: "pointer", fontSize: "18px" }}
              title="Close Project"
              onClick={() =>
                stateChangeHandler(rows.id, rows.projectNo, "closed")
              }
            ></span>{" "}
            <span
              className="icon-waitproj"
              style={{ color: "orange", cursor: "pointer", fontSize: "18px" }}
              title="Mark for Update"
              onClick={() =>
                stateChangeHandler(rows.id, rows.projectNo, "update")
              }
            ></span>{" "}
            <span
              className="icon-checklist link"
              title="Select Checksheets"
              style={{ fontSize: "22px" }}
              onClick={() => selectCLHandler(rows.id)}
            ></span>{" "}
            <span
              className="icon-projinfo"
              title="Update Project Info"
              style={{ fontSize: "20px", color: "green", cursor: "pointer" }}
              onClick={() => selectPIHandler(rows.id)}
            ></span>
          </Fragment>
        );
      } else if (rows.state === "error") {
        pState = (
          <span
            className="icon-noproj"
            style={{ color: "red", whiteSpace: "nowrap" }}
          >
            {rows.projectName === "" ? "Project Not Found" : "Error"}
          </span>
        );
        pActions = (
          <Fragment>
            <span
              onClick={() => projDeleteHandler(rows.id)}
              className="icon-trash link"
              title="Delete Project"
              style={{ fontSize: "18px" }}
            ></span>
            <span
              className="icon-waitproj"
              style={{ color: "orange", cursor: "pointer", fontSize: "18px" }}
              title="Restart"
              onClick={() =>
                stateChangeHandler(rows.id, rows.projectNo, "update")
              }
            ></span>
          </Fragment>
        );
      } else if (rows.state === "closed") {
        pState = (
          <span
            className="icon-noproj"
            style={{ color: "blue", whiteSpace: "nowrap" }}
          >
            Closed
          </span>
        );
        pActions = (
          <Fragment>
            <span
              className="icon-compproj"
              style={{ color: "green", cursor: "pointer", fontSize: "18px" }}
              title="Move to Ready"
              onClick={() =>
                stateChangeHandler(rows.id, rows.projectNo, "ready")
              }
            ></span>
            <span
              className="icon-box"
              style={{ color: "red", cursor: "pointer", fontSize: "18px" }}
              title="Archive Project"
              onClick={() => projArchiveHandler(rows.id, rows.projectNo)}
            ></span>
          </Fragment>
        );
      } else if (rows.state === "archiving") {
        pState = (
          <span style={{ color: "orange", whiteSpace: "nowrap" }}>
            <span className="icon-wait animate-spin"></span> Archiving
          </span>
        );
        pActions = "";
      }

      return [
        rows.projectNo,
        rows.projectName,
        pState,
        <Fragment>
          {rows.submittedBy}
          <br />
          <small style={{ color: "gray" }}>
            {new Date(rows.submittedDateTime).toLocaleString()}
          </small>
        </Fragment>,
        new Date(rows.updateDateTime).toLocaleString(),
        <span style={{ whiteSpace: "nowrap" }}>{pActions}</span>,
      ];
    });
  }

  return (
    <Fragment>
      <ScrollDiv scrollheight="90px">
        <Container>
          <h3>Projects</h3>
          {!qActive && (
            <span style={{ color: "red", fontWeight: "bold" }}>
              ! ! PROCESS QUEUE IS NOT RUNNING. CONTACT ADMIN ! !<br />
              <br />
            </span>
          )}
          <Table header={tHead} footer={tFoot}>
            {tableContent}
          </Table>
        </Container>
      </ScrollDiv>
      {clActive > 0 && (
        <Modal onClose={infoModalHandler} title="Select Check Sheet">
          <ScrollDiv scrollheight="300px">
            <form onSubmit={clSubmitHandler}>
              <ul className={stylesList.wcList}>
                {checkList.map((clItem, i) => (
                  <li key={`h_${clItem.id}`}>
                    <input
                      type="checkbox"
                      name="cl[]"
                      value={clItem.id}
                      ref={(el) => (cbRef.current[i] = el)}
                    />{" "}
                    {clItem.name}{" "}
                    <em style={{ color: "#757575" }}>v{clItem.ver}</em>
                  </li>
                ))}
              </ul>
              <br />
              <br />
              <button className={stylesInp.btn} type="submit">
                Select Checklist
              </button>
            </form>
          </ScrollDiv>
        </Modal>
      )}
      {piActive > 0 && (
        <Modal onClose={infoModalHandler} title="Project Information">
          <ScrollDiv scrollheight="300px">
            <form onSubmit={infoSubmitHandler}>
              <strong style={{ fontSize: "15px" }}>Project Note</strong>
              <br />
              <input
                className={stylesInp.inp}
                style={{ width: "90%", marginTop: "7px" }}
                ref={projNoteRef}
                defaultValue={projInfo.Notes}
              />
              <br />
              <br />
              <strong style={{ fontSize: "15px" }}>
                Notify Project Processing
              </strong>
              <br />
              <small>
                Enter email address to notify of project process completion.
                Comma separated entries.
              </small>
              <br />
              <input
                type="text"
                className={stylesInp.inp}
                style={{ width: "90%", marginTop: "7px" }}
                ref={projEmailRef}
                defaultValue={projInfo.Email}
              ></input>
              <br />
              <br />
              <strong style={{ fontSize: "15px" }}>
                Mechanical Designer Email
              </strong>
              <br />
              <input
                type="text"
                className={stylesInp.inp}
                style={{ width: "90%", marginTop: "7px" }}
                ref={projMechEngRef}
                defaultValue={projInfo.MechEng}
              ></input>
              <br />
              <br />
              <strong style={{ fontSize: "15px" }}>
                Electrical Designer Email
              </strong>
              <br />
              <input
                type="text"
                className={stylesInp.inp}
                style={{ width: "90%", marginTop: "7px" }}
                ref={projElecEngRef}
                defaultValue={projInfo.ElecEng}
              ></input>
              <br />
              <br />
              <button className={stylesInp.btn} type="submit">
                Update Project Info
              </button>
            </form>
          </ScrollDiv>
        </Modal>
      )}
    </Fragment>
  );
};

export default Projects;

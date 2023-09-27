import { useState, useEffect, Fragment } from "react";

import axios from "../../helpers/axios-instance";

import ScrollDiv from "../../UI/ScrollDiv";
import Container from "../../UI/Container";
import Table from "../../UI/Table";

const tHead = ["Project No", "Project Name", "Actions"];

const ProjectArchive = () => {
  const [projects, setProjects] = useState([]);

  //Run the first time and only once to hydrate
  useEffect(() => {
    axios
      .get("/projects/adminlist/archived")
      .then((resp) => setProjects(resp.data));
  }, []);

  const moveProjHandler = (projId, projNo, state) => {
    let msg =
      "Are you sure you want to restore this project from the archive?\n\nRestoring will move the project to update and pull the reports and drawings again.";
    if (state === "deleted") {
      msg =
        "Are you sure you want to delete the project. This action cannot be reverted.";
    }

    if (window.confirm(msg)) {
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
            newProj.splice(objInd, 1);
            return newProj;
          });
        })
        .catch((error) => alert(error.response.data));
    }
  };

  let tableContent = [["No Projects found", "", ""]];
  if (projects.length > 0) {
    tableContent = projects.map((rows) => {
      return [
        rows.projectNo,
        rows.projectName,
        <Fragment>
          <span
            className="icon-waitproj"
            style={{ color: "orange", cursor: "pointer", fontSize: "18px" }}
            title="Restore Project from Archive"
            onClick={() => moveProjHandler(rows.id, rows.projectNo, "update")}
          ></span>{" "}
          <span
            className="icon-trash"
            style={{ color: "red", cursor: "pointer", fontSize: "18px" }}
            title="Delete Project Permanently"
            onClick={() => moveProjHandler(rows.id, rows.projectNo, "deleted")}
          ></span>
        </Fragment>,
      ];
    });
  }

  return (
    <Fragment>
      <ScrollDiv scrollheight="90px">
        <Container>
          <h3>Project Archive</h3>
          <Table header={tHead}>{tableContent}</Table>
        </Container>
      </ScrollDiv>
    </Fragment>
  );
};

export default ProjectArchive;

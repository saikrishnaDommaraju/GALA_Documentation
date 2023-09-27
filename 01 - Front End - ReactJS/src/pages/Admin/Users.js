import { Fragment, useEffect, useState, useRef } from "react";
import axios from "../../helpers/axios-instance";

import EditUserForm from "../../components/EditUserForm";
import Container from "../../UI/Container";
import Table from "../../UI/Table";
import Modal from "../../UI/Modal";
import ScrollDiv from "../../UI/ScrollDiv";
import styles from "../../UI/Input.module.css";

const tHead = [
  "Username",
  "User code",
  "Name",
  "Email (used to log in)",
  "Roles",
  "Actions",
];

const Users = () => {
  const usernameRef = useRef();
  const nameRef = useRef();
  const codeRef = useRef();
  const roleRef = useRef();
  const emailRef = useRef();

  const [users, setUsers] = useState([]);
  const [roles, setRoles] = useState([]);
  const [editUserModal, setEditUserModal] = useState(false);
  const [userData, setUserData] = useState({
    username: "",
    usercode: "",
    name: "",
    email: "",
    role: "",
  });

  useEffect(() => {
    axios.get("/users").then((response) => {
      setUsers(response.data);
    });

    axios.get("/role").then((response) => setRoles(response.data));
  }, []);

  const userAddHandler = () => {
    //Validate the Entry Data
    if (usernameRef.current.value === "" || nameRef.current.value === "") {
      alert("Please enter both the username and name.");
      return false;
    }

    const newUser = {
      username: usernameRef.current.value,
      usercode: codeRef.current.value,
      name: nameRef.current.value,
      email: emailRef.current.value,
      role: roleRef.current.value,
    };
    axios
      .post("/users", newUser)
      .then(() => {
        setUsers((prevUsers) => prevUsers.concat(newUser));
        usernameRef.current.value = "";
        codeRef.current.value = "";
        nameRef.current.value = "";
        emailRef.current.value = "";
      })
      .catch((error) => {
        if (error.response) {
          if (error.response.data.errors) {
            alert(JSON.stringify(error.response.data.errors));
          } else {
            alert("Could not add user : " + error.response.data);
          }
        } else {
          alert("Could not add user : " + error.message);
        }
      });
  };

  const userEditHandler = (username) => {
    const userDataTmp = users.filter((users) => users.username === username);
    setUserData(userDataTmp[0]);
    setEditUserModal(true);
  };

  const userEditCloseHandler = () => {
    setEditUserModal(false);
  };

  const submitFormHandler = (username, usercode, name, email, role) => {
    //Validate the user
    if (username === "" || name === "" || usercode === "") {
      alert("Please enter the username and user code and name");
      return false;
    }

    //Update the Users
    setUsers((prevUsers) => {
      const userIndex = users.findIndex(
        (prevUsers) => prevUsers.username === username
      );
      prevUsers[userIndex] = { username, usercode, name, email, role };
      return prevUsers;
    });

    //Close the Modal
    setEditUserModal(false);

    //Add the data into the datbase
    axios.put("/users", { username, usercode, name, email, role });
  };

  const userDeleteHandler = (username) => {
    if (window.confirm("Are you sure you want to delete " + username + "?")) {
      setUsers((prevUsers) =>
        prevUsers.filter((users) => users.username !== username)
      );

      axios.delete("/users/" + username);
    }
  };

  let tableContent = "";

  if (users.length > 0) {
    tableContent = users.map((rows) => {
      return [
        rows.username,
        rows.usercode,
        rows.name,
        rows.email,
        rows.role,
        <Fragment>
          <span
            onClick={() => userEditHandler(rows.username)}
            className="icon-edit link"
            style={{ fontSize: "18px" }}
          ></span>{" "}
          <span
            onClick={() => userDeleteHandler(rows.username)}
            className="icon-trash link"
            style={{ fontSize: "18px" }}
          ></span>
        </Fragment>,
      ];
    });
  } else {
    tableContent = [["No Users found", "", "", "", "", ""]];
  }

  const tFoot = [
    <input ref={usernameRef} className={styles.inp} placeholder="Username" />,
    <input ref={codeRef} className={styles.inp} placeholder="User Code" />,
    <input ref={nameRef} className={styles.inp} placeholder="Name" />,
    <input ref={emailRef} className={styles.inp} placeholder="Email" />,
    <select ref={roleRef} className={styles.inp}>
      <option value="Admin">Admin</option>
      {roles.length > 0 &&
        roles.map((r) => (
          <option value={r.name} key={"opt-" + r.id}>
            {r.name}
          </option>
        ))}
    </select>,
    <button onClick={userAddHandler} className={styles.btn}>
      <span className="icon-ok"></span>
    </button>,
  ];

  return (
    <Fragment>
      <ScrollDiv scrollheight="90px">
        <Container>
          <h3>Users</h3>
          <Table header={tHead} footer={tFoot}>
            {tableContent}
          </Table>
        </Container>
      </ScrollDiv>
      {editUserModal && (
        <Modal onClose={userEditCloseHandler}>
          <EditUserForm
            userData={userData}
            roles={roles}
            onSubmit={submitFormHandler}
            onClose={userEditCloseHandler}
          />
        </Modal>
      )}
    </Fragment>
  );
};

export default Users;

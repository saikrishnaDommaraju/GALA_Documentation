import { useRef } from "react";
import style from "../UI/Input.module.css";

const EditUserForm = (props) => {
  const codeRef = useRef();
  const nameRef = useRef();
  const emailRef = useRef();
  const roleRef = useRef();

  const formSubmitHandler = (event) => {
    event.preventDefault();
    props.onSubmit(
      props.userData.username,
      codeRef.current.value,
      nameRef.current.value,
      emailRef.current.value,
      roleRef.current.value
    );
  };

  return (
    <form onSubmit={formSubmitHandler}>
      <div className={style["form-control"]}>
        <label>Username : </label>
        <span>{props.userData.username}</span>
      </div>
      <div className={style["form-control"]}>
        <label htmlFor="code">User Code : </label>
        <input
          className={`${style.inp} ${style.inline}`}
          defaultValue={props.userData.usercode}
          id="usercode"
          ref={codeRef}
        />
      </div>
      <div className={style["form-control"]}>
        <label htmlFor="name">Name : </label>
        <input
          className={`${style.inp} ${style.inline}`}
          defaultValue={props.userData.name}
          id="name"
          ref={nameRef}
        />
      </div>
      <div className={style["form-control"]}>
        <label htmlFor="email">Email : </label>
        <input
          className={`${style.inp} ${style.inline}`}
          defaultValue={props.userData.email}
          id="email"
          ref={emailRef}
        />
      </div>
      <div className={style["form-control"]}>
        <label htmlFor="Role">Role : </label>
        <select
          className={`${style.inp} ${style.inline}`}
          id="role"
          ref={roleRef}
          defaultValue={props.userData.role[0]}
        >
          <option value="Admin">Admin</option>
          {props.roles.length > 0 &&
            props.roles.map((r) => (
              <option value={r.name} key={"opt-" + r.id}>
                {r.name}
              </option>
            ))}
        </select>
      </div>
      <button type="submit" className={`${style.btn} right`}>
        Edit User
      </button>
    </form>
  );
};

export default EditUserForm;

import axios from "axios";

// --> test server details
export const BASE_URL = "http://localhost:5000/api";
// export const BASE_URL = "https://localhost:44382/api";
// export const BASE_URL = process.env.PUBLIC_URL + "/api";

const storedToken = localStorage.getItem("token");
let auth = {};  
if (storedToken) {
  auth = { Authorization: `Bearer ${storedToken}` };
}

const instance = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  headers: auth,
});

export default instance;
